//
//  RT_Tests.h
//  RT Tests
//
//  Created by James Savage on 3/22/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface RTTests : SenTestCase

+ (NSData *)ticketStubResponseData;
+ (NSData *)ticketPDFAttachmentResponseData;
+ (NSData *)ticketPDFOriginalData;
-(NSArray *)arrayWithData:(NSData *)data;
-(NSDictionary *)dictionaryWithData:(NSData *)data;



@end
