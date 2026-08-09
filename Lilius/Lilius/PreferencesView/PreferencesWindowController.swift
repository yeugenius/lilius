//
//  PreferencesWindowController.swift
//  Lilius
//
//  Created by Satendra Singh on 21/06/25.
//

import AppKit
import SwiftUI

class PreferencesWindowController: NSWindowController {
    static let shared = PreferencesWindowController()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        let window = NSWindow()
        window.title = "Preferences"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.setContentSize(NSSize(width: 500, height: 300))
        window.center()
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        let preferencesView = PreferencesRootView()
            .environmentObject(self.appDelegate.preferenceStorage)
            .environmentObject(AppDelegate.calendarListViewModel)

        let hostingController = NSHostingController(rootView: preferencesView)
        self.window?.contentView = hostingController.view
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
