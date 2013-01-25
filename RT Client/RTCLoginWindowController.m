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
    self = [super initWithWindowNibName: @"RTCLoginWindowController"];
    if (self) {

    }
    
    
    
    return self;
}

- (IBAction)DoLogin:(id)sender{
    RTEngine * engine = [RTEngine sharedEngine];
    [engine
     setUsername:_username.stringValue
     password:_password.stringValue
     errorBlock:^{
         
     }];
    
 //   _username = nil;
 //   _password = nil;
    
}
    
    


- (IBAction)CloseLoginButton:(id)sender{
    [self close];
    
}

- (IBAction)EnterUsername:(id)sender{
    
}

- (IBAction)EnterPassword:(id)sender{
    
}
    


- (void)windowDidLoad
{
    [super windowDidLoad];

    
    // Implement this method to handle any initialization after your
    // window controller's window has been loaded from its nib file.
}

@end
