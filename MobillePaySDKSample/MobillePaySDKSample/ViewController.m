//
//  ViewController.m
//  MobillePaySDKSample
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "URLConstant.h"
#import "ApplePayViewController.h"
#import "CardPayViewController.h"
#import "ViewController.h"
#import "PayPalViewController.h"
#import "VenmoViewController.h"
#import "DropInUIViewController.h"
#import "YSTestApi.h"
#import <CommonCrypto/CommonDigest.h>
#import <YuansferMobillePaySDK/YSAliWechatPay.h>
//#import "YuansferMobillePaySDK.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *orderNo;
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UITextField *currency;
@property (weak, nonatomic) IBOutlet UITextField *desc;
@property (weak, nonatomic) IBOutlet UITextField *note;
@property (weak, nonatomic) IBOutlet UITextField *notifyURL;
@property (weak, nonatomic) IBOutlet UITextField *storeNo;
@property (weak, nonatomic) IBOutlet UITextField *merchantNo;
@property (weak, nonatomic) IBOutlet UITextField *merGroupNo;
@property (weak, nonatomic) IBOutlet UISwitch *vendorSwitch;
@property (weak, nonatomic) IBOutlet UITextField *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - IBAction

- (IBAction)dropInUIAction:(id)sender {
    DropInUIViewController *diVC = [[DropInUIViewController alloc] initWithNibName:@"DropInUIViewController" bundle:nil];
    [self presentViewController:diVC animated:YES completion:nil];
}

- (IBAction)cardPayAction:(id)sender {
    CardPayViewController *cpVC = [[CardPayViewController alloc] initWithNibName:@"CardPayViewController" bundle:nil];
    [self presentViewController:cpVC animated:YES completion:nil];
}

- (IBAction)venmoAction:(id)sender {
    VenmoViewController *vVC = [[VenmoViewController alloc] initWithNibName:@"VenmoViewController" bundle:nil];
    [self presentViewController:vVC animated:YES completion:nil];
}

- (IBAction)paypalAction:(id)sender {
    PayPalViewController *ppVC = [[PayPalViewController alloc] initWithNibName:@"PayPalViewController" bundle:nil];
    [self presentViewController:ppVC animated:YES completion:nil];
}

- (IBAction)applePayAction:(UIButton *)sender {
    ApplePayViewController *appVC = [[ApplePayViewController alloc] initWithNibName:@"ApplePayViewController" bundle:nil];
    [self presentViewController:appVC animated:YES completion:nil];
}

- (IBAction) payAction:(UIButton *)sender {
    NSString *orderNo_ = self.orderNo.text.length > 0 ? self.orderNo.text : [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    
    NSNumberFormatter *formatter_ = [[NSNumberFormatter alloc] init];
    formatter_.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *amount_ = [formatter_ numberFromString:self.amount.text];
    
    __weak __typeof(self)weakSelf = self;
    [self payOrder:orderNo_
            amount:amount_
          currency:self.currency.text
       description:self.desc.text
              note:self.note.text
         notifyURL:self.notifyURL.text
           storeNo:self.storeNo.text
        merchantNo:self.merchantNo.text
            vendor:self.vendorSwitch.isOn ? YSPayTypeWeChatPay : YSPayTypeAlipay
             token:self.token.text
                 block:^(NSDictionary * _Nullable results, NSError * _Nullable error) {
                     __strong __typeof(weakSelf)strongSelf = weakSelf;
                     if (!error) {
                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"支付成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                         [alert addAction:action];
                         [strongSelf presentViewController:alert animated:YES completion:nil];
                     } else {
                         
                         UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Error domain = %@, error code = %ld", error.domain, (long)error.code] message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                         UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                         [alert addAction:action];
                         [strongSelf presentViewController:alert animated:YES completion:nil];
                     }
                     
                 }];
}

- (void)payOrder:(NSString *)orderNo
          amount:(NSNumber *)amount
        currency:(NSString *)currency
     description:(nullable NSString *)description
            note:(nullable NSString *)note
       notifyURL:(NSString *)notifyURLStr
         storeNo:(NSString *)storeNo
      merchantNo:(NSString *)merchantNo
          vendor:(YSPayType)payType
           token:(NSString *)token
           block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {

    NSString *vendor = nil;

    // 1、检查参数。
    if (orderNo.length == 0 ||
        amount == nil || [amount isEqualToNumber:@0] ||
        currency.length == 0 ||
        notifyURLStr.length == 0 ||
        storeNo.length == 0 ||
        merchantNo.length == 0 ||
        payType == 0 ||
        token.length == 0) {
        !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"参数错误，请检查 API 参数。"}]);
        return;
    }

    if (payType == YSPayTypeAlipay) {
        vendor = @"alipay";
    } else if (payType == YSPayTypeWeChatPay) {
        vendor = @"wechatpay";
    }
    
    NSDictionary* dict = @{
        @"merchantNo":merchantNo,
        @"storeNo": storeNo,
        @"amount":amount.description,
        @"currency": currency,
        @"settleCurrency": @"USD",
        @"description": description,
        @"ipnUrl": notifyURLStr,
        @"note":note,
        @"reference": orderNo,
        @"terminal":@"APP",
        @"vendor": vendor
    };
    
    [YSTestApi callWechatAlipayPrepay:dict token:token completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 是否出错
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !block ?: block(nil, error);

            });
             return;
        }

        // 验证 response 类型
        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Response is not a HTTP URL response."}]);

            });
             return;
        }

        // 验证 response code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{

                !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1002 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP response status code error, statusCode = %ld.", (long)httpResponse.statusCode]}]);

            });
             return;
        }

        // 确保有 response data
        if (!data || data.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{

                !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1003 userInfo:@{NSLocalizedDescriptionKey: @"No response data."}]);

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

                !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1004 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Deserialize JSON error, %@", serializationError.localizedDescription]}]);

            });
             return;
        }

        // 检查业务状态码
        if (![[responseObject objectForKey:@"ret_code"] isEqualToString:@"000100"]) {
            dispatch_async(dispatch_get_main_queue(), ^{

                !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"ret_msg"]]}]);

            });
             return;
        }

        if (payType == YSPayTypeAlipay) {
            // 支付宝支付
            // 检查 payInfo
            NSString *payInfo = [[responseObject objectForKey:@"result"] objectForKey:@"payInfo"];
            if (payInfo.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{

                    !block ?: block(nil, [NSError errorWithDomain:YSErrDomain code:1006 userInfo:@{NSLocalizedDescriptionKey: @"Yuansfer error, payInfo is null."}]);

                });
                 return;
            }
            // 发起支付宝支付
            dispatch_async(dispatch_get_main_queue(), ^{
                [[YSAliWechatPay sharedInstance] requestAliPayment:payInfo fromScheme:@"yuansfer4alipay" block:block];
            });
        } else if (payType == YSPayTypeWeChatPay) {
            // 微信支付
            NSDictionary *result = [responseObject objectForKey:@"result"];
            // 发起微信支付
            dispatch_async(dispatch_get_main_queue(), ^{
                [[YSAliWechatPay sharedInstance]
                 requestWechatPayment:[result objectForKey:@"partnerid"]
                                prepayid:[result objectForKey:@"prepayid"] noncestr:[result objectForKey:@"noncestr"] timestamp:[result objectForKey:@"timestamp"] package:[result objectForKey:@"package"] sign:[result objectForKey:@"sign"]
                                    appId:[result objectForKey:@"appid"]
                                    uniLink:UNIVERSAL_LINKS block:block];
            });
        }
    }];
    
}

@end
