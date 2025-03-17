import SwiftUI

struct CatalogScreen: View {
    
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var categoryViewModel: CategoryViewModel = CategoryViewModel()
    
    @State private var searchText = ""
    @State private var selectedCategoryFilter: Category? = nil
    @State private var showUnavailable = false
    @State private var selectedGame: FullGame? = nil
    
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
                .onChange(of: searchText) { newValue in
                    applyFilters()
                }
                
                // Filtres
                VStack(spacing: 10) {
                    // Filtre de catégorie
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                selectedCategoryFilter = nil
                                applyFilters()
                            } label: {
                                Text("Toutes")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategoryFilter == nil ? Color.blue : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedCategoryFilter == nil ? .white : .primary)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(categoryViewModel.categories, id: \.self) { category in
                                Button {
                                    selectedCategoryFilter = category
                                    applyFilters()
                                } label: {
                                    Text(category.name)
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
                }
                
                // Liste des jeux
                List {
                    ForEach(gameViewModel.forSaleGames) { game in
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
                                    }
                                    
                                    Text(game.publisher.name)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Text(game.category.name)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(5)
                                        
                                        Text("\(game.minimumPlayersNumber)-\(game.maximumPlayersNumber) joueurs")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
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
        .onAppear {
            self.gameViewModel.loadForSaleGames()
            self.categoryViewModel.loadCategories()
        }
    }
    
    private func applyFilters() {
        gameViewModel.applyFilter(filter: Filter(
            gameName: searchText.isEmpty ? nil : searchText,
            publisherName: nil,
            categoryName: selectedCategoryFilter?.name,
            playerNumber: nil,
            minimumPrice: nil,
            maximumPrice: nil
        ))
    }
    
    private func gameDetailView(game: FullGame) -> some View {
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
                        
                        Text(game.publisher.name)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Détails du jeu
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Nombre de joueurs")
                                    .font(.headline)
                                Text("\(game.minimumPlayersNumber) à \(game.maximumPlayersNumber)")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Prix")
                                .font(.headline)
                            Text("\(game.minimumPrice, specifier: "%.2f") €")
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
