import SwiftUI

struct ManagerDashboardView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Manager")) {
                    NavigationLink(destination: Text("User Management")) {
                        Label("Manage Users", systemImage: "person.2")
                    }
                    
                    NavigationLink(destination: Text("Role Management")) {
                        Label("Manage Roles", systemImage: "shield")
                    }
                }
                
                Section(header: Text("Content Management")) {
                    NavigationLink(destination: Text("Course Management")) {
                        Label("Manage Courses", systemImage: "book")
                    }
                    
                    NavigationLink(destination: Text("Resource Management")) {
                        Label("Manage Resources", systemImage: "folder")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Admin Dashboard")
        }
    }
}
