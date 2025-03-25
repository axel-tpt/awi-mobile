import Foundation
import Combine

public protocol StatisticServiceProtocol {
    func getTurnoverStatistics() -> AnyPublisher<turnoverStatisticsResponse, RequestError>
    func getFinancialStatement() -> AnyPublisher<financialStatementResponse, RequestError>
    func getSellsByCategory() -> AnyPublisher<[sellsByCategory], RequestError>
    func getTopSeller() -> AnyPublisher<topSellerResponse, RequestError>
}

public final class StatisticService: StatisticServiceProtocol {
    public func getTurnoverStatistics() -> AnyPublisher<turnoverStatisticsResponse, RequestError> {
        return APIService.fetch(endpoint: "/statistics/turnover-statistics", method: .get)
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
    
    public func getFinancialStatement() -> AnyPublisher<financialStatementResponse, RequestError> {
        return APIService.fetch(endpoint: "/statistics/financial-statement", method: .get)
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
    
    public func getSellsByCategory() -> AnyPublisher<[sellsByCategory], RequestError> {
        return APIService.fetch(endpoint: "/statistics/sells-by-category", method: .get)
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
    
    public func getTopSeller() -> AnyPublisher<topSellerResponse, RequestError> {
        return APIService.fetch(endpoint: "/statistics/top-seller", method: .get)
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
