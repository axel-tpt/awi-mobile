import Foundation

@MainActor
class GamesViewModel: ObservableObject {
    @Published private(set) var games: [FullGame] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    func loadGames() async {
        isLoading = true
        error = nil
        
        do {
            games = try await APIService.shared.fetch("/games/for-sale")
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
} 