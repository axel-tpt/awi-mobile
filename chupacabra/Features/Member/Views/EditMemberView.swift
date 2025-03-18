import SwiftUI

struct EditMemberView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: MemberViewModel
    
    let member: Member
    
    @State private var email: String
    @State private var firstName: String
    @State private var lastName: String
    @State private var permissionLevel: PermissionLevel
    @State private var password = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    init(member: Member, viewModel: MemberViewModel) {
        self.member = member
        self.viewModel = viewModel
        _email = State(initialValue: member.email)
        _firstName = State(initialValue: member.firstName)
        _lastName = State(initialValue: member.lastName)
        _permissionLevel = State(initialValue: member.permissionLevel)
    }
    
    var body: some View {
        NavigationStack {
            MemberFormView(
                email: $email,
                firstName: $firstName,
                lastName: $lastName,
                permissionLevel: $permissionLevel,
                password: $password,
                isNewMember: false
            )
            .navigationTitle("Modifier Membre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        updateMember()
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
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func updateMember() {
        let memberData = MemberForm(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            permissionLevel: permissionLevel,
            password: password.isEmpty ? nil : password.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        viewModel.updateMember(id: member.id, data: memberData, onSuccess: {
            dismiss()
        }, onError: { error in
            alertMessage = error.localizedDescription
            showAlert = true
        })
    }
} 
