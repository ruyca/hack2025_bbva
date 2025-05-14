// AuthenticationView.swift
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showRegistration = false // Estado para alternar entre Login y Registro

    var body: some View {
        NavigationView { // Opcional, pero ayuda con títulos y navegación
            VStack {
                if showRegistration {
                    RegistrationView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
                
            }
           
         
           
        }
        .navigationViewStyle(.stack) // Para evitar problemas en iPad
    }
}

// MARK: - Preview
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AuthenticationViewModel()) // Proporcionar un ViewModel para la preview
    }
}
