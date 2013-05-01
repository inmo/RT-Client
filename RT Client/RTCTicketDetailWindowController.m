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
@property (nonatomic, strong) NSArray * selectedTicketAttachments;

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
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setSelectedTicket:(RTTicket *)selectedTicket
{
    [self.selectedTicket removeObserver:self forKeyPath:@"attachments"];
    
    if ((self->_selectedTicket = selectedTicket))
    {
        self.selectedTicketAttachments = [self.selectedTicket chronologicallySortedTopLevelAttachments];
        [self.selectedTicket addObserver:self forKeyPath:@"attachments" options:NULL context:NULL];
    }
}

- (void)setSelectedTicketAttachments:(NSArray *)selectedTicketAttachments
{
    self->_selectedTicketAttachments = selectedTicketAttachments;
    
    static NSString * detailViewBaseString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // external symbols generated via custom build rule and xxd
        extern unsigned char RTCTicketDetailWindow_html[];
        extern unsigned int RTCTicketDetailWindow_html_len;
        
        detailViewBaseString = [[NSString alloc] initWithBytesNoCopy:RTCTicketDetailWindow_html
                                                          length:RTCTicketDetailWindow_html_len
                                                        encoding:NSUTF8StringEncoding freeWhenDone:NO];
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
    NSMutableArray * attachments = [NSMutableArray arrayWithCapacity:self.selectedTicketAttachments.count];
    [self.selectedTicketAttachments enumerateObjectsUsingBlock:^(RTAttachment * attachment, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary * headers = [NSMutableDictionary dictionaryWithCapacity:[attachment.headers count]];
        [attachment.headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            headers[[key lowercaseString]] = obj;
        }];
        
        [attachments addObject:@{
         @"contents": ENSURE_NOT_NIL([[NSString alloc] initWithData:[attachment content] encoding:NSUTF8StringEncoding]),
         @"date": ENSURE_NOT_NIL([[attachment created] description]),
         @"headers": headers
         }];
    }];
    
    NSError * __autoreleasing jsonError = nil;
    id jsonData = [NSJSONSerialization dataWithJSONObject:attachments options:NULL error:&jsonError];
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$detail.setTicket(%@)", jsonString]];
}

#pragma mark - Toolbar Actions

- (IBAction)replyToSelectedTicket:(id)sender;
{
    [(RTCAppDelegate *)[[NSApplication sharedApplication] delegate]
     openReplyComposerForTicket:self.selectedTicket];
}

@end
