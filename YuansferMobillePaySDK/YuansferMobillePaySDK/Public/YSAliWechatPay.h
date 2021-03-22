//
//  YSAliWechatPay.h
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.

#import <Foundation/Foundation.h>

extern const NSErrorDomain YSErrDomain;
extern const NSErrorDomain YSAlipayErrDomain;
extern const NSErrorDomain YSWechatErrDomain;

typedef NS_ENUM(NSInteger, YSPayType) {
    YSPayTypeAlipay = 1,
    YSPayTypeWeChatPay = 2,
};

@interface YSAliWechatPay : NSObject

+ (instancetype)sharedInstance;

/**
 支付后跳回的处理方法。

 @param aURL 支付结束调起应用的 URL。
 @return 如果成功处理了请求，则为 YES；如果尝试处理 URL 失败，则为 NO。
 */
- (BOOL)handleOpenURL:(NSURL *)aURL;

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


@end

