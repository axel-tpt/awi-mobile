import SwiftUI
import Combine
import JWTDecode

class LoggedUserEnvironment: ObservableObject {
    @Published var loggedUser: LoggedUser?
    private let tokenService: TokenServiceProtocol
    
    init(tokenService: TokenServiceProtocol = TokenService()) {
        self.tokenService = tokenService
        self.loggedUser = nil
        loadUserFromToken()
        
        // S'abonner aux notifications d'expiration de token
        APIService.subscribeToTokenExpiration(observer: self, selector: #selector(handleTokenExpiration))
    }
    
    deinit {
        // Se désabonner des notifications
        APIService.unsubscribeFromTokenExpiration(observer: self)
    }
    
    // Gestionnaire d'expiration de token
    @objc func handleTokenExpiration() {
        DispatchQueue.main.async { [weak self] in
            self?.logout()
        }
    }
    
    func loadUserFromToken() {
        guard let token = tokenService.getToken() else { return }
        
        do {
            let decodedToken = try decode(jwt: token)
            
            if let expiryDate = decodedToken.expiresAt, expiryDate < Date() {
                tokenService.deleteToken()
                loggedUser = nil
                return
            }
            
            let userId = decodedToken["id"].integer
            let permissionLevel = PermissionLevel(rawValue: decodedToken["permissionLevel"].integer ?? -1)
            
            guard let userId = userId, let permissionLevel = permissionLevel else {
                print("Failed to decode JWT: Missing userId or permissionLevel")
                return
            }
            
            self.loggedUser = LoggedUser(
                id: userId,
                permissionLevel: permissionLevel
            )
        } catch {
            print("Failed to decode JWT: \(error.localizedDescription)")
            tokenService.deleteToken()
        }
    }
    
    func logout() {
        tokenService.deleteToken()
        loggedUser = nil
    }
}