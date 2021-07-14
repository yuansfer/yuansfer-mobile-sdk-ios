//
//  YSPayPalPay.h
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "BTPayPalDriver.h"
#import "BTAppSwitch.h"
#import "BTAPIClient.h"
#import "YSApiClient.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSPayPalPay : NSObject

+ (void) requestPayPalOneTimePayment:(BTPayPalRequest *)request
                         fromSchema:(NSString *)fromScheme
             viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                     switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                          completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;

+ (void) requestPayPalBillingPayment:(BTPayPalRequest *)request
                          fromSchema:(NSString *)fromScheme
              viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                      switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                          completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;

+ (BOOL)handleOpenURL:(NSURL *)url
              options:(NSDictionary *)options;

+ (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(nullable NSString *)sourceApplication;

@end

NS_ASSUME_NONNULL_END
