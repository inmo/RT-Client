//
//  RTTicket+Extensions.m
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTicket+Extensions.h"

@implementation RTTicket (Extensions)

+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse;
{
    return [self createTicketFromAPIResponse:apiResponse inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;
{
    if (!apiResponse || !apiResponse[@"id"])
        return nil;
    
    RTTicket * ticket = [self MR_createInContext:context];
    
    ticket.adminCC = apiResponse[@"adminCC"];
    ticket.cc = apiResponse[@"Cc"];
    ticket.created = [NSDate date]; // apiResponse[@"Created"];
    ticket.creator = apiResponse[@"Creator"];
    ticket.finalPriority = @([apiResponse[@"FinalPriority"] integerValue]);
    ticket.initialPriority = @([apiResponse[@"InitialPriority"] integerValue]);
    ticket.lastUpdated = [NSDate date]; // apiResponse[@"LastUpdated"];
    ticket.owner = apiResponse[@"Owner"];
    ticket.priority = @([apiResponse[@"Priority"] integerValue]);
    ticket.queue = apiResponse[@"Queue"];
    ticket.requestors = apiResponse[@"Requestors"];
    ticket.status = apiResponse[@"Status"];
    ticket.subject = apiResponse[@"Subject"];
    ticket.timeEstimated = @([apiResponse[@"TimeEstimated"] integerValue]);
    ticket.timeLeft = @([apiResponse[@"TimeLeft"] integerValue]);
    ticket.timeWorked = @([apiResponse[@"TimeWorked"] integerValue]);
    ticket.ticketID = apiResponse[@"id"];
    
    return ticket;
}

- (void)sync:(BOOL)syncAssociations completion:(RTBasicBlock)completionBlock;
{
    
}

@end
