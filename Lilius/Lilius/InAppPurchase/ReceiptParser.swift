import Foundation
import StoreKit

class ReceiptParser {
    
    // MARK: - Receipt Parsing Models
    
    struct ReceiptInfo {
        var bundleId: String
        var applicationVersion: String
        var originalAppVersion: String?
        var receiptCreationDate: Date?
        var expirationDate: Date?
        var inAppPurchases: [InAppPurchase]
    }
    
    struct InAppPurchase {
        var quantity: Int
        var productId: String
        var transactionId: String
        var originalTransactionId: String
        var purchaseDate: Date
        var originalPurchaseDate: Date
        var expiresDate: Date?
        var cancellationDate: Date?
        var isTrialPeriod: Bool
        var isInIntroOfferPeriod: Bool
        var webOrderLineItemId: String?
    }
    
    // MARK: - Receipt Validation
    
    /// Fetches and parses the receipt data locally
    func fetchReceiptData() -> Data? {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            print("Receipt URL not found")
            return nil
        }
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            return receiptData
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Validates receipt with Apple's servers
    func validateReceipt(receiptData: Data, isProduction: Bool = true, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Convert receipt data to base64 string
        let receiptString = receiptData.base64EncodedString(options: [])
        
        // Prepare request dictionary
        let requestDictionary = ["receipt-data": receiptString,
                                 "password": EnvironmentVars.itunesApiKey,  // Your app-specific shared secret from App Store Connect
                                 "exclude-old-transactions": true] as [String: Any]
        
        // Convert request dictionary to JSON data
        guard let requestData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: []) else {
            completion(.failure(NSError(domain: "ReceiptValidation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create request data"])))
            return
        }
        
        // Determine which URL to use based on environment
        let urlString = isProduction ? 
            "https://buy.itunes.apple.com/verifyReceipt" : 
            "https://sandbox.itunes.apple.com/verifyReceipt"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "ReceiptValidation", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Create URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Send request to Apple's servers
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "ReceiptValidation", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    completion(.failure(NSError(domain: "ReceiptValidation", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])))
                    return
                }
                
                // Check if we need to validate against production environment instead
                if let status = jsonResponse["status"] as? Int, status == 21007, isProduction {
                    // This receipt is from the production environment, but we validated against sandbox
                    self.validateReceipt(receiptData: receiptData, isProduction: false, completion: completion)
                    return
                }
                
                completion(.success(jsonResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Receipt Parsing
    
    /// Parse the JSON response from Apple's verification server
    func parseReceipt(receiptJSON: [String: Any]) -> ReceiptInfo? {
        guard let status = receiptJSON["status"] as? Int, status == 0 else {
            print("Receipt validation failed with status: \(receiptJSON["status"] ?? "unknown")")
            return nil
        }
        
        guard let receipt = receiptJSON["receipt"] as? [String: Any] else {
            print("Receipt data not found in response")
            return nil
        }
        
        // Parse receipt metadata
        let bundleId = receipt["bundle_id"] as? String ?? ""
        let applicationVersion = receipt["application_version"] as? String ?? ""
        let originalAppVersion = receipt["original_application_version"] as? String
        
        // Parse dates
        let receiptCreationDateString = receipt["receipt_creation_date_ms"] as? String
        let receiptCreationDate = self.parseDate(millisecondString: receiptCreationDateString)
        
        // Parse in-app purchases
        var inAppPurchases: [InAppPurchase] = []
        
        // Check for the latest receipt info (for auto-renewable subscriptions)
        let latestReceiptInfo = receiptJSON["latest_receipt_info"] as? [[String: Any]] ?? []
        
        // Parse in-app purchases from latest_receipt_info for subscriptions
        for purchase in latestReceiptInfo {
            if let parsedPurchase = self.parseInAppPurchase(purchase) {
                inAppPurchases.append(parsedPurchase)
            }
        }
        
        // Also check in_app array from the receipt
        if let inAppArray = receipt["in_app"] as? [[String: Any]] {
            for purchase in inAppArray {
                if let parsedPurchase = self.parseInAppPurchase(purchase) {
                    // Only add if not already present (avoid duplicates)
                    if !inAppPurchases.contains(where: { $0.transactionId == parsedPurchase.transactionId }) {
                        inAppPurchases.append(parsedPurchase)
                    }
                }
            }
        }
        
        // Get expiration date for the entire receipt if available
        let expirationDateString = receipt["expiration_date_ms"] as? String
        let expirationDate = self.parseDate(millisecondString: expirationDateString)
        
        return ReceiptInfo(
            bundleId: bundleId,
            applicationVersion: applicationVersion,
            originalAppVersion: originalAppVersion,
            receiptCreationDate: receiptCreationDate,
            expirationDate: expirationDate,
            inAppPurchases: inAppPurchases
        )
    }
    
    /// Parse a single in-app purchase record
    private func parseInAppPurchase(_ purchase: [String: Any]) -> InAppPurchase? {
        guard let productId = purchase["product_id"] as? String,
              let transactionId = purchase["transaction_id"] as? String,
              let originalTransactionId = purchase["original_transaction_id"] as? String else {
            return nil
        }
        
        // Parse dates
        let purchaseDateString = purchase["purchase_date_ms"] as? String
        let originalPurchaseDateString = purchase["original_purchase_date_ms"] as? String
        let expiresDateString = purchase["expires_date_ms"] as? String
        let cancellationDateString = purchase["cancellation_date_ms"] as? String
        
        guard let purchaseDate = parseDate(millisecondString: purchaseDateString),
              let originalPurchaseDate = parseDate(millisecondString: originalPurchaseDateString) else {
            return nil
        }
        
        let expiresDate = parseDate(millisecondString: expiresDateString)
        let cancellationDate = parseDate(millisecondString: cancellationDateString)
        
        // Parse other fields
        let quantity = Int(purchase["quantity"] as? String ?? "1") ?? 1
        let isTrialPeriod = (purchase["is_trial_period"] as? String) == "true"
        let isInIntroOfferPeriod = (purchase["is_in_intro_offer_period"] as? String) == "true"
        let webOrderLineItemId = purchase["web_order_line_item_id"] as? String
        
        return InAppPurchase(
            quantity: quantity,
            productId: productId,
            transactionId: transactionId,
            originalTransactionId: originalTransactionId,
            purchaseDate: purchaseDate,
            originalPurchaseDate: originalPurchaseDate,
            expiresDate: expiresDate,
            cancellationDate: cancellationDate,
            isTrialPeriod: isTrialPeriod,
            isInIntroOfferPeriod: isInIntroOfferPeriod,
            webOrderLineItemId: webOrderLineItemId
        )
    }
    
    /// Parse date from millisecond string
    private func parseDate(millisecondString: String?) -> Date? {
        guard let msString = millisecondString,
              let timeInterval = Double(msString) else {
            return nil
        }
        
        // Convert milliseconds to seconds for Date
        return Date(timeIntervalSince1970: timeInterval / 1000.0)
    }
    
    // MARK: - Subscription Status
    
    /// Check if a subscription is active based on its expiration date
    func isSubscriptionActive(productId: String, receiptInfo: ReceiptInfo) -> (isActive: Bool, expiryDate: Date?) {
        // Filter purchases for the specific product ID and sort by expiry date descending
        let subscriptions = receiptInfo.inAppPurchases
            .filter { $0.productId == productId && $0.expiresDate != nil && $0.cancellationDate == nil }
            .sorted { ($0.expiresDate ?? Date.distantPast) > ($1.expiresDate ?? Date.distantPast) }
        
        // Get the most recent subscription
        if let latestSubscription = subscriptions.first, let expiryDate = latestSubscription.expiresDate {
            // Check if the subscription is still active
            let isActive = expiryDate > Date()
            return (isActive, expiryDate)
        }
        
        return (false, nil)
    }
    
    /// Get the latest expiry date for a specific product
    func getSubscriptionExpiryDate(for productId: String, in receiptInfo: ReceiptInfo) -> Date? {
        // Find all purchases for this product ID that have an expiry date
        let expiryDates = receiptInfo.inAppPurchases
            .filter { $0.productId == productId && $0.expiresDate != nil }
            .compactMap { $0.expiresDate }
            .sorted(by: >)  // Sort descending
        
        // Return the most recent expiry date
        return expiryDates.first
    }
    
    /// Check if the receipt contains an active subscription for any product
    func hasActiveSubscription(receiptInfo: ReceiptInfo) -> (isActive: Bool, productId: String?, expiryDate: Date?, hasTrialUsed: Bool) {
        // Get all subscription purchases that haven't expired yet
        
        let hasUsedTrialPeriod: Bool = receiptInfo.inAppPurchases.contains(where: { $0.isTrialPeriod == true })
#if DEBUG
        for subscription in receiptInfo.inAppPurchases {
            print("Subscription: \(subscription.productId ?? "Unknown product ID") - Expires: \(String(describing: subscription.expiresDate)), isTrialPeriod:\(subscription.isTrialPeriod)")
        }
#endif
        let allSubscriptions = receiptInfo.inAppPurchases
        
            .sorted { ($0.expiresDate ?? Date.distantPast) > ($1.expiresDate ?? Date.distantPast) }
        let activeSubscriptions = receiptInfo.inAppPurchases.filter { purchase in
            if let expiryDate = purchase.expiresDate, purchase.cancellationDate == nil {
                return expiryDate > Date.now
            }
            return false
        }.sorted { ($0.expiresDate ?? Date.distantPast) > ($1.expiresDate ?? Date.distantPast) }
        
        if let activeSubscription = activeSubscriptions.first {
            if let activeSubscriptionExpiryDate = activeSubscription.expiresDate {
                if activeSubscriptionExpiryDate > Date.now {
                    return (true, activeSubscription.productId, activeSubscription.expiresDate, hasUsedTrialPeriod)
                } else {
                    return (false, activeSubscription.productId, activeSubscription.expiresDate, hasUsedTrialPeriod)
                }
            }
        }
        return (false, allSubscriptions.first?.productId, allSubscriptions.first?.expiresDate, hasUsedTrialPeriod)
    }
}

// Helper delegate for refreshing receipts
class ReceiptRefreshRequestDelegate: NSObject, SKRequestDelegate {
    private let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        completion(true)
    }
    
    func request(_ requestrt: SKRequest, didFailWithError error: Error) {
        print("Receipt refresh failed: \(error.localizedDescription)")
        completion(false)
    }
}
