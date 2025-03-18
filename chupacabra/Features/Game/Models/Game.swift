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
    let categoryName: String?
    let playerNumber: Int?
    let minimumPrice: Int?
    let maximumPrice: Int?
    
    static let empty = Filter(gameName: nil, publisherName: nil, categoryName: nil, playerNumber: nil, minimumPrice: nil, maximumPrice: nil)
    
    func toQueryParameters() -> [String: String]? {
        var params: [String: String] = [:]
        
        if let gameName = self.gameName {
            params["name"] = gameName
        }
        
        if let publisherName = self.publisherName {
            params["publisherName"] = publisherName
        }
        
        if let categoryName = self.categoryName {
            params["categoryName"] = categoryName
        }
        
        if let playerNumber = self.playerNumber {
            params["playerNumber"] = "\(playerNumber)"
        }
        
        if let minimumPrice = self.minimumPrice {
            params["minPrice"] = "\(minimumPrice)"
        }
        
        if let maximumPrice = self.maximumPrice {
            params["maxPrice"] = "\(maximumPrice)"
        }
        
        return params.isEmpty ? nil : params
    }
}
