//
//  AlipayResult.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/17.
//

@objcMembers
public class AlipayResult: NSObject, PaymentResultProtocol {
    public let respCode: String
    public let respMsg: String?
    public let memo: String?
    
    init(respCode: String, respMsg: String?, memo: String?) {
        self.respCode = respCode
        self.respMsg = respMsg
        self.memo = memo
    }
    
    public var isSuccessful: Bool {
        return respCode == PockytCodes.ALIPAY_SUCCESS
    }
      
    public var isCancelled: Bool {
        return respCode == PockytCodes.ALIPAY_CANCEL
    }
}
