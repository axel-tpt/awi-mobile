import SwiftUI
import JWTDecode

struct DashboardView: View {
    @EnvironmentObject var loggedUserVM: LoggedUserEnvironment
    @State private var selectedItem: NavigationItem? = .orderCreation
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    enum NavigationItem: Hashable {
        case orderCreation
        case sellerManagement
        case catalog
        case gameLabelling
        case statistics
        case balanceSheet
        case sessionManagement
        case memberManagement
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility, sidebar: {
            List(selection: $selectedItem) {
                ManagerDashboardListWithSelection()
                AdminDashboardListWithSelection()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        loggedUserVM.logout()
                    }) {
                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
        }, detail: {
            NavigationStack {
                detailView
            }
        })
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            // Forcer la visibilité de la sidebar au chargement
            columnVisibility = .all
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        switch selectedItem {
        case .orderCreation:
            OrderCreationScreen()
        case .sellerManagement:
            SellerListScreen()
        case .catalog:
            CatalogScreen()
        case .gameLabelling:
            GameLabellingScreen()
        case .statistics:
            StatisticsScreen()
        case .balanceSheet:
            BalanceSheetScreen()
        case .sessionManagement:
            SessionListScreen()
        case .memberManagement:
            MemberListScreen()
        case nil:
            Text("Sélectionnez une option dans le menu")
        }
    }
}

struct ManagerDashboardListWithSelection: View {
    var body: some View {
        Section(header: Text("Manager")) {
            NavigationLink(value: DashboardView.NavigationItem.orderCreation) {
                Label("Nouvel commande", systemImage: "cart")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.sellerManagement) {
                Label("Gestion des vendeurs", systemImage: "person.2.badge.gearshape")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.catalog) {
                Label("Catalogue des jeux", systemImage: "gamecontroller")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.gameLabelling) {
                Label("Étiquettage des jeux", systemImage: "tag")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.statistics) {
                Label("Statistiques", systemImage: "chart.bar")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.balanceSheet) {
                Label("Bilan comptable", systemImage: "dollarsign.circle")
            }
        }
    }
}

struct AdminDashboardListWithSelection: View {
    var body: some View {
        Section(header: Text("Administration")) {
            NavigationLink(value: DashboardView.NavigationItem.sessionManagement) {
                Label("Gestion des sessions", systemImage: "calendar")
            }
            
            NavigationLink(value: DashboardView.NavigationItem.memberManagement) {
                Label("Gestion des employés", systemImage: "person.3")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
