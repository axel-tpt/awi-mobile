import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 15) {
                        CustomTextField("First Name", text: $viewModel.firstName)
                        CustomTextField("Last Name", text: $viewModel.lastName)
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
                        viewModel.register()
                    }) {
                        if case .authenticating = viewModel.state {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(viewModel.state == .authenticating)
                    
                    Button("Already have an account? Sign In") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding()
            }
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 