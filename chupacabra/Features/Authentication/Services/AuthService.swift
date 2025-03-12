import Foundation
import Combine

public enum AuthError: Error {
    case invalidCredentials
    case networkError(Error)
    case decodingError
    case unauthorized
}

public protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, AuthError>
    func register(email: String, password: String, firstName: String?, lastName: String?) -> AnyPublisher<AuthResponse, AuthError>
    func logout() -> AnyPublisher<Void, Never>
}

public final class AuthService: AuthServiceProtocol {
    private let apiService: APIService
    
    public init(apiService: APIService = APIService()) {
        self.apiService = apiService
    }
    
    public func login(email: String, password: String) -> AnyPublisher<AuthResponse, AuthError> {
        let body = ["email": email, "password": password]
        
        return apiService.request(
            endpoint: "auth/login",
            method: .post,
            body: body
        )
        .mapError { error -> AuthError in
            switch error {
            case .networkError(let error):
                return .networkError(error)
            case .decodingError:
                return .decodingError
            case .invalidResponse(let statusCode) where statusCode == 401:
                return .unauthorized
            default:
                return .networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func register(email: String, password: String, firstName: String?, lastName: String?) -> AnyPublisher<AuthResponse, AuthError> {
        var body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        if let firstName = firstName {
            body["firstName"] = firstName
        }
        if let lastName = lastName {
            body["lastName"] = lastName
        }
        
        return apiService.request(
            endpoint: "auth/register",
            method: .post,
            body: body
        )
        .mapError { error -> AuthError in
            switch error {
            case .networkError(let error):
                return .networkError(error)
            case .decodingError:
                return .decodingError
            case .invalidResponse(let statusCode) where statusCode == 401:
                return .unauthorized
            default:
                return .networkError(error)
            }
        }
        .eraseToAnyPublisher()
    }
    
    public func logout() -> AnyPublisher<Void, Never> {
        // Ici, vous pourriez ajouter un appel à l'API pour invalider le token
        return Just(()).eraseToAnyPublisher()
    }
} 