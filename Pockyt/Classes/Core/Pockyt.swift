//
//  Pockyt.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/20.
//

@objcMembers
public class Pockyt: NSObject {
    public static let shared = Pockyt()
    private var paymentInstances = [String: any PaymentProtocol]()
    private override init() {}
        
    public func requestPay<T: PaymentProtocol>(_ payment: T, completion: @escaping (T.PayResult) -> Void) {
        payment.requestPay(completion: completion)
    }
      
    public func handleOpenURL(_ url: URL) -> Bool {
        for payment in paymentInstances.values {
            if payment.handleOpenURL(url) {
                return true
            }
        }
        return false
    }
    
    public func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        for payment in paymentInstances.values {
            if payment.handleOpenUniversalLink(userActivity) {
                return true
            }
        }
        return false
    }
      
    public func setPaymentInstance<T: PaymentProtocol>(_ payment: T) {
        let className = String(describing: T.self)
        paymentInstances[className] = payment
    }
      
    public func removePaymentInstance<T: PaymentProtocol>(_ payment: T) {
        let className = String(describing: T.self)
        paymentInstances[className] = nil
    }
      
    public func removeAllPaymentInstances() {
        paymentInstances.removeAll()
    }
}
