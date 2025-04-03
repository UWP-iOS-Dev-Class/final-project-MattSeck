//
//  DashboardView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/2/25.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
            NavigationView {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Maintenance Dashboard")
                                .font(.title)
                            Text("Hello, *user's name*")
                            
                            // Your Cars Section
                            Text("Your Cars")
                                .font(.headline)
                                .padding(.top, 10)
                            // car content to go here
                            Text("Car list placeholder")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: geometry.size.height / 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15)
                        .background(Color(.systemGray6))
                        
                        // Maintenance Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Maintenance")
                                .font(.headline)
                            // Add your maintenance content here
                            Text("Maintenance items placeholder")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .frame(height: geometry.size.height / 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 15) // Consistent left padding
                        .background(Color(.systemGray5))
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
    }

#Preview {
    DashboardView()
}
