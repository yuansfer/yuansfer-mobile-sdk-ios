## Language
English | [中文文档](README_zh.md)

## Overview
yuansfer-payment-iOS is an SDK project that enables quick integration of third-party payment platforms such as WeChat Pay, Alipay, credit cards, PayPal, Venmo, and Apple Pay.
Integrated environment: Xcode 10.0+.
Operating environment: iOS 8.0+.

## Pre-access preparation

The preparatory work for the access includes merchant signing, obtaining various KEYs (merchantNo, storeNo, token), and merchant back-end order notification interface development, etc.

## Integration

1、The code in MobilePaySDKSample is a test demo for reference only. The interface call in YSTestApi should be replaced with the merchant server interface in the release project, and the merchant server interface calls the Pockyt interface.

2、Put the corresponding .h and .m files into the project according to the required payment method. The Public directory under YuansferMobillePaySDK contains independent payments such as WeChat Alipay, ApplePay, CardPay, PayPal, Venmo, etc. You don’t need to add the above when using Braintree’s UI with the form File, Internal is the header file of the third-party payment SDK. The demo contains library files of WeChat and Alipay. When you need to integrate WeChat or Alipay, add the contents of these two file directories to the project.

**⚠️ Note: When integrating with payment platforms other than WeChat Pay and Alipay, you need to add the dependency library in the Podfile. Please refer to the instructions for using the Podfile file in the demo for details.**

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

2、In the **Linking** -> **Other Linker Flags** option of the **Build Settings** tab of the Xcode project, add the `-ObjC` parameter.

3、Add the following dependencies to **Link Binary With Libraries** in the **Build Phases** tab of the Xcode project:

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

4、Configure URL Scheme in **URLTypes** on the **Info** tab of the Xcode project：

