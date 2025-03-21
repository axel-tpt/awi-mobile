import SwiftUI

struct SellerGamesListScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SellerGamesViewModel()
    @State private var searchText = ""
    @State private var selectedStatus: PhysicalGameStatus? = nil
    @State private var selectedGames: Set<Int> = []
    @State private var showingAlert = false
    @State private var isSubmitting = false
    
    let sellerId: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Retour")
                    }
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Jeux du vendeur")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Retirer")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(selectedGames.isEmpty ? Color.gray.opacity(0.5) : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                .disabled(selectedGames.isEmpty || isSubmitting)
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            // Search and filter
            VStack(spacing: 10) {
                TextField("Rechercher par nom", text: $searchText)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                HStack {
                    Text("Filtrer par statut:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Menu {
                        Button("Tous") {
                            selectedStatus = nil
                        }
                        
                        ForEach(PhysicalGameStatus.allCases, id: \.self) { status in
                            Button(status.formatted) {
                                selectedStatus = status
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedStatus?.formatted ?? "Tous")
                            Image(systemName: "chevron.down")
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // Games list
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
                Spacer()
            } else if filteredGames.isEmpty {
                Spacer()
                Text("Aucun jeu trouvé")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(filteredGames, id: \.id) { game in
                        HStack {
                            if game.status == .DEPOSITED || game.status == .FOR_SALE {
                                Button(action: {
                                    toggleGameSelection(game.id)
                                }) {
                                    Image(systemName: selectedGames.contains(game.id) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(selectedGames.contains(game.id) ? .blue : .gray)
                                }
                            } else {
                                Spacer()
                                    .frame(width: 24)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(game.game.name)
                                    .font(.headline)
                                    .lineLimit(1)
                                
                                HStack {
                                    StatusBadge(status: game.status)
                                    
                                    if game.status != .DEPOSITED {
                                        Text(game.barcode)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadSellerGames(sellerId: sellerId)
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("Voulez-vous vraiment retirer ces \(selectedGames.count) jeux ?"),
                primaryButton: .destructive(Text("Retirer")) {
                    withdrawSelectedGames()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private var filteredGames: [FullPhysicalGame] {
        viewModel.sellerGames.filter { game in
            let matchesSearch = searchText.isEmpty || 
                               game.game.name.lowercased().contains(searchText.lowercased())
            let matchesStatus = selectedStatus == nil || game.status == selectedStatus
            
            return matchesSearch && matchesStatus
        }
    }
    
    private func toggleGameSelection(_ gameId: Int) {
        if selectedGames.contains(gameId) {
            selectedGames.remove(gameId)
        } else {
            selectedGames.insert(gameId)
        }
    }
    
    private func withdrawSelectedGames() {
        isSubmitting = true
        viewModel.withdrawSellerGames(
            gameIds: Array(selectedGames),
            sellerId: sellerId,
            onSuccess: {
                isSubmitting = false
                selectedGames = []
                // Recharger la liste des jeux
                viewModel.loadSellerGames(sellerId: sellerId)
            },
            onError: { _ in
                isSubmitting = false
            }
        )
    }
}

// Structure du badge de statut pour afficher le statut du jeu
struct StatusBadge: View {
    let status: PhysicalGameStatus
    
    var body: some View {
        Text(status.formatted)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .DEPOSITED:
            return .blue
        case .FOR_SALE:
            return .green
        case .SOLD:
            return .orange
        case .FORGOTTEN:
            return .red
        case .RECOVERED:
            return .purple
        }
    }
}

// Preview
struct SellerGamesListScreen_Previews: PreviewProvider {
    static var previews: some View {
        SellerGamesListScreen(sellerId: 1)
    }
} 