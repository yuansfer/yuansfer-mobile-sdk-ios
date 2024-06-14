//
//  OnFilePayment.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//
@objcMembers
public class OnFileRequest: NSObject, CashAppRequest {
    public var scopeId: String
    public var accountReferenceId: String

    public init(scopeId: String, accountReferenceId: String) {
        self.scopeId = scopeId
        self.accountReferenceId = accountReferenceId
    }
}
