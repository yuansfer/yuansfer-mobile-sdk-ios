//
//  CashAppResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//

@objcMembers
public class CashAppResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    
    init(respCode: String, respMsg: String?) {
        self.respCode = respCode
        self.respMsg = respMsg
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
    
    public var isDeclined: Bool {
        return respCode == PockytCodes.CANCEL
    }
}

