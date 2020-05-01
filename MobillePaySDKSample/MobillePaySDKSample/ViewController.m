//
//  ViewController.m
//  MobillePaySDKSample
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "ViewController.h"
#import <YuansferMobillePaySDK/YuansferMobillePaySDK.h>

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

- (IBAction)payAction:(UIButton *)sender {
    NSString *orderNo_ = self.orderNo.text.length > 0 ? self.orderNo.text : [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    
    NSNumberFormatter *formatter_ = [[NSNumberFormatter alloc] init];
    formatter_.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *amount_ = [formatter_ numberFromString:self.amount.text];
    
    __weak __typeof(self)weakSelf = self;
    [YuansferMobillePaySDK.sharedInstance payOrder:orderNo_
                                            amount:amount_
                                          currency:self.currency.text
                                       description:self.desc.text
                                              note:self.note.text
                                         notifyURL:self.notifyURL.text
                                           storeNo:self.storeNo.text
                                        merchantNo:self.merchantNo.text
                                        merGroupNo:self.merGroupNo.text
                                            vendor:self.vendorSwitch.isOn ? YSPayTypeWeChatPay : YSPayTypeAlipay
                                             token:self.token.text
                                        fromScheme:self.vendorSwitch.isOn ? @"wx1acf098c25647f9e" : @"yuansfer4alipay"
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

@end
