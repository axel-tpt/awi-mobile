import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        if case .authenticated(let user) = authViewModel.state {
            switch user.role {
            case .admin:
                AdminDashboardView(authViewModel: authViewModel)
            case .manager:
                ManagerDashboardView(authViewModel: authViewModel)
            }
        } else {
            LoginView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
