//
//  YuansferMobillePaySDK.h
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YuansferMobillePaySDK : NSObject

+ (instancetype)sharedInstance;

- (NSString *)version;

- (void)payOrder:(NSString *)orderNo
          amount:(NSNumber *)amount
        currency:(NSString *)currency
         timeout:(NSNumber *)timeout
       goodsInfo:(NSString *)goodsInfo
     description:(nullable NSString *)description
            note:(nullable NSString *)note
       notifyURL:(NSString *)notifyURLStr
         storeNo:(NSString *)storeNo
      merchantNo:(NSString *)merchantNo
           token:(NSString *)token
      fromScheme:(NSString *)scheme
           block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;

- (BOOL)handleOpenURL:(NSURL *)aURL;

@end

NS_ASSUME_NONNULL_END
