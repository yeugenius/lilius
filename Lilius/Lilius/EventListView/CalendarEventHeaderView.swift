//
//  CalendarEventHeaderView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct CalendarEventHeaderView: View {
    @EnvironmentObject var eventListModel: CalendarEventListViewModel
    let eventTitle: String
    
    var body: some View {
        HStack {
            Text(eventTitle)
        }
        .font(.headline)
        .fontWeight(.bold)
        .padding()
    }
}

#Preview {
    CalendarEventHeaderView( eventTitle: "Hellow")
}
