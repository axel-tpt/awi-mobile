import SwiftUI
import Foundation

struct MemberListScreen: View {
    @StateObject private var viewModel = MemberViewModel()
    
    @State private var showingCreateSheet = false
    @State private var selectedMember: Member? = nil
    @State private var showConfirmationDialog = false
    @State private var memberToDelete: Member? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Error view
                if let error = viewModel.error {
                    ErrorView(error: error, retryAction: {
                        viewModel.loadMembers()
                    })
                }
                
                // Loading view
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.members.isEmpty {
                    Text("Aucun membre")
                } else {
                    // Member list
                    MemberListView(
                        members: viewModel.members,
                        onEditMember: { member in
                            selectedMember = member
                        },
                        onDeleteMember: { member in
                            memberToDelete = member
                            showConfirmationDialog = true
                        }
                    )
                    .refreshable {
                        await refresh()
                    }
                }
            }
            .navigationTitle("Membres")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Label("Ajouter", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateMemberView(viewModel: viewModel)
            }
            .sheet(item: $selectedMember) { member in
                EditMemberView(member: member, viewModel: viewModel)
            }
            .confirmationDialog(
                "Êtes-vous sûr de vouloir supprimer ce membre ?",
                isPresented: $showConfirmationDialog,
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    if let member = memberToDelete {
                        deleteMember(id: member.id)
                    }
                }
                Button("Annuler", role: .cancel) {
                    memberToDelete = nil
                }
            } message: {
                if let member = memberToDelete {
                    Text("Cette action supprimera définitivement \(member.firstName) \(member.lastName).")
                }
            }
            .onAppear {
                viewModel.loadMembers()
            }
        }
    }
    
    private func deleteMember(id: Int) {
        viewModel.deleteMember(id: id)
        memberToDelete = nil
    }
    
    @MainActor
    private func refresh() async {
        viewModel.loadMembers()
    }
}

// MARK: - Subviews

struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Erreur lors du chargement des membres : " + error.localizedDescription)
            Button("Réessayer") {
                retryAction()
            }
        }.padding()
    }
}

struct MemberListView: View {
    let members: [Member]
    let onEditMember: (Member) -> Void
    let onDeleteMember: (Member) -> Void
    
    var body: some View {
        List {
            ForEach(members) { member in
                MemberRowView(
                    member: member,
                    onEdit: { onEditMember(member) },
                    onDelete: { onDeleteMember(member) }
                )
            }
        }
    }
}

struct MemberRowView: View {
    let member: Member
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(member.firstName) \(member.lastName)")
                    .font(.headline)
                Spacer()
                Menu {
                    Button {
                        onEdit()
                    } label: {
                        Label("Modifier", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.blue)
                }
            }
            
            Text("Email: \(member.email)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Rôle:")
                RoleView(permissionLevel: member.permissionLevel)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RoleView: View {
    let permissionLevel: PermissionLevel
    
    var body: some View {
        Text(permissionLevel.displayName)
            .foregroundColor(.blue)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(4)
    }
}

struct MemberListScreen_Previews: PreviewProvider {
    static var previews: some View {
        MemberListScreen()
    }
} 
