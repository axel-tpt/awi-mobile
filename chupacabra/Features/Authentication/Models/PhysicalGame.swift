import Foundation

public struct PhysicalGame: Decodable {
    let id: Int
    let barcode: String
    let price: Int
    let status: PhysicalGameStatus
    let commissionApplied: Int
    let gameId: Int
    let despositId: Int
}

public struct FullPhysicalGame: Decodable {
    let id: Int
    let barcode: String
    let price: Int
    let status: PhysicalGameStatus
    let commissionApplied: Int
    let gameId: Int
    let despositId: Int
    let game: Game
}

public enum PhysicalGameStatus: String, Decodable {
    case DEPOSITED = "deposited"
    case FOR_SALE = "for_sale"
    case SOLD = "sold"
    case FORGOTTEN = "forgotten"
    case RECOVERED = "recovered"
}
