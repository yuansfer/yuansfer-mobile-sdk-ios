//
//  File.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//

import Braintree

@objcMembers
@objc public class VenmoResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let venmoNonce: BTVenmoAccountNonce?
    
    init(respCode: String, respMsg: String?, venmoNonce: BTVenmoAccountNonce?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.venmoNonce = venmoNonce
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
}
