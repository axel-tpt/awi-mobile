import Foundation
import Combine
import SwiftUI
import JWTDecode

enum AuthState: Equatable {
    case idle
    case authenticating
    case authenticated
    case error(String)
}

@MainActor
class AuthViewModel: ObservableObject {
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
    
    func login(with loggedUserVM: LoggedUserEnvironment) {
        guard !email.isEmpty, !password.isEmpty else {
            state = .error("Please fill in all fields")
            return
        }
        
        state = .authenticating
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (completion: Subscribers.Completion<AuthError>) in
                if case .failure(let error) = completion {
                    self?.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] (response: AuthResponse) in
                guard let self = self else { return }
                self.tokenService.saveToken(response.accessToken)
                
                do {
                    let decodedToken = try decode(jwt: response.accessToken)
                    let userId = decodedToken["id"].integer
                    let permissionLevel = PermissionLevel(rawValue: decodedToken["permissionLevel"].integer ?? -1)
                    
                    guard let userId = userId, let permissionLevel = permissionLevel else {
                        self.state = .error("Failed to decode JWT: Missing userId or permissionLevel")
                        return
                    }
                    
                    self.state = .authenticated
                    loggedUserVM.loggedUser = LoggedUser(
                        id: userId,
                        permissionLevel: permissionLevel
                    )
                } catch {
                    self.state = .error("Failed to decode JWT: \(error.localizedDescription)")
                }
            }
            .store(in: &cancellables)
    }
    
    func logout() {
        tokenService.deleteToken()
        state = .idle
        email = ""
        password = ""
    }
}
