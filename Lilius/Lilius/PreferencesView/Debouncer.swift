//
//  Debouncer.swift
//  Lilius
//
//  Created by Satendra Singh on 01/03/25.
//

import AppKit

class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?
    var context: String? = nil
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func debounce(action: @escaping () -> Void) {
        // Cancel any existing work item
        workItem?.cancel()
        
        // Create a new work item
        let newWorkItem = DispatchWorkItem { [weak self] in
            print("Execute debouncer: \(self?.context ?? "-")")
            action()
        }
        workItem = newWorkItem
        
        // Schedule the work item after the delay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    deinit {
        print("Cancel debouncer: \(context ?? "-")")
        workItem?.cancel()
    }
}
