//
//  RTCErrorMessage.m
//  RT Client
//
//  Created by CSSE Department on 1/24/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCErrorMessage.h"

@interface RTCErrorMessage ()

@end

@implementation RTCErrorMessage

- (id) initWithWindow: (NSWindow *) window
{
    self = [super initWithWindow:window];
    if (self){
        
    }
    
    return self;
}

-(IBAction) closeErrorMessage:(id)sender{
    [self close];
}
-(void)windowDidLoad
{
    [super windowDidLoad];
    
    
}

@end