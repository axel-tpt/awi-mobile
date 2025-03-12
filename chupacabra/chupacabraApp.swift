import SwiftUI

@main
struct chupacabraApp: App {
    @StateObject private var loggedUserVM = LoggedUserViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(loggedUserVM)
        }
    }
} 
