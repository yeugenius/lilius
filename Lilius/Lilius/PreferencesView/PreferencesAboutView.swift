//
//  PreferencesAboutView.swift
//  Lilius
//
//  Created by Satendra Singh on 22/02/25.
//

import SwiftUI

struct PreferencesAboutView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            // About Section
            Section {
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Image("AppIconGeneral")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                        Text("About Lilius")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    Text("App Version:\(Bundle.main.releaseVersionNumber ?? "") ( \(Bundle.main.buildVersionNumber ?? "") )")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            // Legal Section
            Section(header: Text("Legal")) {
                HStack {
                    Label {
                        privacyPolicyView
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                HStack {
                    Label {
                        appleAgreementView
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            // Support Section
            Section(header: Text("Support")) {
                HStack {
                    Label {
                        supportEmailView
                    } icon: {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                Text("© 2025 Lilius. All rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            }
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            
        }
        .scrollDisabled(true)
        .navigationTitle("About")
    }
    
    var privacyPolicyView: some View {
        Link("Privacy Policy", destination: URL(string: "https://lilius.org/#privacy")!)
    }
    
    var appleAgreementView: some View {
        Link("Apple license agreement", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
    }
    
    var supportEmailView: some View {
        Link("Contact Support", destination: URL(string: "mailto:info@overmorrow.ca")!)
    }
}

#Preview {
    PreferencesAboutView()
}
