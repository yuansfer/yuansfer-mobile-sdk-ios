//
//  YSCardPay.h
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "BTCard.h"
#import "BTCardNonce.h"
#import "BTCardClient.h"
#import "YSApiClient.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSCardPay : NSObject
    + (void) requestCardPayment:(BTCard *)card
                     completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END
