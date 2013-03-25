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

+ (NSData *)ticketStubResponseData;
{
    return [NSData dataWithContentsOfFile:@"RT Tests/resources/ticket-stub.response"];
}

+ (NSData *)ticketPDFAttachmentResponseData;
{
    return [NSData dataWithContentsOfFile:@"RT Tests/resources/test-file-1.pdf.response"];
}

+ (NSData *)ticketPDFOriginalData;
{
    return [NSData dataWithContentsOfFile:@"RT Tests/resources/test-file-1.pdf"];
}

#pragma mark - Begin Unit Tests

- (void)setUp
{
    self.parser = [[RTParser alloc] init];
}

- (void)testParsingSearchAPIResponse
{
    NSArray * parsedResponse = [self.parser arrayWithData:RTTests.ticketStubResponseData];
    
    STAssertNotNil(parsedResponse, @"Parsed response was nil");
    STAssertEquals(parsedResponse.count, (NSUInteger) 1, @"Parsed response did not return enough entries");
    
    NSDictionary * aTicket = [parsedResponse lastObject];
    
    NSDate * correctCreatedDate = [NSDate dateWithString:@"2013-03-14 17:15:05 +0000"];
    STAssertTrue([parsedResponse[0][@"Created"] isKindOfClass:[NSDate class]], @"Created date not parsed");
    STAssertEqualObjects(aTicket[@"Created"], correctCreatedDate, @"Created date incorrectly parsed");
    
    NSDate * correctLastUpdatedDate = [NSDate dateWithString:@"2013-03-14 17:15:17 +0000"];
    STAssertTrue([parsedResponse[0][@"LastUpdated"] isKindOfClass:[NSDate class]], @"Last updated date not parsed");
    STAssertEqualObjects(aTicket[@"LastUpdated"], correctLastUpdatedDate, @"Last updated date incorrectly parsed");
}

- (void)testParsingIndividualTicketAttachment
{
    NSDictionary * parsedResponse = [self.parser dictionaryWithData:RTTests.ticketPDFAttachmentResponseData];
    
    STAssertNotNil(parsedResponse, @"Parsed response was nil");
    STAssertEqualObjects(parsedResponse[@"Content"], RTTests.ticketPDFOriginalData, @"Attachment data extracted was incorrect");
    
    NSDate * correctCreatedDate = [NSDate dateWithString:@"2013-01-14 21:15:05 +0000"];
    STAssertTrue([parsedResponse[@"Created"] isKindOfClass:[NSDate class]], @"Created date not parsed");
    STAssertEqualObjects(parsedResponse[@"Created"], correctCreatedDate, @"Created date incorrectly parsed");
    
    STAssertTrue([parsedResponse[@"Headers"] isKindOfClass:[NSDictionary class]], @"Headers were not parsed as dictionary");
}

@end