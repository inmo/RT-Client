//
//  RequestTrackerAPI.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTEngine.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://sulfur.rose-hulman.edu/rt"]

@interface RTEngine (/* Private */)
@end

@implementation RTEngine

@synthesize isAuthenticated = _isAuthenticated;

- (id)init;
{
    if ((self = [super initWithBaseURL:RT_SERVER_URL]))
    {
        [self _doLogin]; // DEBUG: For now, just login immediately
    }
    
    return self;
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

- (void)_doLogin;
{
    // TODO: Retrieve credientals from keychain
    NSDictionary * credientials = [self _retrieveCredientialsDictionary];
    
    [self postPath:@""
        parameters:credientials
           success:^(AFHTTPRequestOperation * operation, id responseObject) {
               // TODO: Logic to determine if login was a success or failure
               /* Might be able to spoof a browser user agent in the request.
                * I noticed that I was getting a 302 response when posting
                * to /NoAuth/Login.html from the browser, but only a 200
                * when doing it from the app. */
               _isAuthenticated = YES;
               
               // DEBUG: Just to prove that it actually worked
               [self getPath:@"REST/1.0/ticket/1"
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         NSLog(@"Response String: %@", operation.responseString);
                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         NSLog(@"Error: %@", error);
                     }];
           }
           failure:^(AFHTTPRequestOperation * operation, NSError * error) {
               // TODO: This needs better error handeling
               NSLog(@"Authentication failed: %@", error);
           }];
}

- (void)_doLogout;
{
    // TODO: POST to /REST/1.0/logout to clear session on the server
    NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:RT_SERVER_URL];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL *stop) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }];
    
    _isAuthenticated = NO;
}

@end
