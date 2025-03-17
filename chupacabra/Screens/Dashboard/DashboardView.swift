import SwiftUI
import JWTDecode

struct DashboardView: View {
    @EnvironmentObject var loggedUserVM: LoggedUserEnvironment
    
    var body: some View {
        NavigationView {
            List {
                ManagerDashboardList()
                AdminDashboardList()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        loggedUserVM.logout()
                    }) {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
