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

@interface RTCSelfServiceWindowController () <NSTableViewDelegate>

@end

@implementation RTCSelfServiceWindowController

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

@end
