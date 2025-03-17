import Foundation
import Combine
import SwiftUI
import JWTDecode

public protocol GameServiceProtocol {
    func loadForSaleGames()
    func loadGames()
    func applyFilter(filter: Filter)
    func getGameById(id: Int) -> FullGame?
    func createGame(game: GameCreate) -> AnyPublisher<FullGame, AuthError>
}

public final class GameService: GameServiceProtocol {

    private var filter: Filter = .empty
    private var _forSaleGames: [FullGame] = []
    private var _games: [FullGame] = []
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    
    public func loadForSaleGames() {
        getForSaleGames(filter: self.filter)
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: { completion in
               if case .failure(let error) = completion {
                   self.state = .error(error.localizedDescription)
               }
           }, receiveValue: { [weak self] (response: [FullGame]) in
               guard let self = self else { return }
               self._forSaleGames = response
           })
           .store(in: &cancellables)
    }
    
    private func getForSaleGames(filter: Filter) -> AnyPublisher<[FullGame], AuthError> {
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
    
    public func loadGames() {
        getGames()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: [FullGame]) in
                guard let self = self else { return }
                self._games = response
            })
            .store(in: &cancellables)
    }
    
    private func getGames() -> AnyPublisher<[FullGame], AuthError> {
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
    
    public func applyFilter(filter: Filter) {
        self.filter = filter
        self.loadForSaleGames()
    }
    public func getGameById(id: Int) -> FullGame? {
        return _games.first { $0.id == id }

    }
    public func createGame(game: GameCreate) -> AnyPublisher<FullGame, AuthError> {
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
