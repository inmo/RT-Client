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
    self.errorLabel.hidden = YES;
    [self.progressIndicator startAnimation:nil];
    
    [[RTEngine sharedEngine]
     setUsername:self.usernameField.stringValue
     password:self.passwordField.stringValue
     errorBlock:^{
         self.errorLabel.hidden = NO;
         [self.progressIndicator stopAnimation:nil];
     }];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:))
    {
        if (control == self.usernameField)
            [self.passwordField becomeFirstResponder];
        
        else if (control == self.passwordField)
            [self validateLogin:control];
        
        return YES;
    }
    
    return NO;
}

@end
