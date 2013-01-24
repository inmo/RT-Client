//
//  MainMenu.h
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainMenu : NSWindowController{
    
}
@property(nonatomic,strong) NSToolbarItem *reply;
@property(nonatomic,strong) NSToolbarItem *replyToAll;
@property(nonatomic,strong) NSToolbarItem *deleiteIt;
@property(nonatomic,strong) NSToolbarItem *createNew;
@property(nonatomic,strong) NSScrollView *tickerList;
@property(nonatomic,strong) NSScrollView *ticketMessage;

- (IBAction)Replier:(id)sender;
- (IBAction)ReplierAll:(id)sender;
- (IBAction)Deleter:(id)sender;
- (IBAction)NewTicket:(id)sender;
- (IBAction)TicketLister:(id)sender;
- (IBAction)TicketMessager:(id)sender;


@end
