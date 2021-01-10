//
//  AppleViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/6.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "ApplePayViewController.h"
#import "BTAPIClient.h"
#import "BTApplePayClient.h"
#import "URLConstant.h"
#import "YSProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>
#import <YuansferMobillePaySDK/YuansferMobillePaySDK.h>
//#import "YuansferMobillePaySDK.h"

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
    // init api client in sandbox env
    [[YuansferMobillePaySDK sharedInstance] initApplePayAuthorization:@"sandbox_ktnjwfdk_wfm342936jkm7dg6"];
    // Do any additional setup after loading the view.
    [self prepay];
}

- (void) payProcess:(NSString *)nonce {
    //参数要按字母自然排序后生成signature
    NSMutableString *sign = [NSMutableString string];
    [sign appendFormat:@"addressLine1=%@", @"addressLine1"];
    [sign appendFormat:@"&addressLine2=%@", @"addressLine2"];
    [sign appendFormat:@"&city=%@", @"city"];
    [sign appendFormat:@"&countryCode=%@", @"countryCode"];
    [sign appendFormat:@"&customerNo=%@", @"cid"];
    [sign appendFormat:@"&email=%@", @"123@qq.com"];
    [sign appendFormat:@"&merchantNo=%@", @"202333"];
    [sign appendFormat:@"&paymentMethod=%@", @"apple_pay_card"];
    [sign appendFormat:@"&paymentMethodNonce=%@", nonce];
    [sign appendFormat:@"&paymentType=%@", @"applePay"];
    [sign appendFormat:@"&phone=%@", @"123"];
    [sign appendFormat:@"&postalCode=%@", @"111"];
    [sign appendFormat:@"&recipientName=%@", @"recipientName"];
    [sign appendFormat:@"&state=%@", @"state"];
    [sign appendFormat:@"&storeNo=%@", @"301854"];
    [sign appendFormat:@"&transactionNo=%@", self.transactionNo];
    [sign appendFormat:@"&%@", [self md5String:@"17cfc0170ef1c017b4a929d233d6e65e"]];
    
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"addressLine1=%@", @"addressLine1"];
    [body appendFormat:@"&addressLine2=%@", @"addressLine2"];
    [body appendFormat:@"&city=%@", @"city"];
    [body appendFormat:@"&countryCode=%@", @"countryCode"];
    [body appendFormat:@"&customerNo=%@", @"cid"];
    [body appendFormat:@"&email=%@", @"123@qq.com"];
    [body appendFormat:@"&merchantNo=%@", @"202333"];
    [body appendFormat:@"&paymentMethod=%@", @"apple_pay_card"];
    [body appendFormat:@"&paymentMethodNonce=%@", nonce];
    [body appendFormat:@"&paymentType=%@", @"applePay"];
    [body appendFormat:@"&phone=%@", @"123"];
    [body appendFormat:@"&postalCode=%@", @"111"];
    [body appendFormat:@"&recipientName=%@", @"recipientName"];
    [body appendFormat:@"&state=%@", @"state"];
    [body appendFormat:@"&storeNo=%@", @"301854"];
    [body appendFormat:@"&transactionNo=%@", self.transactionNo];
    [body appendFormat:@"&%@=%@", @"verifySign", [self md5String:[sign copy]]];
    
    // 2、转圈。
    [YSProgressHUD show];
    [YSProgressHUD setDefaultMaskType:YSProgressHUDMaskTypeClear];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, @"creditpay/v3/process"]]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        [YSProgressHUD dismiss];
        
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
            self.resultLabel.text = @"Apple Pay支付成功";
        });
        
    }];
    [task resume];
}

- (void) prepay {
    //参数要按字母自然排序后生成signature
    NSString* refNo = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    NSMutableString *sign = [NSMutableString string];
    [sign appendFormat:@"amount=%@", @"0.01"];
    [sign appendFormat:@"&creditType=%@", @"yip"];
    [sign appendFormat:@"&currency=%@", @"USD"];
    [sign appendFormat:@"&description=%@", @"description"];
    [sign appendFormat:@"&ipnUrl=%@", @"ipnUrl"];
    [sign appendFormat:@"&merchantNo=%@", @"202333"];
    [sign appendFormat:@"&note=%@", @"note"];
    [sign appendFormat:@"&reference=%@", refNo];
    [sign appendFormat:@"&settleCurrency=%@", @"USD"];
    [sign appendFormat:@"&storeNo=%@", @"301854"];
    [sign appendFormat:@"&terminal=%@", @"APP"];
    [sign appendFormat:@"&timeout=%@", @"120"];
    [sign appendFormat:@"&vendor=%@", @"paypal"];
    [sign appendFormat:@"&%@", [self md5String:@"17cfc0170ef1c017b4a929d233d6e65e"]];
    
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"%@=%@", @"amount", @"0.01"];
     [body appendFormat:@"&%@=%@", @"currency", @"USD"];
     [body appendFormat:@"&%@=%@", @"settleCurrency", @"USD"];
     [body appendFormat:@"&%@=%@", @"creditType", @"yip"];
     [body appendFormat:@"&%@=%@", @"merchantNo", @"202333"];
     [body appendFormat:@"&%@=%@", @"storeNo", @"301854"];
     [body appendFormat:@"&%@=%@", @"description", @"description"];
     [body appendFormat:@"&%@=%@", @"ipnUrl", @"ipnUrl"];
     [body appendFormat:@"&%@=%@", @"note", @"note"];
     [body appendFormat:@"&%@=%@", @"reference", refNo];
     [body appendFormat:@"&%@=%@", @"terminal", @"APP"];
     [body appendFormat:@"&%@=%@", @"timeout", @"120"];
     [body appendFormat:@"&%@=%@", @"vendor", @"paypal"];
     [body appendFormat:@"&%@=%@", @"verifySign", [self md5String:[sign copy]]];
    
    // 2、转圈。
    [YSProgressHUD show];
    [YSProgressHUD setDefaultMaskType:YSProgressHUDMaskTypeClear];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, @"online/v3/secure-pay"]]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
         [YSProgressHUD dismiss];
        
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
        strongSelf.authorization = [[responseObject objectForKey:@"result"] objectForKey:@"authorization"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.resultLabel.text = [[responseObject objectForKey:@"result"] objectForKey:@"authorization"];
            [[YuansferMobillePaySDK sharedInstance] initApplePayAuthorization:strongSelf.authorization];
            [strongSelf.applePayContainer addSubview:[strongSelf createPaymentButton]];
        });
    }];
    [task resume];
}
#pragma mark - private method

- (NSString *)md5String:(NSString *)string {
    const char *str = [string UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5Value = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15]];
    
    return md5Value;
}

- (UIControl *) createPaymentButton {
    if (![[YuansferMobillePaySDK sharedInstance] canApplePayment]) {
        NSLog(@"canMakePayments returns NO, hiding Apple Pay button");
        return nil;
    }
    UIButton *button;
    if (@available(iOS 8.3, *)) {
        if ([PKPaymentButton class]) { // Available in iOS 8.3+
            button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
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
    [[YuansferMobillePaySDK sharedInstance] startApplePaymentByBlock:self
                                            paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (error) {
            strongSelf.resultLabel.text = error.localizedDescription;
            return;
        }

        //实例在sdk被创建，只要配置PkPaymentRequest,如运费、联系人等信息即可。
        paymentRequest.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldName, nil];
        PKShippingMethod *shippingMethod1 = [PKShippingMethod summaryItemWithLabel:@"✈️ Flight Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"1.00"]];
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
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod1.amount],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"14.99"]]
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
