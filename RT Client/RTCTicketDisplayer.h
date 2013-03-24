//
//  RTCTicketDisplayer.h
//  RT Client
//
//  Created by CSSE Department on 3/24/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
NSMutableArray *arrayOfData;

@interface RTCTicketDisplayer : NSTableView

-(void) addTicket:(NSString *) from reciver: (NSString *) reciver date: (NSString *) date priority: (NSString *) priority subject: (NSString *) subject body: (NSString *) body;

-(NSString *)formatTextdateWithInt:(double) timeStamp;


-(void) addTicketDatedouble:(NSString *) from reciver: (NSString *) reciver date: (double) date priority: (NSString *) priority subject: (NSString *) subject body: (NSString *) body;



@end
