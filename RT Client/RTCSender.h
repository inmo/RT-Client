//
//  RTCSender.h
//  RT Client
//
//  Created by CSSE Department on 3/14/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTCSender : NSObject
-(void)sendTicketWithAttachments:(NSString *) senderAddress Address:(NSString *) toAddress Subject:(NSString *) subject Body:(NSString *) bodyText;
-(bool) sendTicket:(NSTask *) task toAddress:(NSString *) toAddress withSubject:(NSString *) subject Attachments:(NSArray *) attachments;
@end
