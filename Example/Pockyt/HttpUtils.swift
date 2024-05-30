//
//  HttpUtils.swift
//  Pockyt_Example
//
//  Created by fly.zhu on 2024/5/20.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import CommonCrypto
  
class HttpUtils {
      
    static let BASE_URL = "https://mapi.yuansfer.yunkeguan.com"
    static let MERCHANT_NO = "202333"
    static let STORE_NO = "301854"
    static let API_TOKEN = "17cfc0170ef1c017b4a929d233d6e65e"
    
    static let APP_ID = "wxa0d4a241e5d692df"
    static let UNIVERSAL_LINK = "https://mapi.yuansfer.yunkeguan.com/ios/"
    static let CLIENT_TOKEN = "sandbox_ktnjwfdk_wfm342936jkm7dg6"
    
    static func doPost(path: String, data: [String: Any], token: String, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let params = sortedDictionary(dict: data)
        var sign = params
        sign.append("&\(md5String(string: token))")
          
        var body = params
        body.append("&verifySign=\(md5String(string: sign))")
          
        let url = URL(string: "\(BASE_URL)\(path)")!
        var request = URLRequest(url: url)
        request.timeoutInterval = 15.0
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
          
        let task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
      
    static func sortedDictionary(dict: [String: Any]) -> String {
        let allKeys = Array(dict.keys)
        let afterSortKeyArray = allKeys.sorted { $0 < $1 }
          
        var tempStr = ""
        var valueArray = [String]()
          
        for sortKey in afterSortKeyArray {
            if let value = dict[sortKey] {
                let valueString = "\(value)"
                if valueString.count > 0 {
                    valueArray.append(valueString)
                    tempStr += "\(sortKey)=\(valueString)&"
                }
            }
        }
          
        if tempStr.count > 0 {
            tempStr = String(tempStr.dropLast())
        }
          
        return tempStr
    }
      
    static func md5String(string: String) -> String {
        guard let strData = string.data(using: .utf8) else {
            return ""
        }
          
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ = strData.withUnsafeBytes {
            CC_MD5($0.baseAddress, CC_LONG(strData.count), &digest)
        }
          
        var md5String = ""
        for byte in digest {
            md5String += String(format: "%02x", byte)
        }
          
        return md5String
    }
      
}
