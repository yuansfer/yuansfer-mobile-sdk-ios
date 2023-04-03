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

+ (void) callWechatAlipayPrepay:(NSDictionary *) data
                          token:(NSString *) token
                     completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    [YSTestApi execHttpRequest:@"micropay/v3/prepay" data:data token:token completion:completionHandler];
}

+ (void) callBraintreePrepay:(NSString *)amount
         completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    // 写死的一些接口数据和token，生产环境要替换为真实数据
    NSString* merchantNo = @"202333";
    NSString* storeNo = @"301854";
    NSString *token = @"17cfc0170ef1c017b4a929d233d6e65e";
    NSString* refNo = [NSString stringWithFormat:@"%.0f", [NSDate date].timeIntervalSince1970];
    NSDictionary* dict = @{
        @"merchantNo": merchantNo,
        @"storeNo": storeNo,
        @"amount": amount,
        @"creditType": @"yip",
        @"currency":@"USD",
        @"description":@"description",
        @"ipnUrl": @"https://receivenotify.merchant.com",
        @"note": @"note",
        @"reference": refNo,
        @"settleCurrency":@"USD",
        @"terminal": @"APP",
        @"timeout": @"120",
        @"vendor": @"paypal"
    };
    [YSTestApi execHttpRequest:@"online/v3/secure-pay" data:dict token:token completion:completionHandler];
}

+ (void) callBraintreeProcess:(NSString *)transactionNo
       paymentMethod:(NSString *)paymentMethod
              nonce:(NSString *)nonce
          deviceData:(NSString *)deviceData
  completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler{
    // 写死的一些接口数据和token，生产环境要替换为真实数据
    NSString* merchantNo = @"202333";
    NSString* storeNo = @"301854";
    NSString *token = @"17cfc0170ef1c017b4a929d233d6e65e";
    NSDictionary* dict = @{
        @"merchantNo":merchantNo,
        @"storeNo": storeNo,
        @"addressLine1": @"addressLine1",
        @"addressLine2": @"addressLine2",
        @"city":@"city",
        @"countryCode":@"countryCode",
        @"customerNo": @"customerNo",
        @"deviceData": deviceData,
        @"email": @"123@qq.com",
        @"paymentMethod":paymentMethod,
        @"paymentMethodNonce": nonce,
        @"phone": @"123",
        @"postalCode": @"111",
        @"transactionNo": transactionNo,
        @"recipientName":@"recipientName",
        @"state":@"state"
    };
    [YSTestApi execHttpRequest:@"online/v3/secure-pay" data:dict token:token completion:completionHandler];
}

#pragma mark - private method

+ (void) execHttpRequest:(NSString *) path data:(NSDictionary *) dict token:(NSString *)token
         completion:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {
    NSString *params = [self sortedDictionary:dict];
    NSMutableString *sign = [NSMutableString string];
    [sign appendString:params];
    [sign appendFormat:@"&%@", [self md5String:token]];
    
    NSMutableString *body = [NSMutableString string];
    [body appendString:params];
    [body appendFormat:@"&%@=%@", @"verifySign", [self md5String:[sign copy]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_URL, path]]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

+ (NSString *)sortedDictionary:(NSDictionary *)dict{
    //将所有的key放进数组
    NSArray *allKeyArray = [dict allKeys];
    //序列化器对数组进行排序的block 返回值为排序后的数组
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id
                                                                                           _Nonnull obj2) {
        //排序操作
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    //排序好的字典
    NSLog(@"afterSortKeyArray:%@",afterSortKeyArray);
    NSString *tempStr = @"";
    //通过排列的key值获取value
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortsing in afterSortKeyArray) {
      //格式化一下 防止有些value不是string
      NSString *valueString = [NSString stringWithFormat:@"%@",[dict objectForKey:sortsing]];
      if(valueString.length>0){
          [valueArray addObject:valueString];
          tempStr=[NSString stringWithFormat:@"%@%@=%@&",tempStr,sortsing,valueString];
      }
    }
    //去除最后一个&符号
    if(tempStr.length>0){
        tempStr=[tempStr substringToIndex:([tempStr length]-1)];
    }
    //最终参数
    NSLog(@"tempStr:%@",tempStr);
    return tempStr;
}

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
