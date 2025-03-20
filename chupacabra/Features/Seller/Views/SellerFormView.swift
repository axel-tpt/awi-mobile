import SwiftUI

struct SellerFormView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var email: String
    @Binding var phone: String
    
    var body: some View {
        Form {
            Section(header: Text("Informations personnelles")) {
                HStack {
                    Text("Prénom")
                    Spacer()
                    TextField("", text: $firstName)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Nom")
                    Spacer()
                    TextField("", text: $lastName)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Email")
                    Spacer()
                    TextField("", text: $email)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                HStack {
                    Text("Téléphone")
                    Spacer()
                    TextField("", text: $phone)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.phonePad)
                }
            }
        }
    }
} 