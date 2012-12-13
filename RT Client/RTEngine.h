//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^RTTemporaryBlock)();

@interface RTEngine : AFHTTPClient

// -- /REST/1.0/ticket/<ticket-id>/show
- (void)requestTicketDetail:(id)ticketID
                 completion:(RTTemporaryBlock)completionBlock
                      error:(RTTemporaryBlock)errorBlock
;

- (void)requestQueues:(void (^)(NSArray * queues))completionBlock
                error:(RTTemporaryBlock)errorBlock
;

@property (nonatomic) BOOL isAuthenticated;

- (void)setUsername:(NSString *)username password:(NSString *)password;
- (void)removeUsernameAndPassword;

@end
