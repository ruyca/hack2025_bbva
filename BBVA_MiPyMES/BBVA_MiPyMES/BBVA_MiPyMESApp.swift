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
    
struct BBVA_MiPyMESApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    SplashScreenView()
                        .onAppear {
                            //Temporizador para ocultar la launch screen después de X segundos
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation {
                                    showLaunchScreen = false
                                }
                            }
                        }
                } else {
                     ContentView()
                    .environmentObject(authViewModel)
                }
            }
            .ignoresSafeArea()
        }
    }
}

// Main content view that handles routing based on authentication state
