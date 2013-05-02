//
//  RTTicket+Extensions.m
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTicket+Extensions.h"
#import "RTAttachment+Extensions.h"

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

static NSString * const RTAttachmentSerializationChronologicalOrderingKey = @"chronologicalOrdering";
static NSString * const RTAttachmentSerializationDateCreatedKey = @"dateCreated";
static NSString * const RTAttachmentSerializationBodyKey = @"body";
static NSString * const RTAttachmentSerializationHeadersKey = @"headers";

- (NSString *)constructTicketHierarchyJSON
{
    NSMutableArray * jsonAttachments = [NSMutableArray array];
    [[self.attachments filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"parent = 0"]]
     enumerateObjectsUsingBlock:^(RTAttachment * attachment, BOOL *stop) {
         NSDictionary * dictionary = [self _constructSubhierarchyForAttachment:attachment];
         if (dictionary) [jsonAttachments addObject:dictionary];
     }];
    
    [jsonAttachments sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:RTAttachmentSerializationChronologicalOrderingKey ascending:YES]]];

    NSError * __autoreleasing error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:jsonAttachments options:NULL error:&error];
    
    if (!data || error)
        return nil;
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)_constructSubhierarchyForAttachment:(RTAttachment *)attachment;
{
    attachment = [self _ensureValidateTopLevelAttachment:attachment];
    
    if (!attachment)
        return nil;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    
    return @{ RTAttachmentSerializationChronologicalOrderingKey: @(attachment.created.timeIntervalSince1970),
              RTAttachmentSerializationDateCreatedKey: ENSURE_NOT_NIL([formatter stringFromDate:attachment.created]),
              RTAttachmentSerializationBodyKey: ENSURE_NOT_NIL([[NSString alloc] initWithData:attachment.content encoding:NSUTF8StringEncoding]),
              RTAttachmentSerializationHeadersKey: ENSURE_NOT_NIL_OR(attachment.headers, @{}) };
}

- (RTAttachment *)_ensureValidateTopLevelAttachment:(RTAttachment *)attachment;
{
    if (attachment.content.length > 0 && [[NSString alloc] initWithData:attachment.content encoding:NSUTF8StringEncoding])
        return attachment;
    
    NSArray * children = [attachment childrenAttachments];
    NSArray * predicates = @[[NSPredicate predicateWithFormat:@"contentType BEGINSWITH \"text\""],
                             [NSPredicate predicateWithBlock:^BOOL(RTAttachment * evaluatedObject, NSDictionary * bindings) {
                                 return !![[NSString alloc] initWithData:evaluatedObject.content encoding:NSUTF8StringEncoding];
                             }]];
    
    RTAttachment * replacementAttachment = nil;
    for (NSPredicate * predicate in predicates)
    {
        NSUInteger foundIdx = [children indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return (*stop = [predicate evaluateWithObject:obj]);
        }];
        
        if (foundIdx != NSNotFound)
            return children[foundIdx];
    }
    
    return nil;
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
