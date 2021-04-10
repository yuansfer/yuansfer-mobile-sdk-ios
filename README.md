# Yuansfer 移动支付 SDK for iOS 集成文档

v1.2.0

集成环境：Xcode 10.0+。

运行环境：iOS 8.0+。

## 接入前期准备

接入前期准备工作包括商户签约、获取各种 KEY（merchantNo、storeNo、token）和商户后端订单通知接口开发等。

## 集成

1、根据需要的支付方式将相应的.h和.m文件放入项目中，YuansferMobillePaySDK下的Public目录包含微信支付宝、ApplePay、CardPay、PayPal、Venmo等独立的支付，使用Braintree的带UI的形式不必添加上述文件，Internal是第三方支付SDK的头文件, demo中包含微信和支付宝的库文件，需要集成微信或支付宝时将这两个文件目录下的内容添加到项目中。

**⚠️ 注意：使用Braintree时需要在Podfile添加依赖库，详见demo中的Podfile文件的使用说明。**

```
└── YuansferMobillePaySDK
    ├── Public
    │   ├── YSAliWechatPay.h/.m
    │   └── YSApiClient.h/.m
    │   └── YSCardPay.h/.m
    │   └── YSApplePay.h/.m
    │   └── YSPayPalPay.h/.m
    │   └── YSVenmoPay.h/.m
    ├── Internal
        ├── WXApi.h
        ├── WXApiObject.h
        ├── APayAuthInfo.h
        └── AlipaySDK.a
        └── ...
└── MobillePaySDKSample
    ├── WeChatSDK
        ├── WXApi.h
        ├── WXApiObject.h
        ├── WechatAuthSDK.h
        ├── libWeChatSDK.a
    ├── AlipaySDK
        ├── AlipaySDK.bundle
        ├── AlipaySDK.framework
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
| PayPal或Venmo | braintree | com.yuansfer.msdk.braintree (一般以app bundle ID拼上标识符)

5、配置微信平台的Universal Link, 首先将Associated Domains打开，并填写我们的域名，前缀是applinks。etc.如果你的域名是test.com，则填上applinks:test.com；其次到苹果开发者中心找到项目的AppId的Associated Domains，打开开关，同时获取到Team ID和Bundle ID; 创建一个apple-app-site-association文件(注意是没有后缀的)，其内容是json格式，把Team ID和Bundle ID填入到以下的字段当中，中间以点号相连，官方示例如下:

```
{
    "applinks": {
        "apps": [],
        "details": [
            {
                "appID": "Team ID.Bundle ID",
                "paths": [ "*" ]
            }
        ]
    }
}
```
把创建好的文件放到后端服务器域名根目录下，保证`https://test.com/apple-app-site-association`可访问；最后去微信后台配置Universal Link, 如图所示，要与上文提到的后端给的域名一致，可以添加一个path，如此处配置为`https://test.com/ios/`，完成Universal Link的配置。

6、在 Xcode 项目 **Info** 选项卡的 **Custom iOS Target Properties** 中配置应用查询 Scheme：

```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>weixin</string>
	<string>weixinULAPI</string>
	<string>com.venmo.touch.v2</string>
</array>
```
7、需要支持Braintree的Apple Pay、Card Pay、PayPal、Venmo等支付方式请先在Podfile文件中添加相应的库,Braintree是必要的，其它的为可选，可根据需要自行添加
```
# Podfile
  # 带ui,默认包含卡支付，其它apple pay, paypal, venmo需要再添加以下各自可选库
  pod 'BraintreeDropIn' , '~> 8.1.2'
  # 不带ui,Braintree为Core必选,其它为各自的库为可选
  pod 'Braintree'
  pod 'Braintree/Apple-Pay'
  pod 'Braintree/Card'
  pod 'Braintree/PayPal'
  pod 'Braintree/Venmo'
  # deviceData采集，建议上报
  pod 'Braintree/DataCollector'
```
## 使用

