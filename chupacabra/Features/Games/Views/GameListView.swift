import SwiftUI

struct GameListView: View {
    @StateObject private var viewModel = GamesViewModel()
    
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 300), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 50)
                } else if let error = viewModel.error {
                    VStack {
                        Text("Erreur de chargement")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Réessayer") {
                            Task {
                                await viewModel.loadGames()
                            }
                        }
                        .padding()
                    }
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.games) { game in
                            GameCardView(game: game)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Catalogue des jeux")
            .task {
                await viewModel.loadGames()
            }
        }
    }
} 