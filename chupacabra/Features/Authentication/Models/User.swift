import Foundation

public struct AuthResponse: Decodable {
    let accessToken: String
    let atExpireDate: String
    let memberId: Int
}

public enum PermissionLevel: Int, Decodable {
    case manager = 1
    case admin = 2
}

public struct LoggedUser: Decodable {
    let id: Int
    let permissionLevel: PermissionLevel
}
