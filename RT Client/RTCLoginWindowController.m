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
    return [super initWithWindowNibName:@"RTCLoginWindowController"];
}

- (void)windowDidLoad
{
    self.window.preventsApplicationTerminationWhenModal = NO;
}

- (void)validateLogin:(id)sender
{
    // Setup window for logging in
    self.errorLabel.hidden = YES;
    [self.progressIndicator startAnimation:nil];
    
    // Verify login
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
    // Hijack the newline selector
    if (commandSelector == @selector(insertNewline:))
    {
        // Jump from the username field to password field
        if (control == self.usernameField)
            [self.passwordField becomeFirstResponder];
        
        // Try login, just like clicking the "Sign In" button
        else if (control == self.passwordField)
            [self validateLogin:control];
        
        return YES;
    }
    
    return NO;
}

@end
