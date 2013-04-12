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

@interface RTCReplyComposerWindowController () <NSTextViewDelegate>

@property (nonatomic, strong) IBOutlet NSTextField * ccField;
@property (nonatomic, strong) IBOutlet NSTextField * bccField;
@property (nonatomic, strong) IBOutlet NSTextField * subjectField;
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

- (void)showWindow:(id)sender
{
    [self _updateWindowTitle];
    [super showWindow:sender];
}

- (void)windowDidLoad
{
    [self.subjectField setStringValue:self.ticket.subject];
    
    NSString * css = @"body { font-family: sans-serif; }"
    @"blockquote { margin-left: 0; padding-left: 15px; border-left: 2px solid blue; color: blue; }"
    @"blockquote blockquote { border-color: green; color: green; }"
    @"blockquote blockquote blockquote { border-color: red; color: red; }";
    
    NSString * editorString = [NSString stringWithFormat:
                               @"<html><head><style>%@</style></head>"
                               @"<body contenteditable=true><p></p><br>%@</body></html>",
                               css, [self.ticket HTMLStringForReplyComposer]];
    
    [[self.webView mainFrame] loadHTMLString:editorString baseURL:nil];
}

#pragma mark - Custom Appearance Methods

- (void)_updateWindowTitle
{
    BOOL isValidTitle = ![@"" isEqualToString:self.subjectField.stringValue];
    self.window.title = (isValidTitle) ? self.subjectField.stringValue : @"New Reply";
}

#pragma mark - NSTextViewDelegate

- (void)controlTextDidChange:(NSNotification *)note;
{
    if (note.object != self.subjectField)
        return;
    
    [self _updateWindowTitle];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.keepAlive = nil;
}

#pragma mark - Composer Actions

- (IBAction)sendDraft:(id)sender
{
    // TODO: Interface with RTEngine
    // TODO: Define async wait interface for composer window
}

- (void)_attachFileInline:(NSURL *)fileURL
{
    // TODO: Keep track of inserted attachments
    // TODO: Monitor DOM for attachment deletion
}

- (IBAction)attachFile:(id)sender
{
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = YES;
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton)
            [self _attachFileInline:openPanel.URL];
    }];
}

@end
