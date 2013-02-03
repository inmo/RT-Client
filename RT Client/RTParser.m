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
        __defaultDateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss";
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
            [returnArray addObject:[self dictionaryWithLinesArray:segmentArray]]; // TODO: missing nil check, good for debugging though
            
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

static NSString * kRTParserAttachmentsKey = @"Attachments";
static NSString * kRTParserHeadersKey = @"Headers";

- (NSDictionary *)dictionaryWithLinesArray:(NSArray *)inputLines;
{
    NSMutableDictionary * returnDictionary = [NSMutableDictionary dictionaryWithCapacity:inputLines.count];
    
    NSCharacterSet * keyValueDividerSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
    NSString * lastKey = nil;
    
    for (NSUInteger idx = 0; idx < inputLines.count; idx++)
    {
        NSString * line = inputLines[idx];
        
        // Skip newlines in input
        if ([@"" isEqualToString:line])
            continue;
        
        if (lastKey && [line hasPrefix:@" "])
        {
            if (line.length < lastKey.length + 2)
                continue; // Error: Cannot extract key.
            
            if ([returnDictionary[lastKey] isKindOfClass:[NSString class]])
                returnDictionary[lastKey] = [(NSString *)returnDictionary[lastKey] stringByAppendingFormat:@"\n%@", [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            continue;
        }
        
        
        NSRange dividerRange = [line rangeOfCharacterFromSet:keyValueDividerSet];
        if (dividerRange.location == NSNotFound)
            continue;
        
        NSString * key = [line substringToIndex:dividerRange.location];
        id value = (line.length > dividerRange.location + 2) ? [line substringFromIndex:dividerRange.location + 2] : @"";
        
        if ([key isEqualToString:kRTParserAttachmentsKey])
        {
            NSMutableArray * attachments = [NSMutableArray array];
            BOOL continueFlag = YES;
            
            NSError * __autoreleasing error = nil;
            // 1: (Unnamed) (text/plain / 2b),
            
            NSString * regex = @"^([0-9]+): (.*) \\(([a-zA-Z0-9\\._-]+/[a-zA-Z0-9\\._-]+) / ([0-9]+(\\.[0-9]+)?[a-z])\\)(,)?$";
            NSRegularExpression * attachmentLineRegex = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
            
            for (idx = idx; continueFlag && idx < inputLines.count; idx++)
            {
                line = [inputLines[idx] substringFromIndex:kRTParserAttachmentsKey.length + 2];
                continueFlag = [line hasSuffix:@","];
                
                NSTextCheckingResult * result = [[attachmentLineRegex matchesInString:line options:0 range:NSMakeRange(0, line.length)] lastObject];
                if (!result.numberOfRanges)
                    return nil; // Malformed Expression!
                
                [attachments addObject:@{
                 @"id": [line substringWithRange:[result rangeAtIndex:1]],
                 @"name": [line substringWithRange:[result rangeAtIndex:2]],
                 @"mimeType": [line substringWithRange:[result rangeAtIndex:3]],
                 @"byteSize": [line substringWithRange:[result rangeAtIndex:4]]}];
            }
            
            value = attachments;
        }
        else if ([key isEqualToString:kRTParserHeadersKey])
        {
            NSMutableArray * headers = [NSMutableArray array];
            
            for (idx = idx; idx < inputLines.count; idx++)
            {
                line = inputLines[idx];
                if ([line isEqualToString:@""] && line.length < kRTParserHeadersKey.length + 2)
                    break;
                
                [headers addObject:[line substringFromIndex:kRTParserHeadersKey.length + 2]];
            }
            
            value = [self dictionaryWithLinesArray:headers];
        }
        else
        {
            // TODO: Correctly parse dates
            NSDate * dateValue = [[self.class defaultDateFormatter] dateFromString:value];
            if (dateValue != nil)
                value = dateValue;
            
            // Unset values are treated as returning nil by the dictionary
            if ([SEGMENT_NOT_SET_MARKER isEqualToString:value])
                value = nil;
        }
        
        if (value != nil)
        {
            returnDictionary[key] = value;
            lastKey = key;
        }
    }
    
    return returnDictionary;
}

- (NSData *)dataWithRequestString:(NSString *)requestString
{
    NSArray * lines = [requestString componentsSeparatedByString:@"\n"];
    lines = [lines subarrayWithRange:NSMakeRange(2, lines.count)];
    requestString = [lines componentsJoinedByString:@""];
    
    return [requestString dataUsingEncoding:NSUTF8StringEncoding];
}

@end
