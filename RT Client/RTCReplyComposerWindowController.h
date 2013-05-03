//
//  RTCReplyComposerWindowController.h
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTTicket;

@interface RTCReplyComposerAttachmentTableViewCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSTextField * detailTextField;
@property (nonatomic, strong) IBOutlet NSButton * quickLookButton;
@property (nonatomic, strong) IBOutlet NSButton * deleteRowButton;

@end

@interface RTCReplyComposerWindowController : NSWindowController

+ (instancetype)registeredWindowControllerForTicket:(RTTicket *)ticket;
- (id)initWithTicket:(RTTicket *)ticket;

- (IBAction)quickLookAttachment:(id)sender;
- (IBAction)deleteAttachment:(id)sender;

@property (nonatomic, copy) void (^completionBlock)(RTCReplyComposerWindowController * composer, BOOL success);

@end
