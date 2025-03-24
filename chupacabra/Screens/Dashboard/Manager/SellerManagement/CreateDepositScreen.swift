import SwiftUI
import Combine

struct CreateDepositScreen: View {
    @ObservedObject var viewModel: DepositViewModel
    @ObservedObject var sellerViewModel: SellerViewModel
    @StateObject private var sessionViewModel = SessionViewModel()
    let sellerId: Int
    @Environment(\.dismiss) private var dismiss
    
    // Pour la recherche de jeux
    @State private var searchQuery = ""
    @State private var showGameSearchResults = true // Toujours montrer les suggestions
    
    // État pour la validation du formulaire
    @State private var showErrors = false
    
    // État pour le formulaire d'ajout de jeu
    @State private var showAddGameForm = false
    
    // État pour suivre l'étape actuelle du formulaire
    @State private var currentStep = 0
    
    // Calculs des données du vendeur
    private var seller: Seller? {
        sellerViewModel.sellers.first(where: { $0.id == sellerId })
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header avec les étapes
            stepperHeader
            
            if viewModel.isLoading || sellerViewModel.isLoading || sessionViewModel.isLoading {
                loadingView
            } else if let error = viewModel.error ?? sellerViewModel.error ?? sessionViewModel.error {
                errorView(error: error)
            } else {
                // Contenu principal basé sur l'étape actuelle
                TabView(selection: $currentStep) {
                    // Étape 1: Information du vendeur et ajout de jeux
                    gameSelectionStep
                        .tag(0)
                    
                    // Étape 2: Configuration des frais
                    feesConfigurationStep
                        .tag(1)
                    
                    // Étape 3: Récapitulatif et validation
                    finalReviewStep
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .simultaneousGesture(DragGesture()) // Désactive le swipe entre onglets
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                navigationButtons
            }
        }
        .navigationTitle("Nouveau dépôt")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddGameForm) {
            addGameFormView
        }
        .onAppear {
            loadData()
        }
    }
    
    // MARK: - Stepper Header
    
    private var stepperHeader: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0..<3) { step in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(currentStep >= step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Text("\(step + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        Text(stepTitle(for: step))
                            .font(.caption)
                            .foregroundColor(currentStep >= step ? .primary : .secondary)
                    }
                    
                    if step < 2 {
                        Rectangle()
                            .fill(currentStep > step ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            .padding([.horizontal, .top])
            
            Divider()
        }
    }
    
    private func stepTitle(for step: Int) -> String {
        switch step {
        case 0: return "Jeux"
        case 1: return "Frais"
        case 2: return "Récap"
        default: return ""
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button(action: {
                    currentStep -= 1
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Précédent")
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            if currentStep < 2 {
                Button(action: {
                    if validateCurrentStep() {
                        currentStep += 1
                    }
                }) {
                    HStack {
                        Text("Suivant")
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            } else {
                Button(action: {
                    submitDeposit()
                }) {
                    HStack {
                        Text(viewModel.isSubmitting ? "Création en cours..." : "Valider le dépôt")
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(viewModel.isSubmitting ? Color.gray : Color.green)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isSubmitting)
            }
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: -5)
    }
    
    // MARK: - Step 1: Game Selection
    
    private var gameSelectionStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Carte d'information du vendeur
                sellerInfoCard
                
                // Section jeux sélectionnés
                selectedGamesSection
                
                // Bouton d'ajout de jeu
                addGameButton
            }
            .padding()
        }
    }
    
    // MARK: - Step 2: Fees Configuration
    
    private var feesConfigurationStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                feesSection
                paymentSection
            }
            .padding()
        }
    }
    
    // MARK: - Step 3: Final Review
    
    private var finalReviewStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Récapitulatif du vendeur
                sellerInfoCard
                
                // Récapitulatif des jeux
                VStack(alignment: .leading, spacing: 10) {
                    Text("Jeux inclus")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    ForEach(viewModel.selectedGames.indices, id: \.self) { index in
                        let game = viewModel.selectedGames[index]
                        let gameInfo = viewModel.getGameById(game.gameId)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(gameInfo?.name ?? "Jeu #\(game.gameId)")
                                    .fontWeight(.medium)
                                Text("\(game.quantity) × \(game.price, specifier: "%.2f")€")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(game.price * Double(game.quantity), specifier: "%.2f")€")
                                .fontWeight(.semibold)
                        }
                        
                        if index < viewModel.selectedGames.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Récapitulatif des frais
                VStack(alignment: .leading, spacing: 10) {
                    Text("Frais appliqués")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Text("Frais de dépôt")
                        Spacer()
                        Text("\(viewModel.feesApplied, specifier: "%.2f")%")
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Commission sur ventes")
                        Spacer()
                        Text("\(viewModel.commissionApplied, specifier: "%.2f")%")
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Moyen de paiement")
                        Spacer()
                        if let paymentId = viewModel.selectedMeanPaymentId,
                           let payment = viewModel.meansOfPayment.first(where: { $0.id == paymentId }) {
                            Text(payment.label)
                                .fontWeight(.medium)
                        } else {
                            Text("Non spécifié")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Totaux
                totalSection
            }
            .padding()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        viewModel.loadGames()
        viewModel.loadMeansOfPayment()
        if sellerViewModel.sellers.isEmpty {
            sellerViewModel.loadSellers()
        }
        
        // Charger les paramètres de session et initialiser les taux par défaut
        sessionViewModel.loadCurrentSession(
            onSuccess: { session in
                // Utiliser les valeurs de la session courante
                viewModel.feesApplied = session.depositFeesRate * 100
                viewModel.commissionApplied = session.commissionRate * 100
            },
            onError: { e in
                print(e)
            }
        )
    }
    
    // MARK: - UI Components
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Chargement des données...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: RequestError) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Erreur: \(error.localizedDescription)")
                .multilineTextAlignment(.center)
                .foregroundColor(.red)
            
            Button(action: {
                loadData()
            }) {
                Text("Réessayer")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var sellerInfoCard: some View {
        if let seller = seller {
            return AnyView(
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text("\(seller.firstName) \(seller.lastName)")
                                .font(.headline)
                            Text(seller.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !seller.phone.isEmpty {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.green)
                            Text(seller.phone)
                                .foregroundColor(.secondary)
                        }
                        .font(.footnote)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        } else {
            return AnyView(
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Vendeur non trouvé")
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
            )
        }
    }
    
    private var selectedGamesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Jeux sélectionnés")
                    .font(.headline)
                
                Spacer()
                
                Text("\(viewModel.selectedGames.count)")
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
            
            if viewModel.selectedGames.isEmpty {
                HStack {
                    Image(systemName: "tray.fill")
                        .foregroundColor(.secondary)
                    Text("Aucun jeu sélectionné")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            } else {
                ForEach(viewModel.selectedGames, id: \.gameId) { game in
                    if let gameInfo = viewModel.getGameById(game.gameId) {
                        VStack {
                            HStack(alignment: .top) {
                                Image(systemName: "gamecontroller.fill")
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(gameInfo.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    HStack {
                                        Text("Prix: \(game.price, specifier: "%.2f")€")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("•")
                                            .foregroundColor(.secondary)
                                        
                                        Text("Quantité: \(game.quantity)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.leading, 4)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(game.price * Double(game.quantity), specifier: "%.2f")€")
                                        .fontWeight(.semibold)
                                    
                                    Button(action: {
                                        withAnimation {
                                            viewModel.removeGame(at: game.gameId)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                            .padding(6)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.vertical, 8)
                            
                            Divider()
                        }
                    }
                }
            }
            
            if showErrors && viewModel.selectedGames.isEmpty {
                Text("Veuillez ajouter au moins un jeu")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var addGameButton: some View {
        Button(action: {
            showAddGameForm = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.headline)
                Text("Ajouter un jeu")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }
    
    private var addGameFormView: some View {
        NavigationView {
            Form {
                Section(header: Text("Sélection du jeu").textCase(.uppercase)) {
                    // Champ de recherche
                    TextField("Rechercher un jeu", text: $searchQuery)
                        .padding(.vertical, 8)
                        .onChange(of: searchQuery) { newValue in
                            viewModel.filterGames(query: newValue)
                        }
                        .overlay(
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.trailing),
                            alignment: .trailing
                        )
                    
                    if viewModel.currentGameId != nil {
                        HStack {
                            if let gameId = viewModel.currentGameId, 
                               let game = viewModel.getGameById(gameId) {
                                Text("Jeu sélectionné: \(game.name)")
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                viewModel.currentGameId = nil
                                searchQuery = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    
                    if !viewModel.filteredGameSuggestions.isEmpty || searchQuery.isEmpty {
                        List {
                            if searchQuery.isEmpty {
                                // Afficher les jeux récents ou populaires quand le champ est vide
                                // On utilise l'ID du jeu comme id ForEach puisque ApiGame n'est pas Identifiable
                                ForEach(viewModel.games.prefix(10).map { game in
                                    (id: game.id, game: game)
                                }, id: \.id) { pair in
                                    Button(action: {
                                        viewModel.currentGameId = pair.game.id
                                        searchQuery = pair.game.name
                                    }) {
                                        HStack {
                                            Text(pair.game.name)
                                            
                                            if viewModel.currentGameId == pair.game.id {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            } else {
                                ForEach(viewModel.filteredGameSuggestions) { suggestion in
                                    Button(action: {
                                        viewModel.currentGameId = suggestion.gameId
                                        searchQuery = suggestion.fullName
                                    }) {
                                        HStack {
                                            Text(suggestion.fullName)
                                            
                                            if viewModel.currentGameId == suggestion.gameId {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if showErrors && viewModel.currentGameId == nil {
                        Text("Veuillez sélectionner un jeu")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                }
                
                Section(header: Text("Prix et quantité").textCase(.uppercase)) {
                    HStack {
                        Text("Prix unitaire (€)")
                        Spacer()
                        TextField("0.00", value: $viewModel.currentGamePrice, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    if showErrors && viewModel.currentGamePrice <= 0 {
                        Text("Le prix doit être supérieur à 0")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    HStack {
                        Text("Quantité")
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if viewModel.currentGameQuantity > 1 {
                                    viewModel.currentGameQuantity -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .padding(8)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            TextField("1", value: $viewModel.currentGameQuantity, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 40)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                                .onChange(of: viewModel.currentGameQuantity) { newValue in
                                    // Validation pour s'assurer que la quantité est entre 1 et 99
                                    if newValue < 1 {
                                        viewModel.currentGameQuantity = 1
                                    } else if newValue > 99 {
                                        viewModel.currentGameQuantity = 99
                                    }
                                }
                            
                            Button(action: {
                                if viewModel.currentGameQuantity < 99 {
                                    viewModel.currentGameQuantity += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                                    .padding(8)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    
                    if viewModel.currentGamePrice > 0 {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gain du vendeur")
                                .font(.subheadline)
                            
                            HStack {
                                if viewModel.currentGamePrice > 0 {
                                    Text("\(viewModel.sellerGainFor(price: viewModel.currentGamePrice), specifier: "%.2f")€ par jeu vendu")
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                } else {
                                    Text("Veuillez définir un prix")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Ajouter un jeu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        resetGameForm()
                        showAddGameForm = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        let isValid = validateGameForm()
                        if isValid {
                            viewModel.addGame()
                            showAddGameForm = false
                            resetGameForm()
                        }
                    }
                    .disabled(viewModel.currentGameId == nil || viewModel.currentGamePrice <= 0)
                }
            }
        }
    }
    
    private var feesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Frais applicables")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Frais de dépôt (%)")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(viewModel.feesApplied, specifier: "%.2f")")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $viewModel.feesApplied, in: 0...50, step: 0.5)
                        .accentColor(.blue)
                }
                
                if showErrors && viewModel.feesApplied < 0 {
                    Text("Les frais ne peuvent pas être négatifs")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Commission (%)")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(viewModel.commissionApplied, specifier: "%.2f")")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                    
                    Slider(value: $viewModel.commissionApplied, in: 0...50, step: 0.5)
                        .accentColor(.blue)
                }
                
                if showErrors && viewModel.commissionApplied < 0 {
                    Text("La commission ne peut pas être négative")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mode de paiement")
                .font(.headline)
                .padding(.bottom, 5)
            
            if viewModel.meansOfPayment.isEmpty {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.secondary)
                    Text("Aucun moyen de paiement disponible")
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.meansOfPayment) { payment in
                        Button(action: {
                            viewModel.selectedMeanPaymentId = payment.id
                        }) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .foregroundColor(.blue)
                                
                                Text(payment.label)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                if viewModel.selectedMeanPaymentId == payment.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.selectedMeanPaymentId == payment.id ? Color.green : Color.gray.opacity(0.3),
                                        lineWidth: viewModel.selectedMeanPaymentId == payment.id ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                if showErrors && viewModel.selectedMeanPaymentId == nil {
                    Text("Veuillez sélectionner un moyen de paiement")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var totalSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Récapitulatif financier")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Valeur totale du dépôt")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(viewModel.totalDepositValue, specifier: "%.2f")€")
                        .fontWeight(.bold)
                }
                
                Divider()
                
                HStack {
                    Text("Frais de dépôt à régler")
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(viewModel.totalFeesAmount, specifier: "%.2f")€")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        Text("Ces frais sont à percevoir immédiatement")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Helper Methods
    
    private func resetGameForm() {
        viewModel.currentGameId = nil
        viewModel.currentGamePrice = 0
        viewModel.currentGameQuantity = 1
        searchQuery = ""
    }
    
    private func validateGameForm() -> Bool {
        showErrors = true
        
        guard viewModel.currentGameId != nil, viewModel.currentGamePrice > 0 else {
            return false
        }
        
        return true
    }
    
    private func validateCurrentStep() -> Bool {
        showErrors = true
        
        switch currentStep {
        case 0:
            return !viewModel.selectedGames.isEmpty
        case 1:
            return viewModel.feesApplied >= 0 && 
                   viewModel.commissionApplied >= 0 && 
                   viewModel.selectedMeanPaymentId != nil
        default:
            return true
        }
    }
    
    private func validateForm() -> Bool {
        showErrors = true
        
        guard !viewModel.selectedGames.isEmpty,
              viewModel.feesApplied >= 0,
              viewModel.commissionApplied >= 0,
              viewModel.selectedMeanPaymentId != nil else {
            return false
        }
        
        return true
    }
    
    private func submitDeposit() {
        if validateForm() {
            viewModel.createDeposit(
                sellerId: sellerId,
                onSuccess: {
                    // Rafraîchir les données du vendeur
                    sellerViewModel.loadSellerDeposits(for: sellerId)
                    sellerViewModel.loadSellerBalanceSheet(for: sellerId)
                    dismiss()
                }
            )
        }
    }
}
