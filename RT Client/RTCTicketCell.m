//
//  RTCTicketCell.m
//  RT Client
//
//  Created by CSSE Department on 3/23/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCTicketCell.h"


@implementation RTCTicketCell
@synthesize tableText;



-(void)SetTextBody:(NSString*) newText{
    BodyText =newText;
    [self UpdateDisplayText];

    
}
-(void)SetTextfrom:(NSString*) newText{
    from=newText;
    [self UpdateDisplayText];

    
}
-(void)SetTextreciver:(NSString*) newText{
    reciver =newText;
    [self UpdateDisplayText];

    
}
-(void)SetTextdate:(NSString*) newText{
    dateText =newText;
    [self UpdateDisplayText];

    
}
-(void)SetTextpriority:(NSString*) newText{
    priority =newText;
    [self UpdateDisplayText];

    
}
-(void)SetTextsubject:(NSString*) newText{
    subject =newText;
    [self UpdateDisplayText];
    
    
}

    



-(void)UpdateDisplayText{
    NSMutableString *tempDisplayText;
    tempDisplayText=[tempDisplayText init];
    if ([from length]==0) {
        [tempDisplayText appendString:@"From: "];
        [tempDisplayText appendString:from];
        [tempDisplayText appendString:@"\n"];
    }
    if ([reciver length]==0) {
        [tempDisplayText appendString:@"to: "];
        [tempDisplayText appendString:reciver];
        [tempDisplayText appendString:@"\n"];
    }
    if ([dateText length]==0) {
        [tempDisplayText appendString:@"date: "];
        [tempDisplayText appendString:dateText];
        [tempDisplayText appendString:@"\n"];
    }
    if ([priority length]==0) {
        [tempDisplayText appendString:@"priority: "];
        [tempDisplayText appendString:priority];
        [tempDisplayText appendString:@"\n"];
    }
    if ([subject length]==0) {
        [tempDisplayText appendString:subject];
        [tempDisplayText appendString:@"\n"];
    }
    if ([BodyText length]==0) {
        [tempDisplayText appendString:BodyText];
    }
    
    displayText=tempDisplayText;

    
    
}


-(NSString *)getText{
    return displayText;
    
}



@end
