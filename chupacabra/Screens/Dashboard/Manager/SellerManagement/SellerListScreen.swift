import SwiftUI
import Combine

struct SellerListScreen: View {
    @ObservedObject private var viewModel = SellerViewModel()
    @State private var searchText = ""
    @State private var showingCreateSheet = false
    
    var filteredSellers: [Seller] {
        if searchText.isEmpty {
            return viewModel.sellers
        } else {
            return viewModel.sellers.filter { seller in
                seller.firstName.lowercased().contains(searchText.lowercased()) ||
                seller.lastName.lowercased().contains(searchText.lowercased()) ||
                seller.email.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.sellers.isEmpty {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(error: error)
                } else if viewModel.sellers.isEmpty {
                    emptyStateView
                } else {
                    sellerListView
                }
            }
            .navigationTitle("Vendeurs")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher un vendeur")
            .sheet(isPresented: $showingCreateSheet) {
                CreateSellerView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadSellers()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        ProgressView("Chargement des vendeurs...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(error: RequestError) -> some View {
        VStack(spacing: 16) {
            Text("Erreur: \(error.localizedDescription)")
                .foregroundColor(.red)
            
            Button("Réessayer") {
                viewModel.loadSellers()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("Aucun vendeur disponible")
                .font(.headline)
            
            Button("Ajouter un vendeur") {
                showingCreateSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var addButton: some View {
        Button {
            showingCreateSheet = true
        } label: {
            Label("Ajouter", systemImage: "plus")
        }
    }
    
    private var sellerListView: some View {
        List {
            ForEach(filteredSellers) { seller in
                NavigationLink(destination: SellerDetailScreen(viewModel: viewModel, sellerId: seller.id)) {
                    SellerRowView(seller: seller)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.deleteSeller(id: seller.id)
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                    
                    NavigationLink(destination: EditSellerView(seller: seller, viewModel: viewModel)) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.loadSellers()
        }
    }
}

// MARK: - Extracted Components

struct SellerRowView: View {
    let seller: Seller
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(seller.firstName) \(seller.lastName)")
                .font(.headline)
            
            Text(seller.email)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(seller.phone)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct SellerListScreen_Previews: PreviewProvider {
    static var previews: some View {
        SellerListScreen()
    }
} 
