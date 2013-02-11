//
//  RTCTicketStubTableCellView.m
//  RT Client
//
//  Created by James Savage on 2/11/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketStubTableCellView.h"

@implementation RTCTicketStubTableCellView {
    NSColor * _primaryTextColor;
    NSColor * _secondaryTextColor;
    NSColor * _dateTextColor;
}

- (void)awakeFromNib
{
    _primaryTextColor = self.authorLabel.textColor;
    _secondaryTextColor = self.summaryLabel.textColor;
    _dateTextColor = self.dateLabel.textColor;
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];
    
    if (backgroundStyle == NSBackgroundStyleDark)
    {
        self.authorLabel.textColor = [NSColor whiteColor];
        self.dateLabel.textColor = [NSColor whiteColor];
        self.subjectLabel.textColor = [NSColor whiteColor];
        self.summaryLabel.textColor = [NSColor whiteColor];
    }
    else
    {
        self.authorLabel.textColor = _primaryTextColor;
        self.dateLabel.textColor = _dateTextColor;
        self.subjectLabel.textColor = _primaryTextColor;
        self.summaryLabel.textColor = _secondaryTextColor;
    }
}

@end
