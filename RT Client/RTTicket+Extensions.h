//
//  RTTicket+Extensions.h
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTicket.h"

@interface RTTicket (Extensions)

+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse;
+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;

- (NSString *)plainTextSummary;
- (NSString *)stringFromCreated;

@end
