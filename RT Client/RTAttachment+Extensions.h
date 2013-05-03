//
//  RTAttachment+Extensions.h
//  RT Client
//
//  Created by James Savage on 2/3/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTAttachment.h"
#import <Quartz/Quartz.h>

extern NSString * const RTAttachmentSerializationChronologicalOrderingKey;
extern NSString * const RTAttachmentSerializationDateCreatedKey;
extern NSString * const RTAttachmentSerializationBodyKey;
extern NSString * const RTAttachmentSerializationHeadersKey;
extern NSString * const RTAttachmentSerializationAttachmentsKey;
extern NSString * const RTAttachmentSerializationResourceFilenameKey;
extern NSString * const RTAttachmentSerializationResourceSizeKey;
extern NSString * const RTAttachmentSerializationResourceURLKey;

@interface RTAttachment (Extensions) <QLPreviewItem>

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse;
+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;

- (NSArray *)childrenAttachments;
- (NSDictionary *)constructSubhierarchyForJSON;

@end
