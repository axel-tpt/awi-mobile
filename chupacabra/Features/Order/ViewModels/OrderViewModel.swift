import Foundation
import Combine

class OrderViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var order: OrderResponse? = nil
    
    private let orderService: OrderServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(orderService: OrderServiceProtocol = OrderService()) {
        self.orderService = orderService
    }
    
    func sendOrder(body: OrderRequest,
                   onSuccess: (() -> Void)? = nil,
                   onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            orderService.order(body),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { order in
                self.order = order
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func sendInvoice(body: InvoiceRequest,
                   onSuccess: (() -> Void)? = nil,
                   onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            orderService.sendInvoice(body),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { order in
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}
