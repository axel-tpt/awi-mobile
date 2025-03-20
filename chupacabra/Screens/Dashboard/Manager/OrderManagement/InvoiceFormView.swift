import SwiftUI

struct InvoiceFormView2: View {
    @Environment(\.dismiss) var dismiss
    @State private var buyerLastName: String = ""
    @State private var buyerFirstName: String = ""
    @State private var buyerEmail: String = ""
    @State private var buyerAddress: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                Button {
                    alertMessage = "Commande terminée avec facture !"
                    showAlert = true
                } label: {
                    Text("Envoyer une facture")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Passer") { dismiss() }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}

struct InvoiceFormView_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceFormView()
    }
}
