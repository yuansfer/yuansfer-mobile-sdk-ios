//
//  YSTestApi.h
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/14.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSTestApi : NSObject

+ (void) callWechatAlipayPrepay:(NSDictionary *) data
                          token:(NSString *) token
                     completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

+ (void) callBraintreePrepay:(NSString *)amount
         completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

+ (void) callBraintreeProcess:(NSString *)transactionNo
     paymentMethod:(NSString *)paymentMethod
            nonce:(NSString *)nonce
          deviceData:(NSString *)deviceData
   completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
