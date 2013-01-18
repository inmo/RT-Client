//
//  RTKeychainEntry.m
//  RT Client
//
//  Created by James Savage on 1/4/13.
//  Copyright (c) 2013 INMO. All rights reserved.
//

#import "RTKeychainEntry.h"

@interface RTKeychainEntry ()

@property (nonatomic, strong, readwrite) NSString * serviceName;
@property (nonatomic, strong, readwrite) NSString * accountName;

@end

@implementation RTKeychainEntry

+ (RTKeychainEntry *)entryForService:(NSString *)serviceName account:(NSString *)accountName;
{
    return [[self alloc] initWithService:serviceName account:accountName];
}

- (id)initWithService:(NSString *)serviceName account:(NSString *)accountName;
{
    if ((self = [super init]))
    {
        self.serviceName = serviceName;
        self.accountName = accountName;
    }
    
    return self;
}

- (NSDictionary *)contents
{
    NSMutableDictionary * keychainQuery = @{
        (__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
        (__bridge_transfer NSString *)kSecAttrService: self.serviceName,
        (__bridge_transfer NSString *)kSecAttrAccount: self.accountName,
        (__bridge_transfer NSString *)kSecReturnData: (__bridge_transfer NSString *)kCFBooleanTrue,
        (__bridge_transfer NSString *)kSecMatchLimit: (__bridge_transfer NSString *)kSecMatchLimitOne,
    }.mutableCopy;
    NSDictionary * contents = nil;
    
    CFTypeRef resultData = NULL;
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef)keychainQuery;
    
    if (SecItemCopyMatching(query, (CFTypeRef *)&resultData) == noErr && resultData)
        contents = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)(resultData)];
    
    CFRelease(query);
    return contents;
}

- (void)setContents:(NSDictionary *)contents
{
    NSMutableDictionary * keychainQuery = @{
        (__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
        (__bridge_transfer NSString *)kSecAttrService: self.serviceName,
        (__bridge_transfer NSString *)kSecAttrAccount: self.accountName,
        (__bridge_transfer NSString *)kSecReturnData: (__bridge_transfer NSString *)kCFBooleanTrue,
    }.mutableCopy;
    
    CFTypeRef resultData = NULL;
    CFDictionaryRef query = (__bridge_retained CFDictionaryRef)keychainQuery;
    
    SecItemDelete(query);
    CFRelease(query);
    
    if (contents)
    {
        [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:contents]
                          forKey:(__bridge_transfer NSString *)kSecValueData];
        CFDictionaryRef query = (__bridge_retained CFDictionaryRef)keychainQuery;
        
        SecItemAdd(query, &resultData);
        CFRelease(query);
    }
}

@end
