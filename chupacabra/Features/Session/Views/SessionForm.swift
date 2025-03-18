import SwiftUI

struct SessionFormView: View {
    @Binding var commissionRate: Double
    @Binding var depositFeesRate: Double
    @Binding var startDateDeposit: Date
    @Binding var endDateDeposit: Date
    @Binding var startDateSelling: Date
    @Binding var endDateSelling: Date
    
    var body: some View {
        Form {
            Section(header: Text("Taux")) {
                HStack {
                    Text("Commission (%)")
                    Spacer()
                    TextField("", value: $commissionRate, format: .number)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Frais de dépôt (%)")
                    Spacer()
                    TextField("", value: $depositFeesRate, format: .number)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Période de dépôt")) {
                DatePicker(
                    "Date de début",
                    selection: $startDateDeposit,
                    displayedComponents: [.date]
                )
                
                DatePicker(
                    "Date de fin",
                    selection: $endDateDeposit,
                    displayedComponents: [.date]
                )
            }
            
            Section(header: Text("Période de vente")) {
                DatePicker(
                    "Date de début",
                    selection: $startDateSelling,
                    displayedComponents: [.date]
                )
                
                DatePicker(
                    "Date de fin",
                    selection: $endDateSelling,
                    displayedComponents: [.date]
                )
            }
        }
    }
}
