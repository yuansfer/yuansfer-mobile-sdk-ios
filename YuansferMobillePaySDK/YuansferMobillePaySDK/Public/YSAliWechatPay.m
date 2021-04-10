//
//  YuansferMobillePaySDK.m
//  YuansferMobillePaySDK
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "YSAliWechatPay.h"
#import "AlipaySDK.h"
#import "WXApi.h"

const NSErrorDomain YSErrDomain = @"YSErrorDomain";
const NSErrorDomain YSAlipayErrDomain = @"YSAlipayErrorDomain";
const NSErrorDomain YSWechatErrDomain = @"YSWeChatErrorDomain";

typedef void (^Completion)(NSDictionary *results, NSError *error);

@interface YSAliWechatPay () <WXApiDelegate>

@property (nonatomic, copy) Completion completion;
@property (nonatomic, copy) NSString *alipayScheme;
@property (nonatomic, copy) NSString *weChatPayScheme;

@end

@implementation YSAliWechatPay

+ (instancetype)sharedInstance {
    static YSAliWechatPay *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - public method

- (void) requestWechatPayment:(NSString *)partnerid
               prepayid:(NSString *)prepayid
               noncestr:(NSString *)noncestr
              timestamp:(NSString *)timestamp
                package:(NSString *)package
                   sign:(NSString *)sign
                  appId:(NSString *)appId
                uniLink:(NSString *)uniLink
                  block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {
    // 初始化微信，只初始化一次。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [WXApi registerApp:appId universalLink:uniLink];
    });

    // 是否安装微信。
    if (![WXApi isWXAppInstalled]) {
        !block ?: block(nil, [NSError errorWithDomain:YSWechatErrDomain code:9001 userInfo:@{NSLocalizedDescriptionKey: @"用户未安装微信。"}]);
        return;
    }
    self.completion = block;
    self.weChatPayScheme = appId;
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = partnerid;
    request.prepayId = prepayid;
    request.nonceStr = noncestr;
    request.timeStamp = [timestamp intValue];
    request.package = package;
    request.sign = sign;
    [WXApi sendReq:request completion:^(BOOL success) {
        NSLog(@"Wechat Pay reqeust result= %@",success ? @"success":@"fail");
    }];
}

- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block {
    self.completion = block;
    self.alipayScheme = fromScheme;
    [[AlipaySDK defaultService] payOrder:payInfo fromScheme:fromScheme callback:^(NSDictionary *resultDic) {
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
                !block ?: block(resultDic, nil);
            } else {
                !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrDomain
                                                         code:9000
                                                     userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
            }
        } else {
            !block ?: block(nil, [NSError errorWithDomain:YSAlipayErrDomain
                                                     code:[[resultDic objectForKey:@"resultStatus"] integerValue]
                                                 userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
        }
    }];
}

- (BOOL)handleOpenURL:(NSURL *)aURL {
    if ([aURL.scheme isEqualToString:self.alipayScheme]) {
        __weak __typeof(self)weakSelf = self;
        [[AlipaySDK defaultService] processOrderWithPaymentResult:aURL standbyCallback:^(NSDictionary *resultDic) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
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
                    !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrDomain code:9000 userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
                }
            } else {
                !strongSelf.completion ?: strongSelf.completion(nil, [NSError errorWithDomain:YSAlipayErrDomain code:[[resultDic objectForKey:@"resultStatus"] integerValue] userInfo:@{NSLocalizedDescriptionKey: [resultDic objectForKey:@"memo"]}]);
            }
        }];
        
        return YES;
    } else if ([aURL.scheme isEqualToString:self.weChatPayScheme]) {
        return [WXApi handleOpenURL:aURL delegate:self];
    }
    return NO;
}

- (BOOL)handleUniversalLink:(NSUserActivity *)userActivity {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

#pragma mark - WXApiDelegate

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:PayResp.class]) {
        if (resp.errCode == 0) {
            // 成功
            !self.completion ?: self.completion(@{@"errCode": @(resp.errCode), @"type": @(resp.type), @"errStr": (resp.errStr ? resp.errStr : @"")}, nil);
        } else {
            NSString *errMsg = @"";
            switch (resp.errCode) {
                case -1:
                    errMsg = @"普通错误类型";
                    break;
                case -2:
                    errMsg = @"用户点击取消并返回";
                    break;
                case -3:
                    errMsg = @"发送失败";
                    break;
                case -4:
                    errMsg = @"授权失败";
                    break;
                case -5:
                    errMsg = @"微信不支持";
                    break;
                default:
                    break;
            }
            
            !self.completion ?: self.completion(nil, [NSError errorWithDomain:YSWechatErrDomain code:resp.errCode userInfo:@{NSLocalizedDescriptionKey: errMsg}]);
        }
    }
}



@end
