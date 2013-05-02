//
//  RTCTicketDetailWindowController.m
//  RT Client
//
//  Created by James Savage on 4/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "RTCTicketDetailWindowController.h"
#import "RTCAppDelegate.h"
#import "RTModels.h"

@interface RTCTicketDetailWindowController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong) IBOutlet WebView * webView;

@property (nonatomic, strong) id keepAlive;

@end

@implementation RTCTicketDetailWindowController

- (id)init
{
    return [super initWithWindowNibName:NSStringFromClass([self class])];
}

- (id)initWithTicket:(RTTicket *)ticket;
{
    if ((self = [self init]))
    {
        self.selectedTicket = ticket;
        self.keepAlive = self;
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
        [self reloadDetailView];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setSelectedTicket:(RTTicket *)selectedTicket
{
    [self.selectedTicket removeObserver:self forKeyPath:@"attachments"];
    
    if ((self->_selectedTicket = selectedTicket))
    {
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
    self.keepAlive = nil;
}

#pragma mark - WebView Frame Loader Delegate

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame
{
    [webView stringByEvaluatingJavaScriptFromString:
     [NSString stringWithFormat:@"$detail.setTicket(%@)",
      [self.selectedTicket constructTicketHierarchyJSON]]];
}

#pragma mark - Toolbar Actions

- (IBAction)replyToSelectedTicket:(id)sender;
{
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openReplyComposerForTicket:self.selectedTicket];
}

@end
