//
//  CashAppAction.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//

@objcMembers
public class CashAppRequest: NSObject {
    public var scopeId: String
      
    public init(scopeId: String) {
        self.scopeId = scopeId
    }
}
