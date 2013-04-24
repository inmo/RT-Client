//
//  RTCAnimatedCloseWindow.m
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "RTCAnimatedCloseWindow.h"

@implementation RTCAnimatedCloseWindow {
    BOOL _isAnimating;
}

- (void)orderOutWithAnimation:(id)sender
{
    if (_isAnimating)
        return;
    
    [self setIgnoresMouseEvents:YES];
    
    _isAnimating = YES;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * context) {
        [context setDuration:0.25];
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        
        NSScreen * screen = [NSScreen screens][0];
        CGRect offscreenRect = CGRectOffset(self.frame, 0, screen.frame.size.height);
        [[self animator] setFrame:offscreenRect display:YES];
    } completionHandler:^{
        [super orderOut:sender];
    }];
}

// Default implementation does not allow windows to be positioned above the menu
// bar. We want to disable this so the window can be aniamted offscreen.
- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen
{
    return frameRect;
}

@end