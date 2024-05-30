//
//  PayPalResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//

import Braintree

@objcMembers
@objc public class PayPalResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    
    init(respCode: String, respMsg: String?, paypalAccountNonce: BTPayPalAccountNonce?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.paypalAccountNonce = paypalAccountNonce
    }
    
    public let paypalAccountNonce: BTPayPalAccountNonce?
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
}
