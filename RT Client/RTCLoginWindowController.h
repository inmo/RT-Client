//
//  RTCLoginWindowController.h
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTCLoginWindowController : NSWindowController{
     
    
}
@property(nonatomic,strong) NSButton *login;
@property(nonatomic,strong) NSButton *close;
@property(nonatomic,strong) NSTextField *username;
@property(nonatomic,strong) NSTextField *password;

- (IBAction)DoLogin:(id)sender;
- (IBAction)CloseLoginButton:(id)sender;
- (IBAction)EnterUsername:(id)sender;
- (IBAction)EnterPassword:(id)sender;



@end