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

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var errorMessage: String?

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

                guard let uid = result?.user.uid else { return }

                self?.user = result?.user

                let userData: [String: Any] = [
                    "fullName": fullName,
                    "phoneNumber": phoneNumber,
                    "email": email,
                    "createdAt": Timestamp()
                ]

                self?.db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        self?.errorMessage = "Failed to save user data: \(error.localizedDescription)"
                    } else {
                        self?.fetchUserProfile()
                    }
                }
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.user = result?.user
                    self?.fetchUserProfile()
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
}
