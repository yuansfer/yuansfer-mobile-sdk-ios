//
//  CashApp.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/6/11.
//
import PayKit

@objcMembers
public class CashApp: NSObject, PaymentProtocol, CashAppPayObserver {
      
    private let cashAppSDK: CashAppPay
    private let cashPayRequest: CashAppRequest
    private var payCompletion: ((PayResult) -> Void)?
      
    public init(clientId: String, request: CashAppRequest, sandboxEnv: Bool = false) {
        self.cashPayRequest = request
        self.cashAppSDK = CashAppPay(clientID: clientId, endpoint: sandboxEnv ? .sandbox : .production)
        super.init()
        self.cashAppSDK.addObserver(self)
    }
      
    public func requestPay(completion: @escaping (CashAppResult) -> Void) {
        self.payCompletion = completion
        Pockyt.shared.setPaymentInstance(self)
        var requestAction: PaymentAction
        if (self.cashPayRequest is OneTimeRequest) {
            let payAction = self.cashPayRequest as! OneTimeRequest
            requestAction = .oneTimePayment(
                scopeID: payAction.scopeId,
                money: Money(amount: UInt(payAction.amount * 100), currency: .USD)
            )
        } else if (self.cashPayRequest is OnFileRequest) {
            let payAction = self.cashPayRequest as! OnFileRequest
            requestAction = .onFilePayment(
                scopeID: payAction.scopeId,
                accountReferenceID: payAction.accountReferenceId
            )
        } else {
            completion(CashAppResult(respCode: PockytCodes.ERROR, respMsg: "Invalid Payment Action"))
            return
        }
        cashAppSDK.createCustomerRequest(
                params: CreateCustomerRequestParams(
                    actions: [requestAction],
                    channel: .IN_APP,
                    redirectURL: URL(string: getCashAppSchemeUrl())!,
                    referenceID: nil,
                    metadata: nil
                )
            )
    }
    
    public func handleOpenURL(_ url: URL) -> Bool {
        NotificationCenter.default.post(
            name: CashAppPay.RedirectNotification,
            object: nil,
            userInfo: [UIApplication.LaunchOptionsKey.url : url]
        )
        return true
    }
    
    private func getCashAppSchemeUrl() -> String {
        var scheme = PockytUtility.getSchemeUrl(for: "cashapp")
        return "\(scheme)://callback"
    }
    
    public func stateDidChange(to state: CashAppPayState) {
        switch state {
            case .notStarted, .creatingCustomerRequest, .updatingCustomerRequest, .redirecting, .polling, .refreshing:
            break
        case .readyToAuthorize(let customerRequest):
            self.cashAppSDK.authorizeCustomerRequest(customerRequest)
            break
        case .approved(_, _):
            handlePaymentCompletion(respCode: PockytCodes.SUCCESS, respMsg: "Payment Approved")
            break
        case .declined:
            handlePaymentCompletion(respCode: PockytCodes.CANCEL, respMsg: "Declined by user")
            break
        case .apiError(let error):
            handlePaymentCompletion(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription)
            break
        case .integrationError(let error):
            handlePaymentCompletion(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription)
            break;
        case .networkError(let error):
            handlePaymentCompletion(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription)
            break;
        case .unexpectedError(let error):
            handlePaymentCompletion(respCode: PockytCodes.ERROR, respMsg: error.localizedDescription)
            break;
        }
    }

    private func handlePaymentCompletion(respCode: String, respMsg: String) {
        self.payCompletion?(CashAppResult(respCode: respCode, respMsg: respMsg))
        Pockyt.shared.removePaymentInstance(self)
    }
}
