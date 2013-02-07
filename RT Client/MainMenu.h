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
@property (nonatomic,strong) IBOutlet NSToolbarItem *reply;
@property (nonatomic,strong) IBOutlet NSToolbarItem *replyToAll;
@property (nonatomic,strong) IBOutlet NSToolbarItem *deleiteIt;
@property (nonatomic,strong) IBOutlet NSToolbarItem *createNew;
@property (nonatomic,strong) IBOutlet NSScrollView *tickerList;
@property (nonatomic,strong) IBOutlet NSScrollView *ticketMessage;

@property (nonatomic, strong) IBOutlet NSArrayController * ticketController;
@property (nonatomic, strong) IBOutlet NSTableView * ticketTableView;

- (IBAction)replier:(id)sender;
- (IBAction)replierAll:(id)sender;
- (IBAction)deleter:(id)sender;
- (IBAction)newTicket:(id)sender;



@end
