//
//  Bundle+Extension.swift
//  Lilius
//
//  Created by Satendra Singh on 22/02/25.
//

import AppKit

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
