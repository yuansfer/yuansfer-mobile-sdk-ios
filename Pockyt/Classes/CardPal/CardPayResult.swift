//
//  File.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//
import Braintree

@objcMembers
public class CardPayResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let tokenizedCard: BTCardNonce?
    
    init(respCode: String, respMsg: String?, tokenizedCard: BTCardNonce?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.tokenizedCard = tokenizedCard
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
}

