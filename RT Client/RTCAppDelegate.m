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
#import "MainMenu.h"

@interface RTCAppDelegate ()
@end

@interface RTCAppDelegate () <RTEngineDelegate> {
    NSWindowController * _loginWindowController;
}
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
    [engine removeUsernameAndPassword];
    engine.delegate = self;
    
    [engine refreshLogin];
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
        if (_loginWindowController)
            [_loginWindowController close];
        
        [engine fetchSelfServiceTicketStubs:^{
            NSError * __autoreleasing error = nil;
            [((MainMenu *)self.window.windowController).ticketController fetchWithRequest:nil merge:NO error:&error];
            [((MainMenu *)self.window.windowController).ticketTableView reloadData];
            
            [RTTicket.MR_findAll enumerateObjectsUsingBlock:^(RTTicket * ticket, NSUInteger idx, BOOL *stop) {
                [engine pullTicketInformation:ticket.objectID completion:^{
                    NSError * __autoreleasing error = nil;
                    [((MainMenu *)self.window.windowController).ticketController fetchWithRequest:nil merge:NO error:&error];
                    [((MainMenu *)self.window.windowController).ticketTableView reloadData];
                }];
            }];
        }];
    }
}

- (void)apiEngineWillLogout:(RTEngine *)engine
{
    NSLog(@"API Engine Will Logout => %i", engine.isAuthenticated);
}

- (void)apiEngineDidLogout:(RTEngine *)engine
{
    NSLog(@"API Engine Did Logout");
}

- (void)apiEngine:(RTEngine *)engine requiresAuthentication:(NSWindowController *)authWindow
{
    NSLog(@"API Engine Requires Authentication: %p", authWindow);
    
    if (_loginWindowController)
        [_loginWindowController close];
    
    _loginWindowController = authWindow;
    [NSApp beginSheet:_loginWindowController.window
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

@end
