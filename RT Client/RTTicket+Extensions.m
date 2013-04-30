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

- (NSArray *)chronologicallySortedTopLevelAttachments;
{
    NSPredicate * topLevelPredicate = [NSPredicate predicateWithFormat:@"parent = 0"];
    NSArray * sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];

    return [[self.attachments filteredSetUsingPredicate:topLevelPredicate]
            sortedArrayUsingDescriptors:sortDescriptors];
}

- (NSAttributedString *)stringForReplyComposer;
{
    NSMutableParagraphStyle * style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.paragraphSpacing = style.paragraphSpacingBefore = 5.0f;
    
    NSMutableAttributedString * composerReply = [NSMutableAttributedString new];
    [composerReply addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, 0)];
    NSArray * attachments = self.chronologicallySortedTopLevelAttachments;
    
    [attachments enumerateObjectsUsingBlock:^(RTAttachment * attachment, NSUInteger idx, BOOL *stop) {
        NSMutableAttributedString * attachmentContents = [[attachment attributedStringContents] mutableCopy];
        if (!attachmentContents)
            return;
        
        style.firstLineHeadIndent = style.headIndent = 10.0 * (CGFloat)(attachments.count - idx);
        
        [attachmentContents setAttributes:@{
            NSParagraphStyleAttributeName: [style copy],
           NSForegroundColorAttributeName: [NSColor blueColor]
         } range:NSMakeRange(0, attachmentContents.length)];
        
        [composerReply insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:0];
        [composerReply insertAttributedString:attachmentContents atIndex:0];
    }];
    
    style.firstLineHeadIndent = style.headIndent = 0.0;
    
    NSAttributedString * header = [[NSAttributedString alloc] initWithString:@"\n" attributes:@{ NSParagraphStyleAttributeName : [NSParagraphStyle defaultParagraphStyle] }];
    [composerReply insertAttributedString:header atIndex:0];
    
    return composerReply;
}

- (NSString *)HTMLStringForReplyComposer;
{
    NSMutableString * string = [NSMutableString new];
    [self.chronologicallySortedTopLevelAttachments enumerateObjectsUsingBlock:^(RTAttachment * attachment, NSUInteger idx, BOOL *stop) {
        [string insertString:[attachment HTMLString] atIndex:0];
        [string insertString:@"<blockquote>" atIndex:0];
        [string appendFormat:@"</blockquote>"];
    }];
    
    return string;
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

- (NSString *)numericTicketID;
{
    NSRange range = [self.ticketID rangeOfString:@"/"];
    BOOL isValidRange = (range.location != NSNotFound && range.location + 1 < self.ticketID.length);
    
    return isValidRange ? [self.ticketID substringFromIndex:range.location + 1] : nil;
}

- (NSString *)lastAttachmentID;
{
    return [[[self.chronologicallySortedTopLevelAttachments lastObject] transaction] stringValue];
}

@end
