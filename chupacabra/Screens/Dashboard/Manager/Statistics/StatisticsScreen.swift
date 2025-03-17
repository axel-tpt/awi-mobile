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
    
    // Données fictives pour les ventes par catégorie
    let categorySales: [CategorySale] = [
        CategorySale(category: "Stratégie", sales: 45),
        CategorySale(category: "Famille", sales: 65),
        CategorySale(category: "Enfants", sales: 25),
        CategorySale(category: "Ambiance", sales: 32),
        CategorySale(category: "Expert", sales: 18)
    ]
    
    // Données fictives pour le meilleur vendeur
    let topSeller = StatsSeller(
        id: 1,
        firstName: "Sophie",
        lastName: "Moreau",
        email: "sophie.moreau@example.com",
        phone: "06 12 34 56 78",
        sales: 23
    )
    
    // Données fictives pour l'évolution du profit
    let weeklyProfits: [WeeklyProfit] = [
        WeeklyProfit(week: "Sem 1", profit: 1240.50),
        WeeklyProfit(week: "Sem 2", profit: 1650.75),
        WeeklyProfit(week: "Sem 3", profit: 1420.25),
        WeeklyProfit(week: "Sem 4", profit: 2100.00),
        WeeklyProfit(week: "Sem 5", profit: 1890.50)
    ]
    
    // Chiffre d'affaires total
    let totalProfit: Double = 8302.00
    
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
                            ForEach(categorySales) { sale in
                                BarMark(
                                    x: .value("Catégorie", sale.category),
                                    y: .value("Ventes", sale.sales)
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
                            Text("\(topSeller.firstName) \(topSeller.lastName)")
                                .font(.title3)
                            Text("Email: \(topSeller.email)")
                                .font(.subheadline)
                            Text("Téléphone: \(topSeller.phone)")
                                .font(.subheadline)
                            Text("Nombre de ventes: \(topSeller.sales)")
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
                            Text("Profit total: \(totalProfit, specifier: "%.2f") €")
                                .font(.title3)
                                .bold()
                            
                            Text("Évolution")
                                .font(.subheadline)
                            
                            Chart {
                                ForEach(weeklyProfits) { weeklyProfit in
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
    }
}

struct StatisticsScreen_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsScreen()
    }
} 