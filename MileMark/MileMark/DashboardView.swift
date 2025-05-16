//
//  DashboardView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/2/25.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showAddCarSheet = false
    @State private var selectedCarToEdit: Car? = nil
    @State private var showDeleteConfirmation = false
    @State private var carToDelete: Car?
    @State private var selectedCar: Car? = nil
    @State private var showMileageInput = false
    @State private var mileageInput = ""
    @State private var showVehicleDetails = false

    // Calculates how many miles remain until each type of maintenance
    var nextMaintenance: (name: String, milesLeft: Int)? {
        guard let car = selectedCar else { return nil }

        let allMaintenance = authViewModel.defaultMaintenanceTypes + car.customMaintenance

        let results: [(String, Int)] = allMaintenance.compactMap { maintenance in
            guard let lastRecord = car.maintenanceHistory
                .filter({ $0.type.lowercased() == maintenance.name.lowercased() })
                .sorted(by: { $0.mileage > $1.mileage })
                .first else {
                return nil
            }

            let nextDue = lastRecord.mileage + maintenance.interval
            let milesLeft = nextDue - car.mileage
            return (maintenance.name, milesLeft)
        }

        return results.sorted {
            if $0.1 == $1.1 {
                return $0.0 < $1.0
            }
            return $0.1 < $1.1
        }.first
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {

                // Top Section: Greeting & Cars
                VStack(alignment: .leading, spacing: 10) {
                    Text("Maintenance Dashboard")
                        .font(.title)
                        .bold()

                    if let name = authViewModel.userProfile?.fullName {
                        HStack {
                            Text("Hello,")
                            Text(name).bold()
                        }
                        .font(.title2)
                    } else {
                        ProgressView("Loading user info...")
                    }

                    HStack {
                        Text("Your Cars")
                            .font(.headline)
                        Button {
                            showAddCarSheet = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .font(.headline)
                        }
                    }
                    .padding(.top, 5)

                    if authViewModel.cars.isEmpty {
                        Text("No cars added yet.")
                            .foregroundColor(.gray)
                    } else {
                        CarScrollView(
                            cars: authViewModel.cars,
                            onEdit: { car in selectedCarToEdit = car },
                            onDelete: { car in
                                carToDelete = car
                                showDeleteConfirmation = true
                            },
                            onSelect: { car in selectedCar = car },
                            selectedCar: selectedCar
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .frame(minHeight: 320)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))

                // Bottom Section: Maintenance
                VStack(alignment: .leading, spacing: 15) {
                    Text("Maintenance")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    HStack(spacing: 20) {
                        Button(action: {
                            if selectedCar != nil {
                                showMileageInput = true
                            }
                        }) {
                            VStack {
                                Image(systemName: "pencil.and.outline")
                                    .font(.title)
                                Text("Log Mileage")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(width: 175, height: 95)
                            .background(Color(.darkGray))
                            .cornerRadius(15)
                            .shadow(radius: 4)
                        }

                        Button(action: {
                            if selectedCar != nil {
                                showVehicleDetails = true
                            }
                        }) {
                            VStack {
                                Image(systemName: "book.closed")
                                    .font(.title)
                                Text("Vehicle Details")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.white)
                            .frame(width: 175, height: 95)
                            .background(Color(.darkGray))
                            .cornerRadius(15)
                            .shadow(radius: 4)
                        }
                    }

                    if let next = nextMaintenance {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(selectedCar != nil ? "\(selectedCar!.mileage) mi" : "--")
                                    .bold()
                                Spacer()
                                Text("Current Odometer Reading")
                            }

                            HStack {
                                Text("\(next.milesLeft) mi")
                                    .bold()
                                    .foregroundColor(next.milesLeft < 0 ? .red : .white)
                                Spacer()
                                Text("Maintenance Due")
                            }

                            HStack {
                                Text(next.name)
                                    .bold()
                                Spacer()
                                Text("Next Maintenance")
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 370)
                        .background(Color(.darkGray))
                        .cornerRadius(15)
                        .shadow(radius: 4)
                    } else if selectedCar == nil {
                        VStack(alignment: .leading) {
                            Text("No car selected")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 370)
                        .background(Color(.darkGray))
                        .cornerRadius(15)
                        .shadow(radius: 4)
                    } else {
                        VStack(alignment: .leading) {
                            Text("No maintenance logged yet")
                                .bold()
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 370)
                        .background(Color(.darkGray))
                        .cornerRadius(15)
                        .shadow(radius: 4)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .background(Color(.systemGray5))
            }
            .onAppear {
                authViewModel.fetchUserProfile()
                authViewModel.fetchCars()
                authViewModel.fetchDefaultMaintenance()
            }
            .alert("Enter Mileage", isPresented: $showMileageInput, actions: {
                TextField("Mileage", text: $mileageInput)
                    .keyboardType(.numberPad)
                Button("Save", action: {
                    if let car = selectedCar, let newMileage = Int(mileageInput),
                       let index = authViewModel.cars.firstIndex(where: { $0.id == car.id }) {

                        authViewModel.updateMileage(for: car, to: newMileage)

                        authViewModel.cars[index].mileage = newMileage
                        selectedCar = authViewModel.cars[index]

                        let carName = "\(car.make) \(car.model)"
                        NotificationManager.shared.scheduleMileageReminder(for: carName, in: 7)
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            })
            .alert("Are you sure you want to delete this car?", isPresented: $showDeleteConfirmation, presenting: carToDelete) { car in
                Button("Delete", role: .destructive) {
                    authViewModel.deleteCar(car: car)
                    carToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    carToDelete = nil
                }
            } message: { car in
                Text("\(car.year) \(car.make) \(car.model)")
            }
            .sheet(isPresented: $showVehicleDetails, onDismiss: dismissFetch) {
                if let index = authViewModel.cars.firstIndex(where: { $0.id == selectedCar?.id }) {
                    VehicleDetailsView(car: $authViewModel.cars[index])
                        .environmentObject(authViewModel)
                }
            }
            .sheet(isPresented: $showAddCarSheet) {
                AddCarSheetView()
            }
            .sheet(item: $selectedCarToEdit) { car in
                AddCarSheetView(editingCar: car)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    func dismissFetch() {
        authViewModel.fetchCars()
        authViewModel.fetchUserProfile()

        if let oldID = selectedCar?.id {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let updatedCar = authViewModel.cars.first(where: { $0.id == oldID }) {
                    selectedCar = updatedCar
                }
            }
        }
    }
}

#Preview {
    DashboardView().environmentObject(AuthViewModel())
}
