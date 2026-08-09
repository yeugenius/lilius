//
//  EKCalendar+Utilities.swift
//  Lilius
//
//  Created by Satendra Dagar on 30/08/20.
//  Copyright © 2020 Satendra Singh. All rights reserved.
//

import Foundation
import EventKit

extension EKCalendar {

    var isGoogleCalendar: Bool {
//        let path = source.title
//        print("Source:\(path)")
//        let path = value(forKey: "serverPath") as? String
        let path2 = value(forKey: "sharedOwnerURLString") as? String

        if description.contains("calendar.google.com") == true || ((path2?.contains("gmail.com")) == true){
            print("\(title) is Google")
            return true
        }
        return false
    }
    
    var isExchageCalendar: Bool {
        if source.sourceType == .exchange  {
            print("\(title) is Exchage")

            return true
        }
        return false
    }

    var isFacebookCalendar: Bool {
        if title.contains("Facebook") {
            return true
        }
//        if source.sourceType == .exchange  {
//            print("\(title) is Exchage")
//
//            return true
//        }
        return false
    }

    var canShow : Bool {
        if isGoogleCalendar == true || isExchageCalendar == true || isFacebookCalendar == true {
            if MembershipActivationManager.shared.isActivePaidUser == true {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
}
