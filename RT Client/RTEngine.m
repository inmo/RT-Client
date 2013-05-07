//
//  RequestTrackerAPI.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSHTTPCookieStorage+RequestTracker.h"

#import "RTEngine.h"
#import "RTKeychainEntry.h"
#import "RTCLoginWindowController.h"
#import "RTRequestOperation.h"
#import "RTModels.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://rhit-rt.axiixc.com/"]

#define SAFE_DELEGATE_CALL(CODE) if (self.delegate) { dispatch_async(dispatch_get_main_queue(), ^{ CODE; }); }

typedef NS_OPTIONS(NSUInteger, RTEngineLoginFailureReason) {
    RTEngineLoginFailureReasonNetwork,
    RTEngineLoginFailureReasonCredentials
};

@interface RTEngine (/* Private */)

@property (nonatomic, assign, readwrite, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong, readwrite) RTKeychainEntry * keychainEntry;

@end

@implementation RTEngine

#pragma mark Singelton Instance

+ (RTEngine *)sharedEngine
{
    static RTEngine * __staticEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __staticEngine = [[self alloc] init];
    });
    
    return __staticEngine;
}

#pragma mark - NSObject Overrides

- (id)init;
{
    NSString * serverPrefValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"RTServerURL"];
    NSURL * serverURL = [NSURL URLWithString:serverPrefValue];
    
    if ((self = [super initWithBaseURL:ENSURE_NOT_NIL_OR(serverURL, RT_SERVER_URL)]))
    {
        [self registerHTTPOperationClass:[RTRequestOperation class]];
        
        self.keychainEntry = [RTKeychainEntry entryForService:@"Request Tracker" account:@"default"];
        [self _forcedLogout];
    }
    
    return self;
}

#pragma mark - AFHTTPClient Overrides

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest * request = [super requestWithMethod:method path:path parameters:parameters];
    [request setTimeoutInterval:120];
    
    return request;
}

- (void)postPath:(NSString *)path parameters:(NSDictionary *)parameters
         success:(void (^)(AFHTTPRequestOperation *, id))success
         failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableDictionary * newParams = [parameters mutableCopy];
    [newParams addEntriesFromDictionary:self.keychainEntry.contents];
    
    [super postPath:path parameters:newParams success:success failure:failure];
    
}

#pragma mark - API Endpoints

- (void)refreshSelfServiceQueue;
{
    [self fetchSearchResultsForQuery:@"(Owner = '__CurrentUser__') AND (Status = 'new' OR Status = 'open')"
             getAllTicketInformation:YES];
}

- (void)fetchSearchResultsForQuery:(NSString *)query getAllTicketInformation:(BOOL)allInfo
{
    [self getPath:@"REST/1.0/search/ticket" parameters:@{
     @"query": query, @"format": @"l",
     } success:^(AFHTTPRequestOperation * operation, id responseObject) {
         NSArray * rawTickets = [operation responseArray];
         NSMutableArray * createdTickets = [NSMutableArray arrayWithCapacity:rawTickets.count];
         NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_context];
         
         [rawTickets enumerateObjectsUsingBlock:^(NSDictionary * response, NSUInteger idx, BOOL *stop) {
             RTTicket * ticket = [RTTicket createTicketFromAPIResponse:response inContext:scratchContext];
             [createdTickets addObject:ticket];
         }];
         
         [scratchContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
             if (!allInfo)
                 return;
             
             for (RTTicket * ticket in createdTickets)
                 [self fetchAttachmentsForTicket:ticket];
         }];
     } failure:nil];
}

- (void)fetchAttachmentsForTicket:(RTTicket *)ticket
{
    NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_context];
    ticket = (RTTicket *)[scratchContext objectWithID:ticket.objectID];
    
    if (!ticket.ticketID)
        return;
    
    [self
     getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments", ticket.ticketID]
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSArray * stubs = operation.responseDictionary[@"Attachments"];
         NSMutableArray * attachmentFetchOperations = [NSMutableArray arrayWithCapacity:stubs.count];
         
         [stubs enumerateObjectsUsingBlock:^(NSDictionary * stub, NSUInteger idx, BOOL *stop) {
             attachmentFetchOperations[idx] = [self _operationForAttachmentWithID:stub[@"id"] associatedWithTicket:ticket];
         }];
         
         [self enqueueBatchOfHTTPRequestOperations:attachmentFetchOperations progressBlock:nil completionBlock:^(NSArray * operations) {
             [scratchContext MR_saveToPersistentStoreAndWait];
         }];
     } failure:nil];
}

