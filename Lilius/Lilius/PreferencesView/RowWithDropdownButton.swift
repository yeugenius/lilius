//
//  RowWithDropdownButton.swift
//  Lilius
//
//  Created by Satendra Singh on 24/11/24.
//

import SwiftUI

struct RowWithDropdownButton: View {
//    var checkState: Binding<Bool>
    var selectedItem: Binding<String>
    var options: [String]

    var title: String
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: selectedItem) {
                ForEach(options, id: \.self) {
                    Text($0)
                }
            }
        }
    }
}

#Preview {
    RowWithDropdownButton(selectedItem: .constant("General"), options: ["General", "Calendars", "Premium"], title: "Drop Down menu")
        .padding()
}
