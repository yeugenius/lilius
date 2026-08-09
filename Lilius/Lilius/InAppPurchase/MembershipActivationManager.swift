//
//  MembershipActivationManager.swift
//  Lilius
//
//  Created by Satendra Singh on 26/01/25.
//

import Foundation


extension Notification.Name {
  static let membershipUpdateNotification = Notification.Name("featureUpdateNotification")
}

enum MembershipType:String {
    case notSubcribed
    case expired
    case premiumSubscriptionMonthly
    case premiumSubscriptionYearly
}

final class MembershipActivationManager: NSObject {
    
    static let shared = MembershipActivationManager()
    private var debouncer = Debouncer(delay: 3.0)
    private lazy var membershipStore = MembershipStore()
    private let subscriptionManager = SubscriptionManager()
    var isTrialAvailable: Bool = true
    
    private override init() {
        super.init()
        self.refreshMembershipStatus()
    }
    
    var type: MembershipType {
        get {
//            return .free
            var type = self.membershipStore.type
            if type != .notSubcribed {
                if isPlanExpired == true {
                    type = .expired
                }
            }
            return type
        }
        
        set {
            self.membershipStore.type = newValue
//            updateForProductChange(type: newValue)
        }
    }
    
    var expiry: Date? {
        get {
            self.membershipStore.expiry
        }
        set {
            if self.membershipStore.expiry != newValue {
                updateForProductChange(type: type)
                self.membershipStore.expiry = newValue
            }
        }
    }
    
    var planAndDate: (plan: String?, expiry: Date?)? {
        return (type.rawValue, expiry)
    }
    
    private func updateForProductChange(type: MembershipType) {
        NotificationCenter.default.post(name: .membershipUpdateNotification, object: type)
        CalendarEventsDataService.sharedInstance.loadCalendarData()
        let notificationName = Notification.Name("ReloadCalendarNo");
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil);
    }
    
    func refreshMembershipStatus(onChange: (() -> Void)? = nil) {
        debouncer.debounce { [weak self] in
            // Or check for a specific subscription product
            self?.subscriptionManager.checkSubscription(productId: PurchasableProducts.monthly) { (isActive, expiryDate, trialUsed)  in
                self?.expiry = expiryDate
                self?.isTrialAvailable = !trialUsed
                if isActive {
                    print("Monthly subscription is active")
                    self?.type = .premiumSubscriptionMonthly
                    if let expiryDate = expiryDate {
                        // Calculate remaining days
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
                        print("Your subscription will renew automatically after \(days) days")
                    }
                } else {
                    if expiryDate != nil {
                        self?.type = .expired
                    } else {
                        self?.type = .notSubcribed
                    }
                    print("Monthly subscription is not active")
                }
            }
        }
    }
    
    var isPlanExpired : Bool {
        guard let expiry = expiry else { return true }
        return expiry < Date()
//        return expiry.compare(Date()) == .orderedDescending
    }
    
    var isActivePaidUser: Bool {
        if type == .expired || type == .notSubcribed {
            return false
        }
        return true
    }
}
