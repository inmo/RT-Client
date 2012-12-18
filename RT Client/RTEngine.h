//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^RTErrorBlock)(NSError * error);

@interface RTEngine : AFHTTPClient

@property (nonatomic, readonly) BOOL isAuthenticated;

// TODO: #1 get a list of ticket/id's via the "/search/ticket..." endpoint
- (void)requestSelfServiceTickets:(void (^)(NSArray * tickets))completionBlock
                            error:(RTErrorBlock)errorBlock;

// TODO: #2 get attachments, metadata, and related tickets to build timeline view
- (void)requestTicketDetails:(id)ticket
                  completion:(void (^)())completionBlock
                       error:(RTErrorBlock)errorBlock;

// TODO: These need written, using keychain for storage
- (void)setUsername:(NSString *)username password:(NSString *)password;
- (void)removeUsernameAndPassword;

@end
