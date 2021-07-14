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
        BOOL ppUrl = [YSPayPalPay handleOpenURL:url
                              sourceApplication:sourceApplication];
        if (!ppUrl) {
            return [YSVenmoPay handleOpenURL:url
                           sourceApplication:sourceApplication];
        }
     }
     return NO;
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL aliWechatUrl = [[YSAliWechatPay sharedInstance] handleOpenURL:url];
    if (!aliWechatUrl) {
       BOOL ppUrl = [YSPayPalPay handleOpenURL:url
                                       options:options];
       if (!ppUrl) {
           return [YSVenmoPay handleOpenURL:url
                                    options:options];
       }
    }
    return NO;
}

#pragma mark - handle universal link

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [[YSAliWechatPay sharedInstance] handleUniversalLink:userActivity];
}

@end
