//
//  RowWithSwitchButton.swift
//  Lilius
//
//  Created by Satendra Singh on 24/11/24.
//

import SwiftUI

struct RowWithSwitchButton: View {
    @Binding var checkState: Bool
    var onchange: (() -> Void)? = nil
    
    var title: String
//    @State showGreeting: Bool = false
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Toggle("", isOn: $checkState)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .onChange(of: checkState) {
                    print("Action")
                    self.onchange?()
                }
        }
    }
}

#Preview {
    RowWithSwitchButton(checkState: .constant(false), title: "Message to Show")
        .padding()
}
