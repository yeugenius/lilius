//
//  Date+Extensions.swift
//  Lilius
//
//  Created by Satendra Singh on 04/12/24.
//

import Foundation

extension Date {
    
//    func isBetween(startDate:Date, endDate:Date)->Bool{
//        return (min(startDate, endDate) ... max(startDate, endDate)).contains(self)
//    }
    
    func isBetween(startDate:Date, endDate:Date)->Bool {
        return startDate.timeIntervalSince1970 <= self.timeIntervalSince1970 && endDate.timeIntervalSince1970  >= self.timeIntervalSince1970
    }
    
    private func matchingDate(startDate:Date, endDate:Date) -> Bool {
        let order = Calendar.current.compare(startDate, to: endDate,toGranularity: .day)
        switch order {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    func isEventDayMatching(startDate:Date, endDate:Date)->Bool {
        return matchingDate(startDate: startDate, endDate: self) || matchingDate(startDate: self, endDate: endDate) || isBetween(startDate: startDate, endDate: endDate)
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var timeString: String {
        Date.timeFormatter.string(from: self)
    }
    
    var expiryString: String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = self.formatted(date: .numeric, time: .omitted)
//        return dateFormatter.string(from: self)
        print(str)
        return str
    }
}

