import SwiftUI

struct RootView: View {
    @EnvironmentObject var loggedUserVM: LoggedUserViewModel
    
    var body: some View {
        switch loggedUserVM.loggedUser?.permissionLevel {
        case nil:
            LoginView()
        default:
            DashboardView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView().environmentObject(LoggedUserViewModel())
    }
}

