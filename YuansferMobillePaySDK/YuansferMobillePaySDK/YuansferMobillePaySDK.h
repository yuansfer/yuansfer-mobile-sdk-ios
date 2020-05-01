//
//  YuansferMobillePaySDK.h
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YSPayType) {
    YSPayTypeAlipay = 1,
    YSPayTypeWeChatPay,
};

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
 调起第三方支付。

 @param orderNo 商家订单号。
 @param amount 订单总金额。
 @param currency 货币。
 @param description 商品描述。
 @param note 商品备注。
 @param notifyURLStr 订单支付完成通知商家后端的 URL。
 @param storeNo 从 Yuansfer 获取到的 storeNo。
 @param merchantNo 从 Yuansfer 获取到的 merchantNo。
 @param merGroupNo 从 Yuansfer 获取到的 merGroupNo。
 @param payType 第三方支付类型：支付宝、微信支付。
 @param token 从 Yuansfer 获取到的 token。
 @param scheme 应用 URL Scheme，请在 Xcode 中配置并在此处正确填写，用于从支付宝、微信支付后跳回。
 @param block 支付结果回调。
 */
- (void)payOrder:(NSString *)orderNo
          amount:(NSNumber *)amount
        currency:(NSString *)currency
     description:(nullable NSString *)description
            note:(nullable NSString *)note
       notifyURL:(NSString *)notifyURLStr
         storeNo:(NSString *)storeNo
      merchantNo:(NSString *)merchantNo
      merGroupNo:(nullable NSString *)merGroupNo
          vendor:(YSPayType)payType
           token:(NSString *)token
      fromScheme:(NSString *)scheme
           block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;


/**
 支付后跳回的处理方法。

 @param aURL 支付结束调起应用的 URL。
 @return 如果成功处理了请求，则为 YES；如果尝试处理 URL 失败，则为 NO。
 */
- (BOOL)handleOpenURL:(NSURL *)aURL;

@end

NS_ASSUME_NONNULL_END
