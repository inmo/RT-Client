//
//  RTParser.m
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTParser.h"

static NSString * kRTParserAttachmentsKey = @"Attachments";
static NSString * kRTParserHeadersKey = @"Headers";

static NSString * kRTParserEmptyLineValue = @"";
static NSString * kRTParserKeyNotSetValue = @"Not set";
static NSString * kRTParserContinueLastKeyMarker = @"";
static NSString * kRTParserSegmentDivisionMarker = @"--";
static NSString * kRTParserKeyValueDivisionMarker = @": ";

@implementation RTParser

static NSData * kRTParserContentRangeMarker = nil;
static NSData * kRTParserAttachmentLineMarker = nil;
static NSData * kRTParserAttachmentTrailerMarker = nil;

+ (void)initialize
{
    kRTParserContentRangeMarker = [@"Content: " dataUsingEncoding:NSUTF8StringEncoding];
    kRTParserAttachmentLineMarker = [@"         " dataUsingEncoding:NSUTF8StringEncoding];
    kRTParserAttachmentTrailerMarker = [NSData dataWithBytes:(char[]){0x0A, 0x0A, 0x0A} length:3];
}

#pragma mark - Dictionary Parsing

- (NSDictionary *)dictionaryWithData:(NSData *)data;
{
    NSString * quickDecodeAttempt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (quickDecodeAttempt)
        return [self _dictionaryWithString:quickDecodeAttempt];
    
    NSRange rangeOfContentMarker = [data rangeOfData:kRTParserContentRangeMarker options:0 range:NSMakeRange(0, data.length)];
    NSRange rangeOfParsableData = NSMakeRange(0, rangeOfContentMarker.location);
    
    NSString * parsableString = [[NSString alloc] initWithData:[data subdataWithRange:rangeOfParsableData] encoding:NSUTF8StringEncoding];
    NSMutableDictionary * resultDictionary = [[self _dictionaryWithString:parsableString] mutableCopy];
    
    NSMutableData * attachmentData = [data mutableCopy];
    NSRange attachmentDataRemovalRange = NSMakeRange(0, rangeOfContentMarker.location + rangeOfContentMarker.length);
    NSRange attachmentDataSearchRange = NSMakeRange(NSNotFound, 0);
    
    do {
        [attachmentData replaceBytesInRange:attachmentDataRemovalRange withBytes:NULL length:0];
        
        attachmentDataSearchRange = NSMakeRange(attachmentDataRemovalRange.location, attachmentData.length - attachmentDataRemovalRange.location);
        attachmentDataRemovalRange = [attachmentData rangeOfData:kRTParserAttachmentLineMarker options:0 range:attachmentDataSearchRange];
    } while (attachmentDataRemovalRange.location != NSNotFound);
    
    NSRange attachmentTrailerCheckRange = NSMakeRange(attachmentData.length - kRTParserAttachmentTrailerMarker.length, kRTParserAttachmentTrailerMarker.length);
    NSData * foundAttachmentTrailer = [attachmentData subdataWithRange:attachmentTrailerCheckRange];
    if ([kRTParserAttachmentTrailerMarker isEqualToData:foundAttachmentTrailer])
        [attachmentData replaceBytesInRange:attachmentTrailerCheckRange withBytes:NULL length:0];
    
    resultDictionary[@"Content"] = attachmentData;
    return resultDictionary;
}

- (NSDictionary *)_dictionaryWithString:(NSString *)inputString;
{
    return [[self _arrayWithString:inputString] lastObject];
}

#pragma mark - Array Parsing

- (NSArray *)arrayWithData:(NSData *)data;
{
    NSString * inputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [self _arrayWithString:inputString];
}

- (NSArray *)_arrayWithString:(NSString *)inputString
{
    inputString = [inputString stringByAppendingFormat:@"\n%@", kRTParserSegmentDivisionMarker];
    
    NSArray * inputLines = [inputString componentsSeparatedByString:@"\n"];
    NSMutableArray * returnArray = [NSMutableArray array];
    
    __block NSRange segmentRange = NSMakeRange(0, 0);
    [inputLines enumerateObjectsUsingBlock:^(NSString * line, NSUInteger idx, BOOL *stop) {
        if ([kRTParserSegmentDivisionMarker isEqualToString:line] && segmentRange.length > 0)
        {
            NSArray * segmentArray = [inputLines subarrayWithRange:segmentRange];
            NSDictionary * result = [self _parseTextualResponseLines:segmentArray];
            
            if (result)
                [returnArray addObject:result];
            
            segmentRange = NSMakeRange(idx + 1, 0);
            return;
        }
        
        segmentRange.length += 1;
    }];
    
    return returnArray;
}

#pragma mark - Private Parser Subroutines

