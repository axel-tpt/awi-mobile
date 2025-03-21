import Foundation

public struct turnoverStatisticsResponse: Decodable {
    let profit: Double
    let profitEvolution: [ProfitEvolution]
}

struct ProfitEvolution: Decodable {
    let week: String
    let profit: Double
}

public struct financialStatementResponse: Decodable {
    let moneyOwed: Double
    let numberOfPhysicalGamesForSale: Int
    let valueOfPhysicalGamesForSale: Double
    let turnoverPossible: Double
    let turnoverOfThisYear: Double
}

public struct sellsByCategory: Decodable, Identifiable {
    let category: String
    let sells: Int
    public var id: String { category }
}

public struct topSellerResponse: Decodable {
    let seller: Seller
    let sales: Int
}

public struct Seller: Decodable, Identifiable {
    public let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
}
