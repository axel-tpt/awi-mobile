import Foundation
import Combine

public enum RequestError: Error {
    case networkError(Error)
    case decodingError
    case serverError(statusCode: Int, underlyingError: Error)
    case unknownError(Error)
    
    public var localizedDescription: String {
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

@MainActor
public protocol RequestHandler: AnyObject {
    var cancellables: Set<AnyCancellable> { get set }
}

public extension RequestHandler {
    func handlePublisher<T>(
        _ publisher: AnyPublisher<T, RequestError>,
        setLoading: @escaping (Bool) -> Void,
        setError: @escaping (RequestError) -> Void,
        onSuccess: @escaping (T) -> Void,
        onError: @escaping (RequestError) -> Void = { _ in }
    ) {
        setLoading(true)
        publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    setLoading(false)
                case .failure(let error):
                    onError(error)
                    setError(error)
                    setLoading(false)
                }
            } receiveValue: { value in
                onSuccess(value)
            }
            .store(in: &cancellables)
    }
}
