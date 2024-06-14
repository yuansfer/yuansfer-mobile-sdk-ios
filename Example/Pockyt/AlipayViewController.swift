//
//  AlipayViewController.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import Pockyt

class AlipayViewController: UIViewController {

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

    @objc func sendRequestButtonTapped() {
        // Perform request and display result
        let path = "/micropay/v3/prepay"
        let params : [String: Any] = [
        "merchantNo": merchantNoTextField.text!,
        "storeNo": storeNoTextField.text!,
        "amount": amountTextField.text!,
        "vendor":"alipay",
        "ipnUrl": "https://merchant.com/ipn",
        "reference": UUID().uuidString,
        "note": "note",
        "description": "description",
        "settleCurrency": "USD",
        "currency": "USD",
        "terminal": "APP"]

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
                        let payInfo = result["payInfo"] as! String
                        DispatchQueue.main.async {
                            self.submitPayment(payInfo: payInfo)
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
    
    private func submitPayment(payInfo: String) {
        let payment = Alipay(payInfo)
        Pockyt.shared.requestPay(payment) { result in
            self.resultLabel.text = "Paid: \(result.isSuccessful), cancelled: \(result.isCancelled), \(result.memo ?? "")"
        }
    }
}





