import Foundation
import Combine

public enum AuthError: Error {
    case networkError(Error)
    case decodingError
    case serverError(statusCode: Int, underlyingError: Error)
    case unknownError(Error)
}

public protocol AuthServiceProtocol {
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, AuthError>
}

public final class AuthService: AuthServiceProtocol {
    
    public func login(email: String, password: String) -> AnyPublisher<AuthResponse, AuthError> {
        let body = ["email": email, "password": password]
        
        return APIService.fetch(endpoint: "/auth/login", method: .post, body: body)
            .mapError { error -> AuthError in
                print("Erreur capturée : \(error)")

                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
