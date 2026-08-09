//
//  CalendarEventListViewMode.swift
//  Lilius
//
//  Created by Satendra Singh on 04/12/24.
//
import SwiftUI

final class CalendarEventListViewModel: ObservableObject {
    let calendarService: CalendarEventsDataService = CalendarEventsDataService.sharedInstance
    @Published var calendarDates:[[CalendarDayModel]]
    @Published var monthYearHeading: String = ""
    @Published var calendarHeader:[String] = PreferencesGeneralDataSource.updatedWeedays()
    @Published var calendarNames:[PreferenceCalendar] = [PreferenceCalendar]()
    
    var currrentDateComponents: (year: Int, month: Int, day: Int) = (0,0,0)
    
    private let dateFormatter: DateFormatter = {
        let Formatter = DateFormatter()
        Formatter.dateFormat = "dd"
        return Formatter
    }()
    
    init() {
        calendarDates = calendarService.selectedMonthCalArray
        calendarService.updateEventClosure = { [weak self] in
            self?.calendarDates = self?.calendarService.selectedMonthCalArray ?? []
        }
        reloadData()
    }
    
    func showNextMonth() {
        calendarService.showNextMonth(self)
        reloadData()
    }
    
    func showPreviousMonth() {
        calendarService.showPreviousMonth(self)
        reloadData()
    }
    
    func reloadData() {
        calendarDates = calendarService.selectedMonthCalArray
        calendarHeader = PreferencesGeneralDataSource.updatedWeedays()
        updateMonthAndYear()
        var updatedComponents: (year: Int, month: Int, day: Int) {
            let currentDate = Date()
            let comps = currentDate.get(.year, .month, .day)
            return (comps.year ?? 0, comps.month ?? 0, comps.day ?? 0)
        }
        self.currrentDateComponents = updatedComponents
        let disabled = PreferencesGeneralDataSource.disabledCalendars
        self.calendarNames = calendarService.calendars.map({.init(account: $0.source.title, calendar: $0.title, selected: (!disabled.contains($0.title)))})
    }
    
    private func updateMonthAndYear() {
        let months = dateFormatter.monthSymbols
        let monthSymbol = months?[calendarService.selectedMonth-1] // month - from your date components
        monthYearHeading = monthSymbol! + ", " + "\(calendarService.selectedYear)"
    }
    
    func isCurrentMonth(day: CalendarDayModel) -> Bool {
        let month = day.month % 12
        if  month == calendarService.selectedMonth && day.year == calendarService.selectedYear {
            return true
        }
        return false
    }
    
    func isCurrentDay(day: CalendarDayModel) -> Bool {
        let month = day.month % 12
        if day.year == currrentDateComponents.year && month == currrentDateComponents.month &&  day.day == currrentDateComponents.day {
            return true
        }
        return false
    }
    
    func eventDetailsTitle(forDay: DateComponents) -> String {
        var dateComponent = forDay
        dateComponent.month = (dateComponent.month ?? 1) % 12
        dateComponent.timeZone = TimeZone.current
        let date = dateComponent.date ?? Date()
        let dateFormatter =  PreferencesStorage.shared.dateFormat
        if dateFormatter == "mm/dd/YY" || dateFormatter == "mm/dd/YYYY" {
            return mmddyyyyFormatter.string(from: date)
        }
        return ddmmyyyyFormatter.string(from: date)
    }
    
    private lazy var mmddyyyyFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter
    }()
    
    private lazy var ddmmyyyyFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMM, yyyy"
        return dateFormatter
    }()
    
    func refreshContent() {
        calendarHeader = PreferencesGeneralDataSource.updatedWeedays()
        calendarService.layoutCalendar()
    }
}
