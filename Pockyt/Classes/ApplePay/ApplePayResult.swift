//
//  ApplePayResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/23.
//

import Braintree

@objcMembers
@objc public class ApplePayResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    
    init(respCode: String, respMsg: String?, applePayNonce: BTApplePayCardNonce?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.applePayNonce = applePayNonce
    }
    
    public let applePayNonce: BTApplePayCardNonce?
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
}

