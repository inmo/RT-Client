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
    date =newText;
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
-(void)SetTextdateWithInt:(double) timeStamp{
    
    
}


-(void)UpdateDisplayText{
    
}


-(NSString *)getText{
    
    
}



@end
