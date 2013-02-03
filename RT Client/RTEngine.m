//
//  RequestTrackerAPI.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "RTEngine.h"
#import "RTKeychainEntry.h"
#import "RTParser.h"
#import "RTCLoginWindowController.h"
#import "RTModels.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://sulfur.rose-hulman.edu/rt"]
#define SAFARI_USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"

// TODO: Docs were unclear about the validity of calling dispatch_get_current_queue() for production code.
// Is this bad practice? Is there a better way to ensure execution on main thread?
#define DISPATCH_DELEGATE(CODE) do { if (self.delegate) { \
    if (dispatch_get_current_queue() != dispatch_get_main_queue()) { \
        dispatch_async(dispatch_get_main_queue(), ^{ CODE; }); \
    } else { CODE; } \
} } while (0)

#define FORCE_LOGOUT() if ((self.authenticated = YES)) { [self _logout]; }

@interface RTEngine (/* Private */)

@property (nonatomic, assign, readwrite, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong, readonly) RTKeychainEntry * keychainEntry;
@property (nonatomic, strong) NSManagedObjectContext * apiContext;
@property (nonatomic, strong) RTParser * responseParser;

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
        self->_keychainEntry = [RTKeychainEntry entryForService:@"request-tracker" account:@"default"];
        FORCE_LOGOUT();
        
        self.apiContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
        self.responseParser = [RTParser new];
    }
    
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableURLRequest * request = [super requestWithMethod:method path:path parameters:parameters];
    [request setTimeoutInterval:120];
    
    return request;
}

#pragma mark - API Endpoints

- (void)fetchSelfServiceTicketStubs:(RTBasicBlock)completionBlock;
{
    [self
     getPath:@"REST/1.0/search/ticket"
     parameters:@{
        @"query": @"(Owner = '__CurrentUser__') AND (Status = 'new' OR Status = 'open')",
        @"format": @"l",
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSArray * rawTickets = [self.responseParser arrayWithString:operation.responseString];
         NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_contextWithParent:self.apiContext];
         
         [scratchContext performBlock:^{
             [rawTickets enumerateObjectsUsingBlock:^(NSDictionary * response, NSUInteger idx, BOOL *stop) {
                 [RTTicket createTicketFromAPIResponse:response inContext:scratchContext];
             }];
             [scratchContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                 if (completionBlock) completionBlock();
             }];
         }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@", error);
         if (completionBlock) completionBlock();
     }];
}

- (void)pullTicketInformation:(NSManagedObjectID *)ticketID completion:(RTBasicBlock)completionBlock;
{
    RTTicket * ticket = (RTTicket *)[self.apiContext objectWithID:ticketID];
    if (!ticket)
    {
        if (completionBlock) completionBlock();
        return;
    }
    
    [self
     getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments", ticket.ticketID]
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary * attachmentList = [self.responseParser dictionaryWithString:operation.responseString];
         NSArray * attachmentStubs = attachmentList[@"Attachments"];
         NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_contextWithParent:self.apiContext];
         
         __block RTTicket * ticket = (RTTicket *)[scratchContext objectWithID:ticketID];;
         __block NSUInteger pendingOperationsCount = attachmentStubs.count;
         // ^^ Synchronize this with the scratchContext
                  
         [attachmentStubs enumerateObjectsUsingBlock:^(NSDictionary * rawAttachmentStub, NSUInteger idx, BOOL *stop) {                 
             [self
              getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments/%@", ticket.ticketID, rawAttachmentStub[@"id"]]
              parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [scratchContext performBlock:^{
                      if (!operation.responseString)
                      {
//                          [operation.responseData writeToFile:@"/Users/axiixc/Desktop/out.bin" atomically:YES];
                          NSLog(@"Coulding extract attachment at %@", operation.request.URL);
                      }
                   
                      NSDictionary * rawAttachment = [self.responseParser dictionaryWithString:operation.responseString];
                      RTAttachment * attachment = [RTAttachment createAttachmentFromAPIResponse:rawAttachment inContext:scratchContext];
                      attachment.ticket = ticket;
                      
//                      NSStringEncoding encoding = NULL;
//                      NSError * __autoreleasing error = nil;
//                      NSLog(@"%@", [[NSString alloc] initWithData:operation.responseData encoding:NSISOLatin1StringEncoding]);
                      
                      pendingOperationsCount--;
                      if (pendingOperationsCount == 0)
                      {
                          [scratchContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                              if (completionBlock) completionBlock();
                          }];
                      }
                  }];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"%@", error);
                  
                  [scratchContext performBlock:^{
                      pendingOperationsCount--;
                      if (pendingOperationsCount == 0 && completionBlock)
                          completionBlock();
                  }];
              }];
         }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"%@", error);
         if (completionBlock) completionBlock();
     }];
}

