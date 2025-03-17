import SwiftUI
import Charts

struct StatisticsScreen: View {
    @State private var isLoading = false
    
    // Données fictives pour les statistiques
    let totalOrders: Int = 247
    let totalSales: Double = 12450.75
    let averageOrderValue: Double = 50.41
    
    // Données fictives pour les ventes par catégorie
    let categorySales: [CategorySale] = [
        CategorySale(category: "Stratégie", sales: 85),
        CategorySale(category: "Famille", sales: 65),
        CategorySale(category: "Enfants", sales: 45),
        CategorySale(category: "Experts", sales: 30),
        CategorySale(category: "Cartes", sales: 22)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Section des indicateurs clés
                    HStack(spacing: 15) {
                        KeyMetricCard(title: "Total commandes", value: "\(totalOrders)", iconName: "cart.fill", color: .blue)
                        KeyMetricCard(title: "Total ventes", value: "\(totalSales, specifier: "%.2f") €", iconName: "eurosign.circle.fill", color: .green)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 15) {
                        KeyMetricCard(title: "Moyenne panier", value: "\(averageOrderValue, specifier: "%.2f") €", iconName: "creditcard.fill", color: .purple)
                        KeyMetricCard(title: "Taux conversion", value: "4.8%", iconName: "arrow.up.right", color: .orange)
                    }
                    .padding(.horizontal)
                    
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
                    
                    // Section des statistiques par période
                    VStack(alignment: .leading) {
                        Text("Statistiques par période")
                            .font(.headline)
                            .padding(.leading)
                        
                        PeriodSelector()
                            .padding(.horizontal)
                        
                        Chart {
                            // Données fictives pour l'évolution des ventes par jour
                            BarMark(
                                x: .value("Jour", "Lun"), 
                                y: .value("Ventes", 1250.50)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Mar"), 
                                y: .value("Ventes", 980.75)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Mer"), 
                                y: .value("Ventes", 1420.25)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Jeu"), 
                                y: .value("Ventes", 1680.00)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Ven"), 
                                y: .value("Ventes", 2100.50)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Sam"), 
                                y: .value("Ventes", 2450.75)
                            )
                            .foregroundStyle(Color.green.gradient)
                            
                            BarMark(
                                x: .value("Jour", "Dim"), 
                                y: .value("Ventes", 1890.00)
                            )
                            .foregroundStyle(Color.green.gradient)
                        }
                        .frame(height: 250)
                        .padding()
                    }
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

struct CategorySale: Identifiable {
    let id = UUID()
    let category: String
    let sales: Int
}

struct KeyMetricCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PeriodSelector: View {
    @State private var selectedPeriod = 0
    let periods = ["Jour", "Semaine", "Mois", "Année"]
    
    var body: some View {
        Picker("Période", selection: $selectedPeriod) {
            ForEach(0..<periods.count, id: \.self) { index in
                Text(periods[index]).tag(index)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical)
    }
}

struct StatisticsScreen_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsScreen()
    }
} 