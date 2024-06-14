//
//  ApplePayViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import PassKit
import Braintree
import Pockyt

class ApplePayViewController: UIViewController {
  
    let contentView = UIView()
    let resultLabel = UILabel()
          
    override func viewDidLoad() {
        view.backgroundColor = .white

        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(contentView)

        let applePayButton = applePayButton()
        // Set gray border color
        applePayButton.layer.borderWidth = 1
        applePayButton.layer.borderColor = applePayButton.currentTitleColor.cgColor
        // Set corner radius
        applePayButton.layer.cornerRadius = 10
        applePayButton.isEnabled = PKPaymentAuthorizationViewController.canMakePayments()
        contentView.addSubview(applePayButton)

        let parentView = UIView(frame: CGRect(x: 20, y: 140, width: view.bounds.width - 40, height: 0))
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
    
    func applePayButton() -> UIButton {
        let button = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        button.cornerRadius = 10
        button.frame = CGRect(x: view.bounds.midX - 100, y: 80, width: 200, height: 40)
        button.addTarget(self, action: #selector(tappedApplePay), for: .touchUpInside)
        return button
    }

      
    @objc func tappedApplePay() {
        let applePay = ApplePay(viewController: self, authorization: HttpUtils.CLIENT_TOKEN)
        applePay.initPaymentRequest() { paymentRequest, error in
            if let paymentRequest = paymentRequest {
                self.resultLabel.text = "Payment request initialized"
                self.showApplePaySheet(paymentRequest: paymentRequest)
                self.presentAuthorizationViewController(applePay)
            } else {
                self.resultLabel.text = "Failed to initialize payment request"
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
            if result.isSuccessful {
                self.resultLabel.text = "Payment processing, please wait..."
                self.resultLabel.text = "Obtained nonce: \(result.applePayNonce!.nonce)"
                self.submitNonceToServer(applePay: applePay, transactionNo: "xxx", nonce: result.applePayNonce!.nonce)
            } else {
                self.resultLabel.text = result.respMsg
            }
        }
    }
    
    /*
     * Send nonce to your server, please read DropInViewController for details.
     */
    private func submitNonceToServer(applePay: ApplePay, transactionNo: String, nonce: String) {
        // Your code to submit nonce to the server
        // Notify Apple that the payment has been successfully completed after the API call.
        // Here is a demonstration of the notification
        let apiSuccess = true
        if (apiSuccess) {
            applePay.notifyPaymentCompletion(true)
        } else {
            applePay.notifyPaymentCompletion(false)
        }
    }
}
