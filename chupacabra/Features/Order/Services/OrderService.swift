import Foundation
import Combine

public protocol OrderServiceProtocol {
    func order(_ body: OrderRequest) -> AnyPublisher<OrderResponse, RequestError>
    func sendInvoice(_ information: InvoiceRequest) -> AnyPublisher<EmptyResponse, RequestError>
}

public final class OrderService: OrderServiceProtocol {
    public func order(_ body: OrderRequest) -> AnyPublisher<OrderResponse, RequestError> {
        return APIService.fetch(endpoint: "/orders", method: .post, body: body)
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
    
    public func sendInvoice(_ information: InvoiceRequest) -> AnyPublisher<EmptyResponse, RequestError> {
        return APIService.fetch(endpoint: "/orders/invoice", method: .post, body: information)
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
