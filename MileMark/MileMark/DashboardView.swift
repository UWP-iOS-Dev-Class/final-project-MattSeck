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
    
    
    //Calculates how many miles remain until each type of maintenance
    //returns the maintenance with the fewest miles left
    var nextMaintenance: (name: String, milesLeft: Int)? {
        guard let car = selectedCar else { return nil }
        
        let results: [(String, Int)] = defaultMaintenance.compactMap { maintenance in
            guard let lastRecord = car.maintenanceHistory
                .filter({ $0.type.lowercased() == maintenance.name.lowercased() })
                .sorted(by: { $0.mileage > $1.mileage })
                .first else {
                return nil // Ignore unlogged maintenance
            }
            
            let nextDue = lastRecord.mileage + maintenance.interval
            let milesLeft = nextDue - car.mileage
            
            return (maintenance.name, milesLeft)
        }
        
        return results.sorted(by: { $0.1 < $1.1 }).first
    }
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Top Section: Greeting & Cars
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Maintenance Dashboard")
                            .font(.title)
                            .bold()
                            .padding(.leading, 15)
                        
                        if let name = authViewModel.userProfile?.fullName {
                            HStack {
                                Text("Hello,")
                                Text(name).bold()
                            }
                            .font(.title2)
                            .padding(.leading, 15)
                        } else {
                            ProgressView("Loading user info...")
                        }
                        
                        HStack {
                            Text("Your Cars")
                                .font(.headline)
                                .padding(.leading, 15)
                            
                            Button {
                                showAddCarSheet = true
                            } label: {
                                Image(systemName: "plus.circle")
                                    .font(.headline)
                            }
                        }
                        .padding(.top, 10)
                        
                        if authViewModel.cars.isEmpty {
                            Text("No cars added yet.")
                                .foregroundColor(.gray)
                                .padding(.leading, 15)
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
                    .frame(height: geometry.size.height / 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    
                    // Bottom Section: Maintenance
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Maintenance")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        
                        Spacer()
                        
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
                        if let next = nextMaintenance{
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(selectedCar != nil ? "\(selectedCar!.mileage) mi" : "--")
                                        .bold()
                                    Spacer()
                                    Text("Current Odometer Reading")
                                }
                                
                                HStack {
                                    Text("\(nextMaintenance?.milesLeft ?? 0) mi")
                                        .bold()
                                        .foregroundColor((nextMaintenance?.milesLeft ?? 0) < 0 ? .red : .white)
                                    Spacer()
                                    Text("Maintenance Due")
                                }
                                
                                HStack {
                                    Text(nextMaintenance?.name ?? "--")
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
                }
                .alert("Enter Mileage", isPresented: $showMileageInput, actions: {
                    TextField("Mileage", text: $mileageInput)
                        .keyboardType(.numberPad)
                    Button("Save", action: {
                        if let car = selectedCar, let newMileage = Int(mileageInput),
                           let index = authViewModel.cars.firstIndex(where: { $0.id == car.id }) {
                            
                            //Update Firebase
                            authViewModel.updateMileage(for: car, to: newMileage)
                            
                            //Update local car in array
                            authViewModel.cars[index].mileage = newMileage
                            
                            //Update selectedCar to trigger UI refresh
                            selectedCar = authViewModel.cars[index]
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
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddCarSheet) {
                AddCarSheetView()
            }
            .sheet(item: $selectedCarToEdit) { car in
                AddCarSheetView(editingCar: car)
            }
        }
    }
    
    //ensures selected car is refreshed when sheet is dismissed
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
