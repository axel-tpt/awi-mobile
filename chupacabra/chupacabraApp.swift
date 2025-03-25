import SwiftUI

@main
struct chupacabraApp: App {
    @StateObject private var loggedUserVM = LoggedUserEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(loggedUserVM)
        }
    }
} 
