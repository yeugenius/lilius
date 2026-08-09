//
//  CenterViewModifier.swift
//  Lilius
//
//  Created by Satendra Singh on 30/11/24.
//

import SwiftUI

struct  CenterViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Spacer()
                content
                Spacer()
            }
            Spacer()
        }
    }
}
