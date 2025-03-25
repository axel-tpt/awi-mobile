import Foundation
import Combine

public protocol DepositServiceProtocol {
    func createDeposit(data: SellerCreateDeposit, sellerId: Int) -> AnyPublisher<EmptyResponse, RequestError>
    func getGames() -> AnyPublisher<[ApiGame], RequestError>
    func getMeansOfPayment() -> AnyPublisher<[MeanPayment], RequestError>
}

public final class DepositService: DepositServiceProtocol {
    
    public init() {}
    
    public func createDeposit(data: SellerCreateDeposit, sellerId: Int) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(sellerId)/deposits", method: .post, body: data)
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
    
    public func getGames() -> AnyPublisher<[ApiGame], RequestError> {
        return APIService.fetch(endpoint: "/games", method: .get)
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
    
    public func getMeansOfPayment() -> AnyPublisher<[MeanPayment], RequestError> {
        return APIService.fetch(endpoint: "/means-payment", method: .get)
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
} 