- (AFHTTPRequestOperation *)_operationForAttachmentWithID:(id)attachmentID associatedWithTicket:(RTTicket *)ticket
{
    NSString * path = [NSString stringWithFormat:@"REST/1.0/%@/attachments/%@", ticket.ticketID, attachmentID];
    NSURLRequest * request = [self requestWithMethod:@"GET" path:path parameters:nil];
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        RTAttachment * attachment = [RTAttachment createAttachmentFromAPIResponse:operation.responseDictionary
                                                                        inContext:ticket.managedObjectContext];
        attachment.ticket = ticket;
    };
    
    return [self HTTPRequestOperationWithRequest:request success:successBlock failure:nil];
}

#pragma mark - Ticket Replies

NSString * const RTTicketReplyMessageCCKey = @"Cc";
NSString * const RTTicketReplyMessageBCCKey = @"Bcc";
NSString * const RTTicketReplyMessageSubjectKey = @"Subject";
NSString * const RTTicketReplyMessageBodyKey = @"Text";

static NSString * const RTTicketReplyMessageTicketIDKey = @"id";
static NSString * const RTTicketReplyMessageActionKey = @"Action";
static NSString * const RTTicketReplyMessageActionCorrespondValue = @"correspond";
static NSString * const RTTicektReplyMessageActionCommentValue = @"comment";
static NSString * const RTTicketReplyMessageAttachmentsKey = @"Attachment";

- (NSDictionary *)_sanitizeInputParameters:(NSDictionary *)inParameters forTicket:(RTTicket *)ticket addingAttachments:(NSArray *)attachments
{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    [inParameters enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
        if (!obj || ([obj isKindOfClass:[NSString class]] && [@"" isEqualToString:obj]))
            return;
        
        if ([obj isKindOfClass:[NSString class]])
        {
            obj = [obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            obj = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        parameters[key] = obj;
    }];
    
    parameters[RTTicketReplyMessageTicketIDKey] = ticket.ticketID;
    parameters[RTTicketReplyMessageActionKey] = RTTicketReplyMessageActionCorrespondValue;
    
    if (!attachments || attachments.count == 0)
        return parameters;
    
    NSMutableArray * attachmentFileNames = [NSMutableArray arrayWithCapacity:attachments.count];
    [attachments enumerateObjectsUsingBlock:^(NSURL * fileURL, NSUInteger idx, BOOL *stop) {
        attachmentFileNames[idx] = [fileURL lastPathComponent];
    }];
    
    parameters[RTTicketReplyMessageAttachmentsKey] = [attachmentFileNames componentsJoinedByString:@", "];
    
    return parameters;
}

static NSString * const RTTicketReplyRequestContentKey = @"content";

- (NSDictionary *)_serializeParametersForReply:(NSDictionary *)inputParameters
{
    NSMutableString * result = [NSMutableString string];
    [inputParameters enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
        [result appendFormat:@"%@: %@\n", key, obj];
    }];
    
    return @{ RTTicketReplyRequestContentKey : result };
}

- (void)postPlainTextReply:(NSDictionary *)inParameters attachments:(NSArray *)attachments toTicket:(RTTicket *)ticket completion:(void (^)(NSError * error))completion;
{
    NSDictionary * sanitizedParameters = [self _sanitizeInputParameters:inParameters forTicket:ticket addingAttachments:attachments];
    NSDictionary * requestParameters = [self _serializeParametersForReply:sanitizedParameters];
    NSString * requestPath = [NSString stringWithFormat:@"REST/1.0/%@/comment", ticket.ticketID];
    
    __block BOOL flag_errorCreatingRequest = NO;
    id block = ^(id <AFMultipartFormData> formData) {
        [attachments enumerateObjectsUsingBlock:^(NSURL * fileURL, NSUInteger idx, BOOL *stop) {
            NSError * __autoreleasing error = nil;
            [formData appendPartWithFileURL:fileURL name:[NSString stringWithFormat:@"attachment_%li", idx + 1] error:&error];
            
            if (error)
            {
                *stop = flag_errorCreatingRequest = YES;
                completion(error);
            }
        }];
    };
    
    NSMutableURLRequest * request = [self multipartFormRequestWithMethod:@"POST" path:requestPath parameters:requestParameters constructingBodyWithBlock:block];
    
    if (flag_errorCreatingRequest)
        return;
    
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", operation.responseString);
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }]];
}

