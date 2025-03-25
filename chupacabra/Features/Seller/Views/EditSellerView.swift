import SwiftUI

struct EditSellerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SellerViewModel
    
    let seller: Seller
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phone: String
    
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(seller: Seller, viewModel: SellerViewModel) {
        self.seller = seller
        self.viewModel = viewModel
        
        // Initialisation des @State avec les valeurs du vendeur
        _firstName = State(initialValue: seller.firstName)
        _lastName = State(initialValue: seller.lastName)
        _email = State(initialValue: seller.email)
        _phone = State(initialValue: seller.phone)
    }
    
    var body: some View {
        NavigationStack {
            SellerFormView(
                firstName: $firstName,
                lastName: $lastName,
                email: $email,
                phone: $phone
            )
            .navigationTitle("Modifier Vendeur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        saveSellerData()
                    }
                    .disabled(isSaving || !isFormValid())
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isSaving {
                    ProgressView("Enregistrement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    private func isFormValid() -> Bool {
        // Vérifications de base pour la validation du formulaire
        guard !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !phone.isEmpty else {
            return false
        }
        
        // Vérification simple du format de l'email
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func saveSellerData() {
        isSaving = true
        
        let sellerData = SellerForm(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone
        )
        
        viewModel.updateSeller(id: seller.id, data: sellerData, onSuccess: {
            isSaving = false
            dismiss()
        }, onError: { error in
            isSaving = false
            errorMessage = error.localizedDescription
            showError = true
        })
    }
} 