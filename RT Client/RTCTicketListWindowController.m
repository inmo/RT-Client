//
//  MainMenu.m
//  RT Client
//
//  Created by CSSE Department on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketListWindowController.h"
#import "RTCTicketDetailWindowController.h"
#import "RTCAppDelegate.h"
#import "RTModels.h"
#import "RTEngine.h"

@interface RTCTicketListWindowController ()

@property (nonatomic, strong) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, strong) IBOutlet NSArrayController * ticketController;
@property (nonatomic, strong) IBOutlet NSTableView * ticketTableView;

@property (nonatomic, strong) RTTicket * selectedTicket;
@property (nonatomic, strong) RTCTicketDetailWindowController * ticketDetailWindowController;
@property (nonatomic, strong) IBOutlet NSSplitView * splitView;

@end

@implementation RTCTicketListWindowController

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (id)init
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])]))
    {
        self.ticketDetailWindowController = [[RTCTicketDetailWindowController alloc] init];
    }
    
    return self;
}

- (void)awakeFromNib;
{
    self.ticketController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
    [self.ticketController addObserver:self forKeyPath:@"selectionIndex" options:NULL context:NULL];
    
    [self.ticketTableView setDoubleAction:@selector(doubleClicked:)];
    
    [self.splitView.subviews.lastObject removeFromSuperview];
    [self.splitView addSubview:self.ticketDetailWindowController.window.contentView];
    [self.splitView adjustSubviews];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectionIndex"] && object == self.ticketController)
    {
        if (self.ticketController.selectionIndex == NSNotFound)
            return;
        
        self.selectedTicket = self.ticketController.arrangedObjects[self.ticketController.selectionIndex];
        [self.ticketDetailWindowController setSelectedTicket:self.selectedTicket];
        
        return;
    }
    
    if ([keyPath isEqualToString:@"attachments"] && object == self.selectedTicket)
    {
        if (self.ticketController.selectionIndex == NSNotFound)
            return;
        
        [self.ticketTableView reloadDataForRowIndexes:[self.ticketTableView selectedRowIndexes]
                                        columnIndexes:[self.ticketTableView selectedColumnIndexes]];
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)doubleClicked:(NSTableView *)sender
{
    RTTicket * clickedTicket = self.ticketController.arrangedObjects[[sender clickedRow]];
    
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openDetailForTicket:clickedTicket];
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

@end
