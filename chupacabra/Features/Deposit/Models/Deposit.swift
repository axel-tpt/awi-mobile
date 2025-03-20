import Foundation

public struct Deposit: Identifiable, Codable, Equatable {
    public let id: Int
    public let date: Date
    public let feesApplied: Double
    public let sessionId: Int
    public let transactionId: Int
    public let sellerId: Int
}