//
//  AppleViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/6.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "ApplePayViewController.h"
#import <YuansferMobillePaySDK/YSApplePay.h>
#import <PassKit/PKPaymentRequestStatus.h>
#import <PassKit/PKPaymentButton.h>
#import "YSTestApi.h"

@interface ApplePayViewController ()

@property (nonatomic, copy) NSString *transactionNo;
@property (nonatomic, copy) NSString *authorization;
@property (nonatomic, copy) PKPaymentAuthorizationResultBlock authorizationResultBlock;

@property (weak, nonatomic) IBOutlet UIView *applePayContainer;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ApplePayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepay];
}

- (void) prepay {
    // 2、转圈。
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callPrepay:@"0.01"
               completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        // 是否出错
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = error.localizedDescription;
            });
             return;
        }
        
        // 验证 response 类型
        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = @"Response is not a HTTP URL response.";
            });
             return;
        }
        
        // 验证 response code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"HTTP response status code error, statusCode = %ld.", (long)httpResponse.statusCode];
            });
             return;
        }
        
        // 确保有 response data
        if (data == nil || !data || data.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = @"No response data.";
            });
             return;
        }
        
        // 确保 JSON 解析成功
        id responseObject = nil;
        NSError *serializationError = nil;
        @autoreleasepool {
            responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&serializationError];
        }
        if (serializationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Deserialize JSON error, %@", serializationError.localizedDescription];
            });
             return;
        }
        
        // 检查业务状态码, 注意测试环境的状态码与正式环境状态码有点区别，这里只判断了正式环境的
        if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"ret_msg"]];
            });
             return;
        }
        
        strongSelf.transactionNo = [[responseObject objectForKey:@"result"] objectForKey:@"transactionNo"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.resultLabel.text = @"prepay接口调用成功,可提交支付数据进行处理";
            [strongSelf.applePayContainer addSubview:[strongSelf createPaymentButton]];
            // 注意，下一行是静态测试授权码，仅用于测试，实际项目中应该是下二行从服务器接口获取动态授权码
            [[YSApiClient sharedInstance] initBraintreeClient:@"sandbox_ktnjwfdk_wfm342936jkm7dg6"];
            // [[YSApiClient sharedInstance] initBraintreeClient:[[responseObject objectForKey:@"result"] objectForKey:@"authorization"]];
            [strongSelf collectDeviceData:[YSApiClient sharedInstance].apiClient];
        });
    }];
}

- (void) payProcess:(NSString *)nonce {
    // 2、转圈。
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callProcess:self.transactionNo paymentMethod:@"apple_pay_card" nonce:nonce
                deviceData:self.deviceData
         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        // 是否出错
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = error.localizedDescription;
            });
             return;
        }
        
        // 验证 response 类型
        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = @"Response is not a HTTP URL response.";
            });
             return;
        }
        
        // 验证 response code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"HTTP response status code error, statusCode = %ld.", (long)httpResponse.statusCode];
            });
             return;
        }
        
        // 确保有 response data
        if (!data || data.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = @"No response data.";
            });
             return;
        }
        
        // 确保 JSON 解析成功
        id responseObject = nil;
        NSError *serializationError = nil;
        @autoreleasepool {
            responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&serializationError];
        }
        if (serializationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Deserialize JSON error, %@", serializationError.localizedDescription];
            });
             return;
        }
        
        // 检查业务状态码
        if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"ret_msg"]];
            });
             return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //通知ApplePay支付成功
            self.authorizationResultBlock([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
            //显示支付成功
            strongSelf.resultLabel.text = @"Apple Pay支付成功";
        });
    }];
}

