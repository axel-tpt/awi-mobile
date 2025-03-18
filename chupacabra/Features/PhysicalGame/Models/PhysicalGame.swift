import Foundation

public struct PhysicalGame: Decodable, Identifiable {
    public let id: Int
    public let barcode: String
    public let price: Double
    public let status: PhysicalGameStatus
    public let commissionApplied: Double
    public let gameId: Int
    public let depositId: Int

    public init(id: Int, barcode: String, price: Double, status: PhysicalGameStatus, commissionApplied: Double, gameId: Int, depositId: Int) {
        self.id = id
        self.barcode = barcode
        self.price = price
        self.status = status
        self.commissionApplied = commissionApplied
        self.gameId = gameId
        self.depositId = depositId
    }
}

public struct FullPhysicalGame: Decodable, Identifiable {
    public let id: Int
    public let barcode: String
    public let price: Double
    public let status: PhysicalGameStatus
    public let commissionApplied: Double
    public let gameId: Int
    public let depositId: Int
    public let game: FullGame

    public init(id: Int, barcode: String, price: Double, status: PhysicalGameStatus, commissionApplied: Double, gameId: Int, depositId: Int, game: FullGame) {
        self.id = id
        self.barcode = barcode
        self.price = price
        self.status = status
        self.commissionApplied = commissionApplied
        self.gameId = gameId
        self.depositId = depositId
        self.game = game
    }
}


public enum PhysicalGameStatus: String, Decodable {
    case DEPOSITED = "deposited"
    case FOR_SALE = "for_sale"
    case SOLD = "sold"
    case FORGOTTEN = "forgotten"
    case RECOVERED = "recovered"
}
