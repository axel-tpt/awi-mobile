import Foundation

public struct ApiGame: Decodable {
    let id: Int
    let name: String
    let minimumPrice: Int
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
}

public struct FullGame: Decodable, Identifiable {
    public let id: Int
    let name: String
    let minimumPrice: Int
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
    let category: Category
    let publisher: Publisher
}

public struct GameCreate: Encodable {
    let name: String
    let minimumPlayersNumber: Int
    let maximumPlayersNumber: Int
    let categoryId: Int
    let publisherId: Int
}

public struct Filter: Encodable {
    let gameName: String?
    let publisherName: String?
    let categoryName: Category?
    let playerNumber: Int?
    let minimumPrice: Int?
    let maximumPrice: Int?
    
    static let empty = Filter(gameName: nil, publisherName: nil, categoryName: nil, playerNumber: nil, minimumPrice: nil, maximumPrice: nil)
}
