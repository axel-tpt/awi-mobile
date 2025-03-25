import SwiftUI

struct AdminDashboardList: View {
    var body: some View {
        Section(header: Text("Administration")) {
            NavigationLink(destination: SessionListScreen()) {
                Label("Gestion des sessions", systemImage: "calendar")
            }
            NavigationLink(destination: MemberListScreen()) {
                Label("Gestion des employés", systemImage: "person.3")
            }
        }
    }
}
