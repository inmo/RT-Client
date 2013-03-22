//
//  RT_Tests.m
//  RT Tests
//
//  Created by James Savage on 3/22/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTests.h"

@implementation RTTests

+ (NSData *)ticketStubResponseData;
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ticket-stub" ofType:@"response" inDirectory:@"resources"]];
}

+ (NSData *)ticketPDFAttachmentResponseData;
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test-file-1.pdf" ofType:@"response" inDirectory:@"resources"]];
}

+ (NSData *)ticketPDFOriginalData;
{
    return [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test-file-1" ofType:@"pdf" inDirectory:@"resources"]];
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    STAssertTrue(YES, @"HI");
}

@end