- (UIControl *) createPaymentButton {
    if (![[YSApplePay sharedInstance] canApplePayment]) {
        NSLog(@"canMakePayments returns NO, hiding Apple Pay button");
        return nil;
    }
    UIButton *button;
    if (@available(iOS 8.3, *)) {
        if ([PKPaymentButton class]) { // Available in iOS 8.3+
            button = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
        } else {
            // TODO: Create and return your own apple pay button
            // button = ...
        }
    } else {
        // Fallback on earlier versions
    }
    [button addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void) tappedApplePayButton {
    __weak __typeof(self)weakSelf = self;
    //第一种调用方法(Block形式)，简单易用，当不能满足需求时请使用第二种方法
    [[YSApplePay sharedInstance] requestApplePayment:self
                                            paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            strongSelf.resultLabel.text = error.localizedDescription;
            return;
        }

        //实例在sdk被创建，只要配置PkPaymentRequest,如运费、联系人等信息即可。
        paymentRequest.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldName, nil];
        PKShippingMethod *shippingMethod1 = [PKShippingMethod summaryItemWithLabel:@"✈️ Flight Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        shippingMethod1.detail = @"Fast but expensive";
        shippingMethod1.identifier = @"fast";
        PKShippingMethod *shippingMethod2 = [PKShippingMethod summaryItemWithLabel:@"🐢 Slow Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
        shippingMethod2.detail = @"Slow but free";
        shippingMethod2.identifier = @"slow";
        PKShippingMethod *shippingMethod3 = [PKShippingMethod summaryItemWithLabel:@"💣 Unavailable Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0xdeadbeef"]];
        shippingMethod3.detail = @"It will make Apple Pay fail";
        shippingMethod3.identifier = @"fail";
        paymentRequest.shippingMethods = @[shippingMethod1, shippingMethod2, shippingMethod3];
        paymentRequest.requiredShippingContactFields = [NSSet setWithObjects:PKContactFieldName, PKContactFieldPhoneNumber, PKContactFieldEmailAddress, nil];
        paymentRequest.paymentSummaryItems = @[
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod1.amount],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"0.02"]]
                                               ];

        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
        if ([paymentRequest respondsToSelector:@selector(setShippingType:)]) {
            paymentRequest.shippingType = PKShippingTypeDelivery;
        }
    } shippingMethodUpdate:^(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock) {
        NSLog(@"Apple Pay shipping method selected");
        PKPaymentSummaryItem *testItem = [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM"
                                                                             amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingMethodUpdate alloc] initWithPaymentSummaryItems:@[testItem]];

        if ([shippingMethod.identifier isEqualToString:@"fast"]) {
            shippingMethodUpdateBlock(update);
        } else if ([shippingMethod.identifier isEqualToString:@"fail"]) {
            update.status = PKPaymentAuthorizationStatusFailure;
            shippingMethodUpdateBlock(update);
        } else {
            shippingMethodUpdateBlock(update);
        }
    } authorizaitonResponse:^(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                              PKPaymentAuthorizationResultBlock authorizationResultBlock) {
         NSLog(@"Apple Pay Did Authorize Payment，error=%@", error);
         __strong __typeof(weakSelf)strongSelf = weakSelf;
         if (error) {
             authorizationResultBlock([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
            //显示支付报错
             strongSelf.resultLabel.text = error.localizedDescription;
         } else {
             self.authorizationResultBlock = authorizationResultBlock;
             //上传nonce至server创建并完成支付交易后在这里通知Apple Pay
             [self payProcess:tokenizedApplePayPayment.nonce];
         }
    }];
    
    //第二种调用形式(Protocol形式)，实现类似下方相应的Protocol方法，处理相关的回调,该方法自定义全面
//    [[YuansferMobillePaySDK sharedInstance] startApplePaymentByDelegate:self delegate:self paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
//        if (error) {
//            return;
//        }
//
//        // Requiring PKAddressFieldPostalAddress crashes Simulator
//        //paymentRequest.requiredBillingAddressFields = PKAddressFieldName|PKAddressFieldPostalAddress;
//        paymentRequest.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldName, nil];
//
//        PKShippingMethod *shippingMethod1 = [PKShippingMethod summaryItemWithLabel:@"✈️ Fast Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"4.99"]];
//        shippingMethod1.detail = @"Fast but expensive";
//        shippingMethod1.identifier = @"fast";
//        PKShippingMethod *shippingMethod2 = [PKShippingMethod summaryItemWithLabel:@"🐢 Slow Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
//        shippingMethod2.detail = @"Slow but free";
//        shippingMethod2.identifier = @"slow";
//        PKShippingMethod *shippingMethod3 = [PKShippingMethod summaryItemWithLabel:@"💣 Unavailable Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0xdeadbeef"]];
//        shippingMethod3.detail = @"It will make Apple Pay fail";
//        shippingMethod3.identifier = @"fail";
//        paymentRequest.shippingMethods = @[shippingMethod1, shippingMethod2, shippingMethod3];
//        paymentRequest.requiredShippingContactFields = [NSSet setWithObjects:PKContactFieldName, PKContactFieldPhoneNumber, PKContactFieldEmailAddress, nil];
//        paymentRequest.paymentSummaryItems = @[
//            [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
//            [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod1.amount],
//            [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"14.99"]]
//        ];
//
//        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
//        if ([paymentRequest respondsToSelector:@selector(setShippingType:)]) {
//            paymentRequest.shippingType = PKShippingTypeDelivery;
//        }
//    }];
}

//- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
//    [controller dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
//                       didAuthorizePayment:(PKPayment *)payment
//                                   handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion {
//    [[[YuansferMobillePaySDK sharedInstance] getApplePayClient] tokenizeApplePayPayment:payment completion:^(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
//        if (error) {
//            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
//        } else {
//            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
//        }
//    }];
//}
//
//- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
//                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
//                                   handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull))completion {
//    PKPaymentSummaryItem *testItem = [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM"
//                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
//    PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingMethodUpdate alloc] initWithPaymentSummaryItems:@[testItem]];
//
//    if ([shippingMethod.identifier isEqualToString:@"fast"]) {
//        completion(update);
//    } else if ([shippingMethod.identifier isEqualToString:@"fail"]) {
//        update.status = PKPaymentAuthorizationStatusFailure;
//        completion(update);
//    } else {
//        completion(update);
//    }
//}
//
//- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(__unused PKPaymentAuthorizationViewController *)controller {
//}

@end
