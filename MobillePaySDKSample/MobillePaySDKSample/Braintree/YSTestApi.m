//
//  YSTestApi.m
//  MobillePaySDKSample
//
//  Created by fly.zhu on 2021/1/14.
//  Copyright © 2021 Yuanex, Inc. All rights reserved.
//

#import "YSTestApi.h"
#import "URLConstant.h"
#import <CommonCrypto/CommonDigest.h>

@implementation YSTestApi

+ (void) callPrepay:(NSString *)amount
         completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    //参数要按字母自然排序后生成signature
    NSString* refNo = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    NSMutableString *sign = [NSMutableString string];
    [sign appendFormat:@"amount=%@", amount];
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
    [body appendFormat:@"%@=%@", @"amount", amount];
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
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, @"online/v3/secure-pay"]]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

+ (void) callProcess:(NSString *)transactionNo
       paymentMethod:(NSString *)paymentMethod
              nonce:(NSString *)nonce
          deviceData:(NSString *)deviceData
  completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    //参数要按字母自然排序后生成signature
    NSMutableString *sign = [NSMutableString string];
    [sign appendFormat:@"addressLine1=%@", @"addressLine1"];
    [sign appendFormat:@"&addressLine2=%@", @"addressLine2"];
    [sign appendFormat:@"&city=%@", @"city"];
    [sign appendFormat:@"&countryCode=%@", @"countryCode"];
    [sign appendFormat:@"&customerNo=%@", @"cid"];
    [sign appendFormat:@"&deviceData=%@", deviceData];
    [sign appendFormat:@"&email=%@", @"123@qq.com"];
    [sign appendFormat:@"&merchantNo=%@", @"202333"];
    [sign appendFormat:@"&paymentMethod=%@", paymentMethod];
    [sign appendFormat:@"&paymentMethodNonce=%@", nonce];
    [sign appendFormat:@"&phone=%@", @"123"];
    [sign appendFormat:@"&postalCode=%@", @"111"];
    [sign appendFormat:@"&recipientName=%@", @"recipientName"];
    [sign appendFormat:@"&state=%@", @"state"];
    [sign appendFormat:@"&storeNo=%@", @"301854"];
    [sign appendFormat:@"&transactionNo=%@", transactionNo];
    [sign appendFormat:@"&%@", [self md5String:@"17cfc0170ef1c017b4a929d233d6e65e"]];
    
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"addressLine1=%@", @"addressLine1"];
    [body appendFormat:@"&addressLine2=%@", @"addressLine2"];
    [body appendFormat:@"&city=%@", @"city"];
    [body appendFormat:@"&countryCode=%@", @"countryCode"];
    [body appendFormat:@"&customerNo=%@", @"cid"];
    [body appendFormat:@"&deviceData=%@", deviceData];
    [body appendFormat:@"&email=%@", @"123@qq.com"];
    [body appendFormat:@"&merchantNo=%@", @"202333"];
    [body appendFormat:@"&paymentMethod=%@", paymentMethod];
    [body appendFormat:@"&paymentMethodNonce=%@", nonce];
    [body appendFormat:@"&phone=%@", @"123"];
    [body appendFormat:@"&postalCode=%@", @"111"];
    [body appendFormat:@"&recipientName=%@", @"recipientName"];
    [body appendFormat:@"&state=%@", @"state"];
    [body appendFormat:@"&storeNo=%@", @"301854"];
    [body appendFormat:@"&transactionNo=%@", transactionNo];
    [body appendFormat:@"&%@=%@", @"verifySign", [self md5String:[sign copy]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, @"creditpay/v3/process"]]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

#pragma mark - private method

+ (NSString *)md5String:(NSString *)string {
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

@end
