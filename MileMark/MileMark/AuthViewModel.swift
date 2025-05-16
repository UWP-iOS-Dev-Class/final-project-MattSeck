//
//  AuthViewModel.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserProfile {
    var fullName: String
    var phoneNumber: String
    var email: String
}

struct Car: Identifiable {
    var id: String
    var make: String
    var model: String
    var year: String
    var mileage: Int
    var maintenanceHistory: [MaintenanceRecord] = []
    var customMaintenance: [MaintenanceType] = []
}

struct MaintenanceRecord: Codable, Identifiable {
    var id = UUID().uuidString
    var type: String
    var mileage: Int
    var date: Date
}

struct MaintenanceType: Identifiable, Codable {
    var id: String
    var name: String
    var interval: Int
}

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?
    @Published var cars: [Car] = []
    @Published var defaultMaintenanceTypes: [MaintenanceType] = []

    private let db = Firestore.firestore()

    init() {
        self.user = Auth.auth().currentUser
        fetchUserProfile() // Fetch on init if already logged in
    }

    func signUp(email: String, password: String, fullName: String, phoneNumber: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self?.errorMessage = "Failed to create user."
                    return
                }

                // ✅ Send verification email
                user.sendEmailVerification { error in
                    if let error = error {
                        self?.errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                    } else {
                        print("📧 Verification email sent to \(user.email ?? "")")
                    }
                }

                // ✅ Optionally save user profile right away
                let userData: [String: Any] = [
                    "fullName": fullName,
                    "phoneNumber": phoneNumber,
                    "email": email,
                    "createdAt": Timestamp()
                ]

                self?.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self?.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    } else {
                        self?.fetchUserProfile()
                    }
                }

                // ⚠️ Don't set self?.user here yet — wait until verification in login
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let user = result?.user else {
                    self?.errorMessage = "Login failed."
                    return
                }

                // ✅ Check if email is verified
                if user.isEmailVerified {
                    self?.user = user
                    self?.fetchUserProfile()
                } else {
                    self?.errorMessage = "Please verify your email before logging in."
                    try? Auth.auth().signOut()
                }
            }
        }
    }
    
    

    func logout() {
        try? Auth.auth().signOut()
        self.user = nil
        self.userProfile = nil
    }

    func fetchUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let data = snapshot?.data(), error == nil {
                let profile = UserProfile(
                    fullName: data["fullName"] as? String ?? "N/A",
                    phoneNumber: data["phoneNumber"] as? String ?? "N/A",
                    email: data["email"] as? String ?? "N/A"
                )
                DispatchQueue.main.async {
                    self?.userProfile = profile
                }
            } else {
                DispatchQueue.main.async {
                    self?.errorMessage = "Unable to fetch user profile."
                }
            }
        }
    }
    
    func fetchCars() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("cars").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching cars: \(error.localizedDescription)")
                return
            }

            self?.cars = snapshot?.documents.compactMap { doc in
                let data = doc.data()

                
                let maintenanceList = (data["maintenanceHistory"] as? [[String: Any]]) ?? []
                let history = maintenanceList.compactMap { item -> MaintenanceRecord? in
                    guard let type = item["type"] as? String,
                          let mileage = item["mileage"] as? Int,
                          let timestamp = item["date"] as? Timestamp else { return nil }

                    return MaintenanceRecord(type: type, mileage: mileage, date: timestamp.dateValue())
                }

                
                let customList = (data["customMaintenance"] as? [[String: Any]]) ?? []
                let customTypes = customList.compactMap { item -> MaintenanceType? in
                    guard let name = item["name"] as? String,
                          let interval = item["interval"] as? Int else { return nil }

                    return MaintenanceType(id: UUID().uuidString, name: name, interval: interval)
                }

                // Build the Car object
                return Car(
                    id: doc.documentID,
                    make: data["make"] as? String ?? "Unknown",
                    model: data["model"] as? String ?? "",
                    year: data["year"] as? String ?? "",
                    mileage: data["mileage"] as? Int ?? 0,
                    maintenanceHistory: history,
                    customMaintenance: customTypes
                )
            } ?? []
        }
    }
    
    func deleteCar(car: Car) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("cars").document(car.id).delete { [weak self] error in
            if let error = error {
                print("Failed to delete car: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
        }
    }
    
    func updateMileage(for car:Car, to newMileage: Int) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        db.collection("users").document(uid).collection("cars").document(car.id).updateData(["mileage": newMileage
          ]) { [weak self] error in
            if let error = error {
                print("Error updating mileage: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
            
        }
    }
    
    func addMaintenance(to car: Car, type: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let currentMileage = car.mileage
        let newRecord = MaintenanceRecord(
            type: type,
            mileage: currentMileage,
            date: Date()
        )

        var updatedHistory = car.maintenanceHistory
        updatedHistory.append(newRecord)

        let updatedHistoryData = updatedHistory.map { record in
            return [
                "type": record.type,
                "mileage": record.mileage,
                "date": Timestamp(date: record.date)
            ]
        }

        db.collection("users").document(uid).collection("cars").document(car.id).updateData([
            "maintenanceHistory": updatedHistoryData
        ]) { [weak self] error in
            if let error = error {
                print("Error logging maintenance: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
        }
    }
    
    func fetchDefaultMaintenance() {
        db.collection("defaultMaintenance").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error fetching default maintenance: \(error.localizedDescription)")
                return
            }

            self?.defaultMaintenanceTypes = snapshot?.documents.compactMap { doc in
                let data = doc.data()
                guard let name = data["name"] as? String,
                      let interval = data["interval"] as? Int else {
                    return nil
                }
                return MaintenanceType(id: doc.documentID, name: name, interval: interval)
            } ?? []
        }
    }
    
    func addCustomMaintenance(to car: Car, name: String, interval: Int) {
        guard let uid = user?.uid else { return }

        let newMaintenance = [
            "name": name,
            "interval": interval
        ] as [String : Any]

        var updated = car.customMaintenance.map { ["name": $0.name, "interval": $0.interval] }
        updated.append(newMaintenance)

        db.collection("users").document(uid).collection("cars").document(car.id).updateData([
            "customMaintenance": updated
        ]) { [weak self] error in
            if let error = error {
                print("Failed to add custom maintenance: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
        }
    }
    
    func updateCustomMaintenance(for car: Car, updatedTask: MaintenanceType) {
        guard let uid = user?.uid else { return }

        var updated = car.customMaintenance.map { item in
            item.id == updatedTask.id
                ? ["name": updatedTask.name, "interval": updatedTask.interval]
                : ["name": item.name, "interval": item.interval]
        }

        db.collection("users").document(uid).collection("cars").document(car.id).updateData([
            "customMaintenance": updated
        ]) { [weak self] error in
            if let error = error {
                print("Failed to update custom maintenance: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
        }
    }
    
    func deleteCustomMaintenance(from car: Car, taskName: String) {
        guard let uid = user?.uid else { return }

        let updated = car.customMaintenance
            .filter { $0.name != taskName }
            .map { ["name": $0.name, "interval": $0.interval] }

        db.collection("users").document(uid).collection("cars").document(car.id).updateData([
            "customMaintenance": updated
        ]) { [weak self] error in
            if let error = error {
                print("Failed to delete custom maintenance: \(error.localizedDescription)")
            } else {
                self?.fetchCars()
            }
        }
    }
}

