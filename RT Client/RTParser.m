//
//  RTParser.m
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTParser.h"

#define SEGMENT_DIVISION_STRING @"--"
#define SEGMENT_NOT_SET_MARKER @"Not set"

@implementation RTParser

+ (NSDateFormatter *)defaultDateFormatter;
{
    static NSDateFormatter * __defaultDateFormatter = nil;
    if (__defaultDateFormatter == nil)
    {
        __defaultDateFormatter = [[NSDateFormatter alloc] init];
        __defaultDateFormatter.dateFormat = @"MMM dd HH:MM:ss yyyy";
        __defaultDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    return __defaultDateFormatter;
}

- (void)_parseTestString;
{
    NSError * unused = nil;
    NSString * testString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"testingString1" ofType:@"txt"]
                                                            encoding:NSUTF8StringEncoding error:&unused];
    NSLog(@"RTParser Test Parse: %@", [self arrayWithString:testString]);
}

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
        
        // If no ":" is contained in the string, it is not a key/value line, and cannot be parsed
        if (dividerRange.location != NSNotFound)
        {
            NSString * key = [line substringToIndex:dividerRange.location];
            id value = (line.length > dividerRange.location + 2) ? [line substringFromIndex:dividerRange.location + 2] : @"";
            
            // TODO: Correctly parse dates
            NSDate * dateValue = [[self.class defaultDateFormatter] dateFromString:value];
            if (dateValue != nil)
                value = dateValue;
            
            // Unset values are treated as returning nil by the dictionary
            if ([SEGMENT_NOT_SET_MARKER isEqualToString:value])
                value = nil;
            
            if (value != nil)
                returnDictionary[key] = value;
        }
    }];
    
    return returnDictionary;
}

@end
