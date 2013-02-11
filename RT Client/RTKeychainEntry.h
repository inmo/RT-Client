//
//  RTKeychainEntry.h
//  RT Client
//
//  Created by James Savage on 1/4/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RTKeychainEntry : NSObject

+ (instancetype)entryForService:(NSString *)serviceName account:(NSString *)accountName;
- (id)initWithService:(NSString *)serviceName account:(NSString *)accountName;

@property (nonatomic, strong, readonly) NSString * serviceName;
@property (nonatomic, strong, readonly) NSString * accountName;

@property (nonatomic, strong) NSDictionary * contents;

@end
