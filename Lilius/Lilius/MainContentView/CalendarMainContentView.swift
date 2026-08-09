//
//  CalendarMainContentView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI
import Combine

struct CalendarMainContentView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var model: CalendarEventListViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                MonthAndYearHeading()
                Divider()
                WeekDaysHeaderView()
                CalendarDatesView()
            }

            .onAppear {
                print("day view opened")
            }
        }
    }
}

#Preview {
    CalendarMainContentView()
        .environmentObject(AppRouter())
}
