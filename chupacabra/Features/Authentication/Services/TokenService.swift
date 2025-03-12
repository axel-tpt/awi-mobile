import Foundation
import Security

public protocol TokenServiceProtocol {
    func saveToken(_ token: String)
    func getToken() -> String?
    func deleteToken()
}

public final class TokenService: TokenServiceProtocol {
    private let tokenKey = "accessToken"
    
    public init() {}
    
    public func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    public func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }
    
    public func deleteToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
} 