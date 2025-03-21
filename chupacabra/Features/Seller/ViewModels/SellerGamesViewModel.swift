import Foundation
import Combine
import SwiftUI

@MainActor
class SellerGamesViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var sellerGames: [FullPhysicalGame] = []
    
    private let sellerService: SellerServiceProtocol
    private let physicalGameService: PhysicalGameServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(sellerService: SellerServiceProtocol = SellerService(),
         physicalGameService: PhysicalGameServiceProtocol = PhysicalGameService()) {
        self.sellerService = sellerService
        self.physicalGameService = physicalGameService
    }
    
    func loadSellerGames(sellerId: Int,
                        onSuccess: (() -> Void)? = nil,
                        onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.getSellerPhysicalGames(id: sellerId),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { games in
                self.sellerGames = games
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func withdrawSellerGames(gameIds: [Int],
                           sellerId: Int,
                           onSuccess: (() -> Void)? = nil,
                           onError: ((RequestError) -> Void)? = nil) {
        guard !gameIds.isEmpty else {
            onSuccess?()
            return
        }
        
        handlePublisher(
            sellerService.withdrawGames(gameIds: gameIds, sellerId: sellerId),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}

// Extension pour PhysicalGameStatus pour un affichage formaté
extension PhysicalGameStatus: CaseIterable {
    public static var allCases: [PhysicalGameStatus] {
        return [.DEPOSITED, .FOR_SALE, .SOLD, .FORGOTTEN, .RECOVERED]
    }
    
    public var formatted: String {
        switch self {
        case .DEPOSITED:
            return "Déposé"
        case .FOR_SALE:
            return "En vente"
        case .SOLD:
            return "Vendu"
        case .FORGOTTEN:
            return "Oublié"
        case .RECOVERED:
            return "Récupéré"
        }
    }
} 