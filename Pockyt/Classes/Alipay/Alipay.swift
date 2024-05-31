//
//  Alipay.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/17.
//
@objcMembers
public class Alipay: NSObject, PaymentProtocol {
    
    private let payInfo: String
    private let fromScheme: String
    private var payCompletion: ((PayResult) -> Void)?
      
    public init(payInfo: String, fromScheme: String) {
        self.fromScheme = fromScheme
        self.payInfo = payInfo
    }
        
    public func requestPay(completion: @escaping (AlipayResult) -> Void) {
        self.payCompletion = completion
        Pockyt.shared.setPaymentInstance(self)
        AlipaySDK.defaultService().payOrder(payInfo, fromScheme: fromScheme) { [weak self] result in
            guard let self = self else { return }
            let payResult = self.parseResult(result)
            completion(payResult)
            Pockyt.shared.removePaymentInstance(self)
        }
    }
    
    public func handleOpenURL(_ url: URL) -> Bool {
        guard url.host == "safepay" else { return false }
        AlipaySDK.defaultService().processOrder(withPaymentResult: url) { [weak self] result in
            guard let self = self else { return }
            let payResult = self.parseResult(result)
            self.payCompletion?(payResult)
            Pockyt.shared.removePaymentInstance(self)
        }
        return true
    }
    
    private func parseResult(_ result: [AnyHashable: Any]?) -> PayResult {
        let respCode = result?["resultStatus"] as? String ?? ""
        let respMsg = result?["result"] as? String
        let memo = result?["memo"] as? String
        return AlipayResult(respCode: respCode, respMsg: respMsg, memo: memo)
    }
}
