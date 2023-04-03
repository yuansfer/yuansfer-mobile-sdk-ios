//
//  PayPalViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "PayPalViewController.h"
#import <YuansferMobillePaySDK/YSPayPalPay.h>
#import "YSTestApi.h"
#import "URLConstant.h"

@interface PayPalViewController ()<BTViewControllerPresentingDelegate,BTAppSwitchDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *payOnetimeButton;
@property (weak, nonatomic) IBOutlet UIButton *payBillingButton;
@property (nonatomic, copy) NSString *transactionNo;
@end

@implementation PayPalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepay];
}

- (void) prepay {
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callBraintreePrepay:@"0.01"
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
            strongSelf.payBillingButton.hidden = NO;
            strongSelf.payOnetimeButton.hidden = NO;
            strongSelf.resultLabel.text = @"prepay接口调用成功,可提交支付数据进行处理";
             [[YSApiClient sharedInstance] initBraintreeClient:[[responseObject objectForKey:@"result"] objectForKey:@"authorization"]];
            [strongSelf collectDeviceData:[YSApiClient sharedInstance].apiClient];
        });
    }];
}

- (void) payProcess:(NSString *)nonce {
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callBraintreeProcess:self.transactionNo paymentMethod:@"paypal_account" nonce:nonce
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
        
        // 检查业务状态码, 注意测试环境的状态码与正式环境状态码有点区别，这里只判断了正式环境的
        if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                strongSelf.resultLabel.text = [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"ret_msg"]];
            });
             return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //显示支付成功
            strongSelf.resultLabel.text = @"PayPal Pay支付成功";
        });
    }];
}

- (IBAction)tappedPayOnetimeButton:(id)sender {
    __weak __typeof(self)weakSelf = self;
    BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:@"0.01"];
    request.displayName = @"PayPal Test";
    [YSPayPalPay requestPayPalOneTimePayment:request fromSchema:BT_URL_SCHEMA viewControllerDelegate:self switchDelegate:self completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (payPalAccount) {
            NSLog(@"Got a nonce! %@", payPalAccount.nonce);
            BTPostalAddress *address = payPalAccount.billingAddress;
            NSLog(@"Billing address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2);
            [self payProcess:payPalAccount.nonce];
        } else if (error) {
            strongSelf.resultLabel.text = [NSString stringWithFormat:@"PayPal Onetime失败:%@", error];
        } else {
            strongSelf.resultLabel.text = @"PayPal Onetime取消";
        }
    }];
}

- (IBAction)tappedPayBillingButton:(id)sender {
    __weak __typeof(self)weakSelf = self;
    BTPayPalRequest *request = [[BTPayPalRequest alloc] initWithAmount:@"0.01"];
    request.displayName = @"PayPal Test";
    [YSPayPalPay requestPayPalBillingPayment:request fromSchema:BT_URL_SCHEMA viewControllerDelegate:self switchDelegate:self completion:^(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (payPalAccount) {
            NSLog(@"Got a nonce! %@", payPalAccount.nonce);
            BTPostalAddress *address = payPalAccount.billingAddress;
            NSLog(@"Billing address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2);
             [self payProcess:payPalAccount.nonce];
        } else if (error) {
            strongSelf.resultLabel.text = [NSString stringWithFormat:@"PayPal Billing失败:%@", error];
        } else {
            strongSelf.resultLabel.text = @"PayPal Billing取消";
        }
    }];
}

#pragma mark - BTViewControllerPresentingDelegate

// Required
- (void)paymentDriver:(id)paymentDriver
requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Required
- (void)paymentDriver:(id)paymentDriver
requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTAppSwitchDelegate

// Optional - display and hide loading indicator UI
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    [self showLoadingUI];

    // You may also want to subscribe to UIApplicationDidBecomeActiveNotification
    // to dismiss the UI when a customer manually switches back to your app since
    // the payment button completion block will not be invoked in that case (e.g.
    // customer switches back via iOS Task Manager)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(hideLoadingUI:)
                                              name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
    [self hideLoadingUI:nil];
}

#pragma mark - Private methods

- (void)showLoadingUI {
    
}

- (void)hideLoadingUI:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    
}

@end
