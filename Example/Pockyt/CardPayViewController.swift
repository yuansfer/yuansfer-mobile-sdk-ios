//
//  CardPayViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Braintree
import Pockyt

class CardPayViewController: UIViewController {
    
    let contentView = UIView()
    let resultLabel = UILabel()
          
    override func viewDidLoad() {
        view.backgroundColor = .white

        contentView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(contentView)

        let sendRequestButton = UIButton(type: .system)
        sendRequestButton.frame = CGRect(x: 20, y: 40, width: view.bounds.width - 40, height: 40)
        sendRequestButton.setTitle("Card Pay", for: .normal)
        sendRequestButton.addTarget(self, action: #selector(tapCardPay), for: .touchUpInside)
        // Set gray border color
        sendRequestButton.layer.borderWidth = 1
        sendRequestButton.layer.borderColor = sendRequestButton.currentTitleColor.cgColor
        // Set corner radius
        sendRequestButton.layer.cornerRadius = 10
        contentView.addSubview(sendRequestButton)

        let threeDSecureButton = UIButton(type: .system)
        threeDSecureButton.frame = CGRect(x: 20, y: sendRequestButton.frame.origin.y + sendRequestButton.frame.size.height + 20, width: view.bounds.width - 40, height: 40)
        threeDSecureButton.setTitle("3D Secure Pay", for: .normal)
        threeDSecureButton.addTarget(self, action: #selector(tapThreeDSecure), for: .touchUpInside)
        // Set gray border color
        threeDSecureButton.layer.borderWidth = 1
        threeDSecureButton.layer.borderColor = threeDSecureButton.currentTitleColor.cgColor
        // Set corner radius
        threeDSecureButton.layer.cornerRadius = 10
        contentView.addSubview(threeDSecureButton)

        let parentView = UIView(frame: CGRect(x: 20, y: threeDSecureButton.frame.origin.y + threeDSecureButton.frame.size.height + 20, width: view.bounds.width - 40, height: 0))
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

    @objc func tapThreeDSecure() {
        
        let path = "/online/v3/secure-pay"
        let params : [String: Any] = [
        "merchantNo": HttpUtils.MERCHANT_NO,
        "storeNo": HttpUtils.STORE_NO,
        "amount": "0.01",
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
                        let authorization = result["authorization"]
                        DispatchQueue.main.async {
                            self.requestThreeDSecure(authorization as! String)
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
      
    @objc func tapCardPay() {
        let cardNumber = "4111111111111111"
        let expirationMonth = "12"
        let expirationYear = "2025"
        let cvv = "999"
            
        let card = BTCard()
        card.number = cardNumber
        card.expirationMonth = expirationMonth
        card.expirationYear = expirationYear
        card.cvv = cvv
            
        let cardPay = CardPay(authorization: HttpUtils.CLIENT_TOKEN, btCard: card)
            
        Pockyt.shared.requestPay(cardPay) { result in
            if result.isSuccessful {
                if let nonce = result.tokenizedCard?.nonce {
                    self.resultLabel.text = "Obtained nonce: \(nonce)"
                } else {
                    self.resultLabel.text = "Failed to obtain nonce"
                }
            } else {
                self.resultLabel.text = "Failed to obtain nonce, error: \(result.respMsg ?? "Unknown error")"
            }
        }
    }
    
    private func requestThreeDSecure(_ authorization: String) {
        let cardNumber = "4111111111111111"
        let expirationMonth = "12"
        let expirationYear = "2025"
        let cvv = "999"
            
        let card = BTCard()
        card.number = cardNumber
        card.expirationMonth = expirationMonth
        card.expirationYear = expirationYear
        card.cvv = cvv
            
        let cardPay = CardPay(authorization: authorization, btCard: card)
            
        Pockyt.shared.requestPay(cardPay) { result in
            if result.isSuccessful {
                if let nonce = result.tokenizedCard?.nonce {
                    self.startThreeDSecurePaymentFlow(cardNonce: nonce, authorization: authorization)
                } else {
                    self.resultLabel.text = "Failed to obtain nonce"
                }
            } else {
                self.resultLabel.text = "Failed to obtain nonce, error: \(result.respMsg ?? "Unknown error")"
            }
        }
    }
    
    private func startThreeDSecurePaymentFlow(cardNonce: String, authorization: String) {
        let threeDSecureRequest = BTThreeDSecureRequest()
        threeDSecureRequest.amount = 0.01
        
        // Important: set the nonce to the 3DSecureRequest
        threeDSecureRequest.nonce = cardNonce
        
        threeDSecureRequest.email = "test@email.com"
        threeDSecureRequest.versionRequested = .version2

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
        let threeDSecure = ThreeDSecurePay(uiViewController: self, authorization: authorization, threeDSecureRequest: threeDSecureRequest)
        Pockyt.shared.requestPay(threeDSecure) {result in
            if let tokenizedCard = result.tokenizedCard {
                if (tokenizedCard.threeDSecureInfo.liabilityShiftPossible) {
                    if (tokenizedCard.threeDSecureInfo.liabilityShifted) {
                        // 3D Secure authentication success
                        self.resultLabel.text = "Liability shift possible and liability shifted"
                    } else {
                        // 3D Secure authentication failed
                        self.resultLabel.text = "3D Secure authentication failed"
                    }
                } else {
                    // 3D Secure authentication was not possible
                    self.resultLabel.text = "3D Secure authentication was attempted but liability shift is not possible"
                }
                self.submitNonceToServer(transactionNo: "xxx", nonce: tokenizedCard.nonce)
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
