//
//  YSBraintreeClient.m
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSApiClient.h"
#import "BTAPIClient.h"

static NSString * const SDKVersion = @"1.2.0";

@implementation YSApiClient

+ (instancetype)sharedInstance {
    static YSApiClient *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)version {
    return SDKVersion;
}

- (void) initBraintreeClient:(NSString*) authorization {
    self.apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
}

@end
