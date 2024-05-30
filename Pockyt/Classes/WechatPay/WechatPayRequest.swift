//
//  WechatPayRequest.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/20.
//

@objcMembers
@objc public class WechatPayRequest: NSObject {
    public let partnerId: String
    public let prepayId: String
    public let packageValue: String
    public let nonceStr: String
    public let timeStamp: String
    public let sign: String
  
    public init(partnerId: String, prepayId: String, packageValue: String, nonceStr: String, timeStamp: String, sign: String) {
        self.partnerId = partnerId
        self.prepayId = prepayId
        self.packageValue = packageValue
        self.nonceStr = nonceStr
        self.timeStamp = timeStamp
        self.sign = sign
    }
}

