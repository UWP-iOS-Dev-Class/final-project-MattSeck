//
//  AddCarSheetView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

struct AddCarSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedMake = ""
    @State private var selectedModel = ""
    @State private var year = ""
    @State private var mileage = ""
    @State private var showMileageError = false

    var editingCar: Car?

    var body: some View {
        NavigationView {
            Form {
                TextField("Make", text: $selectedMake)
                TextField("Model", text: $selectedModel)
                TextField("Year", text: $year)
                    .keyboardType(.numberPad)
                TextField("Current Mileage", text: $mileage)
                    .keyboardType(.numberPad)
            }
            .navigationTitle(editingCar == nil ? "Add Car" : "Edit Car")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCar()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let car = editingCar {
                selectedMake = car.make
                selectedModel = car.model
                year = car.year
                mileage = "\(car.mileage)"
            }
        }
        .alert("Invalid Mileage", isPresented: $showMileageError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please enter a valid, non-negative number for mileage.")
        }
    }

    private func saveCar() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let mileageValue = Int(mileage), mileageValue >= 0 else {
            showMileageError = true
            return
        }

        let carData: [String: Any] = [
            "make": selectedMake,
            "model": selectedModel,
            "year": year,
            "mileage": mileageValue
        ]

        let carRef = Firestore.firestore().collection("users").document(uid).collection("cars")

        let carName = "\(selectedMake) \(selectedModel)"

        if let editingCar = editingCar {
            carRef.document(editingCar.id).setData(carData) { error in
                if let error = error {
                    print("Error updating car: \(error.localizedDescription)")
                } else {
                    authViewModel.fetchCars()
                    presentationMode.wrappedValue.dismiss()
                    NotificationManager.shared.scheduleMileageReminder(for: carName, in: 7)
                }
            }
        } else {
            carRef.addDocument(data: carData) { error in
                if let error = error {
                    print("Error adding car: \(error.localizedDescription)")
                } else {
                    authViewModel.fetchCars()
                    presentationMode.wrappedValue.dismiss()
                    NotificationManager.shared.scheduleMileageReminder(for: carName, in: 7)
                }
            }
        }
    }
}
