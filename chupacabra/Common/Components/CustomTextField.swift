import SwiftUI

struct CustomTextField: View {
    let title: String
    let text: Binding<String>
    let isSecure: Bool
    
    init(_ title: String, text: Binding<String>, isSecure: Bool = false) {
        self.title = title
        self.text = text
        self.isSecure = isSecure
    }
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: text)
            } else {
                TextField(title, text: text)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .autocapitalization(.none)
    }
} 