import Foundation
import Combine
import SwiftUI
import JWTDecode

class PhysicalGameViewModel: ObservableObject {
    @Published private(set) var state: AuthState = .idle
    @Published var email = ""
    @Published var password = ""
    
    private let authService: AuthServiceProtocol
    private let tokenService: TokenServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService(), tokenService: TokenServiceProtocol = TokenService()) {
        self.authService = authService
        self.tokenService = tokenService
    }
    
    func getPhysicalGamesNotLabeled() {
        
    }
    
    func getPhysicalGamesByBarcode(barcode : String) {
        
    }
    
    func bulkUpdatePhysicalGamesStatus(ids: [Int], status: PhysicalGameStatus) {
        
    }
    
    func getForSalePhysicalGamesBarcodes() {
        
    }
}
