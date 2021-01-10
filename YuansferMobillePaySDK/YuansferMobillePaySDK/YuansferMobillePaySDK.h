//
//  YuansferMobillePaySDK.h
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTApplePayClient.h"
#import <PassKit/PKPaymentAuthorizationViewController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSPayType) {
    YSPayTypeAlipay = 1,
    YSPayTypeWeChatPay = 2,
    YSPayTypeApplePay = 3
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

- (BTApplePayClient*) getApplePayClient;

- (void) initApplePayAuthorization:(NSString*) authorization;

- (bool) canApplePayment;

- (void) startWechatPay:(NSString *)partnerid
               prepayid:(NSString *)prepayid
               noncestr:(NSString *)noncestr
              timestamp:(NSString *)timestamp
                package:(NSString *)package
                   sign:(NSString *)sign
            fromSchema:(NSString *)fromScheme
                  block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;

- (void) startAlipay:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;

- (void) startApplePaymentByBlock:(UIViewController*) viewController
                        paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
                        shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
                        authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                               PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;

- (void) startApplePaymentByDelegate:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                      paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;

@end

NS_ASSUME_NONNULL_END
