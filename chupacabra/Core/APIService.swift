import Foundation
import Combine

public struct APIError: Error {
    public let statusCode: Int
    public let underlyingError: Error
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIService {
    private static let baseURL = URL(string: "https://awi-dev.cyrildeschamps.fr/api")!

    public static func fetch<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        params: [String: String]? = nil,
        body: Encodable? = nil,
        headers: [String: String] = [:]
    ) -> AnyPublisher<T, Error> {
        
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        if let params = params {
            urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body, method != .get {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: error).eraseToAnyPublisher()
            }
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return (data, httpResponse.statusCode)
            }
            .mapError { $0 }
            .flatMap { (data, statusCode) -> AnyPublisher<T, Error> in
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { error in
                        return APIError(statusCode: statusCode, underlyingError: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
