//
//  MainMenu.h
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#pragma mark RTCTicketTableController DataSorce

@interface RTCSelfServiceWindowController : NSWindowController

@property (nonatomic, strong) IBOutlet NSArrayController * ticketController;
@property (nonatomic, strong) IBOutlet NSTableView * ticketTableView;
@property (nonatomic, strong) IBOutlet NSTableView * otherTickView;


- (IBAction)refreshSelfServiceTickets:(id)sender;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end


NSString *selectedAuthor;
NSString *selectedDate;
NSString *selectedSubject;
NSString *selectedBody;

@interface RTCTicketTableController : NSTableView


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
-(void)RTCTicketTableController:causeUpdate;



@end
