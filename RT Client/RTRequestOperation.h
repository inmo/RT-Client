//
//  RTRequestOperation.h
//  RT Client
//
//  Created by James Savage on 1/31/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@interface AFHTTPRequestOperation (RTRequestOperation)

@property (nonatomic, strong, readonly) NSDictionary * responseDictionary;
@property (nonatomic, strong, readonly) NSArray * responseArray;

@end

@interface RTRequestOperation : AFHTTPRequestOperation

@end
