//
//  LoginView.swift
//  MileMark
//
//  Created by Matthew Secketa on 4/9/25.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 25) {
            Spacer()

            Text("MileMark")
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

                if errorMessage.contains("verify your email") {
                    Button("Resend Verification Email") {
                        resendVerificationEmail()
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                }
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

    private func resendVerificationEmail() {
        if let user = Auth.auth().currentUser, !user.isEmailVerified {
            user.sendEmailVerification { error in
                if let error = error {
                    print("❌ Failed to resend verification email: \(error.localizedDescription)")
                } else {
                    print("📧 Verification email resent to \(user.email ?? "")")
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
