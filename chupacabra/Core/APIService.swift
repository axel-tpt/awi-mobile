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
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
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
                
                // Vérifier si le statut est 401 (Unauthorized), indiquant un token expiré
                if statusCode == 401 {
                    // Appeler la fonction statique pour notifier l'expiration du token
                    APIService.notifyTokenExpiration()
                    return Fail(error: APIError(statusCode: statusCode, underlyingError: URLError(.userAuthenticationRequired)))
                        .eraseToAnyPublisher()
                }
                
                // Si le type de retour est EmptyResponse et que les données sont vides ou presque vides,
                // retourner directement une EmptyResponse sans décodage
                if T.self == EmptyResponse.self && (data.isEmpty || String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true) {
                    // Créer une EmptyResponse vide et la convertir au type T
                    return Just(EmptyResponse() as! T)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                
                let decoder = JSONDecoder()
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    guard let date = isoFormatter.date(from: dateString) else {
                        throw DecodingError.dataCorruptedError(in: container,
                            debugDescription: "La chaîne de date ne correspond pas au format ISO8601 attendu avec fractions de seconde.")
                    }
                    return date
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: decoder)
                    .mapError { error in
                        return APIError(statusCode: statusCode, underlyingError: error)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        ;
        return flop;
    }

    // Notification center pour l'expiration du token
    private static let tokenExpirationNotification = Notification.Name("TokenExpirationNotification")
    
    // Fonction pour notifier l'expiration du token
    private static func notifyTokenExpiration() {
        // Effacer le token expiré
        tokenService.deleteToken()
        // Poster la notification
        NotificationCenter.default.post(name: tokenExpirationNotification, object: nil)
    }
    
    // Fonction pour s'abonner aux notifications d'expiration de token
    public static func subscribeToTokenExpiration(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: tokenExpirationNotification, object: nil)
    }
    
    // Fonction pour se désabonner des notifications
    public static func unsubscribeFromTokenExpiration(observer: Any) {
        NotificationCenter.default.removeObserver(observer, name: tokenExpirationNotification, object: nil)
    }
}
