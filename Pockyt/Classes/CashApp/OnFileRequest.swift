//
//  OnFilePayment.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//
@objcMembers
public class OnFileRequest: CashAppRequest {
    public var accountReferenceId: String
      
    public init(scopeId: String, accountReferenceId: String) {
        self.accountReferenceId = accountReferenceId
        super.init(scopeId: scopeId)
    }
}
