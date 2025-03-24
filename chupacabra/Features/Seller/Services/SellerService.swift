import Foundation
import Combine

public protocol SellerServiceProtocol {
    func getSellers() -> AnyPublisher<[Seller], RequestError>
    func getSellerById(id: Int) -> AnyPublisher<Seller, RequestError>
    func updateSellerById(id: Int, data: SellerForm) -> AnyPublisher<EmptyResponse, RequestError>
    func removeSellerById(id: Int) -> AnyPublisher<EmptyResponse, RequestError>
    func createSeller(data: SellerForm) -> AnyPublisher<EmptyResponse, RequestError>
    func getSellerBalanceSheet(id: Int) -> AnyPublisher<SellerBalanceSheet, RequestError>
    func getSellerDeposits(id: Int) -> AnyPublisher<[Deposit], RequestError>
    func financialWithdraw(id: Int) -> AnyPublisher<EmptyResponse, RequestError>
}

public final class SellerService: SellerServiceProtocol {
    
    public init() {}
    
    public func getSellers() -> AnyPublisher<[Seller], RequestError> {
        return APIService.fetch(endpoint: "/sellers", method: .get)
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
    
    public func getSellerById(id: Int) -> AnyPublisher<Seller, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)", method: .get)
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
    
    public func updateSellerById(id: Int, data: SellerForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)", method: .put, body: data)
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
    
    public func removeSellerById(id: Int) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)", method: .delete)
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
    
    public func createSeller(data: SellerForm) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sellers", method: .post, body: data)
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
    
    public func getSellerBalanceSheet(id: Int) -> AnyPublisher<SellerBalanceSheet, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)/bilan", method: .get)
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
    
    public func getSellerDeposits(id: Int) -> AnyPublisher<[Deposit], RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)/deposits", method: .get)
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
    
    public func financialWithdraw(id: Int) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/sellers/\(id)/financial-withdrawal", method: .post)
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
