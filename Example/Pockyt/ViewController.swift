//
//  ViewController.swift
//  Pockyt
//
//  Created by fly on 05/17/2024.
//  Copyright (c) 2024 fly. All rights reserved.
//

import UIKit
  
import UIKit
  
class ViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()
          
        setupButtons()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
      
    func setupButtons() {
        let buttonTitles = ["Alipay", "WechatPay", "Drop In", "CardPay", "PayPal", "Venmo", "Apple Pay"]
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 10
        var yOffset: CGFloat = 100
      
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 50, y: yOffset, width: view.frame.width - 100, height: buttonHeight)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
              
            // Set gray border color
            button.layer.borderWidth = 1
            button.layer.borderColor = button.currentTitleColor.cgColor
              
            // Set corner radius
            button.layer.cornerRadius = 10
              
            view.addSubview(button)
              
            yOffset += buttonHeight + spacing
        }
    }
      
    @objc func buttonTapped(_ sender: UIButton) {
        switch sender.currentTitle {
        case "Alipay":
            let alipayViewController = AlipayViewController()
            let navigationController = UINavigationController(rootViewController: alipayViewController)
            present(navigationController, animated: true, completion: nil)
        case "WechatPay":
            let wechatPayViewController = WechatPayViewController()
            let navigationController = UINavigationController(rootViewController: wechatPayViewController)
            present(navigationController, animated: true, completion: nil)
        case "Drop In":
            let dropInViewController = DropInViewController()
            let navigationController = UINavigationController(rootViewController: dropInViewController)
            present(navigationController, animated: true, completion: nil)
        case "CardPay":
            let cardPayViewController = CardPayViewController()
            let navigationController = UINavigationController(rootViewController: cardPayViewController)
            present(navigationController, animated: true, completion: nil)
        case "PayPal":
            let payPalViewController = PayPalViewController()
            let navigationController = UINavigationController(rootViewController: payPalViewController)
            present(navigationController, animated: true, completion: nil)
        case "Venmo":
            let venmoViewController = VenmoViewController()
            let navigationController = UINavigationController(rootViewController: venmoViewController)
            present(navigationController, animated: true, completion: nil)
        case "Apple Pay":
            let applePayViewController = ApplePayViewController()
            let navigationController = UINavigationController(rootViewController: applePayViewController)
            present(navigationController, animated: true, completion: nil)
        default:
            break
        }
    }
}


