import SwiftUI

struct EditSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SessionViewModel()
    
    let session: Session
    
    @State private var commissionRate: Double
    @State private var depositFeesRate: Double
    @State private var startDateDeposit: Date
    @State private var endDateDeposit: Date
    @State private var startDateSelling: Date
    @State private var endDateSelling: Date
    
    init(session: Session) {
        self.session = session
        _commissionRate = State(initialValue: session.commissionRate)
        _depositFeesRate = State(initialValue: session.depositFeesRate)
        _startDateDeposit = State(initialValue: session.startDateDeposit)
        _endDateDeposit = State(initialValue: session.endDateDeposit)
        _startDateSelling = State(initialValue: session.startDateSelling)
        _endDateSelling = State(initialValue: session.endDateSelling)
    }
    
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
            .navigationTitle("Modifier Session")
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
                    Button("Enregistrer") {
                        updateSession()
                    }
                }
            }
        }
    }
    
    private func updateSession() {
        let sessionForm = SessionForm(
            commissionRate: commissionRate,
            depositFeesRate: depositFeesRate,
            startDateDeposit: startDateDeposit,
            endDateDeposit: endDateDeposit,
            startDateSelling: startDateSelling,
            endDateSelling: endDateSelling
        )
        
        viewModel.updateSession(id: session.id, data: sessionForm)
        dismiss()
    }
}

#Preview {
    EditSessionView(
        session: Session(
            id: 1,
            commissionRate: 10.0,
            depositFeesRate: 5.0,
            startDateDeposit: Date(),
            endDateDeposit: Date(),
            startDateSelling: Date(),
            endDateSelling: Date()
        )
    )
} 