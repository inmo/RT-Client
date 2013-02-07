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
    self.ticketController.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES] ];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.ticketController.arrangedObjects count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
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
