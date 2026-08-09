//
//  UserDefaultExtension.swift
//  Lilius
//
//  Created by Satendra Dagar on 05/07/20.
//  Copyright © 2020 Satendra Singh. All rights reserved.
//

import Foundation

extension UserDefaults{
    
    static var defaultStore:UserDefaults{
        return UserDefaults.standard
    }
    
    static func customValue(forKey:String) -> String {
        return defaultStore.string(forKey: forKey) ?? ""
    }
    
    static func setCustomValue(value:String? = "", forKey:String) {
        defaultStore.setValue(value, forKey: forKey)
    }
    
    static func arrayValue(forKey:String) -> [String] {
        return defaultStore.array(forKey: forKey) as?  [String] ?? [String]()
    }
    
    static func setArrayValue(value:[String], forKey:String) {
        defaultStore.set(value, forKey: forKey)
    }
    
    static func dictionaryValue(forKey:String) -> [String:Any] {
        return defaultStore.dictionary(forKey: forKey) ?? [String:Any]()
    }
    
    static func setDictionaryValue(value:[String:Any], forKey:String) {
        defaultStore.set(value, forKey: forKey)
    }
    
    static func addIntoArray(value:String, forKey:String) {
        var current = arrayValue(forKey: forKey)
        current.append(value)
        setArrayValue(value: current, forKey: forKey)
    }
    
    static func removefromArray(value:String, forKey:String) {
        var current = arrayValue(forKey: forKey)
        current.removeAll { (obj) -> Bool in
            if obj == value
            {
                return true
            }
            else {
                return false
            }
        }
        setArrayValue(value: current, forKey: forKey)
    }
    
    static func removeAllfromArray( forKey:String) {
        setArrayValue(value: [], forKey: forKey)
    }
    
    func save() {
        UserDefaults.defaultStore.synchronize()
    }
}