1、在 `AppDelegate.m` 中使用 `-handleOpenURL:` 方法处理从支付宝、微信、Venmo客户端跳转回来, 另外如果接入PayPal或Venmo需要设置URL Scheme。

```objc

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

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [[YSAliWechatPay sharedInstance] handleUniversalLink:userActivity];
}

```

2、在需要调用支付的地方发起支付。
* 发起微信支付,[[YSAliWechatPay sharedInstance] requestWechatPayment]
```objc
- (void) requestWechatPayment:(NSString *)partnerid
                     prepayid:(NSString *)prepayid
                     noncestr:(NSString *)noncestr
                    timestamp:(NSString *)timestamp
                      package:(NSString *)package
                         sign:(NSString *)sign
                        appId:(NSString *)appId
                      uniLink:(NSString *)uniLink
                        block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;
```
* 发起支付宝支付,[[YSAliWechatPay sharedInstance] requestAliPayment]
```objc
- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;
```
* 初始化Braintree api client, authorization为client token或tokenization key,[[YSApiClient sharedInstance] initBraintreeClient]
```objc
- (void) initBraintreeClient:(NSString*) authorization;
```
* 发起Drop-In UI选项卡支付
```objc
[[BTDropInController alloc] initWithAuthorization:self.authToken request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error);
```
* 检查Apple Pay是否可用, [[YSApplePay sharedInstance] canApplePayment]
```objc
- (bool) canApplePayment;
```
* 发起Apple Pay，有block和delegate两种调用方式
```objc
//block形式
- (void) requestApplePayment:(UIViewController*) viewController
                        paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
                        shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
                        authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                               PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;
//delegate
- (void) requestApplePayment:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                      paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;
//自行实现以下delegate方法
- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller;

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion;

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                   handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull)) completion;
```
* 发起信用卡或借记卡支付,[YSCardPay requestCardPayment]
```objc
+ (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;
```
* 发起Venmo客户端支付,[YSVenmoPay requestVenmoPayment]
```objc
+ (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock;
```
* 发起PayPal支付,有两种形式:Vault和Checkout,[YSPayPalPay requestPayPal]
```objc
+ (void) requestPayPalOneTimePayment:(BTPayPalRequest *)request
                        fromSchema:(NSString *)fromScheme
            viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                    switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                                      completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;


+ (void) requestPayPalBillingPayment:(BTPayPalRequest *)request
                        fromSchema:(NSString *)fromScheme
            viewControllerDelegate:(id<BTViewControllerPresentingDelegate>) viewControllerDelegate
                    switchDelegate:(id<BTAppSwitchDelegate>) switchDelegate
                                      completion:(void (^)(BTPayPalAccountNonce * _Nullable payPalAccount, NSError * _Nullable error)) completion;
```
## ⚠️ 注意事项

1、SDK 调用失败，首先请确保 storeNo、merchantNo、token 输入正确。如果 API 调用失败，请从 block 回调返回的 error 中获取相关调试信息。

2、跳转到支付宝、微信后未能正常跳回商家 App，请检查商家应用是否正确配置 URL Scheme 并在接口中传入正确的 Scheme；是否在 `AppDelegate.m` 中实现跳转方法支持。

3、调用下单、支付接口时奔溃，调起支付宝支付请确保添加了支付宝移动支付 SDK；调起微信支付请确保添加了微信支付 SDK；调用Braintree下的各种支付时确保添加了相应的pod sdk。

4、当引用BraintreeDropIn的旧版本时会出出现Braintree DropIn源码中报诸如'topLayoutGuide' is deprecated: first deprecated in iOS 11.0的error,该问题在8.1.0已修复，指定高于8.1.0的版本即可。

5、根据实际需要集成的支付方式选择性的添加相应的文件，Podfile也选择性的安装Braintree依赖库，仅微信或支付宝时不需要Podfile。

6、其它详细使用请参考MobilePaySDKSample里的例子。
