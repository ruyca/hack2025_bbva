import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        Group {
            switch authViewModel.currentState {
            case .unauthenticated, .error:
                // Show authentication screens when user is not logged in
                AuthenticationView()
                
            case .authenticating:
                // Loading view while authentication is in progress
                ProgressView("Autenticando...")
                    .progressViewStyle(CircularProgressViewStyle())
                
            case .requiresBiometricUnlock, .authenticatingBiometric:
                // Show biometric unlock screen
                BiometricUnlockView()
                
            case .authenticated:
                // Show main app content when user is authenticated
                MainAppContentView()
            }
        }
        .environmentObject(authViewModel)
    }
}

// Main app content after authentication
struct MainAppContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            HomeView()
                .environmentObject(authViewModel)
                .environmentObject(homeViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Inicio")
                }
                .tag(0)
            
            // Payment tab
            BBVAPaymentView()
                .environmentObject(homeViewModel)
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cobrar")
                }
                .tag(1)
            
            // Financial Health tab
            FinancialHealth()
                .tabItem {
                    Image(systemName: "heart.text.square.fill")
                    Text("Salud Financiera")
                }
                .tag(2)
            
            // Management tab (placeholder - could be QuadrantHeatmapView)
            QuadrantHeatmapView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Gestión")
                }
                .tag(3)
            
            // Settings tab (placeholder)
           
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Más")
                }
                .tag(4)
        }
        .accentColor(Color(red: 0.004, green: 0.345, blue: 0.663)) // BBVA Blue
    }
}
