import SwiftUI

struct ManagerDashboardList: View {
    var body: some View {
        Section(header: Text("Manager")) {
            NavigationLink(destination: OrderCreationScreen()) {
                Label("Nouvel commande", systemImage: "cart")
            }
            NavigationLink(destination: SellerListScreen()) {
                Label("Gestion des vendeurs", systemImage: "person.2.badge.gearshape")
            }
            NavigationLink(destination: CatalogScreen()) {
                Label("Catalogue des jeux", systemImage: "gamecontroller")
            }
            NavigationLink(destination: GameLabellingScreen()) {
                Label("Étiquettage des jeux", systemImage: "tag")
            }
            NavigationLink(destination: StatisticsScreen()) {
                Label("Statistiques", systemImage: "chart.bar")
            }
            NavigationLink(destination: BalanceSheetScreen()) {
                Label("Bilan comptable", systemImage: "dollarsign.circle")
            }
        }
    }
}
