import Foundation
import Combine
import SwiftUI
import JWTDecode

public protocol CategoryServiceProtocol {
    func getCategories() -> AnyPublisher<[Category], AuthError>
}

public final class CategoryService: CategoryServiceProtocol {
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    
    public func getCategories() -> AnyPublisher<[Category], AuthError> {
        return APIService.fetch(
            endpoint: "categories",
            method: .get
        )
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
