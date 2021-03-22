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

+ (BOOL)handleOpenURL:(NSURL *)aURL {
    if ([aURL.scheme isEqualToString:braintreePayScheme]) {
        return [BTAppSwitch handleOpenURL:aURL];
    }
    return NO;
}

@end
