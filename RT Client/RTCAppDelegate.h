//
//  RTCAppDelegate.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RTTicket;

@interface RTCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow * window;

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@property (nonatomic, assign, readonly) BOOL canLogout;
- (IBAction)logout:(id)sender;

- (void)openReplyComposerForTicket:(RTTicket *)ticket;

@end
