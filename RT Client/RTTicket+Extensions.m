//
//  RTTicket+Extensions.m
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTicket+Extensions.h"
#import "RTAttachment.h"

@implementation RTTicket (Extensions)

+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse;
{
    return [self createTicketFromAPIResponse:apiResponse inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (RTTicket *)createTicketFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;
{
    if (!apiResponse || !apiResponse[@"id"])
        return nil;
    
    NSArray * existingTickets = [self MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"ticketID = %@", apiResponse[@"id"]] inContext:context];
    RTTicket * ticket = (existingTickets.count) ? existingTickets[0] : [self MR_createInContext:context];
    
    ticket.adminCC = apiResponse[@"adminCC"];
    ticket.cc = apiResponse[@"Cc"];
    ticket.created = apiResponse[@"Created"];
    ticket.creator = apiResponse[@"Creator"];
    ticket.finalPriority = @([apiResponse[@"FinalPriority"] integerValue]);
    ticket.initialPriority = @([apiResponse[@"InitialPriority"] integerValue]);
    ticket.lastUpdated = apiResponse[@"LastUpdated"];
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

- (NSString *)plainTextSummary;
{
    NSArray * attachments = [RTAttachment MR_findAllSortedBy:@"attachmentID" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"ticket = %@ AND parent = 0", self]];
    
    if (!attachments.lastObject)
        return @"Loading…";
    
    NSString * rawString = [[NSString alloc] initWithData:((RTAttachment *)attachments.lastObject).content encoding:NSUTF8StringEncoding];
    NSAttributedString * summary = [[NSAttributedString alloc] initWithHTML:[rawString dataUsingEncoding:NSUTF8StringEncoding] baseURL:[[NSBundle mainBundle] bundleURL] documentAttributes:NULL];
    
    return summary.string;
}

- (NSString *)stringFromCreated;
{
    return [NSDateFormatter localizedStringFromDate:self.created dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

@end
