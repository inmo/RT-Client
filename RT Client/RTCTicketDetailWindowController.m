//
//  RTCTicketDetailWindowController.m
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <Quartz/Quartz.h>

#import "RTCTicketDetailWindowController.h"
#import "RTCAppDelegate.h"
#import "RTModels.h"

@interface RTCTicketDetailWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet WebView * webView;

@property (nonatomic, strong) RTAttachment * quickLookAttachment;
@property (nonatomic, strong) QLPreviewPanel * quickLookPanel;

@end

@implementation RTCTicketDetailWindowController

static NSMutableDictionary * __registeredTicketDetailWindows = nil;

+ (void)initialize
{
    __registeredTicketDetailWindows = [NSMutableDictionary new];
}

+ (instancetype)registeredWindowControllerForTicket:(RTTicket *)ticket;
{
    if (!ticket)
        return nil;
    
    RTCTicketDetailWindowController * result = __registeredTicketDetailWindows[ticket.objectID];
    if (!result)
    {
        result = [[self alloc] initWithTicket:ticket];
        
        if (result)
            __registeredTicketDetailWindows[ticket.objectID] = result;
    }
    
    return result;
}

- (id)init
{
    return [super initWithWindowNibName:NSStringFromClass([self class])];
}

- (id)initWithTicket:(RTTicket *)ticket;
{
    if ((self = [self init]))
    {
        self.selectedTicket = ticket;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self.webView setDrawsBackground:NO];
    self.selectedTicket = self.selectedTicket;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"attachments"] && object == self.selectedTicket)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadDetailView];
        });
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setSelectedTicket:(RTTicket *)selectedTicket
{
    [self.selectedTicket removeObserver:self forKeyPath:@"attachments"];
    
    if ((self->_selectedTicket = selectedTicket))
    {
        self.quickLookAttachment = nil;
        [self.quickLookPanel orderOut:self];
        
        [self reloadDetailView];
        [self.selectedTicket addObserver:self forKeyPath:@"attachments" options:NULL context:NULL];
    }
}

- (void)reloadDetailView
{
    static NSString * detailViewBaseString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * path = [[NSBundle mainBundle] pathForResource:@"RTCTicketDetailWindow" ofType:@"html"];
        NSError * __autoreleasing error = nil;
        detailViewBaseString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        if (error) NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    });
    
    [[self.webView mainFrame] loadHTMLString:detailViewBaseString baseURL:nil];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [__registeredTicketDetailWindows removeObjectForKey:self.selectedTicket.objectID];
}

#pragma mark - WebView Frame Loader Delegate

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"$detail.setTicket(%@)",
      [self.selectedTicket constructTicketHierarchyJSON]]];
    self.window.title = self.selectedTicket.subject;
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id <WebPolicyDecisionListener>)listener
{
    if ([actionInformation[WebActionNavigationTypeKey] integerValue] == WebNavigationTypeLinkClicked)
    {
        NSManagedObjectID * objectID = [[NSPersistentStoreCoordinator MR_defaultStoreCoordinator] managedObjectIDForURIRepresentation:[request URL]];
        self.quickLookAttachment = (RTAttachment *)[[NSManagedObjectContext MR_defaultContext] objectWithID:objectID];
        
        if (self.quickLookAttachment) // Ensure that the object is still alive
            self.quickLookAttachment = [RTAttachment MR_findFirstByAttribute:@"self" withValue:self.quickLookAttachment];
        
        if (self.quickLookAttachment)
        {
            [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:self];
            [[QLPreviewPanel sharedPreviewPanel] reloadData];
        }
        else
        {
            [[NSAlert alertWithMessageText:@"Error opening attachment" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:nil]
             beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
        }
        
        [listener ignore];
        return;
    }
    
    [listener use];
}

#pragma mark - Toolbar Actions

- (IBAction)replyToSelectedTicket:(id)sender;
{
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openReplyComposerForTicket:self.selectedTicket];
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
    return (self.quickLookAttachment) ? 1 : 0;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return self.quickLookAttachment;
}

@end
