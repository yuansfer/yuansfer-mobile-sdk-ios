//
//  ApplePay.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/23.
//
import Braintree

@objcMembers
@objc(ApplePay)
public class ApplePay: NSObject, PaymentProtocol, PKPaymentAuthorizationViewControllerDelegate {
      
    private let viewController: UIViewController
    private let braintreeClient: BTAPIClient
    private let applePayClient: BTApplePayClient
    private var paymentRequest: PKPaymentRequest
    private var resultCompletion: ((ApplePayResult) -> Void)?
    private var notifyCompletion: ((PKPaymentAuthorizationResult) -> Void)?
      
    public init(viewController: UIViewController, authorization: String) {
        self.viewController = viewController
        self.braintreeClient = BTAPIClient(authorization: authorization)!
        self.applePayClient = BTApplePayClient(apiClient: self.braintreeClient)
        self.paymentRequest = PKPaymentRequest()
        super.init()
    }
    
    public func initPaymentRequest(completion: @escaping (PKPaymentRequest?, Error?) -> Void) {
        self.applePayClient.paymentRequest { [weak self] paymentRequest, error in
            guard let self = self, let paymentRequest = paymentRequest else {
                completion(nil, error)
                return
            }
            self.paymentRequest = paymentRequest
            completion(paymentRequest, nil)
        }
    }
      
    public func requestPay(completion: @escaping (ApplePayResult) -> Void) {
        if let vc = PKPaymentAuthorizationViewController(paymentRequest: self.paymentRequest) {
            vc.delegate = self
            self.viewController.present(vc, animated: true, completion: nil)
            self.resultCompletion = completion
        } else {
            completion(ApplePayResult(respCode: PockytCodes.ERROR, respMsg: "Payment Request is invalid", applePayNonce: nil))
        }
    }
      
    public func notifyPaymentCompletion(_ isSuccess: Bool) {
        notifyCompletion?(PKPaymentAuthorizationResult(status: isSuccess ? .success : .failure, errors: nil))
    }
      
    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                                   didAuthorizePayment payment: PKPayment,
                                                   handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
          
        applePayClient.tokenizeApplePay(payment) { [weak self] (nonce, error) in
            if let error = error {
                completion(PKPaymentAuthorizationResult(status: .failure, errors: nil))
                self?.resultCompletion?(ApplePayResult(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription, applePayNonce: nil))
                return
            }
            self?.resultCompletion?(ApplePayResult(respCode: PockytCodes.SUCCESS, respMsg: nil, applePayNonce: nonce))
            self?.notifyCompletion = completion
        }
    }
      
    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true)
        self.resultCompletion?(ApplePayResult(respCode: PockytCodes.COMPLETED, respMsg: "Payment authorization completed", applePayNonce: nil))
    }
    
}


