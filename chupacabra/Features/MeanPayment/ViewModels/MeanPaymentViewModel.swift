import Foundation
import Combine
import SwiftUI

class MeanPaymentViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var meansPayment: [MeanPayment] = []
    
    private let meanPaymentService: MeanPaymentServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(meanPaymentService: MeanPaymentServiceProtocol = MeanPaymentService()) {
        self.meanPaymentService = meanPaymentService
    }
    
    func loadMeansPayment(onSuccess: (() -> Void)? = nil,
                     onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            meanPaymentService.getMeanPayment(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { meansPayment in
                self.meansPayment = meansPayment
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}
