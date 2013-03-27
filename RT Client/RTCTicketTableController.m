//
//  RTCTicketTableController.m
//  RT Client
//
//  Created by CSSE Department on 3/26/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketTableController.h"

@implementation RTCTicketTableController


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    if ([aTableColumn value]!=0) {
        return NULL;
    }
    
    return [cellData objectAtIndex:rowIndex];
    
    
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
