//
//  YSApplePay.h
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTApplePayClient.h"
#import "YSApiClient.h"
#import <PassKit/PKPaymentAuthorizationViewController.h>

typedef void (^PKPaymentAuthorizationResultBlock)(PKPaymentAuthorizationResult *authorizationResult);

typedef void (^PKPaymentRequestShippingMethodUpdateBlock)(PKPaymentRequestShippingMethodUpdate *shippingMethodUpdate);

typedef void (^ApplePayAuthorizationCompletion)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                                                PKPaymentAuthorizationResultBlock authorizationResultBlock);

typedef void (^ApplePayDidSelectShippingMethodCompletion)(PKShippingMethod * shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock);

NS_ASSUME_NONNULL_BEGIN

@interface YSApplePay : NSObject

+ (instancetype)sharedInstance;

- (bool) canApplePayment;

- (void) requestApplePayment:(UIViewController*) viewController
            paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
            shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
            authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                                           PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;

- (void) requestApplePayment:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
              paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;

@end

NS_ASSUME_NONNULL_END
