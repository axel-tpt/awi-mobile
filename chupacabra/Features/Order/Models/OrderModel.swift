import Foundation

public struct OrderResponse: Codable {
    let id: Int
    let amount: Double
    let transactionType: String
    let meanPaymentId: Int
    let date: String
    
    var formattedDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: date)
    }
}

public struct OrderRequest: Codable {
    let physicalGameIds: [Int]
    let meanPaymentId: Int
}

public struct InvoiceRequest: Codable {
    let buyerEmail: String
    let buyerAddress: String
    let buyerFirstName: String
    let buyerLastName: String
    let transactionId: Int
}
