//
//  VenmoViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Braintree
import Pockyt

class VenmoViewController: UIViewController {
  
    let contentView = UIView()
    let resultLabel = UILabel()
          
    override func viewDidLoad() {
        view.backgroundColor = .white

        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(contentView)

        let sendRequestButton = UIButton(type: .system)
        sendRequestButton.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 40)
        sendRequestButton.setTitle("Send Request & Pay", for: .normal)
        sendRequestButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        // Set gray border color
        sendRequestButton.layer.borderWidth = 1
        sendRequestButton.layer.borderColor = sendRequestButton.currentTitleColor.cgColor
        // Set corner radius
        sendRequestButton.layer.cornerRadius = 10
        contentView.addSubview(sendRequestButton)

        let parentView = UIView(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 0))
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
      
    @objc func buttonClicked() {
        let request = BTVenmoRequest()
        request.paymentMethodUsage = .multiUse
        let venmo = Venmo(authorization: HttpUtils.CLIENT_TOKEN, venmoRequest: request)
        Pockyt.shared.requestPay(venmo) { result in
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
    
    /*
     * Send nonce to your server, please read DropInViewController for details.
     */
    private func submitNonceToServer(transactionNo: String, nonce: String) {
        // Your code to submit nonce to the server
    }
}
