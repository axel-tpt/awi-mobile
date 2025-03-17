import SwiftUI

struct Session: Identifiable {
    let id: Int
    let commissionRate: Double
    let depositFeesRate: Double
    let startDateDeposit: String
    let endDateDeposit: String
    let startDateSelling: String
    let endDateSelling: String
}

struct SessionListScreen: View {
    @State private var sessions: [Session] = [
        Session(id: 1, commissionRate: 10.0, depositFeesRate: 5.0, startDateDeposit: "01/06/2023", endDateDeposit: "05/06/2023", startDateSelling: "10/06/2023", endDateSelling: "15/06/2023"),
        Session(id: 2, commissionRate: 15.0, depositFeesRate: 7.5, startDateDeposit: "20/07/2023", endDateDeposit: "25/07/2023", startDateSelling: "01/08/2023", endDateSelling: "10/08/2023"),
        Session(id: 3, commissionRate: 12.5, depositFeesRate: 6.0, startDateDeposit: "15/09/2023", endDateDeposit: "20/09/2023", startDateSelling: "25/09/2023", endDateSelling: "05/10/2023")
    ]
    
    @State private var showingCreateSheet = false
    @State private var selectedSession: Session? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("ID: \(session.id)")
                                .font(.headline)
                            Spacer()
                            Menu {
                                Button {
                                    selectedSession = session
                                } label: {
                                    Label("Modifier", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    deleteSession(id: session.id)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Commission: \(session.commissionRate, specifier: "%.1f")%")
                        Text("Frais de dépôt: \(session.depositFeesRate, specifier: "%.1f")%")
                        
                        Group {
                            Text("Période de dépôt:")
                                .font(.subheadline)
                            Text("\(session.startDateDeposit) - \(session.endDateDeposit)")
                                .foregroundColor(.secondary)
                        }
                        
                        Group {
                            Text("Période de vente:")
                                .font(.subheadline)
                            Text("\(session.startDateSelling) - \(session.endDateSelling)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Sessions")
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
                    Text("Créer une nouvelle session")
                        .navigationTitle("Nouvelle Session")
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    showingCreateSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedSession) { session in
                NavigationStack {
                    Text("Modifier la session \(session.id)")
                        .navigationTitle("Modifier Session")
                        #if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        #endif
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    selectedSession = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func deleteSession(id: Int) {
        sessions.removeAll { $0.id == id }
    }
}

struct SessionListScreen_Previews: PreviewProvider {
    static var previews: some View {
        SessionListScreen()
    }
} 