//
//  Venmo.swift
//  Braintree
//
//  Created by fly.zhu on 2024/5/24.
//

import Braintree

@objcMembers
public class Venmo:NSObject, PaymentProtocol {
      
    private let braintreeClient: BTAPIClient
    private let venmoDriver: BTVenmoDriver
    private let venmoRequest: BTVenmoRequest
      
    public init(authorization: String, venmoRequest: BTVenmoRequest) {
        self.braintreeClient = BTAPIClient(authorization: authorization)!
        self.venmoDriver = BTVenmoDriver(apiClient: self.braintreeClient)
        self.venmoRequest = venmoRequest
        super.init()
        setReturnURLSchemeIfNeeded()
    }
      
    private func setReturnURLSchemeIfNeeded() {
        let urlScheme = BTAppContextSwitcher.sharedInstance().returnURLScheme
        if urlScheme.isEmpty {
            if let infoPlist = Bundle.main.infoDictionary,
               let urlTypes = infoPlist["CFBundleURLTypes"] as? [[String: Any]] {
                for urlType in urlTypes {
                    if let identifier = urlType["CFBundleURLName"] as? String,
                       identifier == "braintree",
                       let schemes = urlType["CFBundleURLSchemes"] as? [String],
                       let braintreeScheme = schemes.first {
                        print("Braintree URL Scheme: \(braintreeScheme)")
                        BTAppContextSwitcher.setReturnURLScheme(braintreeScheme)
                    }
                }
            }
        }
    }
    
    public func isiOSAppAvailableForAppSwitch() -> Bool {
        return venmoDriver.isiOSAppAvailableForAppSwitch()
    }
      
    public func requestPay(completion: @escaping (VenmoResult) -> Void) {
        Pockyt.shared.setPaymentInstance(self)
        venmoDriver.tokenizeVenmoAccount(with: venmoRequest) { (venmoNonce, error) in
            guard let venmoNonce = venmoNonce else {
                completion(VenmoResult(respCode: PockytCodes.ERROR, respMsg: error?.localizedDescription, venmoNonce: nil))
                return
            }
              
            let respCode = error == nil ? PockytCodes.SUCCESS : PockytCodes.ERROR
            let respMsg = error?.localizedDescription ?? ""
            let result = VenmoResult(respCode: respCode, respMsg: respMsg, venmoNonce: venmoNonce)
            completion(result)
        }
    }
    
    public func handleOpenURL(_ url: URL) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare(BTAppContextSwitcher.sharedInstance().returnURLScheme) == .orderedSame {
            Pockyt.shared.removePaymentInstance(self)
            return BTAppContextSwitcher.handleOpenURL(url)
        }
        return false
    }
}
