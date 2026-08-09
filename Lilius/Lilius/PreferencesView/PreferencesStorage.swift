//
//  PreferencesStorage.swift
//  Lilius
//
//  Created by Satendra Singh on 01/12/24.
//

import Foundation
import SwiftUI

public final class PreferencesStorage: ObservableObject {
    @AppStorage("autoLaunch") var autoLaunch: Bool = false
    @AppStorage("firstDayOfWeek") var firstDayOfWeek: String = "Sunday"
    @AppStorage("use24HFormat") var use24HFormat: Bool = false
    @AppStorage("showSeconds") var showSeconds: Bool = true
    @AppStorage("dateFormat") var dateFormat: String = "dd/MM/YY"
    @AppStorage("timeFormat") var timeFormat: String = "Date & Time"

    @AppStorage("showFirstDayAsSunday") var showFirstDayAsSunday: Bool = false
    @AppStorage("showTodayAgendaViewAsDefault") var showTodayAgendaViewAsDefault: Bool = false

    static let shared = PreferencesStorage()
    
    private init() {}
}
