import Foundation
import Combine
import SwiftUI
import JWTDecode

class GameViewModel: ObservableObject {
    @Published var filter: Filter = .empty
    @Published private(set) var forSaleGames: [FullGame] = []
    @Published private(set) var games: [FullGame] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    private let gameService: GameServiceProtocol
    
    init(gameService: GameServiceProtocol = GameService()) {
        self.gameService = gameService
    }
    
    public func loadForSaleGames() {
        self.gameService.getForSaleGames(filter: self.filter)
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: { completion in
               if case .failure(let error) = completion {
                   self.state = .error(error.localizedDescription)
               }
           }, receiveValue: { [weak self] (response: [FullGame]) in
               guard let self = self else { return }
               self.forSaleGames = response
           })
           .store(in: &cancellables)
    }
    
    public func loadGames() {
        self.gameService.getGames()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: [FullGame]) in
                guard let self = self else { return }
                self.games = response
            })
            .store(in: &cancellables)
    }
    
    public func applyFilter(filter: Filter) {
        self.filter = filter
        self.loadForSaleGames()
    }
    
    public func getGameById(id: Int) -> FullGame? {
        return games.first { $0.id == id }
    }
    
    func createGame(game: GameCreate) {
        self.gameService.createGame(game: game)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: EmptyResponse) in
                guard self != nil else { return }
            })
            .store(in: &cancellables)
    }
}
