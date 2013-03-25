//
//  RT_Tests.m
//  RT Tests
//
//  Created by James Savage and Thomas Morris on 3/22/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTests.h"
#import "RTParser.m"


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




- (void)testExample
{
  STAssertTrue(YES, @"HI");
}

-(void) testStubResponseData
{
    NSDictionary * attachment = [RTParser dictionaryWithData:[RTTests ticketStubResponseData]];

    STAssertEquals(attachment,  , @"The ticket stub is equivalent");
}

@end
