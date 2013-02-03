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
    
    RTAttachment * attachment = [RTAttachment MR_createInContext:context];
    
    attachment.attachmentID = @([apiResponse[@"id"] integerValue]);
    attachment.subject = apiResponse[@"Subject"];
    attachment.creator = @([apiResponse[@"Creator"] integerValue]);
    attachment.created = [NSDate date];
    attachment.transaction = @([apiResponse[@"Transaction"] integerValue]);
    attachment.parent = @([apiResponse[@"Parent"] integerValue]);
    attachment.messageID = @([apiResponse[@"MessageId"] integerValue]);
    attachment.filename = apiResponse[@"Filename"];
    attachment.contentType = apiResponse[@"ContentType"];
    attachment.contentEncoding = apiResponse[@"ContentEncoding"];
    attachment.headers = apiResponse[@"Headers"];
    attachment.content = [(NSString *)apiResponse[@"Content"] dataUsingEncoding:NSUTF8StringEncoding];
    
    return attachment;
}

@end