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

    @State private var showAddMaintenanceSheet = false
    @State private var newTaskName = ""
    @State private var newTaskInterval = ""

    @State private var editingTask: MaintenanceType? = nil
    @State private var editedName = ""
    @State private var editedInterval = ""
    @State private var showEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(car.year) \(car.make) \(car.model)")
                    .font(.title)

                Text("Mileage: \(car.mileage) mi")

                Divider()

                HStack {
                    Text("Maintenance Tasks")
                        .font(.headline)
                    Spacer()
                    Button("+ Add Maintenance Type") {
                        showAddMaintenanceSheet = true
                    }
                    .font(.subheadline)
                }

                let allMaintenance = authViewModel.defaultMaintenanceTypes + car.customMaintenance

                ForEach(allMaintenance, id: \.name) { maintenance in
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
                        .padding(.vertical, 6)
                        .contentShape(Rectangle())
                        .onLongPressGesture {
                            // Only allow editing custom maintenance tasks
                            if car.customMaintenance.contains(where: { $0.name == maintenance.name }) {
                                editingTask = maintenance
                                editedName = maintenance.name
                                editedInterval = String(maintenance.interval)
                                showEditSheet = true
                            }
                        }
                    }
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

        // Confirm log
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

        // Add custom maintenance
        .sheet(isPresented: $showAddMaintenanceSheet) {
            NavigationView {
                Form {
                    TextField("Maintenance Name", text: $newTaskName)
                    TextField("Interval (miles)", text: $newTaskInterval)
                        .keyboardType(.numberPad)
                }
                .navigationTitle("New Maintenance")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let interval = Int(newTaskInterval) {
                                authViewModel.addCustomMaintenance(to: car, name: newTaskName, interval: interval)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    authViewModel.fetchCars()
                                }
                            }
                            showAddMaintenanceSheet = false
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddMaintenanceSheet = false
                        }
                    }
                }
            }
        }
        //Edit custom maintenance
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                Form {
                    TextField("Maintenance Name", text: $editedName)
                    TextField("Interval (miles)", text: $editedInterval)
                        .keyboardType(.numberPad)
                }
                .navigationTitle("Edit Maintenance")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if var task = editingTask,
                               let interval = Int(editedInterval) {
                                task.name = editedName
                                task.interval = interval
                                authViewModel.updateCustomMaintenance(for: car, updatedTask: task)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    authViewModel.fetchCars()
                                }
                                showEditSheet = false
                            }
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showEditSheet = false
                        }
                    }
                }
            }
        }
    }
}
