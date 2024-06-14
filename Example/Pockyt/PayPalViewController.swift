//
//  PayPalViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Braintree
import Pockyt

class PayPalViewController: UIViewController {
    let contentView = UIView()
    let resultLabel = UILabel()
          
    override func viewDidLoad() {
        view.backgroundColor = .white
      
        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(contentView)
      
        let checkoutButton = UIButton(type: .system)
        checkoutButton.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 40)
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.addTarget(self, action: #selector(checkoutButtonClicked), for: .touchUpInside)
        // Set gray border color
        checkoutButton.layer.borderWidth = 1
        checkoutButton.layer.borderColor = checkoutButton.currentTitleColor.cgColor
        // Set corner radius
        checkoutButton.layer.cornerRadius = 10
        contentView.addSubview(checkoutButton)
      
        let vaultButton = UIButton(type: .system)
        vaultButton.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 40)
        vaultButton.setTitle("Vault", for: .normal)
        vaultButton.addTarget(self, action: #selector(vaultButtonClicked), for: .touchUpInside)
        // Set gray border color
        vaultButton.layer.borderWidth = 1
        vaultButton.layer.borderColor = vaultButton.currentTitleColor.cgColor
        // Set corner radius
        vaultButton.layer.cornerRadius = 10
        contentView.addSubview(vaultButton)
      
        let parentView = UIView(frame: CGRect(x: 20, y: 160, width: view.bounds.width - 40, height: 0))
        parentView.backgroundColor = UIColor.clear
        view.addSubview(parentView)
      
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .left
        resultLabel.text = "" // Fill in the text you want to display
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(resultLabel)
      
        resultLabel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        resultLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        resultLabel.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
      
        resultLabel.sizeToFit()
      
        contentView.addSubview(parentView)
    }
      
    @objc func checkoutButtonClicked() {
        let checkoutRequest = BTPayPalCheckoutRequest(amount: "1.00")
        let paypal = PayPal(authorization: HttpUtils.CLIENT_TOKEN, paypalRequest: checkoutRequest)
        Pockyt.shared.requestPay(paypal) { result in
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
      
    @objc func vaultButtonClicked() {
        let vaultRequest = BTPayPalVaultRequest()
        let paypal = PayPal(authorization: HttpUtils.CLIENT_TOKEN, paypalRequest: vaultRequest)
        Pockyt.shared.requestPay(paypal) { result in
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
    
    /*
     * Send nonce to your server, please read DropInViewController for details.
     */
    private func submitNonceToServer(transactionNo: String, nonce: String) {
        // Your code to submit nonce to the server
        // Submit device data to the server
        let deviceData = DataCollector.collectData()
    }
}
