import Foundation
import Combine
import SwiftUI
import JWTDecode

class CategoryViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    private let categoryService: CategoryServiceProtocol
    
    init(categoryService: CategoryService = CategoryService()) {
        self.categoryService = categoryService
    }
    
    public func loadCategories() {
        self.categoryService.getCategories()
           .receive(on: DispatchQueue.main)
           .sink(receiveCompletion: { completion in
               if case .failure(let error) = completion {
                   self.state = .error(error.localizedDescription)
               }
           }, receiveValue: { [weak self] (response: [Category]) in
               guard let self = self else { return }
               self.categories = response
           })
           .store(in: &cancellables)
    }
}
