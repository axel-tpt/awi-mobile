import SwiftUI

struct EmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct GameLabellingScreen: View {
    
    @StateObject private var physicalGameViewModel: PhysicalGameViewModel = PhysicalGameViewModel()
    
    @State private var selectedGames: Set<Int> = []
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Etiquettage et mise en vente des jeux")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                    Button(action: labelSelectedGames) {
                        Label("Mettre en vente", systemImage: "tag")
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedGames.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(8)
                    }
                    .disabled(selectedGames.isEmpty ||  self.physicalGameViewModel.isLoading)
                    .padding(.trailing)
                }
                .padding(.vertical)
                
                Divider()
                
                if self.physicalGameViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.top, 100)
                } else if physicalGameViewModel.physicalGamesNotLabeled.isEmpty {
                    EmptyStateView(
                        title: "Aucun jeu à étiqueter",
                        systemImage: "tag.slash",
                        description: "Tous les jeux ont déjà été étiquetés"
                    )
                } else {
                    List {
                        ForEach(physicalGameViewModel.physicalGamesNotLabeled, id: \.id) { game in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(game.game.name)
                                        .font(.headline)
                                    Text("Code barre: \(game.barcode)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Prix: \(game.price, specifier: "%.2f") €")
                                        .font(.subheadline)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: Binding(
                                    get: { selectedGames.contains(game.id) },
                                    set: { newValue in
                                        if newValue {
                                            selectedGames.insert(game.id)
                                        } else {
                                            selectedGames.remove(game.id)
                                        }
                                    }
                                ))
                                .labelsHidden()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Étiquetage des jeux")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            self.physicalGameViewModel.loadPhysicalGamesNotLabeled()
        }
    }
    
    private func labelSelectedGames() {
        self.physicalGameViewModel.bulkUpdatePhysicalGamesStatus(ids: Array(selectedGames), status: .FOR_SALE, onSuccess: {
            self.physicalGameViewModel.loadPhysicalGamesNotLabeled()
        })
    }
}

struct GameLabellingScreen_Previews: PreviewProvider {
    static var previews: some View {
        GameLabellingScreen()
    }
} 
