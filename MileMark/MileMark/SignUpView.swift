//
//  SignUpView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/9/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var localError = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Spacer(minLength: 20)
                
                Text("Create Account")
                    .font(.largeTitle.bold())
                
        
                
                VStack(spacing: 16) {
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                if !localError.isEmpty {
                    Text(localError)
                        .foregroundColor(.red)
                        .font(.footnote)
                } else if let firebaseError = authViewModel.errorMessage {
                    Text(firebaseError)
                        .foregroundColor(.red)
                        .font(.footnote)
                }

                Button(action: {
                    guard !fullName.isEmpty, !phoneNumber.isEmpty else {
                        localError = "Please fill out all fields."
                        return
                    }
                    guard password == confirmPassword else {
                        localError = "Passwords do not match"
                        return
                    }
                    localError = ""
                    authViewModel.signUp(
                        email: email,
                        password: password,
                        fullName: fullName,
                        phoneNumber: phoneNumber
                    )
                }) {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                NavigationLink("Already have an account? Log In", destination: LoginView())
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
