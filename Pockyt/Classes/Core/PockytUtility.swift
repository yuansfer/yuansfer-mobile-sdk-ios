//
//  PockytUtility.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/14.
//

import Foundation

class PockytUtility {
    static func getSchemeUrl(for identifier: String) -> String {
        var scheme = ""
        if let infoPlist = Bundle.main.infoDictionary,
           let urlTypes = infoPlist["CFBundleURLTypes"] as? [[String: Any]] {
            for urlType in urlTypes {
                if let urlIdentifier = urlType["CFBundleURLName"] as? String,
                   urlIdentifier == identifier,
                   let schemes = urlType["CFBundleURLSchemes"] as? [String],
                   let schemeUrl = schemes.first {
                    print("URL Scheme for \(identifier): \(schemeUrl)")
                    scheme = schemeUrl
                    break
                }
            }
        }
        return scheme
    }
}
