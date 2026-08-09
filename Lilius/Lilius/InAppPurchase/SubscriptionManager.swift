//
//  SubscriptionManager.swift
//  Lilius
//
//  Created by Satendra Singh on 02/03/25.
//

import StoreKit

class SubscriptionManager {
    private let receiptParser = ReceiptParser()
    private var receiptRefreshRequestDelegate: ReceiptRefreshRequestDelegate?
    
    func validateSubscriptions(completion: @escaping (Bool, String?, Date?, Bool) -> Void) {
        // First, try to get receipt data
        guard let receiptData = receiptParser.fetchReceiptData() else {
            // If receipt data is not available, try to refresh it
            self.refreshReceipt { success in
                if success, let refreshedData = self.receiptParser.fetchReceiptData() {
                    self.validateWithApple(receiptData: refreshedData, completion: completion)
                } else {
                    completion(false, nil, nil, true)
                }
            }
            return
        }
        
        validateWithApple(receiptData: receiptData, completion: completion)
    }
    
    private func validateWithApple(receiptData: Data, completion: @escaping (Bool, String?, Date?, Bool) -> Void) {
        // Send receipt to Apple for validation
        receiptParser.validateReceipt(receiptData: receiptData) { result in
            switch result {
            case .success(let json):
                // Parse the response
                if let receiptInfo = self.receiptParser.parseReceipt(receiptJSON: json) {
                    // Check if there's an active subscription
                    let subscriptionStatus = self.receiptParser.hasActiveSubscription(receiptInfo: receiptInfo)
                    completion(subscriptionStatus.isActive, subscriptionStatus.productId, subscriptionStatus.expiryDate, subscriptionStatus.hasTrialUsed)
                } else {
                    completion(false, nil, nil, true)
                }
                
            case .failure(let error):
                print("Receipt validation failed: \(error.localizedDescription)")
                completion(false, nil, nil, true)
            }
        }
    }
    
    // Check for a specific subscription
    func checkSubscription(productId: String, completion: @escaping (Bool, Date?, Bool) -> Void) {
        validateSubscriptions { (hasAnySubscription, activeProductId, expiryDate, hasTrialUsed) in
            if hasAnySubscription && activeProductId == productId {
                completion(true, expiryDate, hasTrialUsed)
            } else {
                completion(false, expiryDate, hasTrialUsed)
            }
        }
    }
    
    // Refresh the receipt if needed
    private func refreshReceipt(completion: @escaping (Bool) -> Void) {
        let request = SKReceiptRefreshRequest()
        receiptRefreshRequestDelegate = ReceiptRefreshRequestDelegate(completion: completion)
        request.delegate = receiptRefreshRequestDelegate
        request.start()
    }
}
