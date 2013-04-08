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
@synthesize otherTickView;

- (void)awakeFromNib;
{
    self.ticketController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
}

#pragma mark - Toolbar Actions

- (IBAction)refreshSelfServiceTickets:(id)sender;
{
    [[RTEngine sharedEngine] refreshSelfServiceQueue];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    
    printf("\n\n\n\n test change\n\n\n\n");
    NSInteger selectedrow= [ticketTableView selectedRow];
    RTCTicketStubTableCellView *selecedcell= [ticketTableView rowViewAtRow:selectedrow makeIfNecessary:NO];
    selectedSubject = [[selecedcell subjectLabel] stringValue];
    selectedBody=[[selecedcell summaryLabel] stringValue];
    selectedDate=[[selecedcell dateLabel] stringValue];
    selectedAuthor= [[selecedcell authorLabel] stringValue];
    [otherTickView reloadData];
   // NSCell selectedCell= [ticketTableView
    
}


@end


@implementation RTCTicketTableController

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
   
    printf("\n\n\n\n test\n\n\n\n");
    RTCTicketCell *newcell;
    newcell= [newcell init];
    [newcell SetTextBody:selectedBody];
    [newcell SetTextdate:selectedDate];
    [newcell SetTextfrom:selectedAuthor];
    [newcell SetTextsubject:selectedSubject];
    
    return newcell;
    
    
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    
    return 3;
}
-(void)RTCTicketTableController:causeUpdate{
    [self reloadData];
}



@end
