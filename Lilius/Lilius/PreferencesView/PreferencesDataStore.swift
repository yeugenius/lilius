//
//  PreferencesDataStore.swift
//  Lilius
//
//  Created by Satendra Singh on 04/12/24.
//

import Foundation

struct PreferencesGeneralDataSource {
    
    enum TimeFormats:String , CaseIterable {
        case dateAndTime
        case dateOnly
        case timeOnly
        case dayNumberOnly
        
        var title:String {
            switch self {
            case .dateAndTime:
                return "Date & Time"
            case .dateOnly:
                return "Date Only"
            case .timeOnly:
                return "Time Only"
            case .dayNumberOnly:
                return "Day Number Only"
            }
        }
        
        init?(rawValue: String) {
            switch rawValue {
            case "Date & Time":
                self = .dateAndTime
            case "Date Only":
                self = .dateOnly
            case "Time Only":
                self = .timeOnly
            case "Day Number Only":
                self = .dayNumberOnly
            default:
                return nil
            }
        }
    }
    static let weekDays = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    static let dateFormatsOptions = ["dd/MM","dd/MM/YY","dd/MM/YYYY",
                                     "MM/dd/YY","MM/dd/YYYY"]
    static let timeFormatsOptions = TimeFormats.allCases.map(\.title)

    private enum DefaultsKeys:String {
        case disableCalendars
    }

    static var disabledCalendars: [String] {
        return UserDefaults.arrayValue(forKey: DefaultsKeys.disableCalendars.rawValue)
    }
    
    static func disableCalendar(_ calendarName:String){
        UserDefaults.addIntoArray(value: calendarName, forKey: DefaultsKeys.disableCalendars.rawValue)
    }
    
    static func enableCalendar(_ calendarName:String){
        UserDefaults.removefromArray(value: calendarName, forKey: DefaultsKeys.disableCalendars.rawValue)
    }
    
    static func updatedWeedays() -> [String] {
        // Initialize header day
        
        let firstDayIndex = PreferencesGeneralDataSource.weekDays.firstIndex(of: PreferencesStorage.shared.firstDayOfWeek)
        var headerDay : [String] = []
        for index in 0...6 {
            let dayIndex  = (firstDayIndex! + index ) % 7
            
            let dayString : NSString = PreferencesGeneralDataSource.weekDays [ dayIndex ] as NSString ;
            
            let subDayString = dayString.substring(to: 3).uppercased()
            
            headerDay.append(subDayString)
            //            headerDayHighLight.append(highlight)
        }
        return headerDay
    }
}
