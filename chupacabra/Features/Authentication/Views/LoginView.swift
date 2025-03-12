import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 15) {
                    CustomTextField("Email", text: $viewModel.email)
                    CustomTextField("Password", text: $viewModel.password, isSecure: true)
                }
                .padding(.horizontal)
                
                if case .error(let message) = viewModel.state {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    viewModel.login()
                }) {
                    if case .authenticating = viewModel.state {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(viewModel.state == .authenticating)
                
                Button("Don't have an account? Sign Up") {
                    showingRegistration = true
                }
                .sheet(isPresented: $showingRegistration) {
                    RegisterView()
                }
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
} 
