//
//  RTCTicketCell.m
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "RTCTicketCell.h"
#import "RTModels.h"

@implementation RTCTicketCell

- (id)initWithIdentifier:(NSString *)identifier;
{
    if ((self = [super init]))
    {
        self.identifier = identifier;
    }
    
    return self;
}

- (void)configureWithAttachment:(RTAttachment *)attachment;
{
    [[self.webView mainFrame] loadData:[attachment content]
                              MIMEType:[attachment contentType]
                      textEncodingName:@"utf-8"
                               baseURL:nil];
}

@end
