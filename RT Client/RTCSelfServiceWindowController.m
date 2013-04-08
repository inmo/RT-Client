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
    self.ticketController.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES]];
}

#pragma mark - Toolbar Actions

- (IBAction)refreshSelfServiceTickets:(id)sender;
{
    [[RTEngine sharedEngine] refreshSelfServiceQueue];
}

@end
