//
//  RTCTicketCell.m
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

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
    self.descriptionLabel.stringValue = [attachment description];
}

@end
