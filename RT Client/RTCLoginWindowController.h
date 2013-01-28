//
//  RTCLoginWindowController.h
//  RT Client
//
//  Created by CSSE Department on 12/19/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTCLoginWindowController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, strong) IBOutlet NSButton * loginButton;
@property (nonatomic, strong) IBOutlet NSTextField * usernameField;
@property (nonatomic, strong) IBOutlet NSTextField * passwordField;

@property (nonatomic, strong) IBOutlet NSTextField * errorLabel;
@property (nonatomic, strong) IBOutlet NSProgressIndicator * progressIndicator;

- (IBAction)validateLogin:(id)sender;

@end
