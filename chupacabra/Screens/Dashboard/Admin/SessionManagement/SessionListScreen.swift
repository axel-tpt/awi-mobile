import SwiftUI
import Combine

struct SessionListScreen: View {
    @StateObject private var viewModel = SessionViewModel()
    @State private var showingCreateSheet = false
    @State private var selectedSession: Session? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Chargement des sessions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                        
                        Button("Réessayer") {
                            viewModel.loadSessions()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.sessions.isEmpty {
                    VStack(spacing: 16) {
                        Text("Aucune session disponible")
                            .font(.headline)
                        
                        Button("Créer une session") {
                            showingCreateSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    sessionListView
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
                CreateSessionView(viewModel: viewModel)
            }
            .sheet(item: $selectedSession) { session in
                EditSessionView(session: session, viewModel: viewModel)
            }
        }
        .onAppear {
            loadSessions()
        }
    }
    
    private var sessionListView: some View {
        List {
            ForEach(viewModel.sessions) { session in
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
                                viewModel.deleteSession(id: session.id)
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
                        Text("\(formattedDate(session.startDateDeposit)) - \(formattedDate(session.endDateDeposit))")
                            .foregroundColor(.secondary)
                    }
                    
                    Group {
                        Text("Période de vente:")
                            .font(.subheadline)
                        Text("\(formattedDate(session.startDateSelling)) - \(formattedDate(session.endDateSelling))")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .refreshable {
            viewModel.loadSessions()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    SessionListScreen()
} 
