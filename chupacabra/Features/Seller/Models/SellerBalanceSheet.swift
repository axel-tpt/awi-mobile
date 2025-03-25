import Foundation

public struct SellerBalanceSheet: Codable {
    let credit: Double
    let gamesForSale: Int
    let possibleGain: Double
    let gamesToWithdraw: Int
    let valueToWithdraw: Double
    let totalFeesForDeposits: Double
} 