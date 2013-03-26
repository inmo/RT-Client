//
//  RT_Tests.m
//  RT Tests
//
//  Created by James Savage and Thomas Morris on 3/22/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTTests.h"
#import "RTParser.h"


@interface RTTests ()

@property (nonatomic, strong) RTParser * parser;

@end

@implementation RTTests

- (void)setUp
{
    self.parser = [[RTParser alloc] init];
}

#define TEST_FILE(SEL, TYPE) [NSString stringWithFormat:@"RT Tests/resources/%@.%@", NSStringFromSelector(SEL), @#TYPE]
#define BIN_FILE TEST_FILE(_cmd, bin)
#define CHK_FILE TEST_FILE(_cmd, plist)

- (void)testParsingSearchAPIResponse
{
    NSData * responseData = [NSData dataWithContentsOfFile:BIN_FILE];
    NSArray * parsedResponse = [self.parser arrayWithData:responseData];
//    [parsedResponse writeToFile:CHK_FILE atomically:YES];
    
    STAssertNotNil(parsedResponse, @"Parsed response was nil");
    STAssertEquals(parsedResponse.count, (NSUInteger) 1, @"Parsed response did not return enough entries");
    
    NSDictionary * aTicket = [parsedResponse lastObject];
    
    NSDate * correctCreatedDate = [NSDate dateWithString:@"2013-03-14 17:15:05 +0000"];
    STAssertTrue([parsedResponse[0][@"Created"] isKindOfClass:[NSDate class]], @"Created date not parsed");
    STAssertEqualObjects(aTicket[@"Created"], correctCreatedDate, @"Created date incorrectly parsed");
    
    NSDate * correctLastUpdatedDate = [NSDate dateWithString:@"2013-03-14 17:15:17 +0000"];
    STAssertTrue([parsedResponse[0][@"LastUpdated"] isKindOfClass:[NSDate class]], @"Last updated date not parsed");
    STAssertEqualObjects(aTicket[@"LastUpdated"], correctLastUpdatedDate, @"Last updated date incorrectly parsed");
    
    NSArray * correctResponse = [NSArray arrayWithContentsOfFile:CHK_FILE];
    STAssertEqualObjects(parsedResponse, correctResponse, @"Master check failed.");
}

- (void)testParsingIndividualTicketAttachmentList
{
    NSData * responseData = [NSData dataWithContentsOfFile:BIN_FILE];
    NSDictionary * parsedResponse = [self.parser dictionaryWithData:responseData];
//    [parsedResponse writeToFile:CHK_FILE atomically:YES];
    
    STAssertNotNil(parsedResponse, @"Parsed response was nil");
    
    NSDictionary * correctResponse = [NSDictionary dictionaryWithContentsOfFile:CHK_FILE];
    STAssertEqualObjects(parsedResponse, correctResponse, @"Master check failed.");
}

- (void)testParsingIndividualTicketAttachment
{
    NSData * responseData = [NSData dataWithContentsOfFile:BIN_FILE];
    NSDictionary * parsedResponse = [self.parser dictionaryWithData:responseData];
//    [parsedResponse writeToFile:CHK_FILE atomically:YES];
    
    STAssertNotNil(parsedResponse, @"Parsed response was nil");
    
    NSData * correctContent = [NSData dataWithContentsOfFile:@"RT Tests/resources/test-file-1.pdf"];
    STAssertEqualObjects(parsedResponse[@"Content"], correctContent, @"Attachment data extracted was incorrect");
    
    NSDate * correctCreatedDate = [NSDate dateWithString:@"2013-01-14 21:15:05 +0000"];
    STAssertTrue([parsedResponse[@"Created"] isKindOfClass:[NSDate class]], @"Created date not parsed");
    STAssertEqualObjects(parsedResponse[@"Created"], correctCreatedDate, @"Created date incorrectly parsed");
    
    STAssertTrue([parsedResponse[@"Headers"] isKindOfClass:[NSDictionary class]], @"Headers were not parsed as dictionary");
    
    NSDictionary * correctResponse = [NSDictionary dictionaryWithContentsOfFile:CHK_FILE];
    STAssertEqualObjects(parsedResponse, correctResponse, @"Master check failed.");
}

@end