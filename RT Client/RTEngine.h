//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^RTErrorBlock)(NSError * error);
@protocol RTEngineDelegate;

@interface RTEngine : AFHTTPClient

+ (RTEngine *)sharedEngine;

@property (nonatomic, weak) id <RTEngineDelegate> delegate;

@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, readonly) BOOL hasCredientials;

- (void)refreshLogin;

// TODO: #1 get a list of ticket/id's via the "/search/ticket..." endpoint
- (void)requestSelfServiceTickets:(void (^)(NSArray * tickets))completionBlock
                            error:(RTErrorBlock)errorBlock;

// TODO: #2 get attachments, metadata, and related tickets to build timeline view
- (void)requestTicketDetails:(id)ticket
                  completion:(void (^)(/* signature not yet known */))completionBlock
                       error:(RTErrorBlock)errorBlock;

// TODO: These need written, using keychain for storage
- (void)validateUsername:(NSString *)username
                password:(NSString *)password
              completion:(void (^)(BOOL verified))completionBlock;
- (void)removeUsernameAndPassword;

@end

@protocol RTEngineDelegate <NSObject>

@required
- (void)apiEngineWillAttemptLogin:(RTEngine *)engine;
- (void)apiEngineDidAttemptLogin:(RTEngine *)engine;
- (void)apiEngineWillLogout:(RTEngine *)engine;
- (void)apiEngineDidLogout:(RTEngine *)engine;
- (void)apiEngine:(RTEngine *)engine requiresAuthentication:(NSWindow *)authWindow;

@end
