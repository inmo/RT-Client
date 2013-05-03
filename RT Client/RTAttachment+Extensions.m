//
//  RTAttachment+Extensions.m
//  RT Client
//
//  Created by James Savage on 2/3/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTAttachment+Extensions.h"
#import "RTTicket+Extensions.h"

NSString * const RTAttachmentSerializationChronologicalOrderingKey = @"chronologicalOrdering";
NSString * const RTAttachmentSerializationDateCreatedKey = @"dateCreated";
NSString * const RTAttachmentSerializationBodyKey = @"body";
NSString * const RTAttachmentSerializationHeadersKey = @"headers";
NSString * const RTAttachmentSerializationAttachmentsKey = @"attachments";
NSString * const RTAttachmentSerializationResourceFilenameKey = @"filename";
NSString * const RTAttachmentSerializationResourceSizeKey = @"size";
NSString * const RTAttachmentSerializationResourceURLKey = @"url";

@implementation RTAttachment (Extensions)

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse;
{
    return [self createAttachmentFromAPIResponse:apiResponse inContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;
{
    if (!apiResponse || !apiResponse[@"id"])
        return nil;
    
    NSPredicate * existingPredicate = [NSPredicate predicateWithFormat:@"attachmentID = %@", @([apiResponse[@"id"] integerValue])];
    RTAttachment * attachment = [[self MR_findAllWithPredicate:existingPredicate inContext:context] lastObject];
    attachment = (attachment) ?: [RTAttachment MR_createInContext:context];
    
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
    
    NSDictionary * headers = apiResponse[@"Headers"];
    NSMutableDictionary * lowercasedHeaders = [NSMutableDictionary dictionaryWithCapacity:headers.count];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString * key, id obj, BOOL *stop) {
        lowercasedHeaders[key.lowercaseString] = obj;
    }];
    
    attachment.headers = headers;
    
    if ([apiResponse[@"Content"] isKindOfClass:[NSData class]])
        attachment.content = apiResponse[@"Content"];
    else if ([apiResponse[@"Content"] isKindOfClass:[NSString class]])
        attachment.content = [(NSString *)apiResponse[@"Content"] dataUsingEncoding:NSUTF8StringEncoding];
    
    return attachment;
}

+ (NSDateFormatter *)defaultDateFormatter
{
    static NSDateFormatter * __defaultDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultDateFormatter = [[NSDateFormatter alloc] init];
        [__defaultDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [__defaultDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    });
    
    return __defaultDateFormatter;
}

- (NSArray *)childrenAttachments;
{
    NSPredicate * childrenPredicate = [NSPredicate predicateWithFormat:@"parent = %@", self.attachmentID];
    return [[self.ticket.attachments filteredSetUsingPredicate:childrenPredicate] allObjects];
}

- (NSDictionary *)constructSubhierarchyForJSON;
{
    RTAttachment * attachment = [self _validTopLevelAttachmentForAttachment:self];
    
    if (!attachment)
        return nil;
    
    NSMutableArray * children = [self.childrenAttachments mutableCopy];
    [children removeObject:attachment];
    
    NSMutableArray * childrenLeaves = [NSMutableArray array];
    [children enumerateObjectsUsingBlock:^(RTAttachment * child, NSUInteger idx, BOOL *stop) {
        NSDictionary * leaf = [child _createSubhierarchyLeafForJSON];
        
        if (leaf)
            [childrenLeaves addObject:leaf];
    }];
    
    return @{ RTAttachmentSerializationChronologicalOrderingKey: @(attachment.created.timeIntervalSince1970),
              RTAttachmentSerializationDateCreatedKey: ENSURE_NOT_NIL([[[self class] defaultDateFormatter] stringFromDate:attachment.created]),
              RTAttachmentSerializationBodyKey: ENSURE_NOT_NIL([[NSString alloc] initWithData:attachment.content encoding:NSUTF8StringEncoding]),
              RTAttachmentSerializationHeadersKey: ENSURE_NOT_NIL_OR(attachment.headers, @{}),
              RTAttachmentSerializationAttachmentsKey: ENSURE_NOT_NIL_OR(childrenLeaves, @[])};
}

- (RTAttachment *)_validTopLevelAttachmentForAttachment:(RTAttachment *)attachment;
{
    if (attachment.content.length > 0 && [[NSString alloc] initWithData:attachment.content encoding:NSUTF8StringEncoding])
        return attachment;
    
    NSArray * children = [attachment childrenAttachments];
    NSArray * predicates = @[[NSPredicate predicateWithFormat:@"contentType BEGINSWITH \"text\""],
                             [NSPredicate predicateWithBlock:^BOOL(RTAttachment * evaluatedObject, NSDictionary * bindings) {
                                 return !![[NSString alloc] initWithData:evaluatedObject.content encoding:NSUTF8StringEncoding];
                             }]];
    
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

- (NSDictionary *)_createSubhierarchyLeafForJSON;
{
    return @{ // RTAttachmentSerializationChronologicalOrderingKey: @(self.created.timeIntervalSince1970),
              // RTAttachmentSerializationDateCreatedKey: ENSURE_NOT_NIL([[[self class] defaultDateFormatter] stringFromDate:self.created]),
              // RTAttachmentSerializationHeadersKey: ENSURE_NOT_NIL_OR(self.headers, @{}),
              RTAttachmentSerializationResourceFilenameKey: ENSURE_NOT_NIL_OR(self.filename, @"untitled"),
              RTAttachmentSerializationResourceSizeKey: [NSByteCountFormatter stringFromByteCount:self.content.length countStyle:NSByteCountFormatterCountStyleFile],
              RTAttachmentSerializationResourceURLKey: self.objectID.URIRepresentation.absoluteString };
}

@end
