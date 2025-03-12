import SwiftUI

struct StudentDashboardView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("My Learning")) {
                    NavigationLink(destination: Text("Enrolled Courses")) {
                        Label("My Courses", systemImage: "book")
                    }
                    
                    NavigationLink(destination: Text("Available Courses")) {
                        Label("Course Catalog", systemImage: "list.bullet")
                    }
                }
                
                Section(header: Text("Progress")) {
                    NavigationLink(destination: Text("My Grades")) {
                        Label("Grades", systemImage: "chart.bar")
                    }
                    
                    NavigationLink(destination: Text("Assignments")) {
                        Label("Assignments", systemImage: "doc.text")
                    }
                }
                
                Section(header: Text("Resources")) {
                    NavigationLink(destination: Text("Course Materials")) {
                        Label("Course Materials", systemImage: "folder")
                    }
                    
                    NavigationLink(destination: Text("Calendar")) {
                        Label("Calendar", systemImage: "calendar")
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Label("Logout", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Student Dashboard")
        }
    }
} 