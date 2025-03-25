import Foundation
import Combine
import SwiftUI

@MainActor
class DepositViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var games: [ApiGame] = []
    @Published private(set) var meansOfPayment: [MeanPayment] = []
    @Published private(set) var isSubmitting = false
    
    // Pour le formulaire
    @Published var selectedGames: [PhysicalGameForm] = []
    @Published var feesApplied: Double = 0
    @Published var commissionApplied: Double = 0
    @Published var selectedMeanPaymentId: Int? = nil
    
    // Pour l'ajout d'un jeu
    @Published var currentGameId: Int? = nil
    @Published var currentGamePrice: Double = 0
    @Published var currentGameQuantity: Int = 1
    
    // Suggestions filtrées
    @Published var filteredGameSuggestions: [GameSuggestion] = []
    
    private let depositService: DepositServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(depositService: DepositServiceProtocol = DepositService()) {
        self.depositService = depositService
    }
    
    func loadGames(
        onSuccess: (() -> Void)? = nil,
        onError: ((RequestError) -> Void)? = nil
    ) {
        handlePublisher(
            depositService.getGames(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { games in
                self.games = games
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadMeansOfPayment(
        onSuccess: (() -> Void)? = nil,
        onError: ((RequestError) -> Void)? = nil
    ) {
        handlePublisher(
            depositService.getMeansOfPayment(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { meansOfPayment in
                self.meansOfPayment = meansOfPayment
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func createDeposit(
        sellerId: Int,
        onSuccess: (() -> Void)? = nil,
        onError: ((RequestError) -> Void)? = nil
    ) {
        guard !selectedGames.isEmpty, let meanPaymentId = selectedMeanPaymentId else {
            return
        }
        
        let depositForm = SellerCreateDeposit(
            feesApplied: feesApplied / 100,
            commissionApplied: commissionApplied / 100,
            meanPaymentId: meanPaymentId,
            physicalGames: selectedGames
        )
        
        isSubmitting = true
        
        handlePublisher(
            depositService.createDeposit(data: depositForm, sellerId: sellerId),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.isSubmitting = false
                onSuccess?()
            },
            onError: { error in
                self.isSubmitting = false
                onError?(error)
            }
        )
    }
    
    func addGame() {
        guard let gameId = currentGameId, currentGamePrice > 0, currentGameQuantity > 0 else {
            return
        }
        
        let newGame = PhysicalGameForm(
            gameId: gameId,
            price: currentGamePrice,
            quantity: currentGameQuantity
        )
        
        selectedGames.append(newGame)
        
        // Réinitialiser les champs
        currentGameId = nil
        currentGamePrice = 0
        currentGameQuantity = 1
    }
    
    func removeGame(at index: Int) {
        guard index >= 0 && index < selectedGames.count else {
            return
        }
        selectedGames.remove(at: index)
    }
    
    func filterGames(query: String) {
        if query.isEmpty {
            filteredGameSuggestions = []
            return
        }
        
        let lowercasedQuery = query.lowercased()
        filteredGameSuggestions = games
            .filter { $0.name.lowercased().contains(lowercasedQuery) }
            .map { GameSuggestion(gameId: $0.id, fullName: $0.name) }
    }
    
    func getGameById(_ id: Int) -> ApiGame? {
        return games.first { $0.id == id }
    }
    
    var totalDepositValue: Double {
        selectedGames.reduce(0) { total, game in
            total + (game.price * Double(game.quantity))
        }
    }
    
    var totalFeesAmount: Double {
        return (totalDepositValue * feesApplied) / 100.0
    }
    
    func sellerGainFor(price: Double) -> Double {
        return price - (price * commissionApplied / 100.0)
    }
} 
