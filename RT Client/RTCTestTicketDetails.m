//
//  RTCTestTicketDetails.m
//  RT Client
//
//  Created by Thomas Morris on 3/20/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTestTicketDetails.h"
#import "RTTicket+Extensions.m"
#import "RTParser.m"

@implementation RTCTestTicketDetails

- (void)testadminCC:(RTTicket *)adminCC;
{
    RTTicket * expectedadminCC = nil;
    STAssertEquals(expectedadminCC, adminCC, @"The adminCC are what we expected");
}

@end
