# Yuansfer 移动支付 SDK for iOS 集成文档

v1.1.5 

集成环境：Xcode 10.0+。

运行环境：iOS 8.0+。

## 接入前期准备

接入前期准备工作包括商户签约、获取各种 KEY（merchantNo、storeNo、token）和商户后端订单通知接口开发等。

## 集成

1、将 YuansferMobillePaySDK.zip压缩包（包含支付宝移动支付 SDK、微信支付 SDK）解压后导入到项目工程中（勾选 Copy items if needed）。

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
| Venmo | Venmo | com.yuansfer.msdk.payments (一般以app bundle ID拼上标识符)

5、在 Xcode 项目 **Info** 选项卡的 **Custom iOS Target Properties** 中配置应用查询 Scheme：

```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>alipay</string>
	<string>weixin</string>
	<string>com.venmo.touch.v2</string>
</array>
```
6、需要支持Braintree的Apple Pay、Card Pay、PayPal、Venmo等支付方式请先在Podfile文件中添加相应的库,Braintree是必要的，其它的为可选，可根据需要自行添加
```
# Podfile
# 以下必选
pod 'Braintree'
# 以下可选
pod 'Braintree/Apple-Pay'
pod 'Braintree/Card'
pod 'Braintree/PayPal'
pod 'Braintree/Venmo'
```
## 使用

1、在 `AppDelegate.m` 中使用 `-handleOpenURL:` 方法处理从支付宝、微信、Venmo客户端跳转回来。

```objc
#import "YuansferMobillePaySDK.h"

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {    
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [YuansferMobillePaySDK.sharedInstance handleOpenURL:url];
}
```

2、在需要调用支付的地方发起支付。
* 发起微信支付
```objc
- (void) requestWechatPayment:(NSString *)partnerid
               prepayid:(NSString *)prepayid
               noncestr:(NSString *)noncestr
              timestamp:(NSString *)timestamp
                package:(NSString *)package
                   sign:(NSString *)sign
            fromSchema:(NSString *)fromScheme
                  block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;
```
* 发起支付宝支付
```objc
- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;
```
* 初始化Braintree api client, authorization为client token或tokenization key
```objc
- (void) initBraintreeClient:(NSString*) authorization;
```
* 检查Apple Pay是否可用
```objc
- (bool) canApplePayment;
```
* 发起Apple Pay，有block和delegate两种调用方式
```objc
//block形式
- (void) requestApplePaymentByBlock:(UIViewController*) viewController
                        paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
                        shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
                        authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                               PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;
//delegate
- (void) requestApplePaymentByDelegate:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                      paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;
```
* 发起信用卡或借记卡支付
```objc
- (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;
```
* 发起Venmo客户端支付
```objc
- (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock;
```

## ⚠️ 注意事项

1、SDK 调用失败，首先请确保 storeNo、merchantNo、token 输入正确。如果 API 调用失败，请从 block 回调返回的 error 中获取相关调试信息。

2、跳转到支付宝、微信后未能正常跳回商家 App，请检查商家应用是否正确配置 URL Scheme 并在接口中传入正确的 Scheme；是否在 `AppDelegate.m` 中实现跳转方法支持。

3、调用下单、支付接口时奔溃，调起支付宝支付请确保添加了支付宝移动支付 SDK；调起微信支付请确保添加了微信支付 SDK；调用Braintree下的各种支付时确保添加了相应的pod sdk。

4、其它详细使用请参考MobilePaySDKSample里的例子。