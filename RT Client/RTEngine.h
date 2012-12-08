//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>

typedef void (^RTTemporaryBlock)();

@interface RTEngine : AFHTTPClient

// -- /REST/1.0/ticket/<ticket-id>/show
- (void)requestTicketDetail:(id)ticketID
                 completion:(RTTemporaryBlock)completionBlock
                      error:(RTTemporaryBlock)errorBlock
;

@end
