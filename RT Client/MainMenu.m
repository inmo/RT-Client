//
//  MainMenu.m
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "MainMenu.h"

@interface MainMenu ()

@end

@implementation MainMenu

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:(self) selector:(@selector(closeLogin)) userInfo:(self) repeats:NO];
    }
    
    return self;
}
- (IBAction)replier:(id)sender{
    //Make it able to reply to a selected ticket from main receipt
}

- (IBAction)replierAll:(id)sender{
    //Make it able to reply to all party associated with ticket
}

- (IBAction)deleter:(id)sender{
    //Delete the selected ticket *WARNING* add a message box that warns the user does he want to delete ticket.
    
}

- (IBAction)newTicket:(id)sender{
    //The user creates a new blank ticket with multiple features.
}

- (IBAction)ticketLister:(id)sender{
    //The list of all the tickets avaliable in that queue.
}

- (IBAction)ticketMessager:(id)sender{
    //The message is visible by the user.
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
