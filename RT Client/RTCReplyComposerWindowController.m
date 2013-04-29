//
//  RTCReplyComposerWindowController.m
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "RTCReplyComposerWindowController.h"
#import "RTCAnimatedCloseWindow.h"
#import "RTCWindowOverlayProgressIndicatorView.h"
#import "RTEngine.h"
#import "RTModels.h"


@interface RTCReplyComposerWindowController () <NSTextViewDelegate>

@property (nonatomic, strong) IBOutlet NSTextField * ccField;
@property (nonatomic, strong) IBOutlet NSTextField * bccField;
@property (nonatomic, strong) IBOutlet NSTextField * subjectField;
@property (nonatomic, strong) IBOutlet WebView * webView;

@property (nonatomic, strong) RTTicket * ticket;
@property (nonatomic, strong) id keepAlive;

@property (nonatomic, strong) RTCWindowOverlayProgressIndicatorView * indicator;

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

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (NSString *)editorHTMLString
{
    static NSString * editorBaseString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // external symbols generated via custom build rule and xxd
        extern unsigned char RTCReplyComposerEditor_html[];
        extern unsigned int RTCReplyComposerEditor_html_len;
        
        editorBaseString = [[NSString alloc] initWithBytesNoCopy:RTCReplyComposerEditor_html
                                                          length:RTCReplyComposerEditor_html_len
                                                        encoding:NSUTF8StringEncoding freeWhenDone:NO];
    });
    
    return [editorBaseString stringByReplacingOccurrencesOfString:@"${INITIAL_EDITOR_CONTENTS}"
                                                       withString:@""]; // [self.ticket HTMLStringForReplyComposer]
}

- (void)windowDidLoad
{
    [self.subjectField setStringValue:self.ticket.subject];
    [[self.webView mainFrame] loadHTMLString:[self editorHTMLString] baseURL:nil];
}

#pragma mark - WebViewFrameDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [sender stringByEvaluatingJavaScriptFromString:@"document.body.focus();"];
}

#pragma mark - Custom Appearance Methods

- (void)_updateWindowTitle
{
    BOOL isValidTitle = ![@"" isEqualToString:self.subjectField.stringValue];
    self.window.title = (isValidTitle) ? self.subjectField.stringValue : @"(No Subject)";
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
    NSMutableDictionary * params = [NSMutableDictionary new];
    void (^setParam)(NSString *, NSTextField *) = ^(NSString * key, NSTextField * field) {
        if (![@"" isEqualToString:field.stringValue])
            params[key] = field.stringValue;
    };
    
    setParam(@"cc", self.ccField);
    setParam(@"bcc", self.bccField);
    setParam(@"subject", self.subjectField);
    
    params[@"body"] = [self.webView stringByEvaluatingJavaScriptFromString:@"$editor.getContent();"];
    
    self.indicator = [[RTCWindowOverlayProgressIndicatorView alloc] init];
    [self.indicator showInWindow:self.window];
    
    [[RTEngine sharedEngine] postReply:params toTicket:self.ticket completion:^(NSError * error) {
        if (error)
        {
            [self.indicator removeFromSuperview];
            [[NSAlert alertWithError:error] beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
            return;
        }
        
        [(RTCAnimatedCloseWindow *)self.window orderOutWithAnimation:self];
    }];
}

- (void)_attachFileInline:(NSURL *)fileURL
{
    // TODO: Copy to temp directory
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
