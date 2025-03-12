import Foundation

struct Game: Codable, Identifiable {
    let id: Int
    let name: String
    let minimumPrice: Double
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
}

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Publisher: Codable, Identifiable {
    let id: Int
    let name: String
}

struct FullGame: Codable, Identifiable {
    let id: Int
    let name: String
    let minimumPrice: Double
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let category: Category
    let publisher: Publisher
} 