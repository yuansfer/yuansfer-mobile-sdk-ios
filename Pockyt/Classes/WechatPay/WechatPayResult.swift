//
//  WechatPayResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/27.
//

@objcMembers
public class WechatPayResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let respError: String?
    
    init(respCode: String, respMsg: String?, respError: String?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.respError = respError
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.SUCCESS
    }
        
    public var isCancelled: Bool {
        return respCode == PockytCodes.CANCEL
    }
}
