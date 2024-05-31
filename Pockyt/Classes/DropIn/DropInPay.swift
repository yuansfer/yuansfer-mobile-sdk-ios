//
//  DropInPay.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/22.
//

import BraintreeDropIn
import Braintree

@objcMembers
public class DropInPay: NSObject, PaymentProtocol {
      
    private let uiViewController: UIViewController
    private let clientToken: String
    private let dropInRequest: BTDropInRequest
      
    public init(uiViewController: UIViewController, clientToken: String, dropInRequest: BTDropInRequest) {
        self.uiViewController = uiViewController
        self.clientToken = clientToken
        self.dropInRequest = dropInRequest
    }
      
    public func requestPay(completion: @escaping (DropInPayResult) -> Void) {
        let dropIn = BTDropInController(authorization: clientToken, request: dropInRequest) { controller, result, error in
            if let error = error {
                completion(DropInPayResult(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription, dropInResult: nil))
            } else if (result?.isCanceled == true) {
                completion(DropInPayResult(respCode: PockytCodes.CANCEL, respMsg: "User canceled", dropInResult: nil))
            } else if (result?.paymentMethodType == .applePay) {
                completion(DropInPayResult(respCode: PockytCodes.COMPLETED, respMsg: "Please proceed with the Apple Pay flow", dropInResult: result))
            } else if let result = result {
                completion(DropInPayResult(respCode: PockytCodes.SUCCESS, respMsg: "Success", dropInResult: result))
            }
            controller.dismiss(animated: true, completion: nil)
        }
          
        if let dropIn = dropIn {
            uiViewController.present(dropIn, animated: true, completion: nil)
        }
    }
}

