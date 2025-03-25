import Foundation
import Combine

public protocol MemberServiceProtocol {
    func getMembers() -> AnyPublisher<[Member], RequestError>
    func getMemberById(id: Int) -> AnyPublisher<Member, RequestError>
    func updateMemberById(id: Int, data: MemberForm) -> AnyPublisher<EmptyResponse, RequestError>
    func removeMemberById(id: Int) -> AnyPublisher<EmptyResponse, RequestError>
    func createMember(data: MemberForm) -> AnyPublisher<EmptyResponse, RequestError>
}

public final class MemberService: MemberServiceProtocol {
    
    public init() {}
    
    public func getMembers() -> AnyPublisher<[Member], RequestError> {
        return APIService.fetch(endpoint: "/members", method: .get)
            .mapError { error -> RequestError in
                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func getMemberById(id: Int) -> AnyPublisher<Member, RequestError> {
        return APIService.fetch(endpoint: "/members/\(id)", method: .get)
            .mapError { error -> RequestError in
                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func updateMemberById(id: Int, data: MemberForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/members/\(id)", method: .put, body: data)
            .mapError { error -> RequestError in
                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func removeMemberById(id: Int) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/members/\(id)", method: .delete)
            .mapError { error -> RequestError in
                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func createMember(data: MemberForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/members", method: .post, body: data)
            .mapError { error -> RequestError in
                if let apiError = error as? APIError {
                    return .serverError(statusCode: apiError.statusCode, underlyingError: apiError.underlyingError)
                } else if error is URLError {
                    return .networkError(error)
                } else {
                    return .unknownError(error)
                }
            }
            .eraseToAnyPublisher()
    }
} 
