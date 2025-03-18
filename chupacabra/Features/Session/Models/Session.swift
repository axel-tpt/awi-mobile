import Foundation

public struct Session: Decodable, Identifiable {
    public let id: Int
    public let commissionRate: Double
    public let depositFeesRate: Double
    public let startDateDeposit: Date
    public let endDateDeposit: Date
    public let startDateSelling: Date
    public let endDateSelling: Date
}

public struct SessionForm: Encodable {
    public let commissionRate: Double
    public let depositFeesRate: Double
    public let startDateDeposit: Date
    public let endDateDeposit: Date
    public let startDateSelling: Date
    public let endDateSelling: Date
}
