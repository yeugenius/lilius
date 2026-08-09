//
//  File.swift
//  Lilius
//
//  Created by Satendra Singh on 26/01/25.
//


import StoreKit

extension SKProduct{
    private static var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }
    
    var formattedPrice: String? {
        let priceForm = SKProduct.priceFormatter
        priceForm.locale = self.priceLocale
        return priceForm.string(from: price)
    }
    
    var duration: String {
        
        if #available(OSX 10.13.2, *) {
            switch self.subscriptionPeriod?.unit {
            case .day: return "/Day"
                
            case .week: return "/Week"
            case .month: return "/Month"
            case .year: return "/Year"
                
            default:
                return "Unknown"
            }
        } else {
            
            if isMonthly {
                return "/Month"
            }
            if isYearly {
                return "/Year"
            }
        }
        return "Unknown"
    }
    
    
    private var isMonthly: Bool {
        return productIdentifier == PurchasableProducts.monthly
    }
    
    private var isYearly: Bool {
        return productIdentifier == PurchasableProducts.yearly
    }
}
