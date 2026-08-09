//
//  EKEvent+URL.swift
//  Lilius
//
//  Created by Satendra Singh on 22/06/25.
//

import Foundation
import EventKit

extension EKEvent {
    func extractConferenceURL() -> URL? {
        let patterns = [
            #"https://meet\.google\.com/[^\s]+"#,
            #"https://zoom\.us/j/[^\s]+"#,
            #"https://.*?zoom\.us/[^\s]+"#,
            #"https://teams\.microsoft\.com/[^\s]+"#
        ]
        
        let combinedText = [
            url?.absoluteString ?? "",
            title ?? "",
            location ?? "",
            notes ?? ""
        ].joined(separator: " ")
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                let range = NSRange(combinedText.startIndex..<combinedText.endIndex, in: combinedText)
                if let match = regex.firstMatch(in: combinedText, options: [], range: range) {
                    if let urlRange = Range(match.range, in: combinedText) {
                        let urlString = String(combinedText[urlRange])
                        return URL(string: urlString)
                    }
                }
            }
        }
        
        return nil
    }
}
