//
//  ThreeDSecure.swift
//  Braintree
//
//  Created by fly.zhu on 2024/5/27.
//

import Braintree

@objcMembers
@objc(ThreeDSecurePay)
public class ThreeDSecurePay: NSObject, PaymentProtocol {
  
    private let braintreeClient: BTAPIClient
    private let paymentFlowDriver: BTPaymentFlowDriver
    private let threeDSecureRequest: BTThreeDSecureRequest
  
    public init(uiViewController: UIViewController, authorization: String, threeDSecureRequest: BTThreeDSecureRequest) {
        self.braintreeClient = BTAPIClient(authorization: authorization)!
        self.paymentFlowDriver = BTPaymentFlowDriver(apiClient: self.braintreeClient)
        self.threeDSecureRequest = threeDSecureRequest
        self.paymentFlowDriver.viewControllerPresentingDelegate = uiViewController
        self.threeDSecureRequest.threeDSecureRequestDelegate = uiViewController
    }
  
    public func requestPay(completion: @escaping (ThreeDSecureResult) -> Void) {
        self.paymentFlowDriver.startPaymentFlow(self.threeDSecureRequest) { (result, error) in
            guard let result = result as? BTThreeDSecureResult, let tokenizedCard = result.tokenizedCard else {
                completion(ThreeDSecureResult(respCode: PockytCodes.ERROR, respMsg: error?.localizedDescription, tokenizedCard: nil))
                return
            }
            completion(ThreeDSecureResult(respCode: PockytCodes.SUCCESS, respMsg: nil, tokenizedCard: tokenizedCard))
        }
    }

}
