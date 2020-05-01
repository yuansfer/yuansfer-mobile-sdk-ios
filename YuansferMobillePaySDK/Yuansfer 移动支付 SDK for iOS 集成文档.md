# Yuansfer 移动支付 SDK for iOS 集成文档

v1.0.0 

集成环境：Xcode 10.0+。

运行环境：iOS 8.0+。

## 接入前期准备

接入前期准备工作包括商户签约、获取各种 KEY（merchantNo、storeNo、token）和商户后端订单通知接口开发等。

## 集成

1、将 SDK 文件夹（包含支付宝移动支付 SDK、微信支付 SDK）导入到项目工程中（勾选 Copy items if needed）。

**⚠️ 注意：如不需要集成支付宝移动支付或微信支付，可删除包含对应 SDK 的文件夹。同时，接下来流程中对应平台操作不处理即可。**

```
└── YuansferMobillePaySDK
    ├── AlipaySDK
    │   ├── AlipaySDK.bundle
    │   └── AlipaySDK.framework
    ├── WeChatSDK
    │   ├── WXApi.h
    │   ├── WXApiObject.h
    │   ├── WechatAuthSDK.h
    │   └── libWeChatSDK.a
    ├── YuansferMobillePaySDK.h
    └── libYuansferMobillePaySDK.a
```

2、在 Xcode 项目 **Build Settings** 选项卡的 **Linking** -> **Other Linker Flags** 选项中，添加 `-ObjC` 参数。

3、在 Xcode 项目 **Build Phases** 选项卡的 **Link Binary With Libraries** 中添加以下依赖：

```
libc++.tbd // for Alipay, WeChatPay
libz.tbd // for Alipay, WeChatPay
libsqlite3.0.dylib // for WeChatPay
SystemConfiguration.framework // for Alipay, WeChatPay
CoreTelephony.framework // for Alipay, WeChatPay
QuartzCore.framework // for Alipay
CoreText.framework // for Alipay
CoreGraphics.framework // for Alipay, WeChatPay
UIKit.framework // for Alipay, WeChatPay
Foundation.framework // for Alipay, WeChatPay
CFNetwork.framework // for Alipay, WeChatPay
CoreMotion.framework // for Alipay
Security.framework // for WeChatPay
```

4、在 Xcode 项目 **Info** 选项卡的 **URLTypes** 中配置 URL Scheme：

| |Identifier|URL Schemes|
|:-----|:-----|:-----|
| Alipay | alipay | yuansfer4alipay（自定义，不要跟其他 App 一样） |
| WeChatPay | weixin | wx1acf098c25647f9e（微信支付 App id） |

5、在 Xcode 项目 **Info** 选项卡的 **Custom iOS Target Properties** 中配置应用查询 Scheme：

```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>alipay</string>
	<string>weixin</string>
</array>
```

## 使用

1、在 `AppDelegate.m` 中使用 `-handleOpenURL:` 方法处理从支付宝、微信客户端跳转回来。

```objc
#import "YuansferMobillePaySDK.h"

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {    
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}
```

2、在需要调用支付的地方，使用 `-payOrder:amount:currency:description:note:notifyURL:storeNo:merchantNo:vendor:token:fromScheme:block:` 方法传入订单信息，调起支付。

```objc
- (IBAction)payAction:(UIButton *)sender {
    
    [YuansferMobillePaySDK.sharedInstance payOrder:@"商家订单号。"
                                            amount:@(0.01) // 订单总金额
                                          currency:@"货币。"
                                       description:@"商品描述。"
                                              note:@"商品备注。" // 商家可在此处添加自定义备注
                                         notifyURL:@"订单支付完成通知商家后端的 URL。"
                                           storeNo:@"从 Yuansfer 获取到的 storeNo。"
                                        merchantNo:@"从 Yuansfer 获取到的 merchantNo。"
                                        merGroupNo:@"从 Yuansfer 获取到的 merGroupNo。"
                                            vendor:YSPayTypeAlipay // 支付方式：YSPayTypeAlipay, YSPayTypeWeChatPay
                                             token:@"从 Yuansfer 获取到的 token。"
                                        fromScheme:@"应用 URL Scheme，请在 Xcode 中配置并在此处正确填写，用于从支付宝、微信支付后跳回。"
                                             block:^(NSDictionary * _Nullable results, NSError * _Nullable error) {
                                                 if (!error) {
                                                     // 支付失败，根据 error 内容做处理提示。
                                                 } else {
                                                     // 支付成功。
                                                 }
                                             }];
}
```

## ⚠️ 注意事项

1、SDK 调用失败，首先请确保 storeNo、merchantNo、token 输入正确。如果 API 调用失败，请从 block 回调返回的 error 中获取相关调试信息。

2、跳转到支付宝、微信后未能正常跳回商家 App，请检查商家应用是否正确配置 URL Scheme 并在接口中传入正确的 Scheme；是否在 `AppDelegate.m` 中实现跳转方法支持。

3、调用下单、支付接口时奔溃，调起支付宝支付请确保添加了支付宝移动支付 SDK；调起微信支付请确保添加了微信支付 SDK。