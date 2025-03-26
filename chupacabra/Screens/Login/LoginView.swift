import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loggedUserVM: LoggedUserEnvironment
    @StateObject private var viewModel: AuthViewModel

    init() {
        let authVM = AuthViewModel()
        authVM.email = ""
        authVM.password = "Test0202!"
        _viewModel = StateObject(wrappedValue: authVM)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Chupacabra")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(spacing: 15) {
                CustomTextField("Email", text: $viewModel.email)
                CustomTextField("Mot de passe", text: $viewModel.password, isSecure: true)
            }
            .padding(.horizontal)
            
            if case .error(let message) = viewModel.state {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: {
                viewModel.login(with: self.loggedUserVM)
            }) {
                if case .authenticating = viewModel.state {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Se connecter")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.state == .authenticating)
        }
        .padding()
    }
}
