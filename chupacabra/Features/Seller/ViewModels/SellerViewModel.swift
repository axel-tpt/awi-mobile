import Foundation
import Combine
import SwiftUI

@MainActor
class SellerViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var sellers: [Seller] = []
    @Published private(set) var seller: Seller? = nil
    @Published private(set) var balanceSheet: SellerBalanceSheet? = nil
    @Published private(set) var physicalGames: [PhysicalGame] = []
    @Published private(set) var deposits: [Deposit] = []
    
    private let sellerService: SellerServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(sellerService: SellerServiceProtocol = SellerService()) {
        self.sellerService = sellerService
    }
    
    func loadSellers(onSuccess: (() -> Void)? = nil,
                      onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.getSellers(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { sellers in
                self.sellers = sellers
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadSellerBalanceSheet(for sellerId: Int,
                              onSuccess: (() -> Void)? = nil,
                              onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.getSellerBalanceSheet(id: sellerId),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { balanceSheet in
                self.balanceSheet = balanceSheet
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadSellerDeposits(for sellerId: Int,
                          onSuccess: (() -> Void)? = nil,
                          onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.getSellerDeposits(id: sellerId),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { deposits in
                self.deposits = deposits
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func updateSeller(id: Int,
                       data: SellerForm,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.updateSellerById(id: id, data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSellers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func deleteSeller(id: Int,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.removeSellerById(id: id),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSellers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func createSeller(data: SellerForm,
                       onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            sellerService.createSeller(data: data),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { _ in
                self.loadSellers(onSuccess: {
                    onSuccess?()
                })
            },
            onError: { error in
                onError?(error)
            }
        )
    }
} 
