//
//  DropInUIViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/18.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "DropInUIViewController.h"
#import "VenmoViewController.h"
#import "BTAPIClient.h"
#import "YSTestApi.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import <YuansferMobillePaySDK/YSApplePay.h>

@interface DropInUIViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (nonatomic, copy) NSString *transactionNo;
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) PKPaymentAuthorizationResultBlock authorizationResultBlock;

@end

@implementation DropInUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepay];
}

- (void) prepay {
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
        
        // 检查业务状态码
        if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"ret_msg"]];
            });
             return;
        }
        
        strongSelf.transactionNo = [[responseObject objectForKey:@"result"] objectForKey:@"transactionNo"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.payButton.hidden = NO;
            strongSelf.resultLabel.text = @"prepay接口调用成功,可选择支付方式";
             strongSelf.authToken = [[responseObject objectForKey:@"result"] objectForKey:@"authorization"];
            //采集deviceData
            [strongSelf collectDeviceData:[[BTAPIClient alloc] initWithAuthorization:strongSelf.authToken]];
        });
    }];
}

- (void) payProcess:(BTUIKPaymentOptionType) type
                reqNonce:(NSString *) nonce
         deviceData:(NSString *)deviceData {
    // 1、根据支付方式传值
    NSString *paymentMethod;
    if (type == BTUIKPaymentOptionTypePayPal) {
        paymentMethod = @"paypal_account";
    } else if (type == BTUIKPaymentOptionTypeVenmo) {
        paymentMethod = @"venmo_account";
    } else if (type == BTUIKPaymentOptionTypeApplePay) {
        paymentMethod = @"apple_pay_card";
    } else {
        paymentMethod = @"credit_card";
    }
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callProcess:self.transactionNo paymentMethod:paymentMethod nonce:nonce
                deviceData:deviceData
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
            //显示支付成功
            self.resultLabel.text = @"Drop-In Pay支付成功";
            if (self.authorizationResultBlock) {
                //通知ApplePay支付成功
                self.authorizationResultBlock([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
                self.authorizationResultBlock = nil;
            }
        });
    }];
}

- (IBAction)tappedPayButton:(id)sender {
    __weak __typeof(self)weakSelf = self;
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:self.authToken request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [controller dismissViewControllerAnimated:YES completion:nil];
        if (error != nil) {
            NSLog(@"ERROR:%@", error);
            strongSelf.resultLabel.text = [NSString stringWithFormat:@"错误:%@", error];
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            strongSelf.resultLabel.text = @"用户取消";
        } else {
            NSString *nonce = result.paymentMethod.nonce;
            BTUIKPaymentOptionType type = result.paymentOptionType;
            NSLog(@"Drop-in result type:%ld, nonce:%@, icon:%@", (long)type, nonce, result.paymentIcon);
            if (nonce) {
                strongSelf.resultLabel.text = @"正在发起支付处理...";
                [strongSelf payProcess:type
                        reqNonce:nonce
                 deviceData:strongSelf.deviceData];
            } else if (type == BTUIKPaymentOptionTypeApplePay) {
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
                         strongSelf.authorizationResultBlock = authorizationResultBlock;
                         //上传nonce至server创建并完成支付交易后在这里通知Apple Pay
                         [strongSelf payProcess:type
                                 reqNonce:tokenizedApplePayPayment.nonce
                                deviceData:strongSelf.deviceData];
                     }
                }];
            }
        }
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}

@end
