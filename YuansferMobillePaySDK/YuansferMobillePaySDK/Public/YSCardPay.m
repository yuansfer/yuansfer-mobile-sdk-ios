//
//  YSCardPay.m
//  YuansferMobillePaySDK
//
//  Created by fly.zhu on 2021/3/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSCardPay.h"
#import "BTCard.h"
#import "BTCardNonce.h"
#import "BTCardClient.h"
#import "YSApiClient.h"

@implementation YSCardPay

+ (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion {
    BTAPIClient *apiClient = YSApiClient.sharedInstance.apiClient;
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:apiClient];
    [cardClient tokenizeCard:card completion:completion];
}

@end
