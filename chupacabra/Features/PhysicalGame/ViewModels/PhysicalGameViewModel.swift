import Foundation
import Combine
import SwiftUI
import JWTDecode

class PhysicalGameViewModel: ObservableObject, RequestHandler {
    @Published var physicalGamesNotLabeled: [FullPhysicalGame] = []
    @Published var physicalGameByBarcode: FullPhysicalGame? = nil
    @Published var forSalePhysicalGamesBarcodes: [String] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    
    var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    private let physicalGameService: PhysicalGameServiceProtocol
    
    init(physicalGameService: PhysicalGameServiceProtocol = PhysicalGameService()) {
        self.physicalGameService = physicalGameService
    }
    
    func loadPhysicalGamesNotLabeled(onSuccess: (() -> Void)? = nil,
                                     onError: ((RequestError) -> Void)? = nil) {
        self.physicalGameService.getPhysicalGamesNotLabeled()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: [FullPhysicalGame]) in
                guard let self = self else { return }
                self.physicalGamesNotLabeled = response
            })
            .store(in: &cancellables)
    }
    
    func loadPhysicalGameByBarcode(barcode : String,
                                   onSuccess: (() -> Void)? = nil,
                                   onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            self.physicalGameService.getPhysicalGameByBarcode(barcode),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { response in
                self.physicalGameByBarcode = response
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func bulkUpdatePhysicalGamesStatus(ids: [Int], status: PhysicalGameStatus,
                                       onSuccess: (() -> Void)? = nil,
                                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            self.physicalGameService.bulkUpdatePhysicalGamesStatus(ids: ids, status: status),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { response in
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadForSalePhysicalGamesBarcodes(onSuccess: (() -> Void)? = nil,
                                          onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            self.physicalGameService.getForSalePhysicalGamesBarcodes(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { response in
                self.forSalePhysicalGamesBarcodes = response
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}
