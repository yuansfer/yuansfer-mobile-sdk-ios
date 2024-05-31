//
//  CardPay.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/24.
//
import Braintree

@objcMembers
public class CardPay:NSObject, PaymentProtocol {
      
    private let braintreeClient: BTAPIClient
    private let btCard: BTCard
        
    public init(authorization: String, btCard: BTCard) {
        self.braintreeClient = BTAPIClient(authorization: authorization)!
        self.btCard = btCard
    }
          
    public func requestPay(completion: @escaping (CardPayResult) -> Void) {
        let cardClient = BTCardClient(apiClient: braintreeClient)
        cardClient.tokenizeCard(btCard) { tokenizedCard, error in
            let respCode = error == nil ? PockytCodes.SUCCESS : PockytCodes.ERROR
            let respMsg = error?.localizedDescription ?? ""
            let result = CardPayResult(respCode: respCode, respMsg: respMsg, tokenizedCard: tokenizedCard)
            completion(result)
        }
    }
}

