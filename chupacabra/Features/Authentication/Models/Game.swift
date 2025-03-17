import Foundation

public struct Game: Decodable {
    let id: Int
    let name: String
    let minimumPrice: Int
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
}

public struct FullGame {
    let id: Int
    let name: String
    let minimumPrice: Int
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
    let category: Category
    let publisher: Publisher
}

public struct GameCreate {
    let name: String
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
}

public struct Filter {
    let gameName: String
    let publisherName: String
    let categoryName: Category
    let playerNumber: Int
    let minimumPrice: Int
    let maximumPrice: Int
}
