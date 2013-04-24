//
//  RTCAppDelegate.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTTicket;

@interface RTCAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, assign, readonly) BOOL canLogout;

- (IBAction)logout:(id)sender;
- (IBAction)showSelfServiceQueue:(id)sender;

- (void)openReplyComposerForTicket:(RTTicket *)ticket;
- (void)openDetailForTicket:(RTTicket *)ticket;

@end
