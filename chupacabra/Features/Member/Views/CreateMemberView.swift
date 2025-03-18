import SwiftUI

struct CreateMemberView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: MemberViewModel
    
    @State private var email = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var permissionLevel = PermissionLevel.USER
    @State private var password = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(viewModel: MemberViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            MemberFormView(
                email: $email,
                firstName: $firstName,
                lastName: $lastName,
                permissionLevel: $permissionLevel,
                password: $password,
                isNewMember: true
            )
            .navigationTitle("Nouveau Membre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        createMember()
                    }
                    .disabled(viewModel.isLoading || !formIsValid)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Erreur"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private var formIsValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func createMember() {
        let memberData = MemberForm(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            permissionLevel: permissionLevel,
            password: password.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        viewModel.createMember(data: memberData, onSuccess: {
            dismiss()
        }, onError: { error in
            alertMessage = error.localizedDescription
            showAlert = true
        })
    }
} 