- (void)_testHook
{

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
             DISPATCH_DELEGATE([self.delegate apiEngineDidAttemptLogin:self]);
             return;
         }
         
         if (networkError)
             DISPATCH_DELEGATE([self.delegate apiEngineRequiresNetwork:self]);
         
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
    self.keychainEntry.contents = nil;
    FORCE_LOGOUT();
}

#pragma mark - Authentication (Server)

- (void)refreshLogin
{
    NSAssert(self.delegate != nil, @"RTEngine must have a delegate set before operations can take place");
    
    DISPATCH_DELEGATE([self.delegate apiEngineWillAttemptLogin:self]);
    [self
     _tryLoginWithCredentials:self.keychainEntry.contents
     onCompletion:^(BOOL invalidCredentialsError, BOOL networkError) {
         // Only ask user for new credentials if the network was valid
         if (invalidCredentialsError && !networkError)
         {
             RTCLoginWindowController * loginWindowController = [[RTCLoginWindowController alloc] init];
             
             DISPATCH_DELEGATE([self.delegate apiEngine:self requiresAuthentication:loginWindowController]);
             return; // Leave -apiEngineDidAttemptLogin: sequence open, it is handled in verification
         }
         
         // Otherwise, fail here. User must restart operation.
         DISPATCH_DELEGATE([self.delegate apiEngineDidAttemptLogin:self]);
         
         if (networkError)
             DISPATCH_DELEGATE([self.delegate apiEngineRequiresNetwork:self]);
     }];
}

- (void)_tryLoginWithCredentials:(NSDictionary *)roCredentials
                    onCompletion:(void (^)(BOOL invalidCredentialsError, BOOL networkError))completionBlock;
{
    [self _logout];
    
    NSMutableDictionary * credentials = roCredentials.mutableCopy;
    credentials[@"next"] = @"c2eb5af67a20123fbac8cd57aa94e040"; // TODO: Figure this out more
    
    NSURLRequest * request = [self requestWithMethod:@"POST" path:@"NoAuth/Login.html" parameters:credentials];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
        // If no redirect is found, credentials must have failed
        completionBlock(YES, NO);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        // Upon success, the redirection handler invalidates the request, so it technically "errors"
        // But since we already succeeded, prevent the default failure action here.
        if (self.authenticated)
            return;
        
        // Classify all other failures as network errors
        completionBlock(NO, YES);
    }];
    
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        if ([request.URL.absoluteString hasSuffix:@"/rt/"])
        {
            self.authenticated = YES;
            completionBlock(NO, NO);
            return nil;
        }
        
        return request;
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

- (void)_logout;
{
    // If nothing will be changed, don't invoke the delegate methods
    if (!self.authenticated)
        return;
    
    DISPATCH_DELEGATE([self.delegate apiEngineWillLogout:self]);
    
    // TODO: POST to /REST/1.0/logout to clear session on the server
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:RT_SERVER_URL];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL *stop) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }];
    
    self.authenticated = NO;
    DISPATCH_DELEGATE([self.delegate apiEngineDidLogout:self]);
}

@end