// TODO: Debug logging for later
// TODO: Drag & Drop attachments
// TODO: "Delete" key, "Space" key, and double click support for previews within attachments composer
// TODO: Dates aren't parsing correctly

#pragma mark - Authentication (Keychain)

- (void)setUsername:(NSString *)username password:(NSString *)password errorBlock:(RTBasicBlock)errorBlock
{
    NSDictionary * candidateCredentials = @{ @"user": username, @"pass": password };
    
    [self
     _tryLoginWithCredentials:candidateCredentials
     onCompletion:^(BOOL invalidCredentialsError, BOOL networkError) {
         if (!invalidCredentialsError && !networkError)
         {
             self.keychainEntry.contents = candidateCredentials;
             SAFE_DELEGATE_CALL([self.delegate apiEngineDidAttemptLogin:self]);
             return;
         }
         
         if (networkError)
             SAFE_DELEGATE_CALL([self.delegate apiEngineRequiresNetwork:self]);
         
         if (errorBlock)
             errorBlock();
     }];
}

- (NSString *)username
{
    return self.keychainEntry.contents[@"user"];
}

- (void)removeUsernameAndPassword;
{
    self.keychainEntry.contents = @{};
    [self _forcedLogout];
    
    [self refreshLogin];
}

#pragma mark - Authentication (Server)

- (void)refreshLogin
{
    NSAssert(self.delegate != nil, @"RTEngine must have a delegate set before operations can take place");
    
    SAFE_DELEGATE_CALL([self.delegate apiEngineWillAttemptLogin:self]);
    [self
     _tryLoginWithCredentials:self.keychainEntry.contents
     onCompletion:^(BOOL invalidCredentialsError, BOOL networkError) {
         // Only ask user for new credentials if the network was valid
         if (invalidCredentialsError && !networkError)
         {
             RTCLoginWindowController * loginWindowController = [[RTCLoginWindowController alloc] init];
             
             SAFE_DELEGATE_CALL([self.delegate apiEngine:self requiresAuthentication:loginWindowController]);
             return; // Leave -apiEngineDidAttemptLogin: sequence open, it is handled in verification
         }
         
         // Otherwise, fail here. User must restart operation.
         SAFE_DELEGATE_CALL([self.delegate apiEngineDidAttemptLogin:self]);
         
         if (networkError)
             SAFE_DELEGATE_CALL([self.delegate apiEngineRequiresNetwork:self]);
     }];
}

- (void)_tryLoginWithCredentials:(NSDictionary *)roCredentials
                    onCompletion:(void (^)(BOOL invalidCredentialsError, BOOL networkError))completionBlock;
{
    [self _logoutIfAuthenticated];
    
    if (!roCredentials)
        return completionBlock(YES, NO);
    
    NSMutableDictionary * credentials = roCredentials.mutableCopy;
    credentials[@"next"] = @"c2eb5af67a20123fbac8cd57aa94e040"; // TODO: Figure this out more
    
    NSURLRequest * request = [self requestWithMethod:@"POST" path:@"NoAuth/Login.html" parameters:credentials];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
        // Completion means that we failed to get a redirect, bad credentials
        completionBlock(YES, NO);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        // Failure means it was a network error
        completionBlock(NO, YES);
    }];
    
    __weak __typeof(operation) wOp = operation;
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        // NOTE: This is really the only way to grab successful logins as of this version
        //       However, it is also a hack and should be considered for fixing if at all possible.
        if ([request.URL isEqual:RT_SERVER_URL])
        {
            self.authenticated = YES;
            completionBlock(NO, NO);
            [wOp cancel];
        }
        
        return request;
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)_forcedLogout;
{
    self.authenticated = YES;
    [self _logoutIfAuthenticated];
}

- (void)_logoutIfAuthenticated;
{
    if (!self.authenticated)
        return;
    
    SAFE_DELEGATE_CALL([self.delegate apiEngineWillLogout:self]);
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteAllCookiesForURL:RT_SERVER_URL];
    
    self.authenticated = NO;
    SAFE_DELEGATE_CALL([self.delegate apiEngineDidLogout:self]);
}

@end
