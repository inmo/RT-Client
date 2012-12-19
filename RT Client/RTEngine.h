//
//  RequestTrackerAPI.h
//  RT Client
//
//  Created by James Savage on 12/3/12.
//  Copyright (c) 2012 INMO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void (^RTErrorBlock)(NSError * error);

@interface RTEngine : AFHTTPClient

@property (nonatomic, readonly) BOOL isAuthenticated;
@property (nonatomic, readonly) BOOL hasCredientials;

- (void)attemptInitialLogin:(RTBasicBlock)initialLoginBlock
          onLoginCompletion:(void (^)(BOOL didSucceed))loginCompletionBlock
        onVerifyCredentials:(void (^)(NSWindow * credentialsWindow))verifyCredentialsBlock;

- (void)ensureValidCredentials:(void (^)(NSWindowController * accountCreationController))accountCreationBlock
        andPerformInitialLogin:(RTBasicBlock)loginCompleteBlock;

// TODO: #1 get a list of ticket/id's via the "/search/ticket..." endpoint
- (void)requestSelfServiceTickets:(void (^)(NSArray * tickets))completionBlock
                            error:(RTErrorBlock)errorBlock;

// TODO: #2 get attachments, metadata, and related tickets to build timeline view
- (void)requestTicketDetails:(id)ticket
                  completion:(void (^)(/* signature not yet known */))completionBlock
                       error:(RTErrorBlock)errorBlock;

// TODO: These need written, using keychain for storage
- (void)setUsername:(NSString *)username password:(NSString *)password;
- (void)removeUsernameAndPassword;

@end
