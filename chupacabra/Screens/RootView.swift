import SwiftUI

struct RootView: View {
    @EnvironmentObject var loggedUserVM: LoggedUserViewModel
    
    var body: some View {
        switch loggedUserVM.loggedUser?.permissionLevel {
        case .manager:
            ManagerDashboardView()
        case .admin:
            AdminDashboardView()
        case nil:
            LoginView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
