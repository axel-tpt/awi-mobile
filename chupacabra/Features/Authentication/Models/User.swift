import Foundation

public struct AuthResponse: Decodable {
    let accessToken: String
    let atExpireDate: Date
    let memberId: Int
}

public struct User: Decodable {
    let id: Int
    let email: String
    let firstName: String?
    let lastName: String?
    let role: Role
}

public enum Role: String, Decodable {
    case admin
    case manager
}
