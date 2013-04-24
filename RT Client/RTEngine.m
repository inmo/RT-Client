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

@interface RTEngine (/* Private */)

@property (nonatomic, assign, readwrite, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong, readwrite) RTKeychainEntry * keychainEntry;

@property (nonatomic) dispatch_queue_t saveSyncQueue;

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
    if ((self = [super initWithBaseURL:RT_SERVER_URL]))
    {
        [self registerHTTPOperationClass:[RTRequestOperation class]];
        
        self.keychainEntry = [RTKeychainEntry entryForService:@"Request Tracker" account:@"default"];
        [self _forcedLogout];
        
        self.saveSyncQueue = dispatch_queue_create("com.inmo.RTEngine", NULL);
    }
    
    return self;
}

- (RTBasicBlock)saveHandlerForContext:(NSManagedObjectContext *)context numberOfObjects:(NSInteger)numberOfObjects;
{
    __block NSInteger pendingObjects = numberOfObjects;
    return [^{
        dispatch_sync(self.saveSyncQueue, ^{
            pendingObjects -= 1;
            if (pendingObjects == 0)
                [context MR_saveToPersistentStoreAndWait];
        });
    } copy];
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
             
             for (RTTicket * ticket in (allInfo ? createdTickets : nil))
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
         RTBasicBlock saveBlock = [self saveHandlerForContext:scratchContext numberOfObjects:stubs.count];
         
         [stubs enumerateObjectsUsingBlock:^(NSDictionary * stub, NSUInteger idx, BOOL *stop) {
             [self _fetchAttachmentID:stub[@"id"] associatedWithTicket:ticket saveBlock:saveBlock];
         }];
     } failure:nil];
}

- (void)_fetchAttachmentID:(id)attachmentID associatedWithTicket:(RTTicket *)ticket saveBlock:(void (^)())saveBlock
{
    [self
     getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments/%@", ticket.ticketID, attachmentID]
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         RTAttachment * attachment = [RTAttachment createAttachmentFromAPIResponse:operation.responseDictionary
                                                                         inContext:ticket.managedObjectContext];
         attachment.ticket = ticket;
         
         saveBlock();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         saveBlock();
     }];
}

#pragma mark - Ticket Replies

- (void)postReply:(NSDictionary *)parameters toTicket:(RTTicket *)ticket;
{
    NSMutableString * encodedContent = [NSMutableString new];
    [encodedContent appendFormat:@"id: %@\n", ticket.ticketID];
    [encodedContent appendFormat:@"Action: correspond\n"];
    
    NSString * santizedBody = [parameters[@"body"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [encodedContent appendFormat:@"Text: %@\n", santizedBody];
    
    if (parameters[@"cc"])
        [encodedContent appendFormat:@"Cc: %@", parameters[@"cc"]];
    
    if (parameters[@"bcc"])
        [encodedContent appendFormat:@"Bcc: %@", parameters[@"bcc"]];
    
//    [encodedContent appendFormat:@"Attachment: message.html\n"];
    
    NSString * requestPath = [NSString stringWithFormat:@"/REST/1.0/%@/comment", ticket.ticketID];
    [self postPath:requestPath parameters:@{@"content": encodedContent} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"op: %@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
//    Still fighting the API
//    id constructor = ^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:[parameters[@"body"] dataUsingEncoding:NSUTF8StringEncoding] name:@"attachment_1" fileName:@"message.html" mimeType:@"text/html"];
//    };
//    
//    NSMutableURLRequest * request = [self multipartFormRequestWithMethod:@"POST" path:requestPath parameters:@{@"contents" : encodedContent} constructingBodyWithBlock:constructor];
//    
//    id success = ^(AFHTTPRequestOperation * op, id responseObject) {
//        NSLog(@"op: %@", op.responseString);
//    };
//    
//    id error = ^(AFHTTPRequestOperation * op, NSError * error) {
//        NSLog(@"%@", error);
//    };
//    
//    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:request success:success failure:error]];
}

#pragma mark - Add Comment
-(void) addComment:(NSDictionary *)parameters sendTicket:(RTTicket *)ticket;
{
    NSMutableString *addContent = [NSMutableString new];
    [addContent appendFormat:@"id: %@\n", ticket.ticketID];
    [addContent appendFormat:@"Action: comment\n"];
    [addContent appendFormat:@"Text: %@\n", parameters[@"body"]];
    [addContent appendFormat:@"Attachment: message.html\n"];
    
    NSString * requestPath = [NSString stringWithFormat:@"/REST/1.0/%@/comment", ticket.ticketID];
    
    [self postPath:requestPath parameters:@{@"contents": addContent} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"op: %@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];

}

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
        // If no redirect is given, credentials must have failed
        completionBlock(YES, NO);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        // Upon success, the redirection handler invalidates the request, so it technically "errors"
        // But since we already succeeded, prevent the default failure action here.
        if (self.authenticated)
            return;
        
        completionBlock(NO, YES);
    }];
    
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        // NOTE: This is really the only way to grab successful logins as of this version
        //       However, it is also a hack and should be considered for fixing if at all possible.
        if ([request.URL isEqual:RT_SERVER_URL])
        {
            self.authenticated = YES;
            completionBlock(NO, NO);
            return nil;
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
