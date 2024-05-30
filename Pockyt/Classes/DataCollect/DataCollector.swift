//
//  DataCollect.swift
//  Braintree
//
//  Created by fly.zhu on 2024/5/27.
//
import Braintree

public class DataCollector: NSObject {
    @objc public static func collectData(isSandbox: Bool = false) -> String {
        return PPDataCollector.collectPayPalDeviceData(isSandbox: isSandbox)
    }
}
