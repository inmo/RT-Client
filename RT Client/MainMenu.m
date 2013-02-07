//
//  MainMenu.m
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "MainMenu.h"
#import "RTCTicketCellView.h"
#import "RTModels.h"

@interface MainMenu ()

@end

@implementation MainMenu

- (void)awakeFromNib;
{
<<<<<<< HEAD
    self.ticketController.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES] ];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.ticketController.arrangedObjects count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
=======
    self = [super initWithWindow:window];
    NSObject *ticket = nil;
    if (self) {
       
    }
    
    return self;
}
-(void)ticketList:(NSDictionary)

- (void)replier:(id)sender{
    //Make it able to reply to a selected ticket from main receipt
    
}

- (void)replierAll:(id)sender{
    //Make it able to reply to all party associated with ticket
}

- (void)deleter:(id)sender{
    //Delete the selected ticket *WARNING* add a message box that warns the user does he want to delete ticket.
    
}

- (void)newTicket:(id)sender{
    //The user creates a new blank ticket with multiple features.
}


- (void)windowDidLoad
>>>>>>> Synching
{
    RTCTicketCellView * result = (RTCTicketCellView *)[tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    RTTicket * ticket = [self.ticketController.arrangedObjects objectAtIndex:row];
    
    result.authorLabel.stringValue = ticket.owner;
    result.dateLabel.stringValue = ticket.stringFromCreated;
    result.subjectLabel.stringValue = ticket.subject;
    result.summaryLabel.stringValue = ticket.plainTextSummary;
    return result;
}

@end
