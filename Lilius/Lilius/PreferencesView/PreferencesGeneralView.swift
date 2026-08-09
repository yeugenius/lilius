//
//  PreferencesGeneralView.swift
//  Lilius
//
//  Created by Satendra Singh on 24/11/24.
//

import SwiftUI
import ServiceManagement

struct PreferencesGeneralView: View {
    @EnvironmentObject var preferenceStore: PreferencesStorage
    @EnvironmentObject var model: CalendarEventListViewModel

    var body: some View {
        VStack(spacing: 12) {
            RowWithSwitchButton(checkState: preferenceStore.$autoLaunch, onchange: {
                enableAutoLaunch()
            }, title: "Run on system startup")

            RowWithSwitchButton(checkState: preferenceStore.$showFirstDayAsSunday, onchange: {
                print("Sunday Enabled:\(preferenceStore.$showFirstDayAsSunday)")
                    let newValue = preferenceStore.showFirstDayAsSunday == false ? "Monday" : "Sunday"
                print("New Value:\(newValue)")
                    preferenceStore.firstDayOfWeek = newValue
                model.refreshContent()
                model.reloadData()
            }, title: "Use Sunday as a first day of the week")
           
            RowWithDropdownButton(selectedItem: preferenceStore.$timeFormat, options: PreferencesGeneralDataSource.timeFormatsOptions, title: "Display Format:")

            RowWithSwitchButton(checkState: preferenceStore.$use24HFormat, onchange: {
                
            }, title: "Use 24H Time Format")

            RowWithDropdownButton(selectedItem: preferenceStore.$dateFormat, options: PreferencesGeneralDataSource.dateFormatsOptions, title: "Date Format:")
            
//            RowWithSwitchButton(checkState: preferenceStore.$showTodayAgendaViewAsDefault, onchange: {
//            }, title: "Display today agenda automatically")

            //Do not show time in the menu bar
            Spacer()
        }
        .padding()
//        .onDisappear() {
//            self.enableAutoLaunch()
//        }
    }
    
    func enableAutoLaunch() {
        if(PreferencesStorage.shared.autoLaunch == true)
        {
            if (SMLoginItemSetEnabled("ca.overmorrow.lilius.launcher" as CFString, true) == false) {
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = "An error ocurred"
                myPopup.informativeText = "Couldn't add application to launch at login item list."
                myPopup.alertStyle = NSAlert.Style.informational
                myPopup.addButton(withTitle: "OK")
                myPopup.runModal()
            }
        }
        else{
            if (SMLoginItemSetEnabled("ca.overmorrow.lilius.launcher" as CFString, false) == false) {
                let myPopup: NSAlert = NSAlert()
                myPopup.messageText = "An error ocurred"
                myPopup.informativeText = "Couldn't remove application from launch at login item list."
                myPopup.alertStyle = NSAlert.Style.informational
                myPopup.addButton(withTitle: "OK")
                myPopup.runModal()
            }
        }
    }
}

#Preview {
    PreferencesGeneralView()
}
