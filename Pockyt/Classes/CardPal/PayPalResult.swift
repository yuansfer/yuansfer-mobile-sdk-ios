//
//  PayPalResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//

import Braintree

@objcMembers
public class PayPalResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let paypalAccountNonce: BTPayPalAccountNonce?
    
    init(respCode: String, respMsg: String?, paypalAccountNonce: BTPayPalAccountNonce?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.paypalAccountNonce = paypalAccountNonce
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
}
