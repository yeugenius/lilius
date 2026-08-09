//
//  CalendarDatesView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct CalendarDatesView: View {
    @EnvironmentObject var eventListModel: CalendarEventListViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            ForEach(0..<eventListModel.calendarDates.count, id: \.self) { row in
                HStack(spacing: 22) {
                    let column = eventListModel.calendarDates[row]
                    ForEach(0..<column.count, id: \.self) {day in
                        let date = column[day]
                        CalendarDayView(dayObject: date)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    CalendarDatesView()
}
