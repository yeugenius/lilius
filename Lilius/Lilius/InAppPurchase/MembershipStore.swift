//
//  MembershipStore.swift
//  Lilius
//
//  Created by Satendra Singh on 26/01/25.
//

import Foundation


class MembershipStore {
    
    enum StoreKeys: String{
        case defaultsMembershipInfo
        case type
        case expiry
    }

    private var details = UserDefaults.defaultStore.dictionary(forKey: StoreKeys.defaultsMembershipInfo.rawValue) ?? [String: Any]()
    
    var type: MembershipType {
        get {
            guard let typeStr = details[StoreKeys.type.rawValue] as? String else { return .notSubcribed }
            return MembershipType(rawValue: typeStr) ?? .notSubcribed
        }
        set {
            details[StoreKeys.type.rawValue] = newValue.rawValue
            UserDefaults.setDictionaryValue(value: details, forKey: StoreKeys.defaultsMembershipInfo.rawValue)
        }
    }
    
    var expiry: Date? {
        get {
            return details[StoreKeys.expiry.rawValue] as? Date
        }
        set {
            details[StoreKeys.expiry.rawValue] = newValue
            UserDefaults.setDictionaryValue(value: details , forKey: StoreKeys.defaultsMembershipInfo.rawValue)
            UserDefaults.defaultStore.synchronize()
        }
    }
}
