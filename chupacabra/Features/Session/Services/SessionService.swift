import Foundation
import Combine

public enum SessionError: Error {
    case networkError(Error)
    case decodingError
    case serverError(statusCode: Int, underlyingError: Error)
    case unknownError(Error)
    
    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to decode data from the server"
        case .serverError(let statusCode, let error):
            return "Server error with status code \(statusCode): \(error.localizedDescription)"
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
}

public protocol SessionServiceProtocol {
    func loadSessions() -> AnyPublisher<[Session], SessionError>
    func getCurrentSession() -> AnyPublisher<Session, SessionError>
    func getSessionById(id: Int) -> AnyPublisher<Session, SessionError>
    func updateSessionById(id: Int, data: SessionForm) -> AnyPublisher<EmptyResponse, SessionError>
    func removeSessionById(id: Int) -> AnyPublisher<EmptyResponse, SessionError>
    func createSession(data: SessionForm) -> AnyPublisher<EmptyResponse, SessionError>
}

public final class SessionService: SessionServiceProtocol {
    
    public init() {}
    
    public func loadSessions() -> AnyPublisher<[Session], SessionError> {
        return APIService.fetch(endpoint: "/sessions", method: .get)
            .mapError { error -> SessionError in
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
    
    public func getCurrentSession() -> AnyPublisher<Session, SessionError> {
        return APIService.fetch(endpoint: "/sessions/current", method: .get)
            .mapError { error -> SessionError in
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
    
    public func getSessionById(id: Int) -> AnyPublisher<Session, SessionError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .get)
            .mapError { error -> SessionError in
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
    
    public func updateSessionById(id: Int, data: SessionForm) -> AnyPublisher<EmptyResponse, SessionError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .put, body: data)
            .mapError { error -> SessionError in
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
    
    public func removeSessionById(id: Int) -> AnyPublisher<EmptyResponse, SessionError> {
        return APIService.fetch(endpoint: "/sessions/\(id)", method: .delete)
            .mapError { error -> SessionError in
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
    
    public func createSession(data: SessionForm) -> AnyPublisher<EmptyResponse, SessionError> {
        return APIService.fetch(endpoint: "/sessions", method: .post, body: data)
            .mapError { error -> SessionError in
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
