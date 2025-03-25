import Foundation
import Combine


class StatisticViewModel: ObservableObject, RequestHandler {
    @Published private(set) var isLoading = false
    @Published private(set) var error: RequestError? = nil
    @Published private(set) var order: OrderResponse? = nil
    
    @Published private(set) var financialStatement: financialStatementResponse? = nil
    @Published private(set) var turnoverStatistics: turnoverStatisticsResponse? = nil
    @Published private(set) var sellsByCategory: [sellsByCategory] = []
    @Published private(set) var topSeller: topSellerResponse? = nil
    
    private let statisticService: StatisticServiceProtocol
    var cancellables = Set<AnyCancellable>()
 
    init(statisticService: StatisticServiceProtocol = StatisticService()) {
        self.statisticService = statisticService
    }
    
    func loadFinancialStatement(onSuccess: (() -> Void)? = nil,
                                onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            statisticService.getFinancialStatement(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { financialStatement in
                self.financialStatement = financialStatement
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadTurnoverStatistics(onSuccess: (() -> Void)? = nil,
                                onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            statisticService.getTurnoverStatistics(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { turnoverStatistics in
                self.turnoverStatistics = turnoverStatistics
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadSellsByCategory(onSuccess: (() -> Void)? = nil,
                             onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            statisticService.getSellsByCategory(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { sellsByCategory in
                self.sellsByCategory = sellsByCategory
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
    
    func loadTopSeller(onSuccess: (() -> Void)? = nil,
                       onError: ((RequestError) -> Void)? = nil) {
        handlePublisher(
            statisticService.getTopSeller(),
            setLoading: { self.isLoading = $0 },
            setError: { self.error = $0 },
            onSuccess: { topSeller in
                self.topSeller = topSeller
                onSuccess?()
            },
            onError: { error in
                onError?(error)
            }
        )
    }
}
