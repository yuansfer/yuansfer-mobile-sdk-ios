//
//  CardPayPresenter.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2022/11/21.
//  Copyright © 2022 Yuanex, Inc. All rights reserved.
//

#import "CardPayPresenter.h"
#import "BasePayPresenter.h"
#import <YuansferMobillePaySDK/YSCardPay.h>

@implementation CardPayPresenter

+ (instancetype)sharedPresenter {
    static CardPayPresenter *sharedPresenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPresenter = [[self alloc] init];
    });
    return sharedPresenter;
}

- (void) reqCardPayWithJsonStr:(NSString *) jsonStr token:(NSString*) token completion:(void (^)(NSError * error))completionHandler {
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id responseObject = nil;
    NSError *serializationError = nil;
    @autoreleasepool {
        responseObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:kNilOptions
                                                           error:&serializationError];
    }
    if (serializationError) {
        !completionHandler ?: completionHandler([self covertToNSError:@"JSON serializaiton error."]);
        return;
    }
    
    // 初始化
    [[YSApiClient sharedInstance] initBraintreeClient:[[responseObject objectForKey:@"result"] objectForKey:@"authorization"]];
    [self collectDeviceData:[YSApiClient sharedInstance].apiClient];
    
    // 暂写死，需替换真实数据
    BTCard *card = [[BTCard alloc] initWithNumber:@"4111111111111111"
    expirationMonth:@"06"
    expirationYear:@"2022"
                cvv:nil];
    
    [YSCardPay requestCardPayment:card completion:^(BTCardNonce *tokenized, NSError *error) {
        if (error) {
            !completionHandler ?: completionHandler(error);
            return;
        }
        [self sendProcessDataToServer:responseObject token:token nonce:tokenized.nonce completion:completionHandler];
    }];
}

- (void) sendProcessDataToServer:(id) dataJSON token: (NSString*) token nonce:(NSString*)nonce completion:(void (^)(NSError * error))completionHandler {
    
    // 暂写死，需替换真实数据
    NSDictionary* dict = @{
        @"merchantNo":@"202333",
        @"storeNo": @"301854",
        @"addressLine1": @"addressLine1",
        @"addressLine2": @"addressLine2",
        @"city":@"city",
        @"countryCode":@"countryCode",
        @"customerNo": @"customerNo",
        @"deviceData": self.deviceData,
        @"email": @"email",
        @"paymentMethod":@"credit_card",
        @"paymentMethodNonce": nonce,
        @"phone": @"123",
        @"postalCode": @"111",
        @"transactionNo": @"321965643196344588",
        @"recipientName":@"1111",
        @"state":@"state"
    };
    
    [[CardPayPresenter sharedPresenter] processToServer:dict token:token completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 是否出错
            if (error) {
                !completionHandler ?: completionHandler(error);
                return;
            }
            
            // 确保有 response data
            if (data == nil || !data || data.length == 0) {
                !completionHandler ?: completionHandler([self covertToNSError:@"data empty."]);
                return;
            }

            id responseObject = nil;
            NSError *serializationError = nil;
            @autoreleasepool {
                responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&serializationError];
            }
            if (serializationError) {
                !completionHandler ?: completionHandler([self covertToNSError:@"JSON serializaiton error."]);
                 return;
            }
            
            // 检查业务状态码, 注意测试环境的状态码与正式环境状态码有点区别，这里只判断了正式环境的
            if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
                !completionHandler ?: completionHandler([self covertToNSError:[responseObject objectForKey:@"ret_msg"]]);
                return;
            }
            // 支付成功
            !completionHandler ?: completionHandler(nil);
    }];

}

@end
