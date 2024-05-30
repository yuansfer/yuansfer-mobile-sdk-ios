//
//  ThreeDSecureProtocal.swift
//  Pockyt
//
//  Created by fly.zhu on 2024/5/28.
//
import Braintree

/// This approach of extending UIViewController and implementing these protocols may not be ideal as it pollutes the UIViewController class. However, it is necessary to implement these protocols in a UIViewController subclass to utilize their functionality. On the other hand, using inheritance to achieve this is also not considered a good practice.
/// 
extension UIViewController: BTViewControllerPresentingDelegate, BTThreeDSecureRequestDelegate {
    public func paymentDriver(_ driver: Any, requestsPresentationOf viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    public func paymentDriver(_ driver: Any, requestsDismissalOf viewController: UIViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    /// You are required to implement the onLookupComplete method where you can optionally inspect the lookup result. 
    /// When ready to continue with the 3DS flow, you must call next().
    ///
    open func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult result: BTThreeDSecureResult, next: @escaping () -> Void) {
        // Optionally inspect 'result.lookup' and prepare UI if a challenge is required
        next()
    }
}

