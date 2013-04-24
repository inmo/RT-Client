//
//  RTCTicketDetailWindowController.m
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketDetailWindowController.h"
#import "RTCTicketCell.h"
#import "RTModels.h"

@interface RTCTicketDetailWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet NSTableView * ticketDetailView;

@property (nonatomic, strong) NSArray * selectedTicketAttachments;

@end

@implementation RTCTicketDetailWindowController

- (id)init
{
    return [super initWithWindowNibName:NSStringFromClass([self class])];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"attachments"] && object == self.selectedTicket)
    {
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        [self.ticketDetailView reloadData];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setSelectedTicket:(RTTicket *)selectedTicket
{
    [self.selectedTicket removeObserver:self forKeyPath:@"attachments"];
    
    if ((self->_selectedTicket = selectedTicket))
    {
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        [self.selectedTicket addObserver:self forKeyPath:@"attachments" options:NULL context:NULL];
    }
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
