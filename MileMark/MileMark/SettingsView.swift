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
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 5) {
                HStack {
                    Text("Settings")
                        .font(.title)
                        .bold()
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top)
                
                Spacer()
                
                Form {
                    if let profile = authViewModel.userProfile {
                        Section(header: Text("Personal Details")) {
                            HStack {
                                Image(systemName: "envelope.circle")
                                Text(profile.email)
                            }
                            HStack {
                                Image(systemName: "phone.circle")
                                Text(profile.phoneNumber)
                            }
                            HStack {
                                Image(systemName: "lock")
                                Text("CHANGE PASSWORD")
                            }
                        }
                    } else {
                        Section {
                            ProgressView("Loading profile...")
                        }
                    }

                    Section(header: Text("Preferences")) {
                        Toggle("Notifications", isOn: $notificationsEnabled)
                        Toggle("Dark Mode", isOn: $darkMode)
                        Button("Logout", action: authViewModel.logout)
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                authViewModel.fetchUserProfile()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SettingsView().environmentObject(AuthViewModel())
}


