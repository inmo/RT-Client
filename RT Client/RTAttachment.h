//
//  RTAttachment.h
//  RT Client
//
//  Created by James Savage on 5/2/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RTTicket;

@interface RTAttachment : NSManagedObject

@property (nonatomic, retain) NSNumber * attachmentID;
@property (nonatomic, retain) NSData * content;
@property (nonatomic, retain) NSString * contentEncoding;
@property (nonatomic, retain) NSString * contentType;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * creator;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) id headers;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSNumber * parent;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * transaction;
@property (nonatomic, retain) NSString * contentPath;
@property (nonatomic, retain) RTTicket *ticket;

@end
