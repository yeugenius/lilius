//
//  InAppPurchaseService.swift
//  Lilius
//
//  Created by Satendra Singh on 19/01/25.
//

import StoreKit

public typealias ProductIdentifier = String

public typealias TransactionUpdateClosure = (_ state: PurchaseState, _ transaction: SKPaymentTransaction, _ message: String? ) -> Void

public enum PurchaseState {
    case success
    case restored
    case restoreCompleted
    case failed
    case failedRestore
    case inProgress
    case membershipUpdating
    case Unknown
}
 
open class InAppPurchaseService: NSObject  {
    static let shared = InAppPurchaseService()
    var stateUpdateHandler: TransactionUpdateClosure?
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
//        restorePurchases()
    }
}

// MARK: - StoreKit API

extension InAppPurchaseService {
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKPaymentTransactionObserver
extension InAppPurchaseService: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred, .purchasing:
                break
            @unknown default:
                fatalError()
            }
            handleTransaction(state: transaction.transactionState.purchaseState, transaction: transaction)
            self.stateUpdateHandler?(transaction.transactionState.purchaseState, transaction, transaction.error?.localizedDescription )
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        self.stateUpdateHandler?(transaction.transactionState.purchaseState, transaction, transaction.error?.localizedDescription )
        handleTransaction(state: transaction.transactionState.purchaseState, transaction: transaction)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

private extension SKPaymentTransactionState{
    var purchaseState: PurchaseState {
        switch self {
        case .purchased:
            return .success
        case .purchasing, .deferred:
            return .inProgress
        case .restored:
            return .restored
        case .failed:
            return .failed
        default:
            return .Unknown
        }
    }
}
