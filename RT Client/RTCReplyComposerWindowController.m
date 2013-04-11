//
//  RTCReplyComposerWindowController.m
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "RTCReplyComposerWindowController.h"
#import "RTModels.h"

@interface RTCReplyComposerWindowController ()

@property (nonatomic, strong) IBOutlet NSTextField * ccField;
@property (nonatomic, strong) IBOutlet NSTextField * bccField;
@property (nonatomic, strong) IBOutlet NSTextField * subjectField;
@property (nonatomic, strong) IBOutlet NSTextView * composerView;
@property (nonatomic, strong) IBOutlet WebView * webView;

@property (nonatomic, strong) RTTicket * ticket;
@property (nonatomic, strong) id keepAlive;

@end

@implementation RTCReplyComposerWindowController

- (id)initWithTicket:(RTTicket *)ticket
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])]))
    {
        self.ticket = ticket;
        self.keepAlive = self;
    }
    
    return self;
}

- (void)awakeFromNib
{
    self.composerView.textContainerInset = NSMakeSize(10, 10);
}

- (void)windowDidLoad
{
    [self.subjectField setStringValue:self.ticket.subject];
    [[self.composerView textStorage] setAttributedString:[self.ticket stringForReplyComposer]];
    
    NSString * css = @"body { font-family: sans-serif; }"
                     @"blockquote { margin-left: 0; padding-left: 15px; border-left: 2px solid blue; color: blue; }"
                     @"blockquote blockquote { border-color: green; color: green; }"
                     @"blockquote blockquote blockquote { border-color: red; color: red; }";
    NSString * editorString = [NSString stringWithFormat:
                               @"<html><head><style>%@</style></head>"
                               @"<body contenteditable=true><p>&nbsp;</p>%@</body></html>",
                               css, [self.ticket HTMLStringForReplyComposer]];
    [[self.webView mainFrame] loadHTMLString:editorString baseURL:nil];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.keepAlive = nil;
}

#pragma mark - Composer Actions

- (IBAction)sendDraft:(id)sender
{
    
}

@end
