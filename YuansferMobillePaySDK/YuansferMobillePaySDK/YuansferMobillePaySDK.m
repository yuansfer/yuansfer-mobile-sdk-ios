//
//  YuansferMobillePaySDK.m
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "YuansferMobillePaySDK.h"
#import "AlipaySDK.h"
#import "WXApi.h"
#import "BTAPIClient.h"
#import "BTApplePayClient.h"
#import "BTCardClient.h"
#import "BTCard.h"
#import "BTVenmoDriver.h"
#import <PassKit/PKPaymentAuthorizationViewController.h>

const NSErrorDomain YSErrorDomain = @"YSErrorDomain";
const NSErrorDomain YSAlipayErrorDomain = @"YSAlipayErrorDomain";
const NSErrorDomain YSWeChatPayErrorDomain = @"YSWeChatPayErrorDomain";
const NSErrorDomain YSWeApplePayErrorDomain = @"YSWeApplePayErrorDomain";

static NSString * const YSMobillePaySDKVersion = @"1.1.5";

typedef void (^Completion)(NSDictionary *results, NSError *error);

typedef void (^PKPaymentAuthorizationResultBlock)(PKPaymentAuthorizationResult *authorizationResult);

typedef void (^PKPaymentRequestShippingMethodUpdateBlock)(PKPaymentRequestShippingMethodUpdate *shippingMethodUpdate);

typedef void (^ApplePayAuthorizationCompletion)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                                                PKPaymentAuthorizationResultBlock authorizationResultBlock);

typedef void (^ApplePayDidSelectShippingMethodCompletion)(PKShippingMethod * shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock);

@interface YuansferMobillePaySDK () <WXApiDelegate, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, copy) Completion completion;
@property (nonatomic, copy) ApplePayAuthorizationCompletion applePayAuthorizationResponse;
@property (nonatomic, copy) ApplePayDidSelectShippingMethodCompletion applePayDidSelectShippingMethodReponse;

@property (nonatomic, copy) NSString *theAlipayScheme;
@property (nonatomic, copy) NSString *theWeChatPayScheme;
@property (nonatomic, copy) NSString *theVenmoPayScheme;

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTApplePayClient *applePayClient;

@end

@implementation YuansferMobillePaySDK

#pragma mark - public method

+ (instancetype)sharedInstance {
    static YuansferMobillePaySDK *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)version {
    return YSMobillePaySDKVersion;
}

- (void) initBraintreeClient:(NSString*) authorization {
    self.apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
}

- (bool) canApplePayment {
    return [PKPaymentAuthorizationViewController canMakePayments];
}

- (void) requestWechatPayment:(NSString *)partnerid
               prepayid:(NSString *)prepayid
               noncestr:(NSString *)noncestr
              timestamp:(NSString *)timestamp
                package:(NSString *)package
                   sign:(NSString *)sign
             fromSchema:(NSString *)fromScheme
                  block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {
    // 初始化微信，只初始化一次。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXApi registerApp:fromScheme enableMTA:NO];
    });

    // 是否安装微信。
    if (![WXApi isWXAppInstalled]) {
        !block ?: block(nil, [NSError errorWithDomain:YSWeChatPayErrorDomain code:9001 userInfo:@{NSLocalizedDescriptionKey: @"用户未安装微信。"}]);
        return;
    }
    self.completion = block;
    self.theWeChatPayScheme = fromScheme;
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerid;
    request.prepayId = prepayid;
    request.nonceStr = noncestr;
    request.timeStamp = [timestamp intValue];
    request.package = package;
    request.sign = sign;
    [WXApi sendReq:request];
}

- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {
    self.completion = block;
    self.theAlipayScheme = fromScheme;
    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:fromScheme callback:^(NSDictionary *resultDic) {
        if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
            NSArray *results = [[resultDic objectForKey:@"result"] componentsSeparatedByString:@"&"];
            BOOL success = NO;
            for (NSString *substring in results) {
                if ([substring isEqualToString:@"success=\"true\""]) {
                    success = YES;
                    break;
                }
            }
            if (success != NO) {
                // resultStatus=9000,success="true"
                !block ?: block(resultDic, nil);
            } else {
                !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrorDomain
                                                         code:9000
                                                     userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
            }
        } else {
            !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrorDomain
                                                     code:[[resultDic objectForKey:@"resultStatus"] integerValue]
                                                 userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
        }
    }];
}

- (void) requestApplePaymentByBlock:(UIViewController*) viewController
            paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
            shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
            authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                                           PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse {
    self.applePayClient = [[BTApplePayClient alloc] initWithAPIClient:self.apiClient];
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

- (void) requestApplePaymentByDelegate:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                            paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig {
    self.applePayClient = [[BTApplePayClient alloc] initWithAPIClient:self.apiClient];
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

- (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion {
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    [cardClient tokenizeCard:card completion:completion];
}

- (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock {
    self.theVenmoPayScheme = fromScheme;
    BTVenmoDriver *venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
    [venmoDriver authorizeAccountAndVault:vault completion:completionBlock];
}

- (BOOL)handleOpenURL:(NSURL *)aURL {
    if ([aURL.scheme isEqualToString:self.theAlipayScheme]) {
        __weak __typeof(self)weakSelf = self;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:aURL standbyCallback:^(NSDictionary *resultDic) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                NSArray *results = [[resultDic objectForKey:@"result"] componentsSeparatedByString:@"&"];
                BOOL success = NO;
                for (NSString *substring in results) {
                    if ([substring isEqualToString:@"success=\"true\""]) {
                        success = YES;
                        break;
                    }
                }
                if (success != NO) {
                    // resultStatus=9000,success="true"
                    !strongSelf.completion ?: strongSelf.completion(resultDic, nil);
                } else {
                    !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrorDomain code:9000 userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
                }
            } else {
                !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrorDomain code:[[resultDic objectForKey:@"resultStatus"] integerValue] userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
            }
        }];
        
        return YES;
    } else if ([aURL.scheme isEqualToString:self.theWeChatPayScheme]) {
        return [WXApi handleOpenURL:aURL delegate:self];
    } else if ([aURL.scheme isEqualToString:self.theVenmoPayScheme]) {
        [BTAppSwitch handleOpenURL:aURL];
    }
    
    return NO;
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:PayResp.class]) {
        if (resp.errCode == 0) {
            // 成功
            !self.completion ?: self.completion(@{@"errCode": @(resp.errCode), @"type": @(resp.type), @"errStr": (resp.errStr ? resp.errStr : @"")}, nil);
        } else {
            NSString *errMsg = @"";
            switch (resp.errCode) {
                case -1:
                    errMsg = @"普通错误类型";
                    break;
                case -2:
                    errMsg = @"用户点击取消并返回";
                    break;
                case -3:
                    errMsg = @"发送失败";
                    break;
                case -4:
                    errMsg = @"授权失败";
                    break;
                case -5:
                    errMsg = @"微信不支持";
                    break;
                default:
                    break;
            }
            
            !self.completion ?: self.completion(nil, [NSError errorWithDomain:YSWeChatPayErrorDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: errMsg}]);
        }
    }
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
