//
//  AppRouter.swift
//  Lilius
//
//  Created by Satendra Singh on 23/11/24.
//

import Foundation

public final class AppRouter: ObservableObject {
    @Published var showEventDetails: Bool = false
    @Published var mainWindowSize: NSSize =  NSSize(width: 500, height: 450)
    
    var dayModel: CalendarDayModel?
    @Published var frame: CGRect = .zero {
        didSet {
            print(frame)
    }}
}
