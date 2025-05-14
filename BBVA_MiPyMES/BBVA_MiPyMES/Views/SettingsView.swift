//
//  SettingsView.swift
//  BBVA_MiPyMES
//
//  Created by Alejandro Gutiérrez Grimaldo on 13/05/25.
//

//
//  SettingsView.swift
//  BBVA_MiPyMES
//
//  Created by Alejandro Gutiérrez Grimaldo on 14/05/25. // Or your actual creation date
//

import SwiftUI
import Firebase // Import Firebase if needed for any specific Firebase types, though often just the ViewModel handles it

struct SettingsView: View {
    // Access the AuthenticationViewModel from the environment
    // This ViewModel must be provided higher up in your app's view hierarchy
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    // BBVA Colors (optional, you can reuse them from HomeView or define globally)
     let bbvaBlue = Color(red: 0.004, green: 0.345, blue: 0.663)
     let bbvaDarkBlue = Color(red: 0, green: 0.216, blue: 0.416)
     let bbvaBackground = Color(red: 0.95, green: 0.97, blue: 0.98)


    var body: some View {
        NavigationView { // Embed in NavigationView for a title bar
            Form { // Use a Form for a standard settings layout
                Section(header: Text("Cuenta")) { // Section to group account-related settings
                    // Sign Out Button
                    Button(role: .destructive) { // Use role: .destructive for red color (standard for sign out)
                        // Call the signOut method on the AuthenticationViewModel
                        // Access the wrappedValue explicitly in the closure
                        authViewModel.signOut()
                    } label: {
                        // Use an HStack for the text and potentially an icon
                        HStack {
                            Text("Cerrar Sesión")
                            Spacer() // Push the text to the left
                             Image(systemName: "arrow.right.square") // Optional: Add a relevant icon
                        }
                        .foregroundColor(.red) // Ensure text is red even without .destructive role if needed
                    }
                    // Add other account-related settings here if needed later
                    // Example:
                    // Text("Cambiar Contraseña")
                    // Text("Actualizar Perfil")
                }

                // Add other settings sections here (e.g., "General", "Notificaciones", "Ayuda")
                // Section(header: Text("General")) {
                //    Toggle("Recibir notificaciones", isOn: .constant(true))
                //    Text("Idioma")
                // }

            }
            .navigationTitle("Ajustes") // Set the title for the view
            .background(bbvaBackground.edgesIgnoringSafeArea(.all)) // Apply BBVA background if desired
        }
    }
}

// MARK: - Preview



/*
 // Reminder: Your MockAuthenticationViewModel and MockUser should be defined as classes,
 // similar to this (ideally in separate files):

 import Foundation
 import FirebaseAuth // Import FirebaseAuth for User protocol
 import Combine

 class MockAuthenticationViewModel: ObservableObject {
     @Published var user: User? = MockUser(uid: "mock_user_id")
     @Published var isAuthenticated = true
     @Published var isLoading = false
     @Published var errorMessage: String?

     func signIn(email: String, password: String) {}
     func signUp(email: String, password: String) {}
     func signOut() {
         user = nil
         isAuthenticated = false
         print("Mock Sign Out Called")
     }
     func checkAuthenticationState() {}
 }

 class MockUser: User {
     var uid: String
     var providerID: String = "mock"
     var isAnonymous: Bool = false

     // Implement other required User protocol properties and methods as stubs
     var email: String? { nil }
     var displayName: String? { nil }
     var photoURL: URL? { nil }
     var phoneNumber: String? { nil }
     var metadata: UserMetadata? { nil } // Requires Firebase.UserMetadata
     var providerData: [UserInfo] { [] } // Requires Firebase.UserInfo
     var refreshToken: String { "mock_refresh_token" } // Required

     init(uid: String) { // Simplified initializer for the mock
         self.uid = uid
     }

     // Implement required methods as stubs
     func getIDToken(completion: @escaping AuthDataResultCallback) { completion(nil, nil) }
     func getIDTokenResult(completion: @escaping AuthDataResultCallback) { completion(nil, nil) }
     func link(with credential: AuthCredential, completion: @escaping AuthDataResultCallback) { completion(nil, nil) }
     func reauthenticate(with credential: AuthCredential, completion: @escaping AuthDataResultCallback) { completion(nil, nil) }
     func unlink(fromProvider provider: String, completion: @escaping AuthDataResultCallback) { completion(nil, nil) }
     func updateEmail(to email: String, completion: @escaping ErrorCallback) { completion(nil) }
     func updatePassword(to password: String, completion: @escaping ErrorCallback) { completion(nil) }
     func sendEmailVerification(completion: @escaping ErrorCallback) { completion(nil) }
     func delete(completion: @escaping ErrorCallback) { completion(nil) }
     func copy(with zone: NSZone? = nil) -> Any { MockUser(uid: self.uid) } // Basic copy
 }
 */
