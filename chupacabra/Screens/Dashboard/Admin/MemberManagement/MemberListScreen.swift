import SwiftUI

struct Member: Identifiable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let permissionLevel: String
}

struct MemberListScreen: View {
    @State private var members: [Member] = [
        Member(id: 1, email: "admin@example.com", firstName: "Jean", lastName: "Dupont", permissionLevel: "Administrateur"),
        Member(id: 2, email: "manager@example.com", firstName: "Marie", lastName: "Martin", permissionLevel: "Manager"),
        Member(id: 3, email: "user@example.com", firstName: "Pierre", lastName: "Durand", permissionLevel: "Utilisateur")
    ]
    
    @State private var showingCreateSheet = false
    @State private var selectedMember: Member? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(members) { member in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("\(member.firstName) \(member.lastName)")
                                .font(.headline)
                            Spacer()
                            Menu {
                                Button {
                                    selectedMember = member
                                } label: {
                                    Label("Modifier", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    deleteMember(id: member.id)
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
                            Text(member.permissionLevel)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 8)
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
                NavigationStack {
                    Text("Créer un nouveau membre")
                        .navigationTitle("Nouveau Membre")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    showingCreateSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedMember) { member in
                NavigationStack {
                    Text("Modifier le membre \(member.firstName) \(member.lastName)")
                        .navigationTitle("Modifier Membre")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    selectedMember = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func deleteMember(id: Int) {
        members.removeAll { $0.id == id }
    }
}

struct MemberListScreen_Previews: PreviewProvider {
    static var previews: some View {
        MemberListScreen()
    }
} 