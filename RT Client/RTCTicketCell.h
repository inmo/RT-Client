//
//  RTCTicketCell.h
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTAttachment;

@interface RTCTicketCell : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField * descriptionLabel;

- (id)initWithIdentifier:(NSString *)identifier;

- (void)configureWithAttachment:(RTAttachment *)attachment;

@end
