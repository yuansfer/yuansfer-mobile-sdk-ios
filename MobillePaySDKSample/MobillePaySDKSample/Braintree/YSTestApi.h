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

+ (void) callPrepay:(NSString *)amount
         completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

+ (void) callProcess:(NSString *)transactionNo
     paymentMethod:(NSString *)paymentMethod
            nonce:(NSString *)nonce
   completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
@end

NS_ASSUME_NONNULL_END
