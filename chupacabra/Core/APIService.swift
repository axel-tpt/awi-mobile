import Foundation
import Combine

public struct APIError: Error {
    public let statusCode: Int
    public let underlyingError: Error
    
    var localizedDescription: String {
        return "\(statusCode): \(underlyingError)"
    }
}

public struct EmptyResponse: Decodable {}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum APIService {
    private static let baseURL = URL(string: "https://awi-dev.cyrildeschamps.fr/api")!
    private static let tokenService = TokenService()

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

        // Définir les en-têtes de base
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Ajouter le token d'authentification si disponible
        if let token = tokenService.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Ajouter les en-têtes personnalisés (qui peuvent éventuellement remplacer l'en-tête d'authentification)
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

        let flop = URLSession.shared.dataTaskPublisher(for: request)
            .mapError { $0 }
            .tryMap { (data, response) in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                return (data, httpResponse.statusCode)
            }
            .flatMap { (data, statusCode) -> AnyPublisher<T, Error> in
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { error in
                        return APIError(statusCode: statusCode, underlyingError: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        ;
        return flop;
    }
}
