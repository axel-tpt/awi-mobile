import SwiftUI

enum OrderStatus: String, CaseIterable {
    case pending = "En attente"
    case preparing = "En préparation"
    case ready = "Prêt"
    case completed = "Terminé"
    case cancelled = "Annulé"
    
    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .preparing:
            return .blue
        case .ready:
            return .green
        case .completed:
            return .gray
        case .cancelled:
            return .red
        }
    }
}

struct OrderItem: Identifiable {
    let id: Int
    let gameName: String
    let price: Double
    var quantity: Int
}

struct Order: Identifiable {
    let id: Int
    let orderNumber: String
    let customerName: String
    let date: String
    var status: OrderStatus
    var items: [OrderItem]
    var totalAmount: Double
    
    // Calculer le montant total à partir des éléments
    var calculatedTotal: Double {
        items.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

struct Game: Identifiable {
    let id: Int
    let name: String
    let price: Double
    let imageURL: String
    let inStock: Int
}

struct OrderCreationScreen: View {
    @StateObject private var gameViewModel: GameViewModel = GameViewModel()
    
    // État de la commande en cours
    @State private var customerName: String = ""
    @State private var selectedItems: [OrderItem] = []
    @State private var searchText: String = ""
    
    // État de l'interface
    @State private var showingConfirmation = false
    @State private var selectedTab = 0
    
    var totalAmount: Double {
        selectedItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Information client - Toujours visible en haut
                customerInfoView
                    .padding(.bottom, 8)
                
                // TabView pour basculer entre catalogue et panier
                TabView(selection: $selectedTab) {
                    catalogView
                        .tag(0)
                    
                    cartView
                        .tag(1)
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #else
                .tabViewStyle(.automatic)
                #endif
                
                // Barre d'onglets personnalisée
                HStack(spacing: 0) {
                    tabButton(title: "Catalogue", systemImage: "square.grid.2x2", tag: 0)
                    
                    tabButton(
                        title: "Panier (\(selectedItems.count))",
                        systemImage: "cart",
                        tag: 1,
                        showBadge: !selectedItems.isEmpty
                    )
                }
                .padding(.top, 8)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .top
                )
            }
            .navigationTitle("Créer une commande")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert("Confirmer la commande", isPresented: $showingConfirmation) {
                Button("Annuler", role: .cancel) {}
                Button("Confirmer") {
                    createOrder()
                }
            } message: {
                Text("Créer une commande pour \(customerName) avec \(selectedItems.count) article(s) pour un total de \(totalAmount, specifier: "%.2f") € ?")
            }
        }
        .onAppear {
            gameViewModel.loadForSaleGames()
        }
    }
    
    private func applyFilters() {
        gameViewModel.applyFilter(filter: Filter(
            gameName: searchText.isEmpty ? nil : searchText,
            publisherName: nil,
            categoryName: nil,
            playerNumber: nil,
            minimumPrice: nil,
            maximumPrice: nil
        ))
    }
    
    private var customerInfoView: some View {
        VStack(spacing: 8) {
            TextField("Nom du client", text: $customerName)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
            
            if !selectedItems.isEmpty {
                HStack {
                    Text("\(selectedItems.count) article(s)")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Total: \(totalAmount, specifier: "%.2f") €")
                        .bold()
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var catalogView: some View {
        VStack(spacing: 0) {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Rechercher un jeu", text: $searchText)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .onChange(of: searchText) { newValue in
                        applyFilters()
                    }
                }
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding([.horizontal, .top])
            
            // Catalogue de jeux
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ForEach(gameViewModel.forSaleGames) { game in
                        GameCardView(game: game, onAdd: {
                            addGameToOrder(game)
                            // Feedback tactile et visuel
                            #if os(iOS)
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            #endif
                        })
                    }
                }
                .padding()
            }
        }
    }
    
