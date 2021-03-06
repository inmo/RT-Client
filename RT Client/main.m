//
//  main.m
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WebKitDeveloperExtras"];
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
        return NSApplicationMain(argc, (const char **)argv);
    }
}
