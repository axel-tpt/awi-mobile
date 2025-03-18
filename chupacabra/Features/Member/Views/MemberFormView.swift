import SwiftUI
import Foundation

struct MemberFormView: View {
    @Binding var email: String
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var permissionLevel: PermissionLevel
    @Binding var password: String
    @State private var showPassword = false
    
    var isNewMember: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Informations personnelles")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                TextField("Prénom", text: $firstName)
                
                TextField("Nom", text: $lastName)
            }
            
            Section(header: Text("Rôle")) {
                Picker("Niveau de permission", selection: $permissionLevel) {
                    Text("Utilisateur").tag(PermissionLevel.USER)
                    Text("Manager").tag(PermissionLevel.MANAGER)
                    Text("Administrateur").tag(PermissionLevel.ADMIN)
                }
                .pickerStyle(.menu)
            }
            
            if isNewMember {
                Section(header: Text("Sécurité")) {
                    HStack {
                        if showPassword {
                            TextField("Mot de passe", text: $password)
                        } else {
                            SecureField("Mot de passe", text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
} 
