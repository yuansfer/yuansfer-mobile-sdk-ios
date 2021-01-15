//
//  VenmoViewController.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/15.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "VenmoViewController.h"
#import "BTAPIClient.h"
#import "YSProgressHUD.h"
#import <YuansferMobillePaySDK/YuansferMobillePaySDK.h>
#import "YSTestApi.h"
//#import "YuansferMobillePaySDK.h"

@interface VenmoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (nonatomic, copy) NSString *transactionNo;
@end

@implementation VenmoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepay];
}

- (void) prepay {
    // 2、转圈。
    [YSProgressHUD show];
    [YSProgressHUD setDefaultMaskType:YSProgressHUDMaskTypeClear];
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callPrepay:@"0.01"
               completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.resultLabel.text = @"prepay接口调用成功,可提交支付数据进行处理";
            [[YuansferMobillePaySDK sharedInstance] initBraintreeClient:[[responseObject objectForKey:@"result"] objectForKey:@"authorization"]];
            strongSelf.payButton.hidden = NO;
        });
    }];
}

- (void) payProcess:(NSString *)nonce {
    // 2、转圈。
    [YSProgressHUD show];
    [YSProgressHUD setDefaultMaskType:YSProgressHUDMaskTypeClear];
     __weak __typeof(self)weakSelf = self;
    [YSTestApi callProcess:self.transactionNo paymentMethod:@"venmo_account" nonce:nonce completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
            //显示支付成功
            self.resultLabel.text = @"Venmo Pay支付成功";
        });
    }];
}

- (IBAction)tappedPayButton:(id)sender {
    [[YuansferMobillePaySDK sharedInstance] requestVenmoPayment:NO
                                                     fromSchema:@"com.yuansfer.msdk.payments"
                                                     completion:^(BTVenmoAccountNonce * _Nonnull venmoAccount, NSError * _Nonnull error) {
        if (venmoAccount) {
            [self payProcess:venmoAccount.nonce];
        } else if (error) {
             self.resultLabel.text = @"Venmo Pay失败";
        } else {
             self.resultLabel.text = @"Venmo Pay取消";
        }
    }];
}

@end
