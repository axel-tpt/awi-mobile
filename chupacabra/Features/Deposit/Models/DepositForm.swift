import Foundation

public struct SellerCreateDeposit: Encodable {
    public let feesApplied: Double
    public let commissionApplied: Double
    public let meanPaymentId: Int
    public let physicalGames: [PhysicalGameForm]
}

public struct PhysicalGameForm: Encodable {
    public let gameId: Int
    public let price: Double
    public let quantity: Int
}

public struct GameSuggestion: Identifiable, Equatable {
    public let id = UUID()
    public let gameId: Int
    public let fullName: String
}

