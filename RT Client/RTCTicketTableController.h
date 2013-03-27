//
//  RTCTicketTableController.h
//  RT Client
//
//  Created by CSSE Department on 3/26/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSMutableArray *cellData;

@interface RTCTicketTableController : NSTableView

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;




@end
