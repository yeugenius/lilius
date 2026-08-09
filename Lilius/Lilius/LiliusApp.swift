//
//  LiliusApp.swift
//  Lilius
//
//  Created by Satendra Singh on 17/11/24.
//

import SwiftUI
import AppKit
import Combine

@main
struct LiliusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // Still allow native Preferences window
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    private var membershipManager = InAppPurchaseService.shared //start observer
    var timer: Timer?
    private var colors: [NSColor] = [.systemRed, .black]
    var currentIndex = 0
    @ObservedObject var menuBarViewData = MenuBarViewData.sharedInstance
    private var animationCounter: Int = 0
    static let calendarListViewModel = CalendarEventListViewModel()
    let appRoute: AppRouter = AppRouter()
    var preferenceStorage = PreferencesStorage.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        menuBarViewData.onChange = { [weak self] in
            guard let self = self else { return }
            self.updateStatusItem()
        }
        if let button = statusItem?.button {
            updateStatusItemWithColor()
            button.action = #selector(togglePopover)
            button.target = self
        }
        setupPopover()
//        NSApp.effectiveAppearance
        let appearance = NSApp.effectiveAppearance
        var secondaryColor: NSColor = .black
        if let name = appearance.bestMatch(from: [.aqua, .darkAqua]), name == .darkAqua {
            // dark
            secondaryColor = .white
        } else {
            secondaryColor = .black
            // something else
        }
        colors = [.systemRed, secondaryColor]

//
        // Start animation timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.colors.count

            if self.animationCounter <= 10 {
                self.updateStatusItemWithColor()
                self.animationCounter += 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.updateStatusItem()
            }
        }
    }
    
    func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 700, height: 450)
        popover?.behavior = .transient
        popover?.animates = true
    }
    
    func setupContentView() {
        // Set the SwiftUI view as the popover's content
        let contentView = ContentView()
                        .environmentObject(appRoute)
                        .environmentObject(PreferencesStorage.shared)
                        .environmentObject(AppDelegate.calendarListViewModel)
        popover?.contentViewController = NSHostingController(rootView: contentView)
    }
    
    func updateStatusItemWithColor() {
        if let button = statusItem?.button {
            let color = colors[currentIndex]
            let timeFormatType: PreferencesGeneralDataSource.TimeFormats = .init(rawValue: PreferencesStorage.shared.timeFormat) ?? .dateAndTime
            var title: String = menuBarViewData.displayTitle
            if timeFormatType == .dayNumberOnly {
                title = menuBarViewData.currentDayText
            }
            let attributedString = NSAttributedString(
                string: title,
                attributes: [
                    .foregroundColor: color,
//                    .font: NSFont.systemFont(ofSize: 14, weight: .bold)
                ]
            )
            button.attributedTitle = attributedString
        }
    }
    
    func updateStatusItem() {
        if let button = statusItem?.button {
            let timeFormatType: PreferencesGeneralDataSource.TimeFormats = .init(rawValue: PreferencesStorage.shared.timeFormat) ?? .dateAndTime
            var title: String = menuBarViewData.displayTitle
            if timeFormatType == .dayNumberOnly {
                title = menuBarViewData.currentDayText
            }
            button.title = title
        }
    }
    
    @objc func togglePopover() {

        if let popover = popover, let button = statusItem?.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                setupContentView()
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
