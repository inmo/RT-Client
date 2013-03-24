//
//  RTCTicketDisplayer.m
//  RT Client
//
//  Created by CSSE Department on 3/24/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketDisplayer.h"

@implementation RTCTicketDisplayer

-(void) addTicket:(NSString *) from reciver: (NSString *) reciver date: (NSString *) date priority: (NSString *) priority subject: (NSString *) subject body: (NSString *) body{
    NSMutableArray *temp;
    temp=[temp init];
    [temp addObject:from];
    [temp addObject:reciver];
    [temp addObject:date];
    [temp addObject:priority];
    [temp addObject:subject];
    [temp addObject:body];
    
    [arrayOfData addObject:temp];
    
}

-(NSString *)formatTextdateWithInt:(double) timeStamp{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDate *today=[NSDate date];
    NSDateComponents *dateComponents = [calendar components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
    today = [calendar dateFromComponents:dateComponents];
    
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    [myFormatter setDateFormat:@"MMM/dd/yyyy"];
    return [myFormatter stringFromDate:date];
    
}

-(void) addTicketDatedouble:(NSString *) from reciver: (NSString *) reciver date: (double) date priority: (NSString *) priority subject: (NSString *) subject body: (NSString *) body{
    NSString * temp= [self formatTextdateWithInt:date];
    [self addTicket:from reciver: reciver date: temp priority:  priority subject:  subject body: body];
    
}




@end
