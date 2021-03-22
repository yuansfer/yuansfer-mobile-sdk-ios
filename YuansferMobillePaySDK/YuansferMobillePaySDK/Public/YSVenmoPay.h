//
//  YSVenmoPay.h
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "BTAPIClient.h"
#import "YSApiClient.h"
#import "BTVenmoDriver.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSVenmoPay : NSObject

+ (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock;

+ (BOOL)handleOpenURL:(NSURL *)aURL;

@end

NS_ASSUME_NONNULL_END
