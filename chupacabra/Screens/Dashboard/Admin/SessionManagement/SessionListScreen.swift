import SwiftUI
import Combine

struct SessionListScreen: View {
    @StateObject private var viewModel = SessionViewModel()
    @State private var showingCreateSheet = false
    @State private var selectedSession: Session? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Chargement des sessions...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Text("Erreur: \(error)")
                            .foregroundColor(.red)
                        
                        Button("Réessayer") {
                            loadSessions()
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
                CreateSessionView()
            }
            .sheet(item: $selectedSession) { session in
                EditSessionView(session: session)
            }
        }
        .onAppear {
            loadSessions()
        }
        .onReceive(viewModel.$state) { state in
            switch state {
            case .idle:
                isLoading = false
                errorMessage = nil
            case .loading, .loadingCurrent, .creating, .updating, .deleting:
                isLoading = true
                errorMessage = nil
            case .loaded(_):
                isLoading = false
                errorMessage = nil
            case .currentLoaded(_):
                isLoading = false
                errorMessage = nil
            case .error(let message):
                isLoading = false
                errorMessage = message
            }
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
            loadSessions()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func loadSessions() {
        viewModel.loadSessions()
    }
    
    private func deleteSession(id: Int) {
        viewModel.deleteSession(id: id)
    }
}

#Preview {
    SessionListScreen()
} 
