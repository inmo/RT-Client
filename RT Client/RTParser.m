//
//  RTParser.m
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTParser.h"

@implementation RTParser

- (void)_parseTestString;
{
    NSError * unused = nil;
    NSString * testString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testingString1" ofType:@"txt"]
                                                            encoding:NSUTF8StringEncoding error:&unused];
    NSLog(@"RTParser Test Parse: %@", [self arrayWithString:testString]);
}

#define SEGMENT_DIVISION_STRING @"--"

- (NSArray *)arrayWithString:(NSString *)inputString;
{
    inputString = [inputString stringByAppendingFormat:@"\n%@", SEGMENT_DIVISION_STRING];
    NSArray * inputLines = [inputString componentsSeparatedByString:@"\n"];
    NSMutableArray * returnArray = [NSMutableArray array];
    
    __block NSRange segmentRange = NSMakeRange(0, 0);
    [inputLines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        if ([SEGMENT_DIVISION_STRING isEqualToString:line] && segmentRange.length > 0)
        {
            NSArray * segmentArray = [inputLines subarrayWithRange:segmentRange];
            [returnArray addObject:[self dictionaryWithLinesArray:segmentArray]];
            
            segmentRange = NSMakeRange(idx + 1, 0);
        }
        else
        {
            segmentRange.length += 1;
        }
    }];
    
    return returnArray;
}

- (NSDictionary *)dictionaryWithString:(NSString *)inputString;
{
    return [self arrayWithString:inputString].lastObject;
}

- (NSDictionary *)dictionaryWithLinesArray:(NSArray *)inputLines;
{
    NSMutableDictionary * returnDictionary = [NSMutableDictionary dictionaryWithCapacity:inputLines.count];
    
    NSCharacterSet * keyValueDividerSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
    
    [inputLines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        // Skip newlines in input
        if ([@"" isEqualToString:line] || [@"\n" isEqualToString:line])
            return;
        
        NSRange dividerRange = [line rangeOfCharacterFromSet:keyValueDividerSet];
        
        if (dividerRange.location != NSNotFound)
        {
            NSString * key = [line substringToIndex:dividerRange.location];
            NSString * value = (line.length > dividerRange.location + 2) ? [line substringFromIndex:dividerRange.location + 2] : @"";
            
            returnDictionary[key] = value;
        }
    }];
    
    return returnDictionary;
}

@end
