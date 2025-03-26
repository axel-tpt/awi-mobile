import Foundation

public enum PermissionLevel: Int, Codable, Comparable {
    
    
    case USER = 0
    case MANAGER = 1
    case ADMIN = 2
    
    public var displayName: String {
        switch self {
        case .USER: return "Utilisateur"
        case .MANAGER: return "Manager"
        case .ADMIN: return "Administrateur"
        }
    }
    
    public static func < (lhs: PermissionLevel, rhs: PermissionLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct Member: Decodable, Identifiable {
    public let id: Int
    public let email: String
    public let firstName: String
    public let lastName: String
    public let permissionLevel: PermissionLevel
}

public struct MemberForm: Encodable {
    public let email: String
    public let firstName: String
    public let lastName: String
    public let permissionLevel: PermissionLevel
    public let password: String?
    
    public init(email: String, firstName: String, lastName: String, permissionLevel: PermissionLevel, password: String? = nil) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.permissionLevel = permissionLevel
        self.password = password
    }
} 