    private var cartView: some View {
        VStack {
            if selectedItems.isEmpty {
                emptyCartView
            } else {
                cartContentView
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Votre panier est vide")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button {
                selectedTab = 0
            } label: {
                Text("Parcourir le catalogue")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // Liste des articles
            List {
                ForEach(selectedItems) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.gameName)
                                .font(.headline)
                            
                            Text("\(item.price, specifier: "%.2f") € l'unité")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if item.quantity > 1 {
                                    updateQuantity(for: item.id, to: item.quantity - 1)
                                } else {
                                    if let index = selectedItems.firstIndex(where: { $0.id == item.id }) {
                                        selectedItems.remove(at: index)
                                    }
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            
                            Text("\(item.quantity)")
                                .font(.headline)
                                .frame(minWidth: 30, alignment: .center)
                            
                            Button(action: {
                                updateQuantity(for: item.id, to: item.quantity + 1)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title3)
                            }
                            
                            Text("\(item.price * Double(item.quantity), specifier: "%.2f") €")
                                .frame(width: 80, alignment: .trailing)
                                .font(.headline)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: removeItems)
            }
            .listStyle(.plain)
            
            // Bouton de validation
            VStack(spacing: 16) {
                Divider()
                
                HStack {
                    Text("Total à payer")
                        .font(.headline)
                    Spacer()
                    Text("\(totalAmount, specifier: "%.2f") €")
                        .font(.title3)
                        .bold()
                }
                .padding(.horizontal)
                
                Button {
                    showingConfirmation = true
                } label: {
                    Text("Valider la commande")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customerName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(customerName.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .background(Color.white)
        }
    }
    
    private func tabButton(title: String, systemImage: String, tag: Int, showBadge: Bool = false) -> some View {
        Button {
            selectedTab = tag
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 24))
                    
                    if showBadge && tag == 1 {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                            .offset(x: 10, y: -10)
                    }
                }
                
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selectedTab == tag ? .blue : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
    
    private func addGameToOrder(_ game: FullGame) {
        if let index = selectedItems.firstIndex(where: { $0.id == game.id }) {
            // Le jeu est déjà dans le panier, augmenter la quantité
            updateQuantity(for: game.id, to: selectedItems[index].quantity + 1)
        } else {
            // Ajouter le jeu au panier
            let newItem = OrderItem(id: game.id, gameName: game.name, price: game.minimumPrice, quantity: 1)
            selectedItems.append(newItem)
        }
    }
    
    private func updateQuantity(for itemId: Int, to newQuantity: Int) {
        if let index = selectedItems.firstIndex(where: { $0.id == itemId }) {
            selectedItems[index].quantity = newQuantity
        }
    }
    
    private func removeItems(at offsets: IndexSet) {
        selectedItems.remove(atOffsets: offsets)
    }
    
    private func createOrder() {
        // Générer un numéro de commande unique
        let orderNumber = "CMD-\(Date().formatted(.dateTime.year()))-\(Int.random(in: 100...999))"
        
        // Créer une nouvelle commande
        let newOrder = Order(
            id: Int.random(in: 1000...9999),
            orderNumber: orderNumber,
            customerName: customerName,
            date: Date().formatted(.dateTime.day().month().year()),
            status: .pending,
            items: selectedItems,
            totalAmount: totalAmount
        )
        
        // Ici, vous pourriez envoyer la commande à un serveur ou la sauvegarder localement
        print("Commande créée: \(newOrder)")
        
        // Réinitialiser le formulaire
        customerName = ""
        selectedItems = []
    }
}

struct GameCardView: View {
    let game: FullGame
    let onAdd: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            // Placeholder pour l'image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    Text(game.name.prefix(1))
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(game.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text("\(game.minimumPrice, specifier: "%.2f") €")
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                }
                
                Button {
                    onAdd()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Ajouter")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct OrderCreationScreen_Previews: PreviewProvider {
    static var previews: some View {
        OrderCreationScreen()
    }
} 
