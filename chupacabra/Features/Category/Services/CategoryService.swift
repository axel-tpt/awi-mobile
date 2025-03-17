import Foundation
import Combine
import SwiftUI
import JWTDecode

public protocol CategoryServiceProtocol {
    func loadCategories()
}

public final class CategoryService: CategoryServiceProtocol {
    private var _categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    
    public func loadCategories() {
        getCategories()
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: { completion in
               if case .failure(let error) = completion {
                   self.state = .error(error.localizedDescription)
               }
           }, receiveValue: { [weak self] (response: [Category]) in
               guard let self = self else { return }
               self._categories = response
           })
           .store(in: &cancellables)
    }
    
    private func getCategories() -> AnyPublisher<[Category], AuthError> {
        return APIService.fetch(
            endpoint: "categories",
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
