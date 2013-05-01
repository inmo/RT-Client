//
//  RTCReplyComposerWindowController.m
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <QuickLook/QuickLook.h>
#import <Quartz/Quartz.h>

#import "RTCReplyComposerWindowController.h"
#import "RTCAnimatedCloseWindow.h"
#import "RTCWindowOverlayProgressIndicatorView.h"
#import "RTEngine.h"
#import "RTModels.h"

@implementation RTCReplyComposerAttachmentTableViewCellView
@end


@interface RTCReplyComposerWindowController () <NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@property (nonatomic, strong) IBOutlet NSTextField * ccField;
@property (nonatomic, strong) IBOutlet NSTextField * bccField;
@property (nonatomic, strong) IBOutlet NSTextField * subjectField;
@property (nonatomic, strong) IBOutlet NSTextView * editorView;

@property (nonatomic, strong) RTTicket * ticket;
@property (nonatomic, strong) id keepAlive;

@property (nonatomic, strong) NSMutableArray * attachedFiles;
@property (nonatomic, strong) IBOutlet NSPopover * attachmentsPopover;
@property (nonatomic, strong) IBOutlet NSScrollView * attachmentsScrollView;
@property (nonatomic, strong) IBOutlet NSTableView * attachmentsTableView;

@property (nonatomic, strong) QLPreviewPanel * quickLookPanel;

@property (nonatomic, strong) RTCWindowOverlayProgressIndicatorView * indicator;

@end

@implementation RTCReplyComposerWindowController

- (id)initWithTicket:(RTTicket *)ticket
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])]))
    {
        self.ticket = ticket;
        self.keepAlive = self;
        self.attachedFiles = [NSMutableArray new];
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

- (void)windowDidLoad
{
    [self.subjectField setStringValue:self.ticket.subject];
    [self.editorView setTextContainerInset:NSMakeSize(3, 7)];
    // TODO: Default string
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
    self.indicator = [[RTCWindowOverlayProgressIndicatorView alloc] init];
    [self.indicator showInWindow:self.window];
    
    [[RTEngine sharedEngine] postPlainTextReply:@{
                      RTTicketReplyMessageCCKey: ENSURE_NOT_NIL(self.ccField.stringValue),
                     RTTicketReplyMessageBCCKey: ENSURE_NOT_NIL(self.bccField.stringValue),
                 RTTicketReplyMessageSubjectKey: ENSURE_NOT_NIL(self.subjectField.stringValue),
                    RTTicketReplyMessageBodyKey: ENSURE_NOT_NIL(self.editorView.string)
     } attachments:self.attachedFiles toTicket:self.ticket completion:^(NSError * error) {
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
    NSURL * temporaryAttachmentDirectory = [[[NSURL fileURLWithPath:NSTemporaryDirectory()]
                                             URLByAppendingPathComponent:@"com.inmo.RT-Client" isDirectory:YES]
                                            URLByAppendingPathComponent:[NSString stringWithFormat:@"%p", self] isDirectory:YES];;
    
    NSError * __autoreleasing error = nil; // TODO: Handle this error
    [[NSFileManager defaultManager] createDirectoryAtURL:temporaryAttachmentDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSURL * temporaryURL = [temporaryAttachmentDirectory URLByAppendingPathComponent:[fileURL lastPathComponent]];
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:temporaryURL error:&error];
    
    [self.attachedFiles addObject:temporaryURL];
    [self.attachmentsTableView reloadData];
    [self.quickLookPanel reloadData];
}

- (IBAction)toggleAttachmentList:(id)sender
{
    if (self.attachedFiles.count == 0)
    {
        [self attachFile:sender];
        return;
    }
    
    if (self.attachmentsPopover.isShown)
    {
        [self.attachmentsPopover performClose:sender];
    }
    else
    {    
        NSButton * button = (NSButton *) sender;
        [self.attachmentsPopover showRelativeToRect:button.frame ofView:button preferredEdge:NSMaxYEdge];
    }
}

- (IBAction)attachFile:(id)sender
{
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = YES;
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) [openPanel.URLs enumerateObjectsUsingBlock:^(NSURL * url, NSUInteger idx, BOOL *stop) {
            [self _attachFileInline:url];
        }];
    }];
}

- (void)quickLookAttachment:(id)sender
{
    NSInteger row = [(NSButton *)sender tag];
    
    [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
    [[QLPreviewPanel sharedPreviewPanel] setCurrentPreviewItemIndex:row];
}

- (void)deleteAttachment:(id)sender
{
    NSInteger row = [(NSButton *)sender tag];
    
    [self.attachedFiles removeObjectAtIndex:row];
    [self.attachmentsTableView reloadData];
    [self.quickLookPanel reloadData];
}

#pragma - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.attachedFiles.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    RTCReplyComposerAttachmentTableViewCellView * cell = [tableView makeViewWithIdentifier:@"std" owner:self];
    NSURL * fileURL = self.attachedFiles[row];
    
    id __autoreleasing value = nil;
    NSError * __autoreleasing error = nil;
    [fileURL getResourceValue:&value forKey:NSURLFileSizeKey error:&error];
    
    cell.textField.stringValue = [fileURL lastPathComponent];
    cell.detailTextField.stringValue = [NSByteCountFormatter stringFromByteCount:[value longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    cell.imageView.image = [[NSWorkspace sharedWorkspace] iconForFile:[fileURL path]];
    cell.toolTip = [NSString stringWithFormat:@"%@\n%@", cell.textField.stringValue, cell.detailTextField.stringValue];
    cell.quickLookButton.tag = cell.deleteRowButton.tag = row;
    
    return cell;
}

#pragma mark - QLPreviewPanelDelegate

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel;
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    panel.delegate = self;
    panel.dataSource = self;
    
    self.quickLookPanel = panel;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    self.quickLookPanel = nil;
}

#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return [self.attachedFiles count];
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return (NSURL *) self.attachedFiles[index];
}

@end
