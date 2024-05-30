//
//  PockytCodes.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/21.
//

struct PockytCodes {
    // Common codes
    static let SUCCESS = "0"
    static let ERROR = "-1"
    static let CANCEL = "-2"
    static let COMPLETED = "1"
    // Alipay codes
    static let ALIPAY_SUCCESS = "9000"
    static let ALIPAY_CANCEL = "6001"
    static let ALIPAY_PENDING = "8000"
    static let ALIPAY_PAY_FAIL = "4000"
    static let ALIPAY_DUPLICATE_REQUEST = "5000"
    static let ALIPAY_NO_CONNECTION = "6002"
    // Wechat Pay codes
    static let WECHAT_SENT_FAIL = "-3"
    static let WECHAT_AUTH_DENY = "-4"
    static let WECHAT_UN_SUPPORT = "-5"
}

