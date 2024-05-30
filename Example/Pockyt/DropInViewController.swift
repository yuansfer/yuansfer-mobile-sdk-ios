//
//  DropInViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Pockyt
import BraintreeDropIn

class DropInViewController: UIViewController {
    let contentView = UIView()
    let resultLabel = UILabel()

    let merchantNoLabel = UILabel()
    let merchantNoTextField = UITextField()

    let storeNoLabel = UILabel()
    let storeNoTextField = UITextField()

    let amountLabel = UILabel()
    let amountTextField = UITextField()

    let sendRequestButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(contentView)

        merchantNoLabel.frame = CGRect(x: 20, y: 20, width: 200, height: 30)
        merchantNoLabel.text = "MerchantNo."
        contentView.addSubview(merchantNoLabel)

        merchantNoTextField.frame = CGRect(x: 20, y: 60, width: view.bounds.width - 40, height: 30)
        merchantNoTextField.text = HttpUtils.MERCHANT_NO
        merchantNoTextField.borderStyle = .roundedRect
        contentView.addSubview(merchantNoTextField)

        storeNoLabel.frame = CGRect(x: 20, y: 100, width: 200, height: 30)
        storeNoLabel.text = "StoretNo."
        contentView.addSubview(storeNoLabel)

        storeNoTextField.frame = CGRect(x: 20, y: 140, width: view.bounds.width - 40, height: 30)
        storeNoTextField.text = HttpUtils.STORE_NO
        storeNoTextField.borderStyle = .roundedRect
        contentView.addSubview(storeNoTextField)

        amountLabel.frame = CGRect(x: 20, y: 180, width: 200, height: 30)
        amountLabel.text = "Amount"
        contentView.addSubview(amountLabel)

        amountTextField.frame = CGRect(x: 20, y: 220, width: view.bounds.width - 40, height: 30)
        amountTextField.borderStyle = .roundedRect
        amountTextField.text = "0.01"
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        contentView.addSubview(amountTextField)

        sendRequestButton.frame = CGRect(x: 20, y: 260, width: view.bounds.width - 40, height: 40)
        sendRequestButton.setTitle("Send Request & Pay", for: .normal)
        sendRequestButton.addTarget(self, action: #selector(sendRequestButtonTapped), for: .touchUpInside)
        // Set gray border color
        sendRequestButton.layer.borderWidth = 1
        sendRequestButton.layer.borderColor = sendRequestButton.currentTitleColor.cgColor
        // Set corner radius
        sendRequestButton.layer.cornerRadius = 10
        contentView.addSubview(sendRequestButton)

        let parentView = UIView(frame: CGRect(x: 20, y: 320, width: view.bounds.width - 40, height: 0))
        parentView.backgroundColor = UIColor.clear
        view.addSubview(parentView)
          
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .left
        resultLabel.text = "" // 填入你想要显示的文本
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(resultLabel)
          
        resultLabel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        resultLabel.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
          
        resultLabel.sizeToFit()
        
        contentView.addSubview(parentView)
    }
    
    @objc func handleTap() {
        amountTextField.resignFirstResponder()
    }

    /// If you pass a 'customerNo' when generating a client token, Drop-in will display that customer's saved payment methods and automatically add any newly-entered payment methods to their Vault record. Create customer api: https://docs.pockyt.io/reference/register-customer
    /// If vaulted payment methods exist, this is how they will appear in Drop-in.
    ///
    @objc func sendRequestButtonTapped() {
        // Simply do not add the 'customerNo' parameter.
        let path = "/online/v3/secure-pay"
        let params : [String: Any] = [
        "merchantNo": merchantNoTextField.text!,
        "storeNo": storeNoTextField.text!,
        "amount": amountTextField.text!,
        "vendor":"creditcard",
        "ipnUrl": "https://merchant.com/ipn",
        "reference": UUID().uuidString,
        "note": "note",
        "description": "description",
        "settleCurrency": "USD",
        "currency": "USD",
        "terminal": "YIP",
        "osType": "ANDROID"]
        
        HttpUtils.doPost(path: path, data: params, token: HttpUtils.API_TOKEN) { [self] (data, response, error) in
        
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: \(String(describing: response))")
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let retCode = json["ret_code"] as! String
                    if retCode == "000100" {
                        let result = json["result"] as! [String: Any]
                        print("\(path) result: \(result)")
                        let authorization = result["authorization"] ?? HttpUtils.CLIENT_TOKEN
                        DispatchQueue.main.async {
                            self.requestPay(authorization as! String)
                        }
                    } else {
                        let retMsg = json["ret_msg"] as! String
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Error: \(retMsg)"
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func requestPay(_ authorization: String) {
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
    }
    
    private func startApplePay() {
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
    }
    
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
    }
    
    private func presentAuthorizationViewController(_ applePay: ApplePay) {
        applePay.requestPay() { result in
            DispatchQueue.main.async {
                if result.isSuccessful {
                    self.resultLabel.text = "Payment processing"
                    self.submitNonceToServer(transactionNo: "xxx", nonce: result.applePayNonce!.nonce)
                    // Please refer to the ApplePayViewController for updating the Apple Pay status after calling the API.
                    // Here is a demonstration of the notification
                    let apiSuccess = true
                    if (apiSuccess) {
                        applePay.notifyPaymentCompletion(true)
                    } else {
                        applePay.notifyPaymentCompletion(false)
                    }
                } else {
                    self.resultLabel.text = result.respMsg
                }
            }
        }
    }
    
    private func createThreeDSecure() ->  BTThreeDSecureRequest{
        let threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = 0.01
        threeDSecureRequest.email = "test@email.com"

        let address = BTThreeDSecurePostalAddress()
        address.givenName = "Jill" // ASCII-printable characters required, else will throw a validation error
        address.surname = "Doe" // ASCII-printable characters required, else will throw a validation error
        address.phoneNumber = "5551234567"
        address.streetAddress = "555 Smith St"
        address.extendedAddress = "#2"
        address.locality = "Chicago"
        address.region = "IL" // ISO-3166-2 code
        address.postalCode = "12345"
        address.countryCodeAlpha2 = "US"
        threeDSecureRequest.billingAddress = address

        // Optional additional information.
        // For best results, provide as many of these elements as possible.
        let info = BTThreeDSecureAdditionalInformation()
        info.shippingAddress = address
        threeDSecureRequest.additionalInformation = info
        return threeDSecureRequest
    }
    
    private func submitNonceToServer(transactionNo: String, nonce: String) {
        // paymentMethod: paypal_account、venmo_account、credit_card、android_pay_card
        let path = "/creditpay/v3/process"
        let params : [String: Any] = [
        "merchantNo": merchantNoTextField.text!,
        "storeNo": storeNoTextField.text!,
        "amount": amountTextField.text!,
        "paymentMethod":"paypal_account",
        "paymentMethodNonce": nonce,
        "transactionNo": transactionNo]
        HttpUtils.doPost(path: path, data: params, token: HttpUtils.API_TOKEN) { [self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: \(String(describing: response))")
                return
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    let retCode = json["ret_code"] as! String
                    if retCode == "000100" {
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Payment success"
                        }
                    } else {
                        let retMsg = json["ret_msg"] as! String
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Payment failed: \(retMsg)"
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }

}
