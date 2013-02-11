//
//  RTCTicketStubTableCellView.h
//  RT Client
//
//  Created by James Savage on 2/11/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RTCTicketStubTableCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField * authorLabel;
@property (nonatomic, strong) IBOutlet NSTextField * dateLabel;
@property (nonatomic, strong) IBOutlet NSTextField * subjectLabel;
@property (nonatomic, strong) IBOutlet NSTextField * summaryLabel;

@end
