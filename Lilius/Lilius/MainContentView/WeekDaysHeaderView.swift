//
//  WeekDaysHeaderView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct WeekDaysHeaderView: View {
    @EnvironmentObject var eventListModel: CalendarEventListViewModel

    var body: some View {
        HStack(spacing: 30) {
            ForEach(eventListModel.calendarHeader, id: \.self) { item in
                Text(item)
                    .frame(minWidth: 32)
            }
        }
        .padding(.top)
        .font(.headline)
    }
}

#Preview {
    WeekDaysHeaderView()
}
