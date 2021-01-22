//
//  YuansferMobillePaySDK.h
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.

#import "BTApplePayClient.h"
#import <Foundation/Foundation.h>
#import <PassKit/PKPaymentAuthorizationViewController.h>
#import "BTCardNonce.h"
#import "BTCard.h"
#import "BTVenmoDriver.h"
#import "BTPayPalDriver.h"
#import "BTPayPalRequest.h"
#import "BTPayPalAccountNonce.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSPayType) {
    YSPayTypeAlipay = 1,
    YSPayTypeWeChatPay = 2,
};

extern const NSErrorDomain YSErrorDomain;
extern const NSErrorDomain YSAlipayErrorDomain;
extern const NSErrorDomain YSWeChatPayErrorDomain;
extern const NSErrorDomain YSWeApplePayErrorDomain;

typedef void (^PKPaymentAuthorizationResultBlock)(PKPaymentAuthorizationResult *authorizationResult);

typedef void (^PKPaymentRequestShippingMethodUpdateBlock)(PKPaymentRequestShippingMethodUpdate *shippingMethodUpdate);

@interface YuansferMobillePaySDK : NSObject

/**
 本 SDK 单例。

 @return SDK 实例。
 */
+ (instancetype)sharedInstance;


/**
 本 SDK 版本号。

 @return SDK 当前版本号，格式如：1.1.0。
 */
- (NSString *)version;

/**
 支付后跳回的处理方法。

 @param aURL 支付结束调起应用的 URL。
 @return 如果成功处理了请求，则为 YES；如果尝试处理 URL 失败，则为 NO。
 */
- (BOOL)handleOpenURL:(NSURL *)aURL;

- (void) initBraintreeClient:(NSString*) authorization;

- (bool) canApplePayment;

- (void) requestWechatPayment:(NSString *)partnerid
               prepayid:(NSString *)prepayid
               noncestr:(NSString *)noncestr
              timestamp:(NSString *)timestamp
                package:(NSString *)package
                   sign:(NSString *)sign
            fromSchema:(NSString *)fromScheme
                  block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;

- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;

- (void) requestApplePayment:(UIViewController*) viewController
                        paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
                        shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
                        authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                               PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;

- (void) requestApplePayment:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                      paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;

- (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

- (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock;

- (void) requestPayPalOneTimePayment:(BTPayPalRequest *)request
                        fromSchema:(NSString *)fromScheme
            viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                    switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                                      completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;

- (void) requestPayPalBillingPayment:(BTPayPalRequest *)request
                        fromSchema:(NSString *)fromScheme
            viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                    switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                                      completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;

@end

NS_ASSUME_NONNULL_END
