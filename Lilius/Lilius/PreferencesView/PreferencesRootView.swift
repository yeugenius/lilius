//
//  PreferencesView.swift
//  Lilius
//
//  Created by Satendra Singh on 23/11/24.
//

import SwiftUI

struct PreferencesRootView: View {
    @State private var preferencePage = "General"
     var colors = ["General", "Calendars", "About"]

    var body: some View {
        VStack {
            Picker("", selection: $preferencePage) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.palette)
            .padding()
            switch preferencePage {
                case "General":
                PreferencesGeneralView()
            case "Calendars":
                PreferencesCalendarList()
            case "About":
                PreferencesAboutView()
            default:
                PreferencesGeneralView()
            }
            Spacer()
        }
        .frame(width: 440 , height:  340)
        .onDisappear {
//            InAppPurchaseService.shared.resetHandle()
        }
    }
}

#Preview {
    PreferencesRootView()
        .environmentObject(AppRouter())
}
