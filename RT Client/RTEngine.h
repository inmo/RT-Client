//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
 
// Put data fetching methods in here!
@protocol RTDataProvider
// - (void)getTickets...
// - (void)postChanges...
@end

@protocol RTEngineDelegate;

@interface RTEngine : AFHTTPClient <RTDataProvider>

+ (RTEngine *)sharedEngine;

@property (nonatomic, weak) id <RTEngineDelegate> delegate;

@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, readonly) BOOL hasCredentials;

- (void)refreshLogin;

- (void)setUsername:(NSString *)username password:(NSString *)password errorBlock:(RTBasicBlock)errorBlock;
- (void)removeUsernameAndPassword;
- (NSString *)username;

- (void)_testHook;

@end

@protocol RTEngineDelegate <NSObject>

@required
- (void)apiEngineWillAttemptLogin:(RTEngine *)engine;
- (void)apiEngineDidAttemptLogin:(RTEngine *)engine;
- (void)apiEngineWillLogout:(RTEngine *)engine;
- (void)apiEngineDidLogout:(RTEngine *)engine;
- (void)apiEngine:(RTEngine *)engine requiresAuthentication:(NSWindowController *)authWindow;

/**
 * Called when a request failed for network related reasons. Invocation of this method
 * implies that whatever request caused the failure has been terminated. Suggested action
 * is to display a network notification to the user.
 * 
 * Note: this method may be called multiple times in succession. It is the responsibility
 * of the reciever to manage sane display of notifications.
 */
- (void)apiEngineRequiresNetwork:(RTEngine *)engine;

@end

