import SwiftUI

struct CreateSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SessionViewModel
    
    @State private var commissionRate: Double = 10.0
    @State private var depositFeesRate: Double = 5.0
    @State private var startDateDeposit = Date()
    @State private var endDateDeposit = Date()
    @State private var startDateSelling = Date()
    @State private var endDateSelling = Date()
    
    var body: some View {
        NavigationStack {
            SessionFormView(
                commissionRate: $commissionRate,
                depositFeesRate: $depositFeesRate,
                startDateDeposit: $startDateDeposit,
                endDateDeposit: $endDateDeposit,
                startDateSelling: $startDateSelling,
                endDateSelling: $endDateSelling
            )
            .navigationTitle("Nouvelle Session")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        createSession()
                        
                    }
                }
            }
        }
    }
    
    private func createSession() {
        let sessionForm = SessionForm(
            commissionRate: commissionRate,
            depositFeesRate: depositFeesRate,
            startDateDeposit: startDateDeposit,
            endDateDeposit: endDateDeposit,
            startDateSelling: startDateSelling,
            endDateSelling: endDateSelling
        )
        
        viewModel.createSession(data: sessionForm, onSuccess: {
            dismiss()
        })
    }
}

struct CreateSessionView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSessionView(viewModel: SessionViewModel())
    }
}
