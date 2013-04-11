//
//  RTCReplyComposerWindowController.h
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTTicket;

@interface RTCReplyComposerWindowController : NSWindowController

- (id)initWithTicket:(RTTicket *)ticket;

@property (nonatomic, copy) void (^completionBlock)(RTCReplyComposerWindowController * composer, BOOL success);

@end
