//
//  MonthAndYearHeading.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct MonthAndYearHeading: View {
    @Environment(\.openWindow) var openPreferencesWindow
    @EnvironmentObject var eventListModel: CalendarEventListViewModel
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(action: {
                        print("left clicked")
                        eventListModel.showPreviousMonth()
                        
                    }) {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(.borderless)
                    Text(eventListModel.monthYearHeading)
                    
                    Button(action: {
                        print("right clicked")
                        eventListModel.showNextMonth()
                        
                    }) {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.borderless)
                }
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                
                HStack {
                    Spacer()
                    Button(action: {
                        print("Settings clicked")
                        PreferencesWindowController.shared.show()

//                        openPreferencesWindow(id: "openPreferencesWindow")
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            for window in NSApplication.shared.windows {
//                                if window.className == "SwiftUI.AppKitWindow" {
//                                    window.level = .floating
//                                }
//                                print("window class: \(window.className)")
//                            }
//                        }
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                        .frame(width: 30)
                    Button(action: {
                        print("exit clicked")
                        NSApplication.shared.terminate(self)
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }
}

#Preview {
    MonthAndYearHeading()
}
