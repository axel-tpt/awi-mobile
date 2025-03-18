import Foundation

public struct Category: Decodable, Encodable, Equatable, Hashable {
    let id: Int
    let name: String
    
    public static func == (lhs: Category, rhs: Category) -> Bool {
            return lhs.id == rhs.id
        }
}
