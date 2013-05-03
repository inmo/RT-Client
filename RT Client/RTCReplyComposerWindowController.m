//
//  RTCReplyComposerWindowController.m
//  RT Client
//
//  Created by James Savage on 4/10/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <Quartz/Quartz.h>

#import "RTCReplyComposerWindowController.h"
#import "RTCAppDelegate.h"
#import "RTCAnimatedCloseWindow.h"
#import "RTCWindowOverlayProgressIndicatorView.h"
#import "RTEngine.h"
#import "RTModels.h"

// TODO: Add "refresh this ticket" logic
// TODO: Add debug logging

@implementation RTCReplyComposerAttachmentTableViewCellView {
    NSURL * _fileURL;
}

- (void)_configureCellIconWithFileURL:(NSURL *)fileURL
{
    self.imageView.image = nil;
    _fileURL = fileURL;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
        CGImageRef iconPreview = QLThumbnailImageCreate(kCFAllocatorDefault, (__bridge CFURLRef)(fileURL), self.imageView.frame.size, NULL);
        NSImage * icon = (iconPreview) ? [[NSImage alloc] initWithCGImage:iconPreview size:NSZeroSize] : [[NSWorkspace sharedWorkspace] iconForFile:[fileURL path]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_fileURL == fileURL)
                self.imageView.image = icon;
        });
    });
}

- (void)configureCellWithFileURL:(NSURL *)fileURL atRow:(NSInteger)row;
{
    id __autoreleasing value = nil;
    NSError * __autoreleasing error = nil;
    [fileURL getResourceValue:&value forKey:NSURLFileSizeKey error:&error];
    
    self.textField.stringValue = [fileURL lastPathComponent];
    self.detailTextField.stringValue = [NSByteCountFormatter stringFromByteCount:[value longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    [self _configureCellIconWithFileURL:fileURL];
    
    self.toolTip = [NSString stringWithFormat:@"%@\n%@", self.textField.stringValue, self.detailTextField.stringValue];
    self.quickLookButton.tag = self.deleteRowButton.tag = row;
}

@end


@interface RTCReplyComposerWindowController () <NSTableViewDataSource, NSTableViewDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@property (nonatomic, strong) IBOutlet NSTextField * ccField;
@property (nonatomic, strong) IBOutlet NSTextField * bccField;
@property (nonatomic, strong) IBOutlet NSTextView * editorView;

@property (nonatomic, strong) RTTicket * ticket;

@property (nonatomic, strong) NSMutableArray * attachedFiles;
@property (nonatomic, strong) IBOutlet NSPopover * attachmentsPopover;
@property (nonatomic, strong) IBOutlet NSScrollView * attachmentsScrollView;
@property (nonatomic, strong) IBOutlet NSTableView * attachmentsTableView;

@property (nonatomic, strong) QLPreviewPanel * quickLookPanel;

@property (nonatomic, strong) RTCWindowOverlayProgressIndicatorView * indicator;

@end

@implementation RTCReplyComposerWindowController

static NSMutableDictionary * __registeredTicketReplyComposerWindows = nil;

+ (void)initialize
{
    __registeredTicketReplyComposerWindows = [NSMutableDictionary new];
}

+ (instancetype)registeredWindowControllerForTicket:(RTTicket *)ticket;
{
    if (!ticket)
        return nil;
    
    RTCReplyComposerWindowController * result = __registeredTicketReplyComposerWindows[ticket.objectID];
    if (!result)
    {
        result = [[self alloc] initWithTicket:ticket];
        
        if (result)
            __registeredTicketReplyComposerWindows[ticket.objectID] = result;
    }
    
    return result;
}

- (id)initWithTicket:(RTTicket *)ticket
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])]))
    {
        self.ticket = ticket;
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
    [super windowDidLoad];
    
    [self.editorView setTextContainerInset:NSMakeSize(3, 7)];
    [self.attachmentsTableView setDoubleAction:@selector(tableViewDoubleClicked:)];
    // TODO: Default string
}

#pragma mark - Custom Appearance Methods

- (void)_updateWindowTitle
{
    BOOL isValidTitle = ![@"" isEqualToString:self.ticket.subject];
    self.window.title = (isValidTitle) ? self.ticket.subject : @"(No Subject)";
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    [__registeredTicketReplyComposerWindows removeObjectForKey:self.ticket.objectID];
}

#pragma mark - Composer Actions

- (IBAction)sendDraft:(id)sender
{
    self.indicator = [[RTCWindowOverlayProgressIndicatorView alloc] init];
    [self.indicator showInWindow:self.window];
    
    [[RTEngine sharedEngine] postPlainTextReply:@{
                      RTTicketReplyMessageCCKey: ENSURE_NOT_NIL(self.ccField.stringValue),
                     RTTicketReplyMessageBCCKey: ENSURE_NOT_NIL(self.bccField.stringValue),
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

- (IBAction)viewTicketThread:(id)sender;
{
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openDetailForTicket:self.ticket];
}

- (void)_attachFileInline:(NSURL *)fileURL
{
    
    NSURL * temporaryAttachmentDirectory = [NSURL fileURLWithPath:
                                            [[RTDataStorageDirectory() stringByAppendingPathComponent:@"composer-attachment"]
                                             stringByAppendingPathComponent:[NSString stringWithFormat:@"%p", self]]];
    
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
    [self _quickLookAtIndex:[(NSButton *)sender tag]];
}

- (void)_quickLookAtIndex:(NSInteger)index
{
    [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
    [[QLPreviewPanel sharedPreviewPanel] setCurrentPreviewItemIndex:index];

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
    [cell configureCellWithFileURL:self.attachedFiles[row] atRow:row];
    
    return cell;
}

- (void)tableViewDoubleClicked:(NSTableView *)sender
{
    if ([sender clickedRow] < 0)
        return;
    
    [self _quickLookAtIndex:[sender clickedRow]];
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
