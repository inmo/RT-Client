//
//  RTParser.m
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTParser.h"

@implementation RTParser

@synthesize parsedData, inputString;




-(NSDictionary *)getParsedData:(NSString *)string {
    
    //testing string:
    NSError * __autoreleasing error = nil;
    string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testingString1" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    
    //testing ends
    
    
    inputString = string;
    //step1: split the string by lines:
    NSArray *dataByLines = [string componentsSeparatedByString:@"\n"];
    [dataByLines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
        NSArray *kandv = [line componentsSeparatedByString:@":"];
        NSString *key = kandv[0];
        NSString *value = kandv[1];
        [parsedData setObject:value forKey:key];
    }];
    return parsedData;
}

@end
