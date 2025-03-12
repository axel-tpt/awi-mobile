import Foundation
import Combine

enum AuthState: Equatable {
    case idle
    case authenticating
    case authenticated(User)
    case error(String)
    
    static func == (lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.authenticating, .authenticating):
            return true
        case (.authenticated(let user1), .authenticated(let user2)):
            return user1.id == user2.id
        case (.error(let error1), .error(let error2)):
            return error1 == error2
        default:
            return false
        }
    }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published private(set) var state: AuthState = .idle
    @Published var email = ""
    @Published var password = ""
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            state = .error("Please fill in all fields")
            return
        }
        
        state = .authenticating
        
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] response in
                // self?.state = .authenticated(response.user)
                // Ici, vous pourriez sauvegarder le token dans le Keychain
            }
            .store(in: &cancellables)
    }
}
