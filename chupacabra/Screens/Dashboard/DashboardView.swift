import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            List {
                ManagerDashboardList()
                AdminDashboardList()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
