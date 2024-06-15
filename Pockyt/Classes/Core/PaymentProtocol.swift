//
//  PaymentProtocal.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/20.
//

public protocol PaymentProtocol {
    associatedtype PayResult: PaymentResultProtocol
    func requestPay(completion: @escaping (PayResult) -> Void)
    @discardableResult
    func handleOpenURL(_ url: URL) -> Bool
    @discardableResult
    func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool
}
  
extension PaymentProtocol {
    @discardableResult
    public func handleOpenURL(_ url: URL) -> Bool {
        return false
    }
      
    @discardableResult
    public func handleOpenUniversalLink(_ userActivity: NSUserActivity) -> Bool {
        return false
    }
}
  
public protocol PaymentResultProtocol {
    var respCode: String { get }
    var respMsg: String? { get }
}

