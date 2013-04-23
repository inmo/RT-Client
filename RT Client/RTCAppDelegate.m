//
//  RTCAppDelegate.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import "RTCAppDelegate.h"
#import "RTCLoginWindowController.h"
#import "RTEngine.h"
#import "RTModels.h"

#import "RTCSelfServiceWindowController.h"
#import "RTCReplyComposerWindowController.h"

@interface RTCAppDelegate ()
@end

@interface RTCAppDelegate () <RTEngineDelegate>

@property (nonatomic, strong) IBOutlet RTCSelfServiceWindowController * queueWindowController;

@property (nonatomic, strong) NSWindowController * loginWindowController;
@property (nonatomic, assign, readwrite) BOOL canLogout;

@end

@implementation RTCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.queueWindowController = [[RTCSelfServiceWindowController alloc] init];
    [self.queueWindowController.window setExcludedFromWindowsMenu:YES];
    [self.queueWindowController showWindow:self];
    
    RTEngine * engine = [RTEngine sharedEngine];
    engine.delegate = self;
    
    [engine refreshLogin];
}

- (void)showSelfServiceQueue:(id)sender
{
    [self.queueWindowController.window makeKeyAndOrderFront:sender];
}

- (void)apiEngineWillAttemptLogin:(RTEngine *)engine
{
    NSLog(@"API Engine Will Attempt Login");
}

- (void)apiEngineDidAttemptLogin:(RTEngine *)engine
{
    NSLog(@"API Engine Did Attempt Login => %i", engine.isAuthenticated);
    
    if (engine.isAuthenticated)
    {
        self.canLogout = YES;
        if (self.loginWindowController)
            [self.loginWindowController close];
        
        [[RTEngine sharedEngine] refreshSelfServiceQueue];
    }
}

- (void)apiEngineWillLogout:(RTEngine *)engine
{
    NSLog(@"API Engine Will Logout => %i", engine.isAuthenticated);
}

- (void)apiEngineDidLogout:(RTEngine *)engine
{
    NSLog(@"API Engine Did Logout");
    self.canLogout = NO;
}

- (void)apiEngine:(RTEngine *)engine requiresAuthentication:(NSWindowController *)authWindow
{
    NSLog(@"API Engine Requires Authentication: %p", authWindow);
    
    if (self.loginWindowController)
        [NSApp endSheet:self.loginWindowController.window];
    
    self.loginWindowController = authWindow;
    [NSApp beginSheet:authWindow.window
       modalForWindow:self.queueWindowController.window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
}

- (void)apiEngineRequiresNetwork:(RTEngine *)engine
{
    NSLog(@"API Engine Requires Authentication");
}

#pragma mark - Top Level Actions

- (void)openReplyComposerForTicket:(RTTicket *)ticket;
{
    RTCReplyComposerWindowController * composer = [[RTCReplyComposerWindowController alloc] initWithTicket:ticket];
    [composer showWindow:self];
}

#pragma mark - Accessors for CoreData

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSManagedObjectModel *)managedObjectModel
{
    return [NSManagedObjectModel MR_defaultManagedObjectModel];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    return [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
}

- (void)logout:(id)sender
{
    [RTEngine.sharedEngine removeUsernameAndPassword];
}

@end
