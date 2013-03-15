//
//  NSHTTPCookieStorage+RequestTracker.h
//  RT Client
//
//  Created by James Savage on 3/14/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPCookieStorage (RequestTracker)

- (void)deleteAllCookiesForURL:(NSURL *)URL;

@end
