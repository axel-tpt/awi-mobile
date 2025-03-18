import Foundation
import Combine

public protocol SessionServiceProtocol {
    func getSessions() -> AnyPublisher<[Session], RequestError>
    func getCurrentSession() -> AnyPublisher<Session, RequestError>
    func getSessionById(id: Int) -> AnyPublisher<Session, RequestError>
    func updateSessionById(id: Int, data: SessionForm) -> AnyPublisher<EmptyResponse, RequestError>
    func removeSessionById(id: Int) -> AnyPublisher<EmptyResponse, RequestError>
    func createSession(data: SessionForm) -> AnyPublisher<EmptyResponse, RequestError>
}

public final class SessionService: SessionServiceProtocol {
    
    public init() {}
    
    public func getSessions() -> AnyPublisher<[Session], RequestError> {
        return APIService.fetch(endpoint: "/sessions", method: .get)
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
    
    public func getCurrentSession() -> AnyPublisher<Session, RequestError> {
        return APIService.fetch(endpoint: "/sessions/current", method: .get)
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
    
    public func getSessionById(id: Int) -> AnyPublisher<Session, RequestError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .get)
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
    
    public func updateSessionById(id: Int, data: SessionForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .put, body: data)
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
    
    public func removeSessionById(id: Int) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .delete)
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
    
    public func createSession(data: SessionForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sessions", method: .post, body: data)
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
