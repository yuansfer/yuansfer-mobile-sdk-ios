## Introduction

[![CocoaPods](https://img.shields.io/badge/cocoapods-v0.5.0-blue)](https://cocoapods.org/pods/Pockyt)
This is a payment sdk that supports mainstream payment methods such as WeChat Pay, Alipay and Braintree etc.

## Getting Started

- Before integrating the payment, please contact the Pockyt team to create an account. We may require you to submit documentation files.
- For Wechat Pay, configure the bundle identifier and universal links in the WeChat Open Platform. [official guide](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Access_Guide/iOS.html)
- For Braintree, please contact the Pockyt team to confirm the payment mode. When integrating with Braintree, you will need to create an account and configure it on the official platform.[official guide](https://developer.paypal.com/braintree/docs/guides/overview)

## Installation

- Pockyt is available through [CocoaPods](https://cocoapods.org). Due to the independence of payment methods, 
you are free to choose which payment methods you want to install and combine. 
Pockyt includes Alipay and WeChat Pay by default, if only these two methods are needed.
To install it, simply add the following line to your Podfile:
```ruby
  pod 'Pockyt'
```
- Below are the separate installation forms for various payment methods, to be downloaded as 'Pockyt/xxx' sub-components. 
It is important to note that 'Pockyt/DropIn' will automatically include other Braintree payment methods. 
DropIn is a quick integration method using the official UI library, however you still need to import the submodules from the SDK for easy usage. while non-DropIn methods require individual addition of each payment component.
```ruby
  pod 'Pockyt/WechatPay', :path => '../'
  pod 'Pockyt/Alipay', :path => '../'
  pod 'Pockyt/DropIn', :path => '../'
  pod 'Pockyt/ApplePay', :path => '../'
  pod 'Pockyt/CardPal', :path => '../'
  pod 'Pockyt/Venmo', :path => '../'
  pod 'Pockyt/ThreeDSecure', :path => '../'
  pod 'Pockyt/DataCollect', :path => '../'
```

## Configuration

### Alipay
- In Xcode, select your project's settings, choose the "TARGETS" tab, and then select the "info" tab. Under the "URL Types" section, add a "URL Scheme" with the application identifier, such as "pockyt2alipay". It is recommended to have a distinctive identifier that does not overlap with other merchant apps. Otherwise, it may result in the inability to correctly redirect back to the merchant's app from Alipay.

### WeChat Pay
- In Xcode, select your project's settings, choose the "TARGETS" tab, and then select the "info" tab. Under the "URL Types" section, add a "URL Scheme" with the application ID that you have registered.
- In Xcode, select your project's settings, choose the "TARGETS" tab, and then select the "info" tab. Under the "LSApplicationQueriesSchemes" section, add "weixin" and "weixinULAPI".
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>weixin</string>
  <string>weixinULAPI</string>
</array>
```
- Configuring Universal Links for the application.
> Configure Universal Links for your application according to the Apple documentation(https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content).
> In Xcode, Turn on the "Associated Domains" switch and add the Universal Links domain to the configuration.
> Please go to the WeChat Open Platform - Developer Application Registration page to register. After registering and selecting the mobile application for configuration, you will obtain an App ID that can be used immediately for development. However, after the application registration is completed, it still needs to go through the submission and review process. Only applications that pass the review can be officially published and used.

### Drop-in UI
- Xcode 12+
- A minimum deployment target of iOS 12.0
- Swift 5.1+ (or Objective-C)

### Venmo
- In Xcode, select your project's settings, choose the "TARGETS" tab, and then select the "info" tab. Under the "URL Types" section, Add the Identifier as "braintree". Please note that "braintree" is a fixed term and cannot be changed, as it will affect the integration of Venmo.
    Add a "URL Scheme" with the application identifier(begin with your app's bundle ID), such as "com.yuansfer.msdk.pockyt2braintree".
- You must add the following to the queries schemes allowlist in your app's info.plist:
```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>com.venmo.touch.v2</string>
</array>
```
- You must have a display name in your app's info.plist to help Venmo identify your application:
```xml
<key>CFBundleDisplayName</key>
<string>Your App Name</string>
```

### Apple Pay

- In order to use Apple Pay on a real device, you must configure an Apple Pay Merchant ID and an Apple Pay payment processing certificate in Apple's Developer Center, [Offical guide](https://developer.paypal.com/braintree/docs/guides/apple-pay/configuration/ios/v5).
- In Xcode, enable Apple Pay under Capabilities in your Project Settings. Then enable both Apple Pay Merchant IDs. It is important that you compile your app with a provisioning profile for the Apple development team with an Apple Pay Merchant ID. Apple Pay does not support enterprise provisioning.

## How to use

- For WeChat Pay, Alipay, and Venmo, you need to override the following methods in the AppDelegate:
```swift
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return Pockyt.shared.handleOpenURL(url)
}
  
@available(iOS 9.0, *)
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return Pockyt.shared.handleOpenURL(url)
}

// For WeChat Pay
func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return Pockyt.shared.handleOpenUniversalLink(userActivity)
}
```
- After calling the Pockyt prepayment API(`/micropay/v3/prepay` or `/online/v3/secure-pay`), create a payment object and call the Pockyt.shared.requestPay method.
```swift
// For Alipay
let payment = Alipay(payInfo: payInfo, fromScheme: "pockyt2alipay")
Pockyt.shared.requestPay(payment) { result in
    DispatchQueue.main.async {
        self.resultLabel.text = "Paid: \(result.isSuccessful), cancelled: \(result.isCancelled), \(result)"
    }
}

// For WeChat Pay
let request = WechatPayRequest(partnerId: partnerid, prepayId: prepayid, packageValue: package, nonceStr: noncestr, timeStamp: timestamp, sign: sign)
Pockyt.shared.requestPay(WechatPay(request)) { result in
    DispatchQueue.main.async {
        self.resultLabel.text = "Paid: \(result.isSuccessful), cancelled: \(result.isCancelled), \(result)"
    }
}

// For Drop-in UI
let dropReq = BTDropInRequest()
// BTDropInRequest has many configuration options
// ThreeDSeucre for card, optional
// dropReq.threeDSecureRequest = createThreeDSecure()
let payment = DropInPay(uiViewController: self, clientToken: authorization, dropInRequest: dropReq)
Pockyt.shared.requestPay(payment) { result in
    DispatchQueue.main.async {
        if let nonce = result.dropInResult?.paymentMethod?.nonce{
            self.resultLabel.text = "Obtained nonce: \(result.isSuccessful), cancelled: \(result.isCancelled), nonce: \(nonce)"
        } else if .applePay == result.dropInResult?.paymentMethodType {
            self.resultLabel.text = result.respMsg
            // Note that Apple Pay requires continuing the payment flow initiation
            self.startApplePay()
        } else if let error = result.respMsg {
            self.resultLabel.text = "Failed to obtain nonce, cancelled: \(result.isCancelled), error: \(error)"
        } else {
            self.resultLabel.text = "Failed to obtain nonce, cancelled: \(result.isCancelled)"
        }
    }
}

// For PayPal
let request = BTPayPalCheckoutRequest(amount: "1.00")
let request = BTPayPalVaultRequest()
let paypal = PayPal(authorization: HttpUtils.CLIENT_TOKEN, paypalRequest: request)
Pockyt.shared.requestPay(paypal) { result in
    DispatchQueue.main.async {
        if result.isSuccessful {
            if let nonce = result.paypalAccountNonce?.nonce {
                self.resultLabel.text = "Obtained nonce: \(nonce)"
            } else {
                self.resultLabel.text = "Failed to obtain nonce"
            }
        } else {
            self.resultLabel.text = "Failed to obtain nonce, error: \(result.respMsg ?? "Unknown error")"
        }
    }
}

// For Venmo
let request = BTVenmoRequest()
request.paymentMethodUsage = .multiUse
let venmo = Venmo(authorization: HttpUtils.CLIENT_TOKEN, venmoRequest: request)
Pockyt.shared.requestPay(venmo) { result in
    DispatchQueue.main.async {
        if result.isSuccessful {
            if let nonce = result.venmoNonce?.nonce {
                self.resultLabel.text = "Obtained nonce: \(nonce)"
            } else {
                self.resultLabel.text = "Failed to obtain nonce"
            }
        } else {
            self.resultLabel.text = "Failed to obtain nonce, error: \(result.respMsg ?? "Unknown error")"
        }
    }
}

// For Apple Pay, There are a few additional steps in the payment process compared to the ones mentioned above
// First, initialize the Apple Pay request parameters
let applePay = ApplePay(viewController: self, authorization: HttpUtils.CLIENT_TOKEN)
applePay.initPaymentRequest() { paymentRequest, error in
    DispatchQueue.main.async {
        if let paymentRequest = paymentRequest {
            self.resultLabel.text = "Payment request initialized"
            self.showApplePaySheet(paymentRequest: paymentRequest)
            self.presentAuthorizationViewController(applePay)
        } else {
            self.resultLabel.text = "Failed to initialize payment request"
        }
    }
}
// Then, present the Apple Pay sheet
private func showApplePaySheet(paymentRequest: PKPaymentRequest) {
    paymentRequest.requiredBillingContactFields = [.postalAddress]
    // Set other PKPaymentRequest properties here
    paymentRequest.merchantCapabilities = .capability3DS
    paymentRequest.paymentSummaryItems =
    [
        PKPaymentSummaryItem(label: "test_item", amount: NSDecimalNumber(string: "0.02")),
        // Add add'l payment summary items...
        PKPaymentSummaryItem(label: "Pockyt.io", amount: NSDecimalNumber(string: "0.02")),
    ]
    // ...
}
// Secondly, present the Apple Pay authorization view controller
private func presentAuthorizationViewController(_ applePay: ApplePay) {
    applePay.requestPay() { result in
        DispatchQueue.main.async {
            if result.isSuccessful {
                self.resultLabel.text = "Payment processing, please wait..."
                self.submitNonceToServer(applePay: applePay, transactionNo: "xxx", nonce: result.applePayNonce!.nonce)
                self.resultLabel.text = "Payment successful, nonce: \(result.applePayNonce!.nonce)"
            } else {
                self.resultLabel.text = result.respMsg
            }
        }
    }
}
// Finally, Submit the Apple Pay nonce to your server, Notify the Apple Pay wallet of the payment status based on the API result
if (apiSuccess) {
    applePay.notifyPaymentCompletion(true)
} else {
    applePay.notifyPaymentCompletion(false)
}
```
- For Braintree, After obtaining the nonce from the payment result, call the Pockyt process API (`/creditpay/v3/process`) to complete the payment.

## Note

- 'deviceData' is used to reduce the chargeback rate. It is recommended to use the collectData method of DataCollector to obtain and submit the data to the server for processing.
- If you pass a 'customerNo' when generating a client token, Drop-in will display that customer's saved payment methods and automatically add any newly-entered payment methods to their Vault record. Create customer api: https://docs.pockyt.io/reference/register-customer
    If vaulted payment methods exist, this is how they will appear in Drop-in.
- For detailed usage of the SDK, please refer to the example provided for Pockyt.
