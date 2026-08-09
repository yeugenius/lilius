//
//  InAppPurchaseViewModel.swift
//  Lilius
//
//  Created by Satendra Singh on 01/02/25.
//

import Foundation
import SwiftUI
import StoreKit
import Combine

enum InappViewState: Equatable {
    case unsubscribed
    case subscribed(plan:String, expiry: Date?)
    case expired(expiredOn: Date?)
}

final class InAppPurchaseViewModel: ObservableObject {
    
    typealias Result = [SKProduct]
    enum TransactionStates: Equatable {
        case initial
        case loading
        case productInfoAvailable(result:Result)
        case purchasing
        case purchsed
        case error(message:String)
    }
    @Published var viewState: TransactionStates = .initial
    @Published var inappViewState: InappViewState = .unsubscribed
    @Published var isTrialAvailable: Bool = true
    
    private let productService = InAppPurchaseProductDetailsService(productIds: [PurchasableProducts.monthly])
    private let membershipManager = MembershipActivationManager.shared
    private let buyManager = InAppPurchaseService.shared
    
    private var availabilityResult: Result?
    
    init() {
        print("InAppPurchaseViewModel init")
        checkAndFetchProducts()
        self.setupForPurchase()
    }
    
    deinit {
        print("InAppPurchaseViewModel deinitialized")
        InAppPurchaseService.shared.resetHandle()
    }
    
    func checkAndFetchProducts() {
        manageState()
        switch inappViewState {
        case .unsubscribed, .expired: do {
            viewState = .loading
            productService.requestProducts { success, products in
                DispatchQueue.main.async {
                    if success == true, let productArr = products {
                        self.availabilityResult = products
                        self.viewState = .productInfoAvailable(result: productArr)
                    }
                    else{
                        self.viewState = .error(message: "Something went wrong in fetching memberhip plan details")
                    }
                }
            }
        }
        default:
            break
        }
        NotificationCenter.default.addObserver(forName: .membershipUpdateNotification, object: nil, queue: nil) { (not) in
            DispatchQueue.main.async {
                self.manageState()
            }
        }
    }
    
    func purchaseMonthlyMembership() {
        guard let monthlyPlan = availabilityResult?.monthlyPlan  else { return  }
        InAppPurchaseService.shared.buyProduct(monthlyPlan)
        self.viewState = .purchasing
    }
    
    func manageState()  {
        switch MembershipActivationManager.shared.type {
        case .premiumSubscriptionMonthly, .premiumSubscriptionYearly:
            if let res = membershipManager.planAndDate {
                self.inappViewState = .subscribed(plan: res.plan ?? "", expiry: res.expiry)
            }
        case .notSubcribed:
            self.inappViewState = .unsubscribed
        case .expired:
            if let res = membershipManager.planAndDate{
                self.inappViewState = .expired(expiredOn: res.expiry)
            }
        }
        self.isTrialAvailable = membershipManager.isTrialAvailable
    }
    
    func restorePurchases() {
        InAppPurchaseService.shared.restorePurchases()
    }
}


private  extension InAppPurchaseViewModel.Result {
    var monthlyPlan : SKProduct?{
        return filter { $0.productIdentifier == PurchasableProducts.monthly }.first
    }
    
    var yearlyPlan : SKProduct?{
        return filter { $0.productIdentifier == PurchasableProducts.yearly }.first
    }
}

extension InAppPurchaseViewModel {
    func setupForPurchase() {
        InAppPurchaseService.shared.stateUpdateHandler = { (state: PurchaseState,  transaction: SKPaymentTransaction, message: String? ) in
            InAppPurchaseService.shared.handleTransaction(state: state, transaction: transaction)
            DispatchQueue.main.async {
                self.handleMembershipResponse(state, transaction, message)
            }
        }
    }
    
    func handleMembershipResponse(_ state: PurchaseState, _ transaction: SKPaymentTransaction, _ message: String? )  {
        switch state {
        case .success,.restored, .restoreCompleted:
            self.viewState = .purchsed
            MembershipActivationManager.shared.refreshMembershipStatus { [weak self] in
                self?.manageState()
            }
        case .inProgress:
            break
        default:
            self.viewState = .error(message: message ?? "Something went worng.")
            
        }
    }
}

extension InAppPurchaseService {
    
    func handleTransaction(state: PurchaseState,  transaction: SKPaymentTransaction ) {
        switch state {
        case .success,.restored, .restoreCompleted:
            DispatchQueue.main.async {
                MembershipActivationManager.shared.refreshMembershipStatus()
            }
            break
        default: break
        }
    }
    
    func resetHandle() {
        stateUpdateHandler = { (state: PurchaseState,  transaction: SKPaymentTransaction, message: String? ) in
            self.handleTransaction(state: state, transaction: transaction)
        }
    }
}

private extension SKPaymentTransaction {
    
    var plan: MembershipType?{
        switch self.payment.productIdentifier {
        case PurchasableProducts.monthly:
            return .premiumSubscriptionMonthly
            
        case PurchasableProducts.yearly:
            return .premiumSubscriptionYearly
        default:
            return nil
        }
    }
    
    var expiryDate: Date? {
        guard let txDate = self.original?.transactionDate else { return nil }
        let calendar = NSCalendar.current
        var unit = Calendar.Component.month
        switch plan {
        case .premiumSubscriptionYearly:
            unit = .year
        default:
            break
        }
        return calendar.date(byAdding: unit, value: 1, to: txDate)
    }
}
