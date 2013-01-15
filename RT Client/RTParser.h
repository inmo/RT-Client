//
//  RTParser.h
//  RT Client
//
//  Created by Eric Tao on 1/15/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTParser : NSObject

@property (nonatomic) NSString *inputString;
@property (nonatomic) NSDictionary *parsedData;


-(NSDictionary *)getParsedData:(NSString *)string;


@end
