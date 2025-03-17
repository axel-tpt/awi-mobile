import SwiftUI

struct Seller: Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let totalGames: Int
    let totalSoldGames: Int
}

struct SellerListScreen: View {
    @State private var sellers: [Seller] = [
        Seller(id: 1, firstName: "Jean", lastName: "Dupont", email: "jean.dupont@example.com", phone: "06 12 34 56 78", totalGames: 8, totalSoldGames: 5),
        Seller(id: 2, firstName: "Marie", lastName: "Martin", email: "marie.martin@example.com", phone: "06 23 45 67 89", totalGames: 12, totalSoldGames: 7),
        Seller(id: 3, firstName: "Pierre", lastName: "Durand", email: "pierre.durand@example.com", phone: "06 34 56 78 90", totalGames: 5, totalSoldGames: 3),
        Seller(id: 4, firstName: "Sophie", lastName: "Leroy", email: "sophie.leroy@example.com", phone: "06 45 67 89 01", totalGames: 15, totalSoldGames: 9),
        Seller(id: 5, firstName: "Lucas", lastName: "Moreau", email: "lucas.moreau@example.com", phone: "06 56 78 90 12", totalGames: 3, totalSoldGames: 1)
    ]
    
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    @State private var selectedSeller: Seller? = nil
    
    var filteredSellers: [Seller] {
        if searchText.isEmpty {
            return sellers
        } else {
            return sellers.filter { seller in
                seller.firstName.lowercased().contains(searchText.lowercased()) ||
                seller.lastName.lowercased().contains(searchText.lowercased()) ||
                seller.email.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Rechercher un vendeur", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Liste des vendeurs
                List {
                    ForEach(filteredSellers) { seller in
                        NavigationLink(destination: sellerDetailsView(seller: seller)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(seller.firstName) \(seller.lastName)")
                                    .font(.headline)
                                
                                Text(seller.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(seller.phone)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("Jeux: \(seller.totalGames)")
                                    Spacer()
                                    Text("Vendus: \(seller.totalSoldGames)")
                                    
                                    let progress = Float(seller.totalSoldGames) / Float(seller.totalGames)
                                    let color: Color = progress < 0.5 ? .orange : .green
                                    
                                    Text("\(Int(progress * 100))%")
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(color.opacity(0.2))
                                        .foregroundColor(color)
                                        .cornerRadius(4)
                                }
                                .padding(.top, 4)
                            }
                            .padding(.vertical, 4)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                removeSeller(id: seller.id)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                            
                            Button {
                                selectedSeller = seller
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Vendeurs")
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
                    Text("Créer un nouveau vendeur")
                        .navigationTitle("Nouveau Vendeur")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    showingCreateSheet = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedSeller) { seller in
                NavigationStack {
                    Text("Modifier le vendeur \(seller.firstName) \(seller.lastName)")
                        .navigationTitle("Modifier Vendeur")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Annuler") {
                                    selectedSeller = nil
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func sellerDetailsView(seller: Seller) -> some View {
        VStack {
            Text("Détails du vendeur \(seller.firstName) \(seller.lastName)")
                .font(.title2)
                .padding()
            
            List {
                Section("Informations personnelles") {
                    HStack {
                        Text("Prénom")
                        Spacer()
                        Text(seller.firstName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Nom")
                        Spacer()
                        Text(seller.lastName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(seller.email)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Téléphone")
                        Spacer()
                        Text(seller.phone)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Statistiques") {
                    HStack {
                        Text("Total des jeux")
                        Spacer()
                        Text("\(seller.totalGames)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Jeux vendus")
                        Spacer()
                        Text("\(seller.totalSoldGames)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Taux de vente")
                        Spacer()
                        let progress = Float(seller.totalSoldGames) / Float(seller.totalGames)
                        let color: Color = progress < 0.5 ? .orange : .green
                        
                        Text("\(Int(progress * 100))%")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.2))
                            .foregroundColor(color)
                            .cornerRadius(4)
                    }
                }
                
                Section {
                    Button("Créer un dépôt") {
                        // Action pour créer un dépôt
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    
                    Button("Retrait des jeux") {
                        // Action pour retirer des jeux
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(8)
                }
                .listRowInsets(EdgeInsets())
                .padding()
            }
        }
        .navigationTitle("Détails du vendeur")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func removeSeller(id: Int) {
        sellers.removeAll { $0.id == id }
    }
}

struct SellerListScreen_Previews: PreviewProvider {
    static var previews: some View {
        SellerListScreen()
    }
} 