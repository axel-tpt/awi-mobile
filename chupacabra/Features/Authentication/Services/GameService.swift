import Foundation
import Combine
import SwiftUI
import JWTDecode

public protocol GameServiceProtocol {
    func loadForSaleGames() -> AnyPublisher<[FullGame], AuthError>
    func loadGames() -> AnyPublisher<[FullGame], AuthError>
    func applyFilter(filter: Filter)
    func getGameById(id: Int) -> FullGame?
    func createGame(game: GameCreate) -> AnyPublisher<FullGame, AuthError>
}

public final class GameService: GameServiceProtocol {

    public func loadForSaleGames() -> AnyPublisher<[FullGame], AuthError> {
        
    }
    public func loadGames() -> AnyPublisher<[FullGame], AuthError>
    public func applyFilter(filter: Filter)
    func getGameById(id: Int) -> FullGame?
    func createGame(game: GameCreate) -> AnyPublisher<FullGame, AuthError>
}
