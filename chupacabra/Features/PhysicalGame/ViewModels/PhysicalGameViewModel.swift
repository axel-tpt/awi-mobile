import Foundation
import Combine
import SwiftUI
import JWTDecode

class PhysicalGameViewModel: ObservableObject {
    @Published var physicalGamesNotLabeled: [FullPhysicalGame] = []
    @Published var physicalGameByBarcode: FullPhysicalGame? = nil
    @Published var forSalePhysicalGamesBarcodes: [FullPhysicalGame] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var state: AuthState = .idle
    private let physicalGameService: PhysicalGameServiceProtocol
    
    init(physicalGameService: PhysicalGameServiceProtocol = PhysicalGameService()) {
        self.physicalGameService = physicalGameService
    }
    
    func getPhysicalGamesNotLabeled() {
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
    
    func getPhysicalGameByBarcode(barcode : String) {
        self.physicalGameService.getPhysicalGameByBarcode(barcode)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: FullPhysicalGame) in
                guard let self = self else { return }
                self.physicalGameByBarcode = response
            })
            .store(in: &cancellables)
    }
    
    func bulkUpdatePhysicalGamesStatus(ids: [Int], status: PhysicalGameStatus) {
        self.physicalGameService.bulkUpdatePhysicalGamesStatus(ids: ids, status: status)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (response: EmptyResponse) in
                guard self != nil else { return }
            })
            .store(in: &cancellables)
    }
    
    func getForSalePhysicalGamesBarcodes() {
        
    }
}
