//
//  RequestTrackerAPI.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTEngine.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://sulfur.rose-hulman.edu/rt"]
#define SAFARI_USER_AGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17"

#define DISPATCH_DELEGATE(CODE) do { if (self.delegate) { \
    if (dispatch_get_current_queue() != dispatch_get_main_queue()) { \
        dispatch_async(dispatch_get_main_queue(), ^{ CODE; }); \
    } else { CODE; } \
} } while (0)

@interface RTEngine (/* Private */)

@property (nonatomic, assign, readwrite, getter = isAuthenticated) BOOL authenticated;

@end

@implementation RTEngine

- (id)init;
{
    if ((self = [super initWithBaseURL:RT_SERVER_URL]))
    {
//        [self setDefaultHeader:@"User-Agent" value:SAFARI_USER_AGENT];
//        [self setDefaultHeader:@"Referer" value:@"http://sulfur.rose-hulman.edu/rt/"];
//        [self setDefaultHeader:@"Origin" value:@"http://sulfur.rose-hulman.edu"];
    }
    
    
    return self;
}

- (void)refreshLogin
{
    NSAssert(self.delegate != nil, @"RTEngine must have a delegate set before operations can take place");
    
    [self _doLogin:^(BOOL credentialsFailed, BOOL networkFailed) {
        // TODO: Continue these error values through the app
        DISPATCH_DELEGATE([self.delegate apiEngineDidAttemptLogin:self]);
        
        if (credentialsFailed)
        {
            NSWindow * aWindow = [[NSWindow alloc] init];
            [aWindow setFrame:NSMakeRect(0, 0, 320, 320) display:YES];
            
            DISPATCH_DELEGATE([self.delegate apiEngine:self requiresAuthentication:aWindow]);
        }
    }];
}

#pragma mark - API Endpoints

- (void)requestSelfServiceTickets:(void (^)(NSArray * tickets))completionBlock
                            error:(RTErrorBlock)errorBlock;
{
    // TODO: #1 get a list of ticket/id's via the "/search/ticket..." endpoint
}

- (void)requestTicketDetails:(id)ticket
                  completion:(void (^)())completionBlock
                       error:(RTErrorBlock)errorBlock;
{
    // TODO: #2 get attachments, metadata, and related tickets to build timeline view
}

#pragma mark - Authentication (Keychain)

- (void)setUsername:(NSString *)username password:(NSString *)password;
{
    // TODO: Implement this method stub
}

- (void)removeUsernameAndPassword;
{
    // TODO: Implement this method stub
}

- (NSDictionary *)_retrieveCredientialsDictionary;
{
    // DEBUG: Replace this with working keychain code
    return @{ @"user": @"root", @"pass": @"password" };
}

#pragma mark - Authentication (Server)

- (void)_doLogin:(void (^)(BOOL credentialsFailed, BOOL networkFailed))completionBlock;
{
    [self _doLogout];
    
    DISPATCH_DELEGATE([self.delegate apiEngineWillAttemptLogin:self]);
    
    // TODO: Retrieve credientals from keychain
    NSMutableDictionary * credientials = [self _retrieveCredientialsDictionary].mutableCopy;
    credientials[@"next"] = @"c2eb5af67a20123fbac8cd57aa94e040"; // TODO: Figure this out more
    
    NSURLRequest * request = [self requestWithMethod:@"POST" path:@"NoAuth/Login.html" parameters:credientials];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * operation, id responseObject) {
        completionBlock(YES, NO);
    } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
        if (self.authenticated)
            return;
        
        // TODO: This needs better error handeling
        NSLog(@"Authentication failed: %@", error);
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

- (void)_doLogout;
{
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
