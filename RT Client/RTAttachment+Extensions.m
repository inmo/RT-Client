//
//  RTAttachment+Extensions.m
//  RT Client
//
//  Created by James Savage on 2/3/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTAttachment+Extensions.h"

@implementation RTAttachment (Extensions)

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse;
{
    return [self createAttachmentFromAPIResponse:apiResponse inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;
{
    if (!apiResponse || !apiResponse[@"id"])
        return nil;
    
    NSArray * existingAttachments = [self MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"attachmentID = %@", @([apiResponse[@"id"] integerValue])] inContext:context];
    RTAttachment * attachment = (existingAttachments.count) ? existingAttachments[0] : [RTAttachment MR_createInContext:context];
    
    attachment.attachmentID = @([apiResponse[@"id"] integerValue]);
    attachment.subject = apiResponse[@"Subject"];
    attachment.creator = @([apiResponse[@"Creator"] integerValue]);
    attachment.created = ([apiResponse[@"Created"] isKindOfClass:[NSDate class]]) ?  apiResponse[@"Created"] : nil;
    attachment.transaction = @([apiResponse[@"Transaction"] integerValue]);
    attachment.parent = @([apiResponse[@"Parent"] integerValue]);
    attachment.messageID = @([apiResponse[@"MessageId"] integerValue]);
    attachment.filename = apiResponse[@"Filename"];
    attachment.contentType = apiResponse[@"ContentType"];
    attachment.contentEncoding = apiResponse[@"ContentEncoding"];
    attachment.headers = apiResponse[@"Headers"];
    
    if ([apiResponse[@"Content"] isKindOfClass:[NSData class]])
        attachment.content = apiResponse[@"Content"];
    else if ([apiResponse[@"Content"] isKindOfClass:[NSString class]])
        attachment.content = [(NSString *)apiResponse[@"Content"] dataUsingEncoding:NSUTF8StringEncoding];
    
    return attachment;
}

@end
