//
//  RTCTicketDetailWindowController.h
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTTicket;

@interface RTCTicketDetailWindowController : NSWindowController

@property (nonatomic, strong) RTTicket * selectedTicket;

- (id)initWithTicket:(RTTicket *)ticket;

@end
