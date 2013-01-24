//
//  RTCLoginWindowController.h
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

<<<<<<< HEAD
@interface RTCLoginWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet NSTextField * username;
=======
@interface RTCLoginWindowController : NSWindowController{
    IBOutlet NSButton *login;
    IBOutlet NSButton *close;
    IBOutlet NSTextField *username;
    IBOutlet NSTextField *password;
    
}
>>>>>>> UI

- (IBAction)DoLogin:(id)sender;
- (IBAction)CloseLoginButton:(id)sender;
- (IBAction)EnterUsername:(id)sender;
- (IBAction)EnterPassword:(id)sender;



@end
