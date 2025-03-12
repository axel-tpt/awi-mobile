import SwiftUI
import Combine

class LoggedUserViewModel: ObservableObject {
    @Published var loggedUser: LoggedUser?
    
    init() {
        self.loggedUser = nil
    }
}
