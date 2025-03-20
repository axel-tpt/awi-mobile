import Foundation

public struct Seller: Identifiable, Codable, Equatable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String
}

public struct SellerForm: Encodable {
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phone: String
} 
