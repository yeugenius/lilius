//
//  CalendarEventModel.swift
//  Lilius
//
//  Created by Satendra Singh on 04/12/24.
//

import Foundation
import EventKit

class CalendarDayEventModel: Equatable, Identifiable {
    var type: Int = 0
    var url : URL?
    var event: EKCalendarItem?
    var isAllDay: Bool = false
    static func == (lhs: CalendarDayEventModel, rhs: CalendarDayEventModel) -> Bool {
        lhs.type == rhs.type && lhs.event == rhs.event
    }
}