| |Identifier|URL Schemes|
|:-----|:-----|:-----|
| Alipay | alipay | yuansfer4alipay(Customize, don’t be the same as other apps） |
| WeChatPay | weixin | wx1acf098c25647f9e(WeChat Pay App id) |
| PayPal or Venmo | braintree | com.yuansfer.msdk.braintree (Usually use the app bundle ID to spell the identifier)

5、WeChat Pay has made some upgrades (openSDK1.8.6) to comply with the requirements of iOS 13. The most important change is that the jump method has been changed to Universal Links to verify the legitimacy of initiating sharing.

> Login to the Apple Developer account, create an application, and enable the Associated Domains function for this AppID (check Associated Domains in IDENTIFIER).

> Create an empty JSON format file (named apple-app-site-association, with no extension!) and place it in the root directory of the specified server, providing an HTTPS access address.
    For example: https://www.baidu.com/.well-known/apple-app-site-association. The JSON file format is as follows:
    
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
> Configure the associated domains in Xcode. Open Xcode, select project → Signing & Capabilities → + Capability, find "Associated Domains" and add it.

6、Configure the application query Scheme in **Custom iOS Target Properties** in the **Info** tab of the Xcode project:

```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>weixin</string>
	<string>weixinULAPI</string>
	<string>com.venmo.touch.v2</string>
</array>
```
7、If you need to support Apple Pay, Card Pay, PayPal, Venmo and other payment methods, please add the corresponding library to the Podfile first. Braintree is necessary, and the others are optional. You can add them according to your needs.
```
# Podfile
  # With ui, card payment is included by default, other apple pay, paypal, venmo need to add the following optional libraries
  pod 'BraintreeDropIn' , '~> 8.1.2'
  # Without ui, Braintree is required for Core, others are optional for their respective libraries
  pod 'Braintree'
  pod 'Braintree/Apple-Pay'
  pod 'Braintree/Card'
  pod 'Braintree/PayPal'
  pod 'Braintree/Venmo'
  # deviceData collection, it is recommended to report
  pod 'Braintree/DataCollector'
```
## Use

1、Use the `-handleOpenURL:` method in `AppDelegate.m` to handle redirects from Alipay, WeChat, and Venmo clients. In addition, if you access PayPal or Venmo, you need to set the URL Scheme.

```objc

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

```

2、Initiate payment wherever payment needs to be called.
* Initiate WeChat payment,[[YSAliWechatPay sharedInstance] requestWechatPayment]
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
* Initiate Alipay payment,[[YSAliWechatPay sharedInstance] requestAliPayment]
```objc
- (void) requestAliPayment:(NSString *)payInfo
          fromScheme:(NSString *)fromScheme
               block:(void (^)(NSDictionary * _Nullable results, NSError * _Nullable error))block;
```
* Initialize Braintree api client, authorization is client token,[[YSApiClient sharedInstance] initBraintreeClient]
```objc
- (void) initBraintreeClient:(NSString*) authorization;
```
* Initiate Drop-In UI tab payment
```objc
[[BTDropInController alloc] initWithAuthorization:self.authToken request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error);
```
* Check whether Apple Pay is available, [[YSApplePay sharedInstance] canApplePayment]
```objc
- (bool) canApplePayment;
```
* Initiating Apple Pay, there are two calling methods: block and delegate
```objc
//block
- (void) requestApplePayment:(UIViewController*) viewController
                        paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig
                        shippingMethodUpdate:(void(^)(PKShippingMethod *shippingMethod, PKPaymentRequestShippingMethodUpdateBlock shippingMethodUpdateBlock)) shippingMethodReponse
                        authorizaitonResponse:(void(^)(BTApplePayCardNonce *tokenizedApplePayPayment, NSError *error,
                               PKPaymentAuthorizationResultBlock authorizationResult)) authorizaitonResponse;
//delegate
- (void) requestApplePayment:(UIViewController*) viewController
                            delegate:(id<PKPaymentAuthorizationViewControllerDelegate>) delegate
                      paymentRequest:(void(^)(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error)) paymentRequestConfig;
//Implement the following delegate method by yourself
- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller;

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion;

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                   handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull)) completion;
```
* Initiate a credit or debit card payment,[YSCardPay requestCardPayment]
```objc
+ (void) requestCardPayment:(BTCard *)card
                 completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;
```
* Initiate Venmo client payment,[YSVenmoPay requestVenmoPayment]
```objc
+ (void) requestVenmoPayment:(BOOL)vault
                  fromSchema:(NSString *)fromScheme
                  completion:(void (^)(BTVenmoAccountNonce *venmoAccount, NSError *error))completionBlock;
```
* There are two ways to initiate a PayPal payment:Vault和Checkout,[YSPayPalPay requestPayPal]
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

* Saving payment methods such as credit cards and PayPal

  Save payment methods such as credit cards and PayPal. To facilitate customers using the same payment method for future payments, saving the most recent payment method can avoid the need to repeatedly enter account information and complete payment. The client integration process is as follows:

  1. Register a customer before the first payment, including information such as email, phone, and country. The customer information can be retrieved or updated as needed.
  2. Call the /online/v3/secure-pay interface and pass in the customerNo field associated with the customer from the previous step.
  3. Call the /creditpay/v3/process interface to complete the payment.
   
  **Drop-in method:**
  
  Following the above steps, the Drop-in method will automatically save and display the previously used payment methods such as Credit Card and PayPal for the customer in the Drop-in display panel. After selecting the payment method, the customer can proceed to complete the payment without entering any information.
    
  **Custom UI method:**

  - Call the /online/v3/secure-pay interface to obtain the authorization and bind the fragment.
  - After obtaining the instance of YSApiClient.sharedInstance.apiClient, call the fetchPaymentMethodNonces function to retrieve and display the list of recent payment methods, including payment type and last 4 digits of the card number.
## ⚠️ Announcements

1、SDK call failed. First of all, please make sure that storeNo, merchantNo, and token are entered correctly. If the API call fails, please obtain relevant debugging information from the error returned by the block callback.

2、After jumping to Alipay and WeChat, it fails to jump back to the merchant app. Please check whether the merchant app has configured the URL Scheme correctly and passed the correct Scheme in the interface; whether the jump method is supported in `AppDelegate.m`.

3、When calling the order and payment interface, please make sure to add the Alipay mobile payment SDK; when calling the WeChat payment, please make sure to add the WeChat payment SDK; when calling various payments under Braintree, make sure to add the corresponding pod sdk .

4、When referencing the old version of BraintreeDropIn, an error such as'topLayoutGuide' is deprecated: first deprecated in iOS 11.0 will appear in the source code of Braintree DropIn. This problem has been fixed in 8.1.0. Just specify a version higher than 8.1.0.

5、According to the actual needs of the integrated payment method, the corresponding files are selectively added. Podfile also selectively installs the Braintree dependency library. Podfile is not required for WeChat or Alipay.

6、It cannot be called up or called back through the universal link. Please refer to the relevant configuration rules.

7、For other detailed usage, please refer to the example in MobilePaySDKSample, The example is for reference only and should not be used directly in the project.
