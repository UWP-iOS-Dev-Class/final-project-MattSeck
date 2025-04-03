//
//  SettingsView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/2/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkMode = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                HStack {
                    Text("Settings")
                        .font(.title)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                Form {
                    Section(header: Text("Personal Details")) {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("*user's email*")
                            Spacer()
                            Text(">")
                        }
                        HStack {
                            Image(systemName: "phone.circle")
                            Text("*user's phone number*")
                            Spacer()
                            Text(">")
                        }
                        HStack {
                            Image(systemName: "lock")
                            Text("CHANGE PASSWORD")
                            Spacer()
                            Text(">")
                        }
                        
                    }
                    
                    Section(header: Text("Preferences")) {
                        Toggle("Notifications", isOn: $notificationsEnabled)
                        Toggle("Dark Mode", isOn: $darkMode)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SettingsView()
}

