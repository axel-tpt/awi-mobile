import SwiftUI
import Charts

struct FinancialData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
}

import SwiftUI

struct BalanceSheetScreen: View {
    @StateObject private var statisticViewModel = StatisticViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FinancialCard(icon: "person.badge.dollar",
                                  title: "Dû aux vendeurs",
                                  value: statisticViewModel.financialStatement?.moneyOwed ?? 0,
                                  color: .red)
                    
                    FinancialCard(icon: "cube.box",
                                  title: "Jeux en vente",
                                  value: Double(statisticViewModel.financialStatement?.numberOfPhysicalGamesForSale ?? 0),
                                  color: .blue)
                    
                    FinancialCard(icon: "dollarsign.circle",
                                  title: "Valeur des jeux en vente",
                                  value: statisticViewModel.financialStatement?.valueOfPhysicalGamesForSale ?? 0,
                                  color: .orange)
                    
                    FinancialCard(icon: "chart.bar.fill",
                                  title: "CA Possible",
                                  value: statisticViewModel.financialStatement?.turnoverPossible ?? 0,
                                  color: .green)
                    
                    FinancialCard(icon: "chart.line.uptrend.xyaxis",
                                  title: "CA Annuel",
                                  value: statisticViewModel.financialStatement?.turnoverOfThisYear ?? 0,
                                  color: .purple)
                }
                .padding()
            }
            .navigationTitle("Bilan Financier")
            .onAppear {
                statisticViewModel.loadFinancialStatement()
            }
        }
    }
}

struct FinancialCard: View {
    let icon: String
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(String(format: "%.2f", value)) €")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: color.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}


struct BalanceSheetScreen_Previews: PreviewProvider {
    static var previews: some View {
        BalanceSheetScreen()
    }
} 
