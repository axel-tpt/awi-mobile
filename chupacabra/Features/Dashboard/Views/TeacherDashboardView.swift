import SwiftUI

struct TeacherDashboardView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Teaching")) {
                    NavigationLink(destination: Text("My Courses")) {
                        Label("My Courses", systemImage: "book.fill")
                    }
                    
                    NavigationLink(destination: Text("Create Course")) {
                        Label("Create Course", systemImage: "plus.circle")
                    }
                }
                
                Section(header: Text("Students")) {
                    NavigationLink(destination: Text("Student List")) {
                        Label("Student Management", systemImage: "person.3")
                    }
                    
                    NavigationLink(destination: Text("Grades")) {
                        Label("Grade Management", systemImage: "chart.bar")
                    }
                }
                
                Section(header: Text("Resources")) {
                    NavigationLink(destination: Text("Course Materials")) {
                        Label("Course Materials", systemImage: "folder")
                    }
                    
                    NavigationLink(destination: Text("Assignments")) {
                        Label("Assignments", systemImage: "list.bullet.clipboard")
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
            .navigationTitle("Teacher Dashboard")
        }
    }
} 