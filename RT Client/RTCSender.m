//
//  RTCSender.m
//  RT Client
//
//  Created by Thomas Morris on 3/14/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTCSender.h"
#import "RTTicket+Extensions.h"
#import "RTAttachment+Extensions.h"
#import "RTKeychainEntry.h"
#import "RTEngine.h"

@implementation RTCSender

- (void)sendTicketWithAttachments:(NSString *) senderAddress Address:(NSString *) toAddress Subject:(NSString *) subject Body:(NSString *) bodyText {
    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:%@?Subject=%@&body=%@",toAddress,subject,bodyText] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
    NSLog(@"Mailto:%@default.yahoo.com",mailtoAddress);
}

-(void)fetchTicketHistoryReply:(RTBasicBlock)completionBlock{
    [[RTEngine sharedEngine] postPath:
     parameters:(NSDictionary *) success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSMutable
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         <#code#>
     } {
    
    }
     }
//- (bool) sendTicket:(NSTask *) task InfoData: (RTEngine*) data toAddress:(NSString *) toAddress withSubject:(NSString *) subject Attachments:(NSArray *) attachments {
//    
//    
//    NSLog(@"Trying to send message");
//    //Set up Tickets to be sent as messages
//    NSString *username = data.username;
//    NSString *hostname = @"";
//    NSString *port = @"";
//    NSString *fromAddress = @"";
//    NSString *bodyText = @"Body text \n\r";
//    NSMutableArray *arguments = [NSMutableArray arrayWithObjects:
//                                 username,
//                                 hostname,
//                                 port,
//                                 fromAddress,
//                                 toAddress,
//                                 subject,
//                                 bodyText,
//                                 nil];
//    for (int i = 0; i < [attachments count]; i++) {
//        [arguments addObject:[attachments objectAtIndex:i]];
//    }
//    
//    
//    
//    
//    NSDictionary *environment = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @"", @"",
//                                 @"", @"",
//                                 nil];
//    [task setEnvironment:environment];
//    [task setLaunchPath:@""];
//    
//    [task setArguments:arguments];
//    
//    NSPipe *stdinPipe = [NSPipe pipe];
//    [task setStandardInput:stdinPipe];
//    
//    [task launch];
//    
//    [[stdinPipe fileHandleForReading] closeFile];
//    NSFileHandle *stdinFH = [stdinPipe fileHandleForWriting];
//    [stdinFH writeData:passwordData];
//    [stdinFH writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [stdinFH writeData:[@"Description" dataUsingEncoding:NSUTF8StringEncoding]];
//    [stdinFH closeFile];
//    
//    [task waitUntilExit];
//    
//    if ([task terminationStatus] == 0) {
//        NSLog(@"Message successfully sent");
//        return YES;
//    } else {
//        NSLog(@"Message not sent");
//        return NO;


@end
