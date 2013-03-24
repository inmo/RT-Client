//
//  RTCTicketCell.h
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString *displayText;
NSString *BodyText;
NSString *from;
NSString *reciver;
NSString *dateText;
NSString *priority;
NSString *subject;


@interface RTCTicketCell : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField * tableText;

-(void)SetTextBody:(NSString*) newText;
-(void)SetTextfrom:(NSString*) newText;
-(void)SetTextreciver:(NSString*) newText;
-(void)SetTextdate:(NSString*) newText;
-(void)SetTextpriority:(NSString*) newText;
-(void)SetTextsubject:(NSString*) newText;

-(void)UpdateDisplayText;
-(NSString *)getText;

@end
