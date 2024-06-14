//
//  OneTimeRequestData.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//
@objcMembers
public class OneTimeRequest: NSObject, CashAppRequest {
    public var amount: Double
    public var scopeId: String

    public init(scopeId: String, amount: Double) {
        self.scopeId = scopeId
        self.amount = amount
    }
}
