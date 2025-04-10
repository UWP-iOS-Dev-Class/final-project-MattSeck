//
//  LoginView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/9/25.
//
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text("Welcome Back")
                .font(.largeTitle.bold())
            
            Text("Login to continue")
                .foregroundColor(.gray)
                .font(.subheadline)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.top, 5)
            }

            Button(action: {
                authViewModel.login(email: email, password: password)
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            Spacer()
            
            NavigationLink("Don't have an account? Sign Up", destination: SignUpView())
                .font(.footnote)
                .foregroundColor(.blue)
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
