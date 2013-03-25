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

- (NSArray *)_arrayWithString:(NSString *)inputString
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
            return;
        }
        
        segmentRange.length += 1;
    }];
    
    return returnArray;
}

- (NSArray *)arrayWithData:(NSData *)data;
{
    NSString * inputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [self _arrayWithString:inputString];
}

- (NSDictionary *)dictionaryWithString:(NSString *)inputString;
{
    return [[self _arrayWithString:inputString] lastObject];
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
            NSDate * dateValue = [self coerceDateFromString:value];
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

- (NSDictionary *)dictionaryWithData:(NSData *)data;
{
    NSString * quickDecodeAttempt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (quickDecodeAttempt)
        return [self dictionaryWithString:quickDecodeAttempt];
    
    // TODO These are constants, so they should probably be made static eventually
    NSData * contentRangeMarker = [@"Content: " dataUsingEncoding:NSUTF8StringEncoding];
    NSData * attachmentLineMarker = [@"         " dataUsingEncoding:NSUTF8StringEncoding];
    
    NSRange rangeOfContentMarker = [data rangeOfData:contentRangeMarker options:0 range:NSMakeRange(0, data.length)];
    NSRange rangeOfParsableData = NSMakeRange(0, rangeOfContentMarker.location);
    
    NSString * parsableString = [[NSString alloc] initWithData:[data subdataWithRange:rangeOfParsableData] encoding:NSUTF8StringEncoding];
    NSMutableDictionary * resultDictionary = [[self dictionaryWithString:parsableString] mutableCopy];
    
    NSMutableData * attachmentData = [data mutableCopy];
    NSRange attachmentDataRemovalRange = NSMakeRange(0, rangeOfContentMarker.location + rangeOfContentMarker.length);
    
    do {
        [attachmentData replaceBytesInRange:attachmentDataRemovalRange withBytes:NULL length:0];
        
        NSRange attachmentDataSearchRange = NSMakeRange(attachmentDataRemovalRange.location, attachmentData.length - attachmentDataRemovalRange.location);
        attachmentDataRemovalRange = [attachmentData rangeOfData:attachmentLineMarker options:0 range:attachmentDataSearchRange];
    } while (attachmentDataRemovalRange.location != NSNotFound);
    
    // TODO There is still a trailing 0xA0A0A0 that I'm not sure if we should be removing
    resultDictionary[@"Content"] = attachmentData;
    return resultDictionary;
}

#pragma mark - Date Parsing

+ (NSDateFormatter *)defaultDateFormatter;
{
    static NSDateFormatter * __defaultDateFormatter = nil;
    if (__defaultDateFormatter == nil)
    {
        __defaultDateFormatter = [[NSDateFormatter alloc] init];
        __defaultDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    return __defaultDateFormatter;
}

- (NSDate *)coerceDateFromString:(NSString *)str;
{
    NSDateFormatter * dateFormatter = [self.class defaultDateFormatter];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss yyyy";
    
    NSDate * date = [dateFormatter dateFromString:str];
    if (date) return date;
    
    dateFormatter.dateFormat = @"yyyy-mm-dd HH:mm:ss";
    
    date = [dateFormatter dateFromString:str];
    if (date) return date;
    
    return nil;
}

@end
