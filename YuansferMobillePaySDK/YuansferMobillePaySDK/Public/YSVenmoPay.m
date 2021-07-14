//
//  YSVenmoPay.m
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSVenmoPay.h"
#import "BTAPIClient.h"
#import "YSApiClient.h"
#import "BTVenmoDriver.h"

static NSString *braintreePayScheme;

@implementation YSVenmoPay

+ (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock {
    braintreePayScheme = fromScheme;
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
    [venmoDriver authorizeAccountAndVault:vault completion:completionBlock];
}

+ (BOOL)handleOpenURL:(NSURL *)url
              options:(NSDictionary *)options {
    if ([url.scheme isEqualToString:braintreePayScheme]) {
        return [BTAppSwitch handleOpenURL:url
                                  options:options];
    }
    return NO;
}

+ (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(nullable NSString *)sourceApplication {
    if ([url.scheme isEqualToString:braintreePayScheme]) {
        return [BTAppSwitch handleOpenURL:url
                        sourceApplication:sourceApplication];
    }
    return NO;
}

@end
