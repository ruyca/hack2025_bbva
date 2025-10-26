import SwiftUI
import Firebase

@main
struct BBVAMiPyMEsApp: App {
    // Create the AuthenticationViewModel as a StateObject for app-wide use
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State private var showLaunchScreen = true
    
    init() {
        // Configure Firebase when app launches
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
        
    }
}
