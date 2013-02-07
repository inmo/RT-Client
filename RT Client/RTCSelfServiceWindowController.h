//
//  MainMenu.h
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTCSelfServiceWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet NSArrayController * ticketController;
@property (nonatomic, strong) IBOutlet NSTableView * ticketTableView;

- (IBAction)refreshSelfServiceTickets:(id)sender;

@end
