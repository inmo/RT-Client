//
//  RTCErrorMessage.h
//  RT Client
//
//  Created by CSSE Department on 1/24/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RTCErrorMessage : NSWindowController{
    
}
@property(nonatomic, strong) NSButton *closeMessage;

-(IBAction)closeErrorMessage:(id)sender;

@end
