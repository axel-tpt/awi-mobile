import SwiftUI
import Combine

struct SellerDetailScreen: View {
    @ObservedObject var viewModel: SellerViewModel
    @State private var showCreateDeposit = false
    @State private var showGamesList = false
    let sellerId: Int
    
    // Calcule le vendeur actuel à partir du viewModel à chaque fois qu'il change
    private var seller: Seller? {
        viewModel.sellers.first(where: { $0.id == sellerId })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else if let seller = seller {
                    actionButtonsSection
                    
                    sellerInfoSection(seller: seller)
                    
                    if let balanceSheet = viewModel.balanceSheet {
                        statisticsSection(balanceSheet: balanceSheet)
                    } else {
                        Text("Chargement des statistiques...")
                            .padding()
                    }
                    
                    if !viewModel.deposits.isEmpty {
                        depositsSection(deposits: viewModel.deposits)
                    } else {
                        Text("Aucun dépôt trouvé")
                            .padding()
                    }
                } else {
                    Text("Impossible de trouver le vendeur")
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Détails du vendeur")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if let seller = seller {
                    NavigationLink(destination: EditSellerView(seller: seller, viewModel: viewModel)) {
                        Label("Modifier", systemImage: "pencil")
                    }
                }
            }
        }
        .onAppear {
            loadBalanceSheet()
            loadDeposits()
        }
        .sheet(isPresented: $showCreateDeposit) {
            if let seller = seller {
                CreateDepositScreen(
                    viewModel: DepositViewModel(),
                    sellerViewModel: viewModel,
                    sellerId: sellerId
                )
            }
        }
        .sheet(isPresented: $showGamesList) {
            SellerGamesListScreen(sellerId: sellerId)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadBalanceSheet() {
        viewModel.loadSellerBalanceSheet(for: sellerId)
    }
    
    private func loadDeposits() {
        viewModel.loadSellerDeposits(for: sellerId)
    }
    
    // MARK: - UI Components
    
    private var loadingView: some View {
        ProgressView("Chargement des informations...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 100)
    }
    
    private func errorView(error: RequestError) -> some View {
        VStack(spacing: 16) {
            Text("Erreur: \(error.localizedDescription)")
                .foregroundColor(.red)
            
            Button("Réessayer") {
                loadBalanceSheet()
                loadDeposits()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func sellerInfoSection(seller: Seller) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Informations personnelles")
                .font(.headline)
                .padding(.bottom, 8)
            
            infoRow(label: "Prénom", value: seller.firstName)
            infoRow(label: "Nom", value: seller.lastName)
            infoRow(label: "Email", value: seller.email)
            infoRow(label: "Téléphone", value: seller.phone)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func statisticsSection(balanceSheet: SellerBalanceSheet) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiques")
                .font(.headline)
                .padding(.bottom, 8)
            
            infoRow(label: "Crédit", value: "\(String(format: "%.2f", balanceSheet.credit)) €")
            infoRow(label: "Jeux en vente", value: "\(balanceSheet.gamesForSale)")
            infoRow(label: "Gains possibles", value: "\(String(format: "%.2f", balanceSheet.possibleGain)) €")
            infoRow(label: "Jeux à retirer", value: "\(balanceSheet.gamesToWithdraw)")
            infoRow(label: "Valeur à retirer", value: "\(String(format: "%.2f", balanceSheet.valueToWithdraw)) €")
            infoRow(label: "Frais de dépôt", value: "\(String(format: "%.2f", balanceSheet.totalFeesForDeposits)) €")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func depositsSection(deposits: [Deposit]) -> some View {
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter
        }()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Dépôts")
                .font(.headline)
                .padding(.bottom, 8)
            
            ForEach(deposits) { deposit in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Dépôt #\(deposit.id)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    
                    let formattedDate = dateFormatter.string(from: deposit.date)
                    infoRow(label: "Date", value: formattedDate)
                    infoRow(label: "Taux frais de dépôt", value: "\(String(format: "%.2f", deposit.feesApplied))")
                    
                    Divider()
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button("Créer un dépôt") {
                showCreateDeposit = true
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: .blue))
            
            Button("Liste des jeux") {
                showGamesList = true
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: .orange))
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Views
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .padding()
            .background(backgroundColor.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(8)
    }
}

struct SellerDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SellerDetailScreen(viewModel: SellerViewModel(), sellerId: 1)
        }
    }
} 
