//
//  RTCTicketCellView.m
//  RT Client
//
//  Created by James Savage on 2/7/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketCellView.h"

@implementation RTCTicketCellView {
    NSColor * _defaultPrimaryLabelColor;
    NSColor * _defaultDateLabelColor;
    NSColor * _defaultSecondaryLabelColor;
}

- (void)awakeFromNib
{
    _defaultPrimaryLabelColor = self.authorLabel.textColor;
    _defaultDateLabelColor = self.dateLabel.textColor;
    _defaultSecondaryLabelColor = self.summaryLabel.textColor;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    if (backgroundStyle == NSBackgroundStyleDark)
    {
        self.authorLabel.textColor = [NSColor whiteColor];
        self.dateLabel.textColor = [NSColor whiteColor];
        self.subjectLabel.textColor = [NSColor whiteColor];
        self.summaryLabel.textColor = [NSColor whiteColor];
    }
    else
    {
        self.authorLabel.textColor = _defaultPrimaryLabelColor;
        self.dateLabel.textColor = _defaultDateLabelColor;
        self.subjectLabel.textColor = _defaultPrimaryLabelColor;
        self.summaryLabel.textColor = _defaultSecondaryLabelColor;
    }
    
    [super setBackgroundStyle:backgroundStyle];
}

@end
