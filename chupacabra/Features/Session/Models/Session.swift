import Foundation

public struct Session: Decodable, Identifiable {
    public let id: Int
    public let commissionRate: Double
    public let depositFeesRate: Double
    public let startDateDeposit: Date
    public let endDateDeposit: Date
    public let startDateSelling: Date
    public let endDateSelling: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case commissionRate
        case depositFeesRate
        case startDateDeposit
        case endDateDeposit
        case startDateSelling
        case endDateSelling
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        commissionRate = try container.decode(Double.self, forKey: .commissionRate)
        depositFeesRate = try container.decode(Double.self, forKey: .depositFeesRate)
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let startDateDepositString = try? container.decode(String.self, forKey: .startDateDeposit) {
            startDateDeposit = dateFormatter.date(from: startDateDepositString) ?? Date()
        } else {
            startDateDeposit = try container.decode(Date.self, forKey: .startDateDeposit)
        }
        
        if let endDateDepositString = try? container.decode(String.self, forKey: .endDateDeposit) {
            endDateDeposit = dateFormatter.date(from: endDateDepositString) ?? Date()
        } else {
            endDateDeposit = try container.decode(Date.self, forKey: .endDateDeposit)
        }
        
        if let startDateSellingString = try? container.decode(String.self, forKey: .startDateSelling) {
            startDateSelling = dateFormatter.date(from: startDateSellingString) ?? Date()
        } else {
            startDateSelling = try container.decode(Date.self, forKey: .startDateSelling)
        }
        
        if let endDateSellingString = try? container.decode(String.self, forKey: .endDateSelling) {
            endDateSelling = dateFormatter.date(from: endDateSellingString) ?? Date()
        } else {
            endDateSelling = try container.decode(Date.self, forKey: .endDateSelling)
        }
    }
    
    public init(id: Int, commissionRate: Double, depositFeesRate: Double, startDateDeposit: Date, endDateDeposit: Date, startDateSelling: Date, endDateSelling: Date) {
        self.id = id
        self.commissionRate = commissionRate
        self.depositFeesRate = depositFeesRate
        self.startDateDeposit = startDateDeposit
        self.endDateDeposit = endDateDeposit
        self.startDateSelling = startDateSelling
        self.endDateSelling = endDateSelling
    }
}

public struct SessionForm: Encodable {
    public let commissionRate: Double
    public let depositFeesRate: Double
    public let startDateDeposit: Date
    public let endDateDeposit: Date
    public let startDateSelling: Date
    public let endDateSelling: Date
    
    public init(commissionRate: Double, depositFeesRate: Double, startDateDeposit: Date, endDateDeposit: Date, startDateSelling: Date, endDateSelling: Date) {
        self.commissionRate = commissionRate
        self.depositFeesRate = depositFeesRate
        self.startDateDeposit = startDateDeposit
        self.endDateDeposit = endDateDeposit
        self.startDateSelling = startDateSelling
        self.endDateSelling = endDateSelling
    }
}
