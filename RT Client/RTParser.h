//
//  RTParser.h
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTParser : NSObject

- (NSDictionary *)dictionaryWithString:(NSString *)inputString;
- (NSArray *)arrayWithString:(NSString *)inputString;

- (NSData *)dataWithRequestString:(NSString *)requestString;

- (void)_parseTestString;

@end
