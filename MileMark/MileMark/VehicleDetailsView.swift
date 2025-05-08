//
//  VehicleDetailsView.swift
//  MileMark
//
//  Created by Matthew Secketa on 5/7/25.
//

import SwiftUI

struct VehicleDetailsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var car: Car

    @State private var showConfirmation = false
    @State private var selectedMaintenance: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(car.year) \(car.make) \(car.model)")
                    .font(.title)

                Text("Mileage: \(car.mileage) mi")

                Divider()

                Text("Standard Maintenance")
                    .font(.headline)

                ForEach(defaultMaintenance, id: \.name) { maintenance in
                    VStack(alignment: .leading) {
                        let lastRecord = car.maintenanceHistory
                            .filter { $0.type.lowercased() == maintenance.name.lowercased() }
                            .sorted { $0.mileage > $1.mileage }
                            .first
                        let nextDue = (lastRecord?.mileage ?? 0) + maintenance.interval
                        HStack {
                            VStack(alignment: .leading) {
                                Text(maintenance.name)
                                    .bold()
                                if let last = lastRecord {
                                    Text("Last done at \(last.mileage) mi")
                                        .font(.subheadline)
                                } else {
                                    Text("Not yet logged")
                                        .font(.subheadline)
                                }
                                Text("Next due at \(nextDue) mi")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Log") {
                                selectedMaintenance = maintenance.name
                                showConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Divider()

                Text("Maintenance History")
                    .font(.headline)

                ForEach(car.maintenanceHistory.sorted { $0.mileage > $1.mileage }) { record in
                    VStack(alignment: .leading) {
                        Text(record.type)
                            .bold()
                        Text("At \(record.mileage) miles")
                        Text("On \(record.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
        .alert("Log Maintenance", isPresented: $showConfirmation) {
            Button("Confirm", role: .destructive) {
                if let type = selectedMaintenance {
                    authViewModel.addMaintenance(to: car, type: type)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authViewModel.fetchCars()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to log this maintenance?")
        }
    }
}

struct MaintenanceType {
    let name: String
    let interval: Int
}

let defaultMaintenance: [MaintenanceType] = [
    MaintenanceType(name: "Oil Change", interval: 3000),
    MaintenanceType(name: "Tire Rotation", interval: 6000),
    MaintenanceType(name: "Brake Inspection", interval: 12000)
]
