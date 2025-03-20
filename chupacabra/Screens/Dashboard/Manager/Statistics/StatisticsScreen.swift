import SwiftUI
import Charts

struct CategorySale: Identifiable {
    let id = UUID()
    let category: String
    let sales: Int
}

struct StatsSeller: Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let sales: Int
}

struct WeeklyProfit: Identifiable {
    let id = UUID()
    let week: String
    let profit: Double
}

struct StatisticsScreen: View {
    @State private var isLoading = false
    @StateObject private var statisticViewModel: StatisticViewModel = StatisticViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Section des ventes par catégorie
                    VStack(alignment: .leading) {
                        Text("Ventes par catégorie")
                            .font(.headline)
                            .padding(.leading)
                        
                        Chart {
                            ForEach(statisticViewModel.sellsByCategory) { sale in
                                BarMark(
                                    x: .value("Catégorie", sale.category),
                                    y: .value("Ventes", sale.sells)
                                )
                                .foregroundStyle(Color.blue.gradient)
                            }
                        }
                        .frame(height: 250)
                        .padding()
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Section du meilleur vendeur
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Meilleur vendeur")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(statisticViewModel.topSeller?.seller.firstName ?? "Inconnu") \(statisticViewModel.topSeller?.seller.lastName ?? "Inconnu")")
                                .font(.title3)
                            
                            Text("Email: \(statisticViewModel.topSeller?.seller.email ?? "Non disponible")")
                                .font(.subheadline)
                            
                            Text("Téléphone: \(statisticViewModel.topSeller?.seller.phone ?? "Non disponible")")
                                .font(.subheadline)
                            
                            Text("Nombre de ventes: \(statisticViewModel.topSeller?.sales ?? 0)")
                                .font(.subheadline)
                                .bold()
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Section des statistiques de chiffre d'affaires
                    VStack(alignment: .leading) {
                        Text("Statistiques de chiffre d'affaires")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Profit total: \(statisticViewModel.turnoverStatistics?.profit ?? -1, specifier: "%.2f") €")
                                .font(.title3)
                                .bold()
                            
                            Text("Évolution")
                                .font(.subheadline)
                            
                            Chart {
                                ForEach(statisticViewModel.turnoverStatistics?.profitEvolution ?? [], id: \.week) { weeklyProfit in
                                    BarMark(
                                        x: .value("Semaine", weeklyProfit.week),
                                        y: .value("Profit", weeklyProfit.profit)
                                    )
                                    .foregroundStyle(Color.green.gradient)  
                                }
                            }
                            .frame(height: 250)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistiques")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .onAppear {
            statisticViewModel.loadTopSeller()
            statisticViewModel.loadFinancialStatement()
            statisticViewModel.loadTurnoverStatistics()
            statisticViewModel.loadSellsByCategory()
        }
    }
}

struct StatisticsScreen_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsScreen()
    }
} 
