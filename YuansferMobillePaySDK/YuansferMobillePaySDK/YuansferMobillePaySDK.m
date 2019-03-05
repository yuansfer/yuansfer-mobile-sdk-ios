//
//  YuansferMobillePaySDK.m
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "YuansferMobillePaySDK.h"
#import <CommonCrypto/CommonDigest.h>
#import "YSProgressHUD.h"
#import "AlipaySDK.h"

#define BASE_URL_TEST @"https://mapi.yuansfer.yunkeguan.com/appTransaction/v2/securepay"
#define BASE_URL @"https://mapi.yuansfer.com/appTransaction/v2/securepay"

const NSErrorDomain YSErrorDomain = @"YSErrorDomain";
const NSErrorDomain YSAlipayErrorDomain = @"YSAlipayErrorDomain";

static NSString * const YSMobillePaySDKVersion = @"0.9.0";

typedef void (^Completion)(NSDictionary *results, NSError *error);

@interface YuansferMobillePaySDK ()

@property (nonatomic, copy) Completion completion;

@end

@implementation YuansferMobillePaySDK

+ (instancetype)sharedInstance {
    static YuansferMobillePaySDK *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (NSString *)version {
    return YSMobillePaySDKVersion;
}

- (void)payOrder:(NSString *)orderNo
          amount:(NSNumber *)amount
        currency:(NSString *)currency
         timeout:(NSNumber *)timeout
       goodsInfo:(NSString *)goodsInfo
     description:(nullable NSString *)description
            note:(nullable NSString *)note
       notifyURL:(NSString *)notifyURLStr
         storeNo:(NSString *)storeNo
      merchantNo:(NSString *)merchantNo
           token:(NSString *)token
      fromScheme:(NSString *)scheme
           block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {
    // 置空上次的 block
    self.completion = nil;
    
    // 1、检查参数。
    if (orderNo.length == 0 ||
        amount == nil ||
        [amount isEqualToNumber:@0] ||
        currency.length == 0 ||
        timeout == nil ||
        [timeout isEqualToNumber:@0] ||
        goodsInfo.length == 0 ||
        notifyURLStr.length == 0 ||
        storeNo.length == 0 ||
        merchantNo.length == 0 ||
        token.length == 0 ||
        scheme.length == 0) {
        !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"参数不能为空，请检查 API 参数."}]);
        return;
    }
    self.completion = block;
    
    // 2、转圈。
    [YSProgressHUD show];
    [YSProgressHUD setDefaultMaskType:YSProgressHUDMaskTypeClear];
    
    // 3、发送到后端，获取处理完的字符串。
    NSMutableString *sign = [NSMutableString string];
    [sign appendFormat:@"amount=%@", amount];
    [sign appendFormat:@"&currency=%@", currency];
    if (description.length > 0) {
        [sign appendFormat:@"&description=%@", description];
    }
    [sign appendFormat:@"&goodsInfo=%@", goodsInfo];
    [sign appendFormat:@"&ipnUrl=%@", notifyURLStr];
    [sign appendFormat:@"&merchantNo=%@", merchantNo];
    if (note.length > 0) {
        [sign appendFormat:@"&note=%@", note];
    }
    [sign appendFormat:@"&reference=%@", orderNo];
    [sign appendFormat:@"&storeNo=%@", storeNo];
    [sign appendFormat:@"&terminal=%@", @"APP"];
    [sign appendFormat:@"&timeout=%@", timeout];
    [sign appendFormat:@"&vendor=%@", @"alipay"];
    [sign appendFormat:@"&%@", [self md5String:token]];
    
    NSMutableString *body = [NSMutableString string];
    [body appendFormat:@"%@=%@", YSPercentEscapedStringFromString(@"reference"), YSPercentEscapedStringFromString(orderNo)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"amount"), YSPercentEscapedStringFromString(amount.description)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"currency"), YSPercentEscapedStringFromString(currency)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"timeout"), YSPercentEscapedStringFromString(timeout.description)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"goodsInfo"), YSPercentEscapedStringFromString(goodsInfo)];
    if (description.length > 0) {
        [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"description"), YSPercentEscapedStringFromString(description)];
    }
    if (note.length > 0) {
        [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"note"), YSPercentEscapedStringFromString(note)];
    }
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"ipnUrl"), YSPercentEscapedStringFromString(notifyURLStr)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"storeNo"), YSPercentEscapedStringFromString(storeNo)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"merchantNo"), YSPercentEscapedStringFromString(merchantNo)];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"terminal"), YSPercentEscapedStringFromString(@"APP")];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"vendor"), YSPercentEscapedStringFromString(@"alipay")];
    [body appendFormat:@"&%@=%@", YSPercentEscapedStringFromString(@"verifySign"), YSPercentEscapedStringFromString([self md5String:[sign copy]])];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BASE_URL]];
    request.timeoutInterval = 15.0f;
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[body copy] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 是否出错
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, error);
                
                return;
            });
        }
        
        // 验证 response 类型
        if (![response isKindOfClass:[NSHTTPURLResponse class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Response is not a HTTP URL response."}]);
                
                return;
            });
        }
        
        // 验证 response code
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1002 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP response status code error, statusCode = %ld.", (long)httpResponse.statusCode]}]);
                
                return;
            });
        }
        
        // 确保有 response data
        if (!data || data.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1003 userInfo:@{NSLocalizedDescriptionKey: @"No response data."}]);
                
                return;
            });
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
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1004 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Deserialize JSON error, %@", serializationError.localizedDescription]}]);
                
                return;
            });
        }
        
        // 检查业务状态码
        if (![[responseObject objectForKey:@"retCode"] isEqualToString:@"SUCCESS"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1005 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Yuansfer error, %@.", [responseObject objectForKey:@"retMsg"]]}]);
                
                return;
            });
        }
        
        // 检查 payInfo
        NSString *payInfo = [responseObject objectForKey:@"payInfo"];
        if (payInfo.length == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [YSProgressHUD dismiss];
                
                !block ?: block(nil, [NSError errorWithDomain:YSErrorDomain code:1006 userInfo:@{NSLocalizedDescriptionKey: @"Yuansfer error, payInfo is null."}]);
                
                return;
            });
        }
        
        // 发起支付
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlipaySDK defaultService] payOrder:payInfo fromScheme:scheme callback:^(NSDictionary *resultDic) {
                [YSProgressHUD dismiss];
                
                if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                    NSString *result = [resultDic objectForKey:@"result"];
                    NSArray *results = [result componentsSeparatedByString:@"&"];
                    BOOL success = NO;
                    for (NSString *substring in results) {
                        if ([substring isEqualToString:@"success=\"true\""]) {
                            success = YES;
                            break;
                        }
                    }
                    if (success != NO) {
                        // resultStatus=9000,success="true"
                        !block ?: block(resultDic, nil);
                    } else {
                        !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrorDomain
                                                                 code:9000
                                                             userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
                    }
                } else {
                    !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrorDomain
                                                             code:[[resultDic objectForKey:@"resultStatus"] integerValue]
                                                         userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
                }
            }];
        });
    }];
    [task resume];
}

- (BOOL)handleOpenURL:(NSURL *)aURL {
    if ([aURL.host isEqualToString:@"safepay"]) {
        __weak __typeof(self)weakSelf = self;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:aURL standbyCallback:^(NSDictionary *resultDic) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            [YSProgressHUD dismiss];
            
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {
                NSArray *results = [[resultDic objectForKey:@"result"] componentsSeparatedByString:@"&"];
                BOOL success = NO;
                for (NSString *substring in results) {
                    if ([substring isEqualToString:@"success=\"true\""]) {
                        success = YES;
                        break;
                    }
                }
                if (success != NO) {
                    // resultStatus=9000,success="true"
                    !strongSelf.completion ?: strongSelf.completion(resultDic, nil);
                } else {
                    !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrorDomain code:9000 userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
                }
            } else {
                !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrorDomain code:[[resultDic objectForKey:@"resultStatus"] integerValue] userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
            }
        }];
    }
    
    return YES;
}

#pragma mark -

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

/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
NSString * YSPercentEscapedStringFromString(NSString *string) {
    static NSString * const kYSCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kYSCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kYSCharactersGeneralDelimitersToEncode stringByAppendingString:kYSCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    
    return escaped;
}

@end
