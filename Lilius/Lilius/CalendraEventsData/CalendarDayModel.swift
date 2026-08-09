//
//  CalendarDayModel.swift
//  Lilius
//
//  Created by Satendra Singh on 04/12/24.
//

import Foundation

class CalendarDayModel {
    var day :Int = 0
    var month: Int = 0
    var year: Int = 0
    var events: [CalendarDayEventModel] = []
    
    var dateComponent: DateComponents {
        var component = DateComponents()
        component.calendar = NSCalendar.current
        component.year = year
        component.month = month % 12
        component.day = day
        return component
    }
}
