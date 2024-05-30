//
//  PockytCodes.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/21.
//

@objcMembers
public class PockytCodes: NSObject {
    // Common codes
    public static let SUCCESS = "0"
    public static let ERROR = "-1"
    public static let CANCEL = "-2"
    public static let COMPLETED = "1"
    // Alipay codes
    public static let ALIPAY_SUCCESS = "9000"
    public static let ALIPAY_CANCEL = "6001"
    public static let ALIPAY_PENDING = "8000"
    public static let ALIPAY_PAY_FAIL = "4000"
    public static let ALIPAY_DUPLICATE_REQUEST = "5000"
    public static let ALIPAY_NO_CONNECTION = "6002"
    // Wechat Pay codes
    public static let WECHAT_SENT_FAIL = "-3"
    public static let WECHAT_AUTH_DENY = "-4"
    public static let WECHAT_UN_SUPPORT = "-5"
}


