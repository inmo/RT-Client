//
//  RTAttachment+Extensions.h
//  RT Client
//
//  Created by James Savage on 2/3/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTAttachment.h"

@interface RTAttachment (Extensions)

+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse;
+ (RTAttachment *)createAttachmentFromAPIResponse:(NSDictionary *)apiResponse inContext:(NSManagedObjectContext *)context;

- (NSArray *)childrenAttachments;

@end
