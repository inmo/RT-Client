//
//  MainMenu.m
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCSelfServiceWindowController.h"
#import "RTModels.h"
#import "RTEngine.h"
#import "RTCTicketStubTableCellView.h"
#import "RTCTicketCell.h"
#import "RTCAppDelegate.h"

@interface RTCSelfServiceWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet NSArrayController * ticketController;
@property (nonatomic, strong) IBOutlet NSTableView * ticketTableView;
@property (nonatomic, strong) IBOutlet NSTableView * ticketDetailView;

@property (nonatomic, strong) RTTicket * selectedTicket;
@property (nonatomic, strong) NSArray * selectedTicketAttachments;

@end

@implementation RTCSelfServiceWindowController

- (void)awakeFromNib;
{
    self.ticketController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    [self.ticketController addObserver:self forKeyPath:@"selectionIndex" options:NULL context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionIndex"] && object == self.ticketController)
    {
        if (self.ticketController.selectionIndex == NSNotFound)
            return;
        
        self.selectedTicket = self.ticketController.arrangedObjects[self.ticketController.selectionIndex];
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        [self.ticketDetailView reloadData];
        
        return;
    }
    
    if ([keyPath isEqualToString:@"attachments"] && object == self.selectedTicket)
    {
        if (self.ticketController.selectionIndex == NSNotFound)
            return;
        
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        
        [self.ticketDetailView reloadData];
        [self.ticketTableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:self.ticketController.selectionIndex]
                                        columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Setters & Getters

- (void)setSelectedTicket:(RTTicket *)selectedTicket
{
    [self.selectedTicket removeObserver:self forKeyPath:@"attachments"];
    
    if ((self->_selectedTicket = selectedTicket))
        [self.selectedTicket addObserver:self forKeyPath:@"attachments" options:NULL context:NULL];
}

#pragma mark - Toolbar Actions

- (IBAction)refreshSelfServiceTickets:(id)sender;
{
    [[RTEngine sharedEngine] refreshSelfServiceQueue];
}

- (IBAction)replyToSelectedTicket:(id)sender
{
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openReplyComposerForTicket:self.selectedTicket];
}

#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.selectedTicketAttachments.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    static NSString * const TicketCellIdentifier = @"ticketCell";
    
    RTCTicketCell * cell = [tableView makeViewWithIdentifier:TicketCellIdentifier owner:self];
    cell = (cell) ?: [[RTCTicketCell alloc] initWithIdentifier:TicketCellIdentifier];
    
    [cell configureWithAttachment:self.selectedTicketAttachments[row]];
    
    return cell;
}

@end
