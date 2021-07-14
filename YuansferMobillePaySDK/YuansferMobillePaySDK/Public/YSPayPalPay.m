//
//  YSPayPalPay.m
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSPayPalPay.h"
#import "BTAppSwitch.h"
#import "BTAPIClient.h"
#import "YSApiClient.h"
#import "BTPayPalDriver.h"

static NSString *braintreePayScheme;

@implementation YSPayPalPay

+ (void) requestPayPalOneTimePayment:(BTPayPalRequest *)request
                         fromSchema:(NSString *)fromScheme
             viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                     switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                         completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion {
    braintreePayScheme = fromScheme;
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    driver.viewControllerPresentingDelegate = viewControllerDelegate;
    driver.appSwitchDelegate = switchDelegate;
    [driver requestOneTimePayment:request completion:completion];
}

+ (void) requestPayPalBillingPayment:(BTPayPalRequest *)request
                          fromSchema:(NSString *)fromScheme
              viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                      switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                          completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion {
    braintreePayScheme = fromScheme;
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
    driver.viewControllerPresentingDelegate = viewControllerDelegate;
    driver.appSwitchDelegate = switchDelegate;
    [driver requestBillingAgreement:request completion:completion];
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
