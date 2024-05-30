//
//  Alipay.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/17.
//

@objcMembers
public class WechatPay: NSObject, PaymentProtocol {

    private let request: WechatPayRequest
    private var payCompletion: ((PayResult) -> Void)?
    private var delegate: WXApiDelegate?

    public init(_ request: WechatPayRequest) {
        self.request = request
        super.init()
        self.delegate = WechatPayDelegate(self)
    }
    
    public static func registerWechat(appid: String, universalLink: String) {
        WXApi.registerApp(appid, universalLink: universalLink)
    }
    
    public static func isAppInstalled() -> Bool {
        return WXApi.isWXAppInstalled()
    }
    
    public static func isWXAppSupportApi() -> Bool {
        return WXApi.isWXAppSupport()
    }

    public func requestPay(completion: @escaping (WechatPayResult) -> Void) {
        self.payCompletion = completion
        let payReq = PayReq.init()
        payReq.partnerId = request.partnerId
        payReq.prepayId = request.prepayId
        payReq.package = request.packageValue
        payReq.nonceStr = request.nonceStr
        payReq.timeStamp = UInt32(request.timeStamp) ?? 0
        payReq.sign = request.sign
        WXApi.send(payReq) { success in
            if !success {
                let result = WechatPayResult(respCode: "-1", respMsg: "Request failed", respError: "Wechat pay request failed")
                completion(result)
            } else {
                Pockyt.shared.setPaymentInstance(self)
            }
        }
    }
      
    public func handleOpenURL(_ url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: delegate)
    }
        
    public func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        return WXApi.handleOpenUniversalLink(userActivity, delegate: delegate)
    }
      
    // 直接在WechatPay类实现WXApiDelegate会编译报错，不知原因
    private class WechatPayDelegate: NSObject, WXApiDelegate {
          
        private weak var wechatPay: WechatPay?
          
        init(_ wechatPay: WechatPay) {
            self.wechatPay = wechatPay
            super.init()
        }
          
        public func onResp(_ resp: BaseResp) {
            if let payResp = resp as? PayResp {
                if let paymentInstance = wechatPay {
                    Pockyt.shared.removePaymentInstance(paymentInstance)
                    let result = WechatPayResult(respCode: "\(payResp.errCode)", respMsg: payResp.errStr, respError: payResp.errStr)
                    paymentInstance.payCompletion?(result)
                }
            }
        }
    }
}

