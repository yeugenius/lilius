//
//  Untitled.swift
//  Lilius
//
//  Created by Satendra Singh on 08/12/24.
//

import EventKit

extension EKCalendarItem{
    
    var startD: Date? {
        get {
            if self.isKind(of: EKEvent.self) {
                
                if let str = self as? EKEvent {
                    // success
                    return str.startDate
                } else {
                    // fail
                    if let str = self as? EKReminder {
                        
                        if let comps =  str.startDateComponents{
                            
                            let date = Calendar.current.date(from: comps)
                            return date
                        }
                    }
                    
                }
                //
            }
            return nil
        }
    }
    
    var endD: Date? {
        get {
            if let str = self as? EKEvent {
                // success
                return str.endDate
            } else {
                // fail
                if let str = self as? EKReminder {
                    
                    if let comps =  str.dueDateComponents{
                        
                        let date = Calendar.current.date(from: comps)
                        return date
                    }
                }
                
            }
            return nil
        }
    }
}
