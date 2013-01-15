//
//  RTCLoginWindowController.m
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTCLoginWindowController.h"

@interface RTCLoginWindowController ()

@end

@implementation RTCLoginWindowController

- (id)init
{
    self = [super initWithWindowNibName: @"RTCLoginWindowController"];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:(self) selector:(@selector(closeLogin)) userInfo:(self) repeats:NO];
    }
    
    
    
    
    return self;
}
- (IBAction)DoLogin:(id)sender{
    NSLog(@"You are logged in");
}

- (IBAction)CloseLoginButton:(id)sender{
    [self close];
    
}

- (IBAction)EnterUsername:(id)sender{
    NSString *user = @"";
    user = username.stringValue;
    //Check for info verification
}

- (IBAction)EnterPassword:(id)sender{
    NSString *pass = @"";
    pass = password.stringValue;
    //Check for info verification
}
    


- (void)windowDidLoad
{
    [super windowDidLoad];

    
    // Implement this method to handle any initialization after your
    // window controller's window has been loaded from its nib file.
}

@end
