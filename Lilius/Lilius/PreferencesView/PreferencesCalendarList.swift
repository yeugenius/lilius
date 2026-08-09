//
//  PreferencesCalendarList.swift
//  Lilius
//
//  Created by Satendra Singh on 28/11/24.
//

import SwiftUI

struct PreferenceCalendar: Identifiable {
    var id = UUID()
    let account: String
    let calendar: String
    var selected: Bool
}

struct PreferencesCalendarList: View {
    @EnvironmentObject var model: CalendarEventListViewModel

    var body: some View {
        Text("Enable calendars to show in Lilius (you have configure system calendars first).\nYou have to buy premium version fo get access to Google/Outlook calendars.")
        Table(model.calendarNames) {
            TableColumn("Account", value: \.account)
            TableColumn("Calendar", value: \.calendar)
            TableColumn("Enabled") { calendar in
                TogglePreferencesView(enabled: calendar.selected, name: calendar.calendar)
            }
        }.onDisappear() {
            model.reloadData()
        }
    }
}

#Preview {
    PreferencesCalendarList()
}

struct TogglePreferencesView: View {
    @EnvironmentObject var model: CalendarEventListViewModel

    @State var enabled: Bool = true
    var name: String = ""

    var body: some View {
        Toggle("", isOn: $enabled)
            .onChange(of: enabled) {
                print("Action")
                if enabled {
                    PreferencesGeneralDataSource.enableCalendar(name)
                } else {
                    PreferencesGeneralDataSource.disableCalendar(name)
                }
            }
            .tint(.primary)
    }
}
