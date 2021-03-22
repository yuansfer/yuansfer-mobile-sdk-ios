//
//  YSApplePay.m
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSApplePay.h"
#import "BTApplePayClient.h"
#import "YSApiClient.h"
#import <PassKit/PKPaymentAuthorizationViewController.h>

@interface YSApplePay () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, copy) ApplePayAuthorizationCompletion applePayAuthorizationResponse;
@property (nonatomic, copy) ApplePayDidSelectShippingMethodCompletion applePayDidSelectShippingMethodReponse;
@property (nonatomic, strong) BTApplePayClient *applePayClient;

@end

@implementation YSApplePay

+ (instancetype)sharedInstance {
    static YSApplePay *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (bool) canApplePayment {
    return [PKPaymentAuthorizationViewController canMakePayments];
}

- (void) requestApplePayment:(UIViewController*) viewController
            paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
            shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
            authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                                           PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse {
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    self.applePayClient = [[BTApplePayClient alloc] initWithAPIClient:apiClient];
    self.applePayAuthorizationResponse = authorizaitonResponse;
    self.applePayDidSelectShippingMethodReponse = shippingMethodReponse;
    [self.applePayClient paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
        if (error) {
            paymentRequestConfig(nil, error);
            return;
        }
        paymentRequestConfig(paymentRequest, nil);
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        vc.delegate = self;
        [viewController presentViewController:vc animated:YES completion:nil];
    }];
}

- (void) requestApplePayment:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                            paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig {
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    self.applePayClient = [[BTApplePayClient alloc] initWithAPIClient:apiClient];
    [self.applePayClient paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
        if (error) {
            paymentRequestConfig(nil, error);
            return;
        }
        paymentRequestConfig(paymentRequest, nil);
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        vc.delegate = delegate;
        [viewController presentViewController:vc animated:YES completion:nil];
    }];
}

#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion {
    [self.applePayClient tokenizeApplePayPayment:payment completion:^(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        self.applePayAuthorizationResponse(tokenizedApplePayPayment, error, completion);
    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                   handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull)) completion {
    self.applePayDidSelectShippingMethodReponse(shippingMethod, completion);
}

@end
