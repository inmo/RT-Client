//
//  MainMenu.h
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainMenu : NSWindowController{
    IBOutlet NSToolbarItem *reply;
    IBOutlet NSToolbarItem *replyToAll;
    IBOutlet NSToolbarItem *deleteIt;
    IBOutlet NSToolbarItem *createNew;
    IBOutlet NSScrollView *ticketList;
    IBOutlet NSScrollView *ticketMessage;
}

- (IBAction)Replier:(id)sender;
- (IBAction)ReplierAll:(id)sender;
- (IBAction)Deleter:(id)sender;
- (IBAction)NewTicket:(id)sender;
- (IBAction)TicketLister:(id)sender;
- (IBAction)TicketMessager:(id)sender;


@end
