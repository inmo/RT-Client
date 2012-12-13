//
//  RequestTrackerAPI.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTEngine.h"

#define RT_SERVER_URL [NSURL URLWithString:@"http://sulfur.rose-hulman.edu/rt"]

@interface RTEngine () {
    
}

- (void)_doAuthenticate;

@end

@implementation RTEngine

- (id)init
{
    if ((self = [super initWithBaseURL:RT_SERVER_URL]))
    {
        [self _doAuthenticate];
    }
}

- (void)_doAuthenticate
{
    for (NSHTTPCookie * cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:RT_SERVER_URL])
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    [self
     postPath:@"NoAuth/Login.html"
     parameters:@{@"user": @"savagejs", @"password":@"password"}
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"Posting to %@", [[operation request] URL]);
         NSLog(@"Login success: %@", [[operation response] allHeaderFields]);
         
         for (NSHTTPCookie * cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:RT_SERVER_URL])
         {
             if ([[cookie name] isEqualToString:@"RT_SID_sulfur.rose-hulman.edu.80"])
                 [self setDefaultHeader:@"Cookie" value:[NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]]];   
         }
         
         [self
          getPath:@"REST/1.0/ticket/1"
          parameters:@{@"user": @"savagejs", @"password":@"password"}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"Request headers: %@", [[operation request] allHTTPHeaderFields]);
              NSLog(@"Search success: %@", [[operation response] allHeaderFields]);
              NSLog(@"Response: %@", [operation responseString]);
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Failure");
          }];
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Unexpected error: %@", error);
     }];
}

- (void)requestTicket:(NSString *)ticketID
           completion:(void (^)(NSArray *))completionBlock
                error:(void (^)(NSError *))errorBlock
{
    
}

@end
