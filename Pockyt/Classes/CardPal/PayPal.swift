//
//  PayPal.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//
import Braintree

@objcMembers
public class PayPal:NSObject, PaymentProtocol {
        
    private let braintreeClient: BTAPIClient?
    private let paypalRequest: BTPayPalRequest
          
    public init(authorization: String, paypalRequest: BTPayPalRequest) {
        self.braintreeClient =  BTAPIClient(authorization: authorization)
        self.paypalRequest = paypalRequest
    }
            
    public func requestPay(completion: @escaping (PayPalResult) -> Void) {
        guard let braintreeClient = braintreeClient else {
            let result = PayPalResult(respCode: PockytCodes.ERROR, respMsg: "Failed to create BTAPIClient", paypalAccountNonce: nil)
            completion(result)
            return
        }
            
        let paypalDriver = BTPayPalDriver(apiClient: braintreeClient)
        paypalDriver.tokenizePayPalAccount(with: paypalRequest) { paypalAccountNonce, error in
            let respCode = error == nil ? PockytCodes.SUCCESS : PockytCodes.ERROR
            let respMsg = error?.localizedDescription ?? ""
            let result = PayPalResult(respCode: respCode, respMsg: respMsg, paypalAccountNonce: paypalAccountNonce)
            completion(result)
        }
    }
}

