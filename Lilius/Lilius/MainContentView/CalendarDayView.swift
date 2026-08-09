//
//  CalendarDayView.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI

struct CalendarDayView: View {
    //    var day: String
    var dayObject: CalendarDayModel
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var model: CalendarEventListViewModel
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("showTodayAgendaViewAsDefault") var showTodayAgendaViewAsDefault: Bool = false

    var eventTitle: String {
//        if dayObject.events.count > 0 {
//            return "\(dayObject.day)."
//        }
        return "\(dayObject.day)"
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            HStack {
                ZStack {
                    GeometryReader { geometry in
                        if model.isCurrentDay(day: dayObject) {
                            Circle()
                                .strokeBorder(Color.green,lineWidth: 2)
                        }
                        Button {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                let frame = geometry.frame(in: .scrollView)
                                router.dayModel = dayObject
                                router.frame = frame
                                router.showEventDetails.toggle()
                            }
                            
                        } label: {
                            Text(eventTitle)
                                .modifier(CenterViewModifier())
                                .multilineTextAlignment(.center)
                                .foregroundColor(model.dayColorforDay(day: dayObject, colorScheme: colorScheme))
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            if model.isCurrentDay(day: dayObject) { //&&  showTodayAgendaViewAsDefault == true 
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    let frame = geometry.frame(in: .scrollView)
                                    router.dayModel = dayObject
                                    router.frame = frame
                                    router.showEventDetails.toggle()
                                }
                            }
                        }
                        .onDisappear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                router.dayModel = nil
                                router.frame = .zero
                                router.showEventDetails = false
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 40, height: 40)
    }
}


#Preview {
    CalendarDayView(dayObject: CalendarDayModel())
}

extension CalendarEventListViewModel {
    
    func dayColorforDay(day: CalendarDayModel, colorScheme: ColorScheme) -> Color {

        let isDarkMode: Bool = colorScheme == .dark
        if isCurrentMonth(day: day) {
            return isDarkMode ? .white :  .black
        } else {
            return isDarkMode ? dimmedColor :  .gray
        }
    }
}

fileprivate let dimmedColor = Color.white.opacity(0.3)
