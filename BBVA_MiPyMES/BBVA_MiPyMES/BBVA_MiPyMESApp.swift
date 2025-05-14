import SwiftUI
import Firebase

@main
struct BBVAMiPyMEsApp: App {
    // Create the AuthenticationViewModel as a StateObject for app-wide use
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        // Configure Firebase when app launches
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

// Main content view that handles routing based on authentication state
