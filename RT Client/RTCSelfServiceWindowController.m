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

@interface RTCSelfServiceWindowController () <NSTableViewDelegate>

@end

@implementation RTCSelfServiceWindowController

@synthesize ticketTableView;

- (void)awakeFromNib;
{
    self.ticketController.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES] ];
}

#pragma mark - Toolbar Actions

- (IBAction)refreshSelfServiceTickets:(id)sender;
{
    if (![RTEngine.sharedEngine isAuthenticated])
        return;
    
    [RTEngine.sharedEngine fetchSelfServiceTicketStubs:^{
        NSError * __autoreleasing error = nil;
        [self.ticketController fetchWithRequest:nil merge:NO error:&error];
        [self.ticketTableView reloadData];
        
        [RTTicket.MR_findAll enumerateObjectsUsingBlock:^(RTTicket * ticket, NSUInteger idx, BOOL *stop) {
            [RTEngine.sharedEngine pullTicketInformation:ticket.objectID completion:^{
                NSError * __autoreleasing error = nil;
                [self.ticketController fetchWithRequest:nil merge:NO error:&error];
                [self.ticketTableView reloadData];
            }];
        }];
    }];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    NSInteger selectedrow= [ticketTableView selectedRow];
    RTCTicketStubTableCellView *selecedcell= [ticketTableView rowViewAtRow:selectedrow makeIfNecessary:NO];
    selectedSubject = [[selecedcell subjectLabel] stringValue];
    selectedBody=[[selecedcell summaryLabel] stringValue];
    selectedDate=[[selecedcell dateLabel] stringValue];
    selectedAuthor= [[selecedcell authorLabel] stringValue];
    
   // NSCell selectedCell= [ticketTableView
    
}


@end


@implementation RTCTicketTableController


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    if ([aTableColumn value]!=0) {
        return NULL;
    }
    RTCTicketCell *newcell;
    newcell= [newcell init];
    [newcell SetTextBody:selectedBody];
    [newcell SetTextdate:selectedDate];
    [newcell SetTextfrom:selectedAuthor];
    [newcell SetTextsubject:selectedSubject];
    
    return newcell;
    
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    
    return 1;
}



@end
