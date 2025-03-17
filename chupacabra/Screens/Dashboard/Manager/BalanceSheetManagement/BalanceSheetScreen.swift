import SwiftUI
import Charts

struct FinancialData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

struct BalanceSheetScreen: View {
    // Données fictives
    let totalRevenue: Double = 12500.75
    let totalExpenses: Double = 5230.45
    let totalProfit: Double = 7270.30
    
    let revenues: [FinancialData] = [
        FinancialData(category: "Ventes de jeux", amount: 8750.50),
        FinancialData(category: "Frais de dépôt", amount: 1250.25),
        FinancialData(category: "Commissions", amount: 2500.00)
    ]
    
    let expenses: [FinancialData] = [
        FinancialData(category: "Location", amount: 2000.00),
        FinancialData(category: "Personnel", amount: 2500.00),
        FinancialData(category: "Matériel", amount: 450.45),
        FinancialData(category: "Marketing", amount: 280.00)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Résumé financier
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Revenus")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(totalRevenue, specifier: "%.2f") €")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Dépenses")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(totalExpenses, specifier: "%.2f") €")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        Divider()
                            .padding(.vertical)
                        
                        HStack {
                            Text("Bilan net")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(totalProfit, specifier: "%.2f") €")
                                .font(.title)
                                .foregroundColor(totalProfit >= 0 ? .green : .red)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Graphique des revenus
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ventilation des revenus")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(revenues) { revenue in
                                BarMark(
                                    x: .value("Montant", revenue.amount),
                                    y: .value("Catégorie", revenue.category)
                                )
                                .foregroundStyle(getColor(index: revenues.firstIndex(where: { $0.id == revenue.id }) ?? 0))
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        
                        // Légende
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(revenues) { revenue in
                                HStack {
                                    Circle()
                                        .fill(getColor(index: revenues.firstIndex(where: { $0.id == revenue.id }) ?? 0))
                                        .frame(width: 10, height: 10)
                                    Text(revenue.category)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(revenue.amount, specifier: "%.2f") €")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Graphique des dépenses
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Ventilation des dépenses")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(expenses) { expense in
                                BarMark(
                                    x: .value("Montant", expense.amount),
                                    y: .value("Catégorie", expense.category)
                                )
                                .foregroundStyle(getColor(index: expenses.firstIndex(where: { $0.id == expense.id }) ?? 0, isExpense: true))
                            }
                        }
                        .frame(height: 250)
                        .padding()
                        
                        // Légende
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(expenses) { expense in
                                HStack {
                                    Circle()
                                        .fill(getColor(index: expenses.firstIndex(where: { $0.id == expense.id }) ?? 0, isExpense: true))
                                        .frame(width: 10, height: 10)
                                    Text(expense.category)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(expense.amount, specifier: "%.2f") €")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Bilan financier")
        }
    }
    
    // Fonction pour obtenir des couleurs différentes selon l'index
    private func getColor(index: Int, isExpense: Bool = false) -> Color {
        let colors: [Color] = isExpense ? 
            [.red, .orange, .pink, .purple] :
            [.blue, .green, .teal, .indigo]
        return colors[index % colors.count]
    }
}

struct BalanceSheetScreen_Previews: PreviewProvider {
    static var previews: some View {
        BalanceSheetScreen()
    }
} 