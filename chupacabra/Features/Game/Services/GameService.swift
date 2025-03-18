import Foundation
import Combine
import SwiftUI
import JWTDecode

public protocol GameServiceProtocol {
    func getGames() -> AnyPublisher<[FullGame], AuthError>
    func getForSaleGames(filter: Filter) -> AnyPublisher<[FullGame], AuthError>
    func createGame(game: GameCreate) -> AnyPublisher<EmptyResponse, AuthError>
}

public final class GameService: GameServiceProtocol {
    

    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    
    public func getForSaleGames(filter: Filter) -> AnyPublisher<[FullGame], AuthError> {
        return APIService.fetch(
            endpoint: "games/for-sale",
            method: .get,
            body: filter
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
    
    public func getGames() -> AnyPublisher<[FullGame], AuthError> {
        return APIService.fetch(
            endpoint: "games",
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
    
    public func createGame(game: GameCreate) -> AnyPublisher<EmptyResponse, AuthError> {
        return APIService.fetch(
            endpoint: "games",
            method: .post,
            body: game
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
