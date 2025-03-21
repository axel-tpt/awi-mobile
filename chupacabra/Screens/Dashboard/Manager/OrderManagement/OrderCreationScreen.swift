import SwiftUI

struct OrderCreationScreen: View {
    @StateObject private var physicalGameViewModel: PhysicalGameViewModel = PhysicalGameViewModel()
    @StateObject private var meanPaymentViewModel: MeanPaymentViewModel = MeanPaymentViewModel()
    @StateObject private var orderViewModel: OrderViewModel = OrderViewModel()
    
    // État de la commande en cours
    @State private var selectedPhysicalsGames: [FullPhysicalGame] = []
    @State private var showingInvoiceForm = false
    @State private var orderId = -1
    @State private var searchQuery: String = ""
    @State private var selectedPaymentId: Int?
    
    // UI States
    @State private var isSearchFocused: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Search Section
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(isFocused ? .blue : .gray)
                            
                            TextField("Rechercher un jeu par code-barre", text: $searchQuery)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($isFocused)
                                .submitLabel(.search)
                            
                            if !searchQuery.isEmpty {
                                Button(action: {
                                    searchQuery = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        )
                        .padding(.horizontal)
                        .animation(.easeInOut(duration: 0.2), value: searchQuery)
                        
                        // Search results
                        if !filteredBarcodes.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(filteredBarcodes, id: \.self) { barcode in
                                        Button(action: {
                                            addPhysicalGame(by: barcode)
                                            withAnimation {
                                                isFocused = false
                                            }
                                        }) {
                                            HStack {
                                                Text(barcode)
                                                    .foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                            }
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(Color(UIColor.tertiarySystemBackground))
                                            )
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    
                    // Selected Items Section
                    if selectedPhysicalsGames.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Votre panier est vide")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text("Recherchez et ajoutez des jeux à votre commande")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                        .padding(.horizontal)
                    } else {
                        VStack(alignment: .leading) {
                            Text("Votre panier")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(selectedPhysicalsGames, id: \.barcode) { physicalGame in
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(physicalGame.game.name)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                
                                                HStack(spacing: 8) {
                                                    Label(physicalGame.barcode, systemImage: "barcode")
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Text("\(String(format: "%.2f", physicalGame.price)) €")
                                                .font(.headline)
                                                .foregroundColor(.blue)
                                            
                                            Button(action: {
                                                withAnimation {
                                                    removePhysicalGame(physicalGame)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                                    .frame(width: 32, height: 32)
                                                    .background(
                                                        Circle()
                                                            .fill(Color.red.opacity(0.1))
                                                    )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(UIColor.tertiarySystemBackground))
                                        )
                                        .padding(.horizontal)
                                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Payment & Checkout Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Total")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.2f", totalPrice)) €")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Moyen de paiement")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(meanPaymentViewModel.meansPayment, id: \.id) { payment in
                                    Button {
                                        selectedPaymentId = payment.id
                                    } label: {
                                        HStack {
                                            Text(payment.label)
                                            if selectedPaymentId == payment.id {
                                                Spacer()
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "creditcard")
                                        .foregroundColor(.blue)
                                    
                                    Text(selectedPaymentLabel)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                            }
                            .contentShape(Rectangle())
                        }
                        
                        Button(action: validateOrder) {
                            HStack {
                                Spacer()
                                
                                Image(systemName: "cart.fill.badge.plus")
                                    .font(.headline)
                                
                                Text("Valider la commande")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(checkoutButtonEnabled ? Color.blue : Color.gray.opacity(0.3))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(!checkoutButtonEnabled)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
                    )
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("Nouvelle commande")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showingInvoiceForm) {
                InvoiceFormView(orderId: self.orderId)
            }
            .onTapGesture {
                isFocused = false
            }
        }
        .onAppear {
            physicalGameViewModel.loadForSalePhysicalGamesBarcodes()
            meanPaymentViewModel.loadMeansPayment()
        }
    }
    
    // MARK: - Computed Properties
    
    private var totalPrice: Double {
        selectedPhysicalsGames.reduce(0) { $0 + $1.price }
    }
    
    private var filteredBarcodes: [String] {
        let barcodes = physicalGameViewModel.forSalePhysicalGamesBarcodes
        let selectedBarcodes = selectedPhysicalsGames.map { $0.barcode }
        return barcodes.filter { !selectedBarcodes.contains($0) }
            .filter { searchQuery.isEmpty || $0.lowercased().contains(searchQuery.lowercased()) }
    }
    
    private var selectedPaymentLabel: String {
        if let id = selectedPaymentId,
           let payment = meanPaymentViewModel.meansPayment.first(where: { $0.id == id }) {
            return payment.label
        }
        return "Sélectionner un moyen de paiement"
    }
    
    private var checkoutButtonEnabled: Bool {
        return !selectedPhysicalsGames.isEmpty && selectedPaymentId != nil
    }
    
    // MARK: - Functions
    
    private func validateOrder() {
        if let pid = self.selectedPaymentId {
            print("Commande validée avec \(selectedPhysicalsGames.count) jeux, total: \(totalPrice)€")
            let body = OrderRequest(
                physicalGameIds: self.selectedPhysicalsGames.map { $0.id },
                meanPaymentId: pid
            )
            orderViewModel.sendOrder(body: body)
            self.showingInvoiceForm = true
            self.selectedPhysicalsGames = []
        } else {
            print("Mean Payment isn't selected")
        }
    }
    
    private func addPhysicalGame(by barcode: String) {
        physicalGameViewModel.loadPhysicalGameByBarcode(barcode: barcode, onSuccess: {
            if let physicalGame = physicalGameViewModel.physicalGameByBarcode {
                withAnimation {
                    selectedPhysicalsGames.append(physicalGame)
                }
            }
            searchQuery = ""
        })
    }
    
    private func removePhysicalGame(_ game: FullPhysicalGame) {
        selectedPhysicalsGames.removeAll { $0.barcode == game.barcode }
    }
}

struct InvoiceFormView: View {
    @StateObject private var orderViewModel: OrderViewModel = OrderViewModel()
    
    @Environment(\.dismiss) var dismiss
    @State private var buyerLastName: String = ""
    @State private var buyerFirstName: String = ""
    @State private var buyerEmail: String = ""
    @State private var buyerAddress: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case lastName, firstName, email, address
    }
    
    var orderId: Int
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                            )
                        
                        Text("Informations de facturation")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Ces informations seront utilisées pour générer la facture client")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Nom")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Dupont", text: $buyerLastName)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                                .focused($focusedField, equals: .lastName)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .firstName
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                                Text("Prénom")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("Jean", text: $buyerFirstName)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                                .focused($focusedField, equals: .firstName)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .email
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.blue)
                                Text("Email")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("jean.dupont@example.com", text: $buyerEmail)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .address
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text("Adresse")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            TextField("123 rue de Paris, 75001 Paris", text: $buyerAddress)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(UIColor.tertiarySystemBackground))
                                )
                                .focused($focusedField, equals: .address)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Bottom Buttons
                    VStack(spacing: 12) {
                        Button {
                            if allFieldsFilled() {
                                alertMessage = "Commande terminée avec facture !"
                                showAlert = true
                                sendInvoice()
                            } else {
                                alertMessage = "Veuillez remplir tous les champs."
                                showAlert = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "doc.fill.badge.plus")
                                Text("Envoyer une facture")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(allFieldsFilled() ? Color.blue : Color.gray.opacity(0.3))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(!allFieldsFilled())
                        
                        Button {
                            alertMessage = "Commande terminée sans facture !"
                            showAlert = true
                        } label: {
                            Text("Passer")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.tertiarySystemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
                    )
                }
                .padding(.bottom, 8)
            }
            .navigationTitle("Facturation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        
                        Button("Terminé") {
                            focusedField = nil
                        }
                    }
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { dismiss() }
            }
        }
    }
    
    // Function to check if all fields are filled
    func allFieldsFilled() -> Bool {
        return !buyerLastName.isEmpty && !buyerFirstName.isEmpty && !buyerEmail.isEmpty && !buyerAddress.isEmpty
    }
    
    // Function to send the invoice
    func sendInvoice() {
        let body = InvoiceRequest(
            buyerEmail: buyerEmail,
            buyerAddress: buyerAddress,
            buyerFirstName: buyerFirstName,
            buyerLastName: buyerLastName,
            transactionId: orderId
        )
        orderViewModel.sendInvoice(body: body)
    }
}

struct OrderCreationScreen_Previews: PreviewProvider {
    static var previews: some View {
        OrderCreationScreen()
    }
}
