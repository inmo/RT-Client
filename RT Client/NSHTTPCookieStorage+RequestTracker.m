//
//  NSHTTPCookieStorage+RequestTracker.m
//  RT Client
//
//  Created by James Savage on 3/14/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "NSHTTPCookieStorage+RequestTracker.h"

@implementation NSHTTPCookieStorage (RequestTracker)

- (void)deleteAllCookiesForURL:(NSURL *)URL;
{
    [[self cookiesForURL:URL] enumerateObjectsUsingBlock:^(NSHTTPCookie * cookie, NSUInteger idx, BOOL *stop) {
        [self deleteCookie:cookie];
    }];
}

@end
