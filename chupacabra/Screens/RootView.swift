import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if case .authenticated(let user) = authViewModel.state {
                switch user.role {
                case .admin:
                    AdminDashboardView(authViewModel: authViewModel)
                case .teacher:
                    TeacherDashboardView(authViewModel: authViewModel)
                case .student:
                    StudentDashboardView(authViewModel: authViewModel)
                }
            } else {
                LoginView()
            }
        }
    }
}

struct RootPreview: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
