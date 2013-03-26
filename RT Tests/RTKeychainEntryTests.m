//
//  RTKeychainEntryTests.m
//  RT Client
//
//  Created by James Savage on 3/25/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTKeychainEntryTests.h"
#import "RTKeychainEntry.h"

@implementation RTKeychainEntryTests

- (void)testKeychainEntry
{
    RTKeychainEntry * entry = [RTKeychainEntry entryForService:@"rt-test" account:@"rt-blank"];
    
    if (entry.contents)
    {
        STFail(@"Oops. Something got left in the keychain. Kick it out please.");
        return;
    }

    NSDictionary * correctContents = entry.contents = @{ @"Stuff": @"Things" };
    STAssertEqualObjects(entry.contents, correctContents, @"Keychain entry didn't remember the value we gave it");
    
    correctContents = entry.contents = @{ @"Foo": @"Bar", @"Cat": @3.14 };
    STAssertEqualObjects(entry.contents, correctContents, @"Keychain entry didn't update its value");
    
    entry.contents = nil;
    STAssertNil(entry.contents, @"Keychain entry didn't erase its value");
}

@end
