import Foundation
import Combine
import SwiftUI
import JWTDecode

struct BulkUpdateRequest: Encodable {
    let ids: [Int]
    let status: String
}

public protocol PhysicalGameServiceProtocol {
    func getPhysicalGamesNotLabeled() -> AnyPublisher<[FullPhysicalGame], AuthError>
    func getPhysicalGameByBarcode(_ barcode : String) -> AnyPublisher<FullPhysicalGame, AuthError>
    func bulkUpdatePhysicalGamesStatus(ids: [Int], status: PhysicalGameStatus) -> AnyPublisher<EmptyResponse, AuthError>
    func getForSalePhysicalGamesBarcodes() -> AnyPublisher<[String], AuthError>
}

public final class PhysicalGameService: PhysicalGameServiceProtocol {
    
    public func getPhysicalGamesNotLabeled() -> AnyPublisher<[FullPhysicalGame], AuthError> {
        return APIService.fetch(
            endpoint: "physical-games",
            method: .get
        )
        .mapError { error -> AuthError in
            print("Erreur capturée : \(error)")

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
    
    public func getPhysicalGameByBarcode(_ barcode : String) -> AnyPublisher<FullPhysicalGame, AuthError> {
        return APIService.fetch(
            endpoint: "physical-games/by-barcode/" + barcode,
            method: .get
        )
        .mapError { error -> AuthError in
            print("Erreur capturée : \(error)")

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
    
    public func bulkUpdatePhysicalGamesStatus(
        ids: [Int],
        status: PhysicalGameStatus
    ) -> AnyPublisher<EmptyResponse, AuthError> {
        let body = BulkUpdateRequest(ids: ids, status: status.rawValue)
        
        return APIService.fetch(
            endpoint: "physical-games",
            method: .put,
            body: body
        )
        .mapError { error -> AuthError in
            print("Erreur capturée : \(error)")

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
    
    public func getForSalePhysicalGamesBarcodes() -> AnyPublisher<[String], AuthError> {
        return APIService.fetch(
            endpoint: "physical-games/for-sale-barcodes",
            method: .get
        )
        .mapError { error -> AuthError in
            print("Erreur capturée : \(error)")

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
}
