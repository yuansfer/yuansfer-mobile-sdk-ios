//
//  AppDelegate.m
//  MobillePaySDKSample
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "BTAppSwitch.h"
#import <YuansferMobillePaySDK/YSAliWechatPay.h>
#import <YuansferMobillePaySDK/YSPayPalPay.h>
#import <YuansferMobillePaySDK/YSVenmoPay.h>
//#import "YuansferMobillePaySDK.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [BTAppSwitch setReturnURLScheme:@"com.yuansfer.msdk.braintree"];
    return YES;
}

#pragma mark - handle open URL

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {    
     BOOL aliWechatUrl = [[YSAliWechatPay sharedInstance] handleOpenURL:url];
     if (!aliWechatUrl) {
        BOOL ppUrl = [YSPayPalPay handleOpenURL:url];
        if (!ppUrl) {
            return [YSVenmoPay handleOpenURL:url];
        }
     }
     return NO;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL aliWechatUrl = [[YSAliWechatPay sharedInstance] handleOpenURL:url];
    if (!aliWechatUrl) {
       BOOL ppUrl = [YSPayPalPay handleOpenURL:url];
       if (!ppUrl) {
           return [YSVenmoPay handleOpenURL:url];
       }
    }
    return NO;
}


@end
