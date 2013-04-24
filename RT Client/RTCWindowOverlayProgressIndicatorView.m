//
//  RTCWindowOverlayProgressIndicatorView.m
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCWindowOverlayProgressIndicatorView.h"

@interface RTCWindowOverlayProgressIndicatorView ()

@property (nonatomic, strong) NSProgressIndicator * indicator;
@property (nonatomic, strong) NSTextField * textView;

@property (nonatomic, weak) NSWindow * presentingWindow;

@end

@implementation RTCWindowOverlayProgressIndicatorView

- (id)init
{
    if ((self = [super init]))
    {
        self.indicator = [[NSProgressIndicator alloc] init];
        [self.indicator setStyle:NSProgressIndicatorSpinningStyle];
        [self.indicator setIndeterminate:YES];
        [self.indicator startAnimation:self];
        [self addSubview:self.indicator];
        
        self.textView = [[NSTextField alloc] init];
        [self.textView setEditable:NO];
        [self.textView setBordered:NO];
        [self.textView setStringValue:@"Sending…"];
        [self.textView setTextColor:[NSColor blackColor]];
        [self.textView setFont:[NSFont boldSystemFontOfSize:25.0]];
        [self addSubview:self.textView];
    }
    
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSWindow * window = [self window];
    NSPoint where = [window convertBaseToScreen:[theEvent locationInWindow]];
    NSPoint origin = [window frame].origin;
    
    while ((theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDownMask|NSLeftMouseDraggedMask|NSLeftMouseUpMask
                                          untilDate:[NSDate distantFuture]
                                             inMode:NSEventTrackingRunLoopMode
                                            dequeue:YES])
           && ([theEvent type] != NSLeftMouseUp))
    {
        NSPoint now = [window convertBaseToScreen:[theEvent locationInWindow]];
        origin.x += now.x - where.x;
        origin.y += now.y - where.y;
        
        [window setFrameOrigin:origin];
        where = now;
    }
}

- (void)showInWindow:(NSWindow *)window;
{
    self.presentingWindow = window;
    [self layoutSubtreeIfNeeded];
    
    self.alphaValue = 0.0;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * context) {
        [context setDuration:0.25];
        [[self animator] setAlphaValue:1.0];
    } completionHandler:nil];
}

- (void)setPresentingWindow:(NSWindow *)presentingWindow
{
    if (self.presentingWindow)
    {
        [[_presentingWindow standardWindowButton:NSWindowZoomButton] setEnabled:YES];
        [_presentingWindow setShowsResizeIndicator:YES];
        [_presentingWindow setResizeIncrements:NSMakeSize(1, 1)];
        
        [self removeFromSuperview];
    }
    
    _presentingWindow = presentingWindow;
    self.frame = [[_presentingWindow.contentView superview] frame];
    
    [[_presentingWindow standardWindowButton:NSWindowZoomButton] setEnabled:NO];
    [_presentingWindow setShowsResizeIndicator:NO];
    [_presentingWindow setResizeIncrements:NSMakeSize(MAXFLOAT, MAXFLOAT)];
    
    [[_presentingWindow.contentView superview] addSubview:self];
}

- (void)layoutSubtreeIfNeeded
{
    [self.indicator sizeToFit];
    [self.textView sizeToFit];
    
    CGFloat intraSpacing = 10.0;
    CGFloat totalWidth = self.indicator.frame.size.width + self.textView.frame.size.width + intraSpacing;
    CGFloat baseXOffset = (self.frame.size.width - totalWidth) / 2;
    
    [self.indicator setFrameOrigin:NSMakePoint(baseXOffset, (self.frame.size.height - self.indicator.frame.size.height) / 2)];
    [self.textView setFrameOrigin:NSMakePoint(baseXOffset + intraSpacing + self.indicator.frame.size.width,
                                              (self.frame.size.height - self.textView.frame.size.height) / 2)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor redColor] setFill];
    
    const CGFloat locations[] = { 0.0, 2.0 };
    NSGradient * gradient = [[NSGradient alloc] initWithColors:@[[[NSColor whiteColor] colorWithAlphaComponent:0.75],
                                                                 [[NSColor whiteColor] colorWithAlphaComponent:0.25]]
                                                   atLocations:locations
                                                    colorSpace:[NSColorSpace genericRGBColorSpace]];
    
    [gradient drawInRect:self.frame relativeCenterPosition:NSMakePoint(0.0, 0.0)];
}

@end
