//
//  AppDelegate.m
//  MobillePaySDKSample
//
//  Created by Joe on 2019/2/13.
//  Copyright © 2019 Yuanex, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <YuansferMobillePaySDK/YuansferMobillePaySDK.h>
//#import "YuansferMobillePaySDK.h"
@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - handle open URL


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {    
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}


@end
