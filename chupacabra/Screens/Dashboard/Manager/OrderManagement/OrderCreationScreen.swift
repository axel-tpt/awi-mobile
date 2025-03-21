import SwiftUI

struct OrderCreationScreen: View {
    @StateObject private var physicalGameViewModel: PhysicalGameViewModel = PhysicalGameViewModel()
    @StateObject private var orderViewModel: OrderViewModel = OrderViewModel()
    
    // État de la commande en cours
    @State private var selectedPhysicalsGames: [FullPhysicalGame] = []
    @State private var showingInvoiceForm = false
    @State private var orderId = -1
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack {
                    TextField("Rechercher un jeu", text: $searchQuery)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !filteredBarcodes.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(filteredBarcodes, id: \.self) { barcode in
                                    Text(barcode)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            addPhysicalGame(by: barcode)
                                        }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                
                List {
                    ForEach(selectedPhysicalsGames, id: \.barcode) { physicalGame in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("📦 \(physicalGame.game.name)")
                                    .font(.headline)
                                Text("🔖 \(physicalGame.barcode)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("💰 \(String(format: "%.2f", physicalGame.price)) €")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                removePhysicalGame(physicalGame)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                Spacer()
                
                // Section Prix total + Validation
                VStack {
                    HStack {
                        Text("Total:")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text("\(String(format: "%.2f", totalPrice)) €")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Button(action: validateOrder) {
                        Text("Valider la commande")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedPhysicalsGames.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(selectedPhysicalsGames.isEmpty)
                }
                .background(Color(UIColor.systemBackground))
                .shadow(radius: 5)
            }
            .navigationTitle("Créer une commande")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showingInvoiceForm) {
                InvoiceFormView(orderId: self.orderId)
            }
        }
        .onAppear {
            physicalGameViewModel.loadForSalePhysicalGamesBarcodes()
        }
    }
    
    private var totalPrice: Double {
        selectedPhysicalsGames.reduce(0) { $0 + $1.price }
    }
    
    private func validateOrder() {
        // Action pour valider la commande
        print("Commande validée avec \(selectedPhysicalsGames.count) jeux, total: \(totalPrice)€")
    }
    
    private var filteredBarcodes: [String] {
        let barcodes = physicalGameViewModel.forSalePhysicalGamesBarcodes
        let selectedBarcodes = selectedPhysicalsGames.map { $0.barcode }
        return barcodes.filter { !selectedBarcodes.contains($0) }
            .filter { searchQuery.isEmpty || $0.lowercased().contains(searchQuery.lowercased()) }
    }
    
    private func addPhysicalGame(by barcode: String) {
        physicalGameViewModel.loadPhysicalGameByBarcode(barcode: barcode)
        if let physicalGame = physicalGameViewModel.physicalGameByBarcode {
            selectedPhysicalsGames.append(physicalGame)
        }
        searchQuery = "" // Réinitialise la recherche après sélection
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
    
    var orderId: Int
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    TextField("Nom du client", text: $buyerLastName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    TextField("Prénom du client", text: $buyerFirstName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    TextField("Email du client", text: $buyerEmail)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    TextField("Adresse du client", text: $buyerAddress)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }
                
                Spacer()
                
                // Button to send the invoice
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
                    Text("Envoyer une facture")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(allFieldsFilled() ? Color.blue : Color.gray)  // Change button color based on validation
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(!allFieldsFilled())  // Disable button if fields are empty
                
                Button {
                    alertMessage = "Commande terminée sans facture !"
                    showAlert = true
                } label: {
                    Text("Passer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Facturation")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Passer") { dismiss() }
                }
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
