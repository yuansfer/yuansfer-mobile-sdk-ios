//
//  OneTimeRequestData.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//
@objcMembers
public class OneTimeRequest: CashAppRequest {
    public var amount: Double
      
    public init(scopeId: String, amount: Double) {
        self.amount = amount
        super.init(scopeId: scopeId)
    }
}
