//
//  RTCTicketCell.h
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTAttachment;
@class WebView;

@interface RTCTicketCell : NSTableCellView

@property (nonatomic, strong) IBOutlet WebView * webView;

- (id)initWithIdentifier:(NSString *)identifier;
- (void)configureWithAttachment:(RTAttachment *)attachment;

@end
