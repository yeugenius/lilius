//
//  MenuBarViewData.swift
//  Lilius
//
//  Created by Satendra Singh on 12/12/24.
//

import Foundation
import SwiftUI

class MenuBarViewData: ObservableObject {
    @Published var displayTitle: String = ""
    @Published var dayImage: Image? = nil
    @Published var currentDayText: String = ""
    var onChange: (() -> Void)?
    
    private var lastDay: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                if let img = self.copyToClipboard() {
                    self.dayImage = Image(nsImage: img)
                }
                self.currentDayText = "|\(String(format: "%02d", self.lastDay))|"
            }
        }
    }
    
    weak var timer: Timer?
    
    static let sharedInstance = MenuBarViewData()
    
    init() {
        registerUpdateTime()
    }
    
    var currentDay: Int {
        let date = Date()
        // MARK: Way 1
        let components = date.get(.day)
        return components
    }
    
    func registerUpdateTime() {
        unregisterUpdateTime()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTopbar), userInfo: nil, repeats: true)
        self.displayTitle = title
        if lastDay != currentDay {
            lastDay = currentDay
        }
    }
    
    func unregisterUpdateTime() {
        timer?.invalidate()
    }
    
    @objc
    private func updateTopbar() {
        if displayTitle != title {
            displayTitle = title
            onChange?()
        }
        if lastDay != currentDay {
            lastDay = currentDay
        }
    }
    
    var title: String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier: "en_US_POSIX") as Locale;
        // big range 1
//        String(format: "%02d", myInt)
        let prefStorage = PreferencesStorage.shared
        
        var strTimeFormatter:String =  prefStorage.dateFormat
        let timeFormatType: PreferencesGeneralDataSource.TimeFormats = .init(rawValue: prefStorage.timeFormat) ?? .dateAndTime
        if timeFormatType == .dateAndTime {
            var strHour: String!
//            if prefStorage.showSeconds == true {
//                if (prefStorage.use24HFormat == true) {
//                    strHour = "HH:mm:ss"
//                } else {
//                    strHour = "hh:mm:ss a"
//                }
//            } else {
                if (prefStorage.use24HFormat == true) {
                    strHour = "HH:mm "
                } else {
                    strHour = "hh:mm a"
                }
            strTimeFormatter.append(" ")
            strTimeFormatter.append(strHour)
        } else if timeFormatType == .timeOnly {
            var strHour: String!
            if (prefStorage.use24HFormat == true) {
                strHour = "HH:mm "
            } else {
                strHour = "hh:mm a"
            }
            strTimeFormatter = strHour
        }
        
//        print("Format:\(strTimeFormatter)")

        dateFormatter.dateFormat = strTimeFormatter
        
        //Monospace font to prevent "jumping" of seconds in menu bar. SF Mono is forbidden by Apple. Try to use Helvetica neue mono
//        if let fontx = NSFont(name: "SF Pro Display Light", size: 15)
//        {
//            var attributes = [String: AnyObject]()
//            attributes[NSFontAttributeName] = fontx
//            let attriString = NSAttributedString(string:dateFormatter.string(from: Date()), attributes: attributes)
//            print("attriString:\(attriString)")
//            statusItem.attributedTitle = attriString
//        }
//        else{
//            statusItem.title = dateFormatter.string(from: Date())
//        }
        return dateFormatter.string(from: Date())
    }

    @ViewBuilder var label: some View {
        Text("\(lastDay)")
            .padding(4)
        //            .border(.pink, width: 5)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.red, lineWidth: 2)
            )
    }
    
    @MainActor func copyToClipboard() -> NSImage? {
        let qrCodeView = label.frame(width: 28, height: 28)
        guard let cgImage = ImageRenderer(content: qrCodeView).cgImage else {
            return nil
        }

        let image = NSImage(cgImage: cgImage, size: .init(width: 28, height: 28))
    //    let pasteboard = NSPasteboard.general
    //    pasteBoard.clearContents()
    //    pasteBoard.writeObjects([image])
        return image
    }

}
