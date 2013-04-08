//
//  RTRequestOperation.m
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTRequestOperation.h"
#import "RTParser.h"

@interface RTRequestOperation ()

@property (nonatomic, strong) RTParser * responseParser;

@end

@implementation RTRequestOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)urlRequest
{
    return YES;
}

- (RTParser *)responseParser;
{
    if (!self->_responseParser)
        self->_responseParser = [[RTParser alloc] init];
    
    return self->_responseParser;
}

- (NSDictionary *)responseDictionary
{
    return [self.responseParser dictionaryWithData:self.responseData];
}

- (NSArray *)responseArray
{
    return [self.responseParser arrayWithData:self.responseData];
}

@end
