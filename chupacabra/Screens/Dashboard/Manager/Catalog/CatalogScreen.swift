import SwiftUI

struct CatalogGame: Identifiable {
    let id: Int
    let name: String
    let publisher: String
    let category: String
    let minPlayers: Int
    let maxPlayers: Int
    let duration: Int // durée en minutes
    let price: Double
    let isAvailable: Bool
    let description: String
}

struct CatalogScreen: View {
    @State private var games: [CatalogGame] = [
        CatalogGame(id: 1, name: "Catan", publisher: "Kosmos", category: "Stratégie", minPlayers: 3, maxPlayers: 4, duration: 75, price: 35.0, isAvailable: true, description: "Construisez des colonies, des routes et des villes sur l'île de Catan. Échangez et négociez pour obtenir les ressources dont vous avez besoin."),
        CatalogGame(id: 2, name: "Monopoly", publisher: "Hasbro", category: "Famille", minPlayers: 2, maxPlayers: 8, duration: 120, price: 29.99, isAvailable: true, description: "Le jeu de commerce immobilier classique où vous achetez, vendez et échangez des propriétés pour construire votre empire."),
        CatalogGame(id: 3, name: "Risk", publisher: "Hasbro", category: "Stratégie", minPlayers: 2, maxPlayers: 6, duration: 120, price: 42.50, isAvailable: false, description: "Un jeu de conquête mondiale où vous déployez vos armées pour contrôler des territoires et éliminer vos adversaires."),
        CatalogGame(id: 4, name: "Scrabble", publisher: "Mattel", category: "Mots", minPlayers: 2, maxPlayers: 4, duration: 60, price: 19.99, isAvailable: true, description: "Le jeu de mots croisés classique où vous marquez des points en formant des mots sur un plateau."),
        CatalogGame(id: 5, name: "Trivial Pursuit", publisher: "Hasbro", category: "Quiz", minPlayers: 2, maxPlayers: 6, duration: 90, price: 39.95, isAvailable: true, description: "Testez vos connaissances dans diverses catégories pour remporter des camemberts et gagner la partie.")
    ]
    
    @State private var searchText = ""
    @State private var selectedCategoryFilter: String? = nil
    @State private var showUnavailable = false
    @State private var selectedGame: CatalogGame? = nil
    
    let categories = ["Stratégie", "Famille", "Mots", "Quiz", "Ambiance"]
    
    var filteredGames: [CatalogGame] {
        games.filter { game in
            let matchesSearch = searchText.isEmpty || 
                game.name.lowercased().contains(searchText.lowercased()) ||
                game.publisher.lowercased().contains(searchText.lowercased()) ||
                game.category.lowercased().contains(searchText.lowercased())
            
            let matchesCategory = selectedCategoryFilter == nil || game.category == selectedCategoryFilter
            
            let matchesAvailability = showUnavailable || game.isAvailable
            
            return matchesSearch && matchesCategory && matchesAvailability
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Rechercher un jeu", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Filtres
                VStack(spacing: 10) {
                    // Filtre de catégorie
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                selectedCategoryFilter = nil
                            } label: {
                                Text("Toutes")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategoryFilter == nil ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategoryFilter == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                Button {
                                    selectedCategoryFilter = category
                                } label: {
                                    Text(category)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedCategoryFilter == category ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedCategoryFilter == category ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Toggle pour afficher les jeux non disponibles
                    Toggle("Afficher les jeux non disponibles", isOn: $showUnavailable)
                        .padding(.horizontal)
                        .toggleStyle(.switch)
                }
                
                // Liste des jeux
                List {
                    ForEach(filteredGames) { game in
                        Button {
                            selectedGame = game
                        } label: {
                            HStack {
                                // Image du jeu (simulée)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Text(String(game.name.prefix(1)))
                                            .font(.title)
                                            .foregroundColor(.white)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(game.name)
                                            .font(.headline)
                                        
                                        if !game.isAvailable {
                                            Text("Indisponible")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 5)
                                                .padding(.vertical, 2)
                                                .background(Color.red)
                                                .cornerRadius(4)
                                        }
                                    }
                                    
                                    Text(game.publisher)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text(game.category)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(5)
                                        
                                        Text("\(game.minPlayers)-\(game.maxPlayers) joueurs")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(game.duration) min")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(game.price, specifier: "%.2f") €")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Catalogue des jeux")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(item: $selectedGame) { game in
                gameDetailView(game: game)
            }
        }
    }
    
    private func gameDetailView(game: CatalogGame) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête
                    VStack(alignment: .center, spacing: 15) {
                        // Image du jeu (simulée)
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Text(String(game.name.prefix(1)))
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                            )
                        
                        Text(game.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(game.publisher)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    // Disponibilité
                    HStack {
                        Spacer()
                        if game.isAvailable {
                            Text("Disponible")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(8)
                        } else {
                            Text("Indisponible")
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Détails du jeu
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Nombre de joueurs")
                                    .font(.headline)
                                Text("\(game.minPlayers) à \(game.maxPlayers)")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Durée")
                                    .font(.headline)
                                Text("\(game.duration) minutes")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Prix")
                                .font(.headline)
                            Text("\(game.price, specifier: "%.2f") €")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .bold()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Détails du jeu")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        selectedGame = nil
                    }
                }
            }
        }
    }
}

struct CatalogScreen_Previews: PreviewProvider {
    static var previews: some View {
        CatalogScreen()
    }
} 