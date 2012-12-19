//
//  RTCLoginWindowController.h
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RTCLoginWindowController : NSWindowController{
    IBOutlet NSButton *login;
    
    
}

- (IBAction)DoLogin:(id)sender;
- (IBAction)closeLoginButton:(id)sender;



@end
