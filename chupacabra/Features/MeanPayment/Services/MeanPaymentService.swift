import Foundation
import Combine

public protocol MeanPaymentServiceProtocol {
    func getMeanPayment() -> AnyPublisher<[MeanPayment], RequestError>
}

public final class MeanPaymentService: MeanPaymentServiceProtocol {
    public func getMeanPayment() -> AnyPublisher<[MeanPayment], RequestError> {
        return APIService.fetch(endpoint: "/means-payment", method: .get)
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
    
    
}
