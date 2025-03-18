import Foundation

// Structure locale pour éviter les ambiguïtés
public struct ImportedGame: Decodable, Identifiable {
    public let id: Int
    public let name: String
    public let publisher: String
    public let category: String
    public let minPlayers: Int
    public let maxPlayers: Int
    public let duration: Int
    public let price: Double
    
    public init(id: Int, name: String, publisher: String, category: String, minPlayers: Int, maxPlayers: Int, duration: Int, price: Double) {
        self.id = id
        self.name = name
        self.publisher = publisher
        self.category = category
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.duration = duration
        self.price = price
    }
}

public struct PhysicalGame: Decodable, Identifiable {
    public let id: Int
    public let barcode: String
    public let price: Double
    public let isLabellingDone: Bool
    public let isSold: Bool
    
    public init(id: Int, barcode: String, price: Double, isLabellingDone: Bool, isSold: Bool) {
        self.id = id
        self.barcode = barcode
        self.price = price
        self.isLabellingDone = isLabellingDone
        self.isSold = isSold
    }
}

public struct FullPhysicalGame: Decodable {
    public let id: Int
    public let barcode: String
    public let price: Double
    public let game: ImportedGame
    public let isLabellingDone: Bool
    public let isSold: Bool
    
    public init(id: Int, barcode: String, price: Double, game: ImportedGame, isLabellingDone: Bool, isSold: Bool) {
        self.id = id
        self.barcode = barcode
        self.price = price
        self.game = game
        self.isLabellingDone = isLabellingDone
        self.isSold = isSold
    }
}

public enum PhysicalGameStatus: String, Decodable {
    case DEPOSITED = "deposited"
    case FOR_SALE = "for_sale"
    case SOLD = "sold"
    case FORGOTTEN = "forgotten"
    case RECOVERED = "recovered"
}
