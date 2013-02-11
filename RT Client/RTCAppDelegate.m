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

@interface RTCAppDelegate ()
@end

@interface RTCAppDelegate () <RTEngineDelegate> {
    NSWindowController * _loginWindowController;
}

@property (nonatomic, assign, readwrite) BOOL canLogout;
@end

@implementation RTCAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

+ (void)initialize
{
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    RTEngine * engine = [RTEngine sharedEngine];
    engine.delegate = self;
    
    [engine removeUsernameAndPassword];
//    [engine refreshLogin];
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
        if (_loginWindowController)
            [_loginWindowController close];
        
        [(RTCSelfServiceWindowController *)self.window.windowController refreshSelfServiceTickets:self];
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
    
    if (_loginWindowController)
        [NSApp endSheet:_loginWindowController.window];
    
    _loginWindowController = authWindow;
    [NSApp beginSheet:authWindow.window
       modalForWindow:self.window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
}

- (void)apiEngineRequiresNetwork:(RTEngine *)engine
{
    NSLog(@"API Engine Requires Authentication");
}

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
