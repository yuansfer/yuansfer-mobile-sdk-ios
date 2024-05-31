//
//  DropInPayResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/23.
//
import BraintreeDropIn

@objcMembers
public class DropInPayResult:NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let dropInResult: BTDropInResult?
      
    init(respCode: String, respMsg: String?, dropInResult: BTDropInResult?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.dropInResult = dropInResult
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
      
    public var isCancelled: Bool {
        return respCode == PockytCodes.CANCEL
    }
}
