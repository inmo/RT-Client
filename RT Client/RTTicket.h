//
//  RTTicket.h
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RTTicket : NSManagedObject

@property (nonatomic, retain) NSString * adminCC;
@property (nonatomic, retain) NSString * cc;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * creator;
@property (nonatomic, retain) NSNumber * finalPriority;
@property (nonatomic, retain) NSNumber * initialPriority;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * queue;
@property (nonatomic, retain) NSString * requestors;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * timeEstimated;
@property (nonatomic, retain) NSNumber * timeLeft;
@property (nonatomic, retain) NSNumber * timeWorked;
@property (nonatomic, retain) NSString * ticketID;

@end
