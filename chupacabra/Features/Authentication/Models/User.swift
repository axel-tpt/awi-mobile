import Foundation

public struct AuthResponse: Decodable {
    let accessToken: String
    let atExpireDate: String
    let memberId: Int
}

public struct LoggedUser: Decodable {
    let id: Int
    let permissionLevel: PermissionLevel
}
