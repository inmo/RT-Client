//
//  RTCLoginWindowController.m
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTCLoginWindowController.h"
#import "RTEngine.h"

@interface RTCLoginWindowController ()

@end

@implementation RTCLoginWindowController

- (id)init
{
    if ((self = [super initWithWindowNibName:@"RTCLoginWindowController"]))
    {

    }
    
    return self;
}

- (void)validateLogin:(id)sender
{
    [[RTEngine sharedEngine]
     setUsername:self.usernameField.stringValue
     password:self.passwordField.stringValue
     errorBlock:^{
         self.errorLabel.hidden = NO;
     }];
}

@end
