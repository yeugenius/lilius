//
//  ContentView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: CalendarEventListViewModel
    @EnvironmentObject var router: AppRouter

    var body: some View {
        HStack {
            if let dayModel = router.dayModel {
                CalendarEventListView(dayModel: dayModel)
                    .frame(width: 200, height: 520)
            } else {
                EmptyView()
                    .frame(width: 0, height: 520)
            }

            CalendarMainContentView()
                .frame(width: 500, height: 520)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}
