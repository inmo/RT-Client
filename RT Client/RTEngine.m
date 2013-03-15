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
#import "RTParser.h"
#import "RTCLoginWindowController.h"
#import "RTModels.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://rhit-rt.axiixc.com/"]

#define SAFE_DELEGATE_CALL(CODE) if (self.delegate) { dispatch_async(dispatch_get_main_queue(), ^{ CODE; }); }
#define FORCE_LOGOUT() if ((self.authenticated = YES)) { [self _logout]; }

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
        self->_keychainEntry = [RTKeychainEntry entryForService:@"Request Tracker" account:@"default"];
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
    [self getPath:@"REST/1.0/search/ticket" parameters:@{
        @"query": @"(Owner = '__CurrentUser__') AND (Status = 'new' OR Status = 'open')",
        @"format": @"l",
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSArray * rawTickets = [self.responseParser arrayWithString:operation.responseString];
         NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_context];
         
         [rawTickets enumerateObjectsUsingBlock:^(NSDictionary * response, NSUInteger idx, BOOL *stop) {
             [RTTicket createTicketFromAPIResponse:response inContext:scratchContext];
         }];
         
         [scratchContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
             if (completionBlock) completionBlock();
         }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    [self getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments", ticket.ticketID] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary * attachmentList = [self.responseParser dictionaryWithString:operation.responseString];
         NSArray * attachmentStubs = attachmentList[@"Attachments"];
         NSManagedObjectContext * scratchContext = [NSManagedObjectContext MR_contextWithParent:self.apiContext];
         
         __block RTTicket * ticket = (RTTicket *)[scratchContext objectWithID:ticketID];
         __block NSUInteger pendingOperationsCount = attachmentStubs.count;
         // ^^ Synchronize this with the scratchContext
                  
         [attachmentStubs enumerateObjectsUsingBlock:^(NSDictionary * rawAttachmentStub, NSUInteger idx, BOOL *stop) {
             [self
              getPath:[NSString stringWithFormat:@"REST/1.0/%@/attachments/%@", ticket.ticketID, rawAttachmentStub[@"id"]]
              parameters:nil
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary * rawResponse = nil;
                  
                  if (!operation.responseString)
                  {
                      // NSLog(@"Coulding extract attachment at %@", operation.request.URL);
                      // [operation.responseData writeToFile:@"/Users/axiixc/Desktop/bad.bin" atomically:YES];
                      
                      NSData * responseData = operation.responseData;
                      NSRange fullDataRange = NSMakeRange(0, responseData.length);
                      NSRange contentRange = [responseData rangeOfData:[@"Content: " dataUsingEncoding:NSUTF8StringEncoding] options:0 range:fullDataRange];
                      NSData * validResponseData = [responseData subdataWithRange:NSMakeRange(0, contentRange.location)];
                      NSString * partialResponseString = [[NSString alloc] initWithData:validResponseData encoding:NSUTF8StringEncoding];
                      rawResponse = [[self.responseParser dictionaryWithString:partialResponseString] mutableCopy];
                      
                      NSMutableData * unprocessedAttachmentData = [[responseData subdataWithRange:NSMakeRange(contentRange.location + contentRange.length, responseData.length - contentRange.location - contentRange.length)] mutableCopy];
                      while (YES) {
                          NSRange searchRange = NSMakeRange(0, unprocessedAttachmentData.length); // TODO: Update this so we don't search everything every time
                          NSData * searchData = [@"         " dataUsingEncoding:NSUTF8StringEncoding];
                          NSRange matchRange = [unprocessedAttachmentData rangeOfData:searchData options:0 range:searchRange];
                          
                          if (matchRange.location == NSNotFound)
                              break;
                          
                          [unprocessedAttachmentData replaceBytesInRange:matchRange withBytes:NULL length:0];
                      }
                      
                      // TODO: Still not sure if the trailing 0x0A0A0A is okay to leave on...
                      // [unprocessedAttachmentData writeToFile:@"/Users/axiixc/Desktop/good.bin" atomically:YES];
                      [(NSMutableDictionary *)rawResponse setObject:unprocessedAttachmentData forKey:@"Content"];
                  }
                  else
                  {
                      rawResponse = [self.responseParser dictionaryWithString:operation.responseString];
                  }
                  
                  [scratchContext performBlock:^{
                      RTAttachment * attachment = [RTAttachment createAttachmentFromAPIResponse:rawResponse inContext:scratchContext];
                      attachment.ticket = ticket;
                      
                      pendingOperationsCount--; // TODO: This can be redone using barriers in GCD
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
    FORCE_LOGOUT();
    
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
    [self _logout];
    
    if (!roCredentials)
        return completionBlock(YES, NO);
    
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
        // TODO: This is really the only way to grab successful logins as of this version
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

- (void)_logout;
{
    if (!self.authenticated)
        return;
    
    SAFE_DELEGATE_CALL([self.delegate apiEngineWillLogout:self]);
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteAllCookiesForURL:RT_SERVER_URL];
    
    self.authenticated = NO;
    SAFE_DELEGATE_CALL([self.delegate apiEngineDidLogout:self]);
}

@end