- (NSDictionary *)_parseTextualResponseLines:(NSArray *)lines;
{
    NSMutableDictionary * returnDictionary = [NSMutableDictionary dictionaryWithCapacity:lines.count];
    NSString * lastKey = nil;
    
    for (NSUInteger idx = 0; idx < lines.count; idx++)
    {
        NSString * line = lines[idx];
        
        if ([kRTParserEmptyLineValue isEqualToString:line])
            continue;
        
        BOOL candidateContinuationLine = (lastKey && [line hasPrefix:kRTParserContinueLastKeyMarker]);
        BOOL canAppendToLastKey = [returnDictionary[lastKey] isKindOfClass:[NSString class]];
        BOOL enoughCharactersInCurrentLine = (line.length >= lastKey.length + 2);
        
        if (candidateContinuationLine && canAppendToLastKey && enoughCharactersInCurrentLine)
        {
            NSString * trimmedAddition = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            returnDictionary[lastKey] = [(NSString *)returnDictionary[lastKey] stringByAppendingFormat:@"\n%@", trimmedAddition];
            continue;
        }
        
        NSRange keyValueDivisionRange = [line rangeOfString:kRTParserKeyValueDivisionMarker];
        NSUInteger keyValueDivisionRangeEnd = keyValueDivisionRange.location + keyValueDivisionRange.length;
        
        if (keyValueDivisionRange.location == NSNotFound || keyValueDivisionRangeEnd >= line.length)
            continue;
        
        NSString * key = [line substringToIndex:keyValueDivisionRange.location];
        id value = [self _parseLineForGenericKey:[line substringFromIndex:keyValueDivisionRangeEnd]];;
        
        if ([key isEqualToString:kRTParserAttachmentsKey])
            value = [self _parseLinesForAttachmentsKey:lines index:&idx];
        
        if ([key isEqualToString:kRTParserHeadersKey])
            value = [self _parseLinesForHeadersKey:lines index:&idx];
        
        if (value)
        {
            returnDictionary[key] = value;
            lastKey = key;
        }
    }
    
    return returnDictionary;
}

- (NSArray *)_parseLinesForAttachmentsKey:(NSArray *)lines index:(NSUInteger *)idx
{
    // This is the syntax this regex matches...
    // 1: (Unnamed) (text/plain / 2b),
    // 2: somefile.type (foo/bar / 12k),
    // 3: even spaces really.stuff (foo/bar / 1342m)
    
    NSError * __autoreleasing error = nil;
    NSString * regex = @"^([0-9]+): (.*) \\(([a-zA-Z0-9\\._-]+/[a-zA-Z0-9\\._-]+) / ([0-9]+(\\.[0-9]+)?[a-z])\\)(,)?$";
    NSRegularExpression * attachmentLineRegex = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&error];
    
    if (error)
    {
        @throw [NSException exceptionWithName:@"Parse Error"
                                       reason:@"Could not create regular expression"
                                     userInfo:@{ @"lines": lines, @"index": @(*idx) }];
    }
    
    NSMutableArray * attachments = [NSMutableArray array];
    for (NULL; *idx < lines.count; *idx += 1)
    {
        NSString * line = [lines[*idx] substringFromIndex:kRTParserAttachmentsKey.length + 2];
        
        NSTextCheckingResult * regexResult = [[attachmentLineRegex matchesInString:line options:0 range:NSMakeRange(0, line.length)] lastObject];
        if (!regexResult.numberOfRanges)
        {
            @throw [NSException exceptionWithName:@"Parse Error"
                                           reason:@"Malformed expression in attachment value"
                                         userInfo:@{ @"lines": lines, @"index": @(*idx) }];
        }
        
        [attachments addObject:@{
         @"id": [line substringWithRange:[regexResult rangeAtIndex:1]],
         @"name": [line substringWithRange:[regexResult rangeAtIndex:2]],
         @"mimeType": [line substringWithRange:[regexResult rangeAtIndex:3]],
         @"byteSize": [line substringWithRange:[regexResult rangeAtIndex:4]]}];
        
        if (![line hasSuffix:@","])
            break;
    }
    
    return attachments;
}

- (NSDictionary *)_parseLinesForHeadersKey:(NSArray *)lines index:(NSUInteger *)idx
{
    NSMutableArray * headers = [NSMutableArray array];
    
    for (NULL; *idx < lines.count; *idx += 1)
    {
        NSString * line = lines[*idx];
        
        if ([line isEqualToString:@""] && line.length < kRTParserHeadersKey.length + 2)
            break;
        
        [headers addObject:[line substringFromIndex:kRTParserHeadersKey.length + 2]];
    }
    
    return [self _parseTextualResponseLines:headers];
}

- (id)_parseLineForGenericKey:(NSString *)line
{
    NSDate * dateValue = [self coerceDateFromString:line];
    if (dateValue != nil)
        return dateValue;
    
    if ([kRTParserKeyNotSetValue isEqualToString:line])
        return nil;
    
    return line;
}

#pragma mark - Date Parsing

+ (NSDateFormatter *)defaultDateFormatter;
{
    static NSDateFormatter * __defaultDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultDateFormatter = [[NSDateFormatter alloc] init];
        __defaultDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });
    
    return __defaultDateFormatter;
}

- (NSDate *)coerceDateFromString:(NSString *)str;
{
    NSDateFormatter * dateFormatter = [self.class defaultDateFormatter];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss yyyy";
    
    NSDate * date = [dateFormatter dateFromString:str];
    if (date) return date;
    
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    date = [dateFormatter dateFromString:str];
    if (date) return date;
    
    return nil;
}

@end
