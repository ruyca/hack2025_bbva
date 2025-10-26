import SwiftUI
import Combine
import AuthenticationServices
import LocalAuthentication

// MARK: - QuickLinkView (remains unchanged)

struct QuickLinkView: View {
    let iconName: String
    let label: String

    var body: some View {
        Button {
            print("Quick link tapped: \(label)")
        } label: {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 80)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - LoginFieldsView (remains unchanged)

struct LoginFieldsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Ingresa tus credenciales")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.BBVATextPrimary)
                    .padding(.bottom)

                TextField("Correo electrónico", text: $authViewModel.email)
                    .textFieldStyle(BBVATextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)

                SecureField("Contraseña", text: $authViewModel.password)
                    .textFieldStyle(BBVATextFieldStyle())
                    .textContentType(.password)

                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color.BBVAError)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                Button {
                    authViewModel.login()
                } label: {
                    if authViewModel.currentState == .authenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Confirmar Inicio de Sesión")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BBVAButtonStyle())
                .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.currentState == .authenticating)

                Spacer()
            }
            .padding()
            .navigationTitle("Iniciar Sesión")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                        authViewModel.errorMessage = nil
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

// MARK: - LoginView

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showingRegistrationSheet = false
    @State private var showingLoginSheet = false
    // New state variable for the language sheet
    @State private var showingLanguageSheet = false
    
    // Define BBVA brand colors (Modern Fintech)
    let BBVAPrimaryRed = Color.BBVAPrimaryRed
    let BBVACharcoal = Color.BBVACharcoal
    
    var body: some View {
        ZStack {
            // Background with gradient - Modern Blue
            LinearGradient(
                gradient: Gradient(colors: [Color.BBVAPrimaryRed, Color.BBVADarkRed]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Background city image with opacity
            Image("Bellasartes")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.1)
            
            // Content
            VStack(spacing: 0) {
                // Top white space
                
                
                // BBVA Logo centered
                ZStack {
                    Rectangle()
                        .opacity(0)
                        .frame(height: 40)
                    
                    Text("BBVA")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(2)
                    
                    
                    
                    Text("Tu aliado financiero")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.9)).padding(.top, 100)
                }
                
                // Main content area
                VStack(spacing: 32) { // Increased spacing slightly
                    Spacer().frame(height: 160)
                    
                    // Login button - Modernizado
                    Button {
                        showingLoginSheet = true
                    } label: {
                        HStack {
                            Text("Iniciar sesión")
                                .font(.system(size: 17, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(Color.BBVABlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Registration text
                    Text("¿Primera vez en BBVA? Crea tu cuenta en minutos.")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    // Create access link
                    Button {
                        showingRegistrationSheet = true
                    } label: {
                        Text("Crear cuenta")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    Spacer() // Pushes content up
                    
                    // Quick links section and Language button
                    VStack(spacing: 24) { // Vertical stack for bottom elements
                        // Quick links - Actualizados
                        HStack(spacing: 36) {
                            QuickLinkView(iconName: "building.2.fill", label: "Oficinas")
                            QuickLinkView(iconName: "chart.line.uptrend.xyaxis", label: "Inversiones")
                            QuickLinkView(iconName: "creditcard.fill", label: "Tarjetas")
                        }
                        .padding(.horizontal) // Add some horizontal padding if needed
                        
                        // Language Button
                        Button {
                            showingLanguageSheet = true
                        } label: {
                            Text("Español")
                                .font(.caption) // Smaller font to fit with quick links
                                .foregroundColor(.white)
                                .underline() // Often language options are underlined links
                        }
                        .padding(.top, 8) // Add some space above the button
                    }
                    .padding(.bottom, 24) // Padding below the bottom stack

                    // Add another Spacer below the bottom stack if you want to push the bottom stack up
                     Spacer() // Adjust or remove based on desired layout
                }
            }
            .navigationBarHidden(true)
            
            // MARK: Sheets
            
            .sheet(isPresented: $showingRegistrationSheet) {
                RegistrationView() // Make sure RegistrationView exists
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingLoginSheet) {
                LoginFieldsView()
                    .environmentObject(authViewModel)
            }
            // New sheet for language selection
            .sheet(isPresented: $showingLanguageSheet) {
                LanguageSelectionSheet()
            }
            
            // MARK: Biometric Logic (remains unchanged)
            
            .onChange(of: authViewModel.shouldTriggerBiometricAuthentication) {  shouldTrigger in
                if shouldTrigger {
                    authViewModel.triggerBiometricAuthentication()
                }
            }
            .alert("Habilitar Autenticación Biométrica", isPresented: $authViewModel.shouldPromptForBiometricsSetup) {
                Button("Sí", role: .none) {
                    authViewModel.enableBiometrics()
                }
                Button("Ahora No", role: .cancel) {
                    authViewModel.shouldPromptForBiometricsSetup = false
                }
            } message: {
                Text("¿Te gustaría usar Face ID o Touch ID para iniciar sesión más rápido la próxima vez?")
            }
        }
    }
}

// MARK: - LanguageSelectionSheet (New Placeholder View)

struct LanguageSelectionSheet: View {
    @Environment(\.dismiss) var dismiss

    // Placeholder list of languages
    let languages = ["Español", "Náhuatl", "Maya", "Otomí", "Mixteco", "Zapoteco", "Inglés"] // Add more as needed

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Idiomas disponibles")) {
                    ForEach(languages, id: \.self) { lang in
                        Button {
                            print("Selected language (placeholder): \(lang)")
                            // In a real app, you would change the language here
                            // and dismiss the sheet
                            dismiss()
                        } label: {
                            HStack {
                                Text(lang)
                                Spacer()
                                // Indicate current language (optional placeholder)
                                if lang == "Español" { // Assuming Spanish is default
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary) // Ensure text color is readable in list
                    }
                }
            }
            .navigationTitle("Seleccionar Idioma")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - Custom Styles (Modern BBVA)

// Custom text field style for BBVA app
struct BBVATextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(14)
            .background(Color.white.opacity(0.15))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            .foregroundColor(.white)
    }
}

// Custom button style for BBVA app
struct BBVAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(14)
            .background(configuration.isPressed ? Color.BBVABlue.opacity(0.9) : Color.BBVABlue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Preview (remains unchanged)

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel()) // Ensure you have an AuthenticationViewModel
    }
}

// This is a placeholder and should be implemented - AuthenticationViewModel
// You would need to provide a basic AuthenticationViewModel class for this to compile and run.
/*
 class AuthenticationViewModel: ObservableObject {
     @Published var email = ""
     @Published var password = ""
     @Published var errorMessage: String? = nil
     @Published var currentState: AuthenticationState = .idle
     @Published var isAuthenticated = false
     @Published var shouldTriggerBiometricAuthentication = false
     @Published var shouldPromptForBiometricsSetup = false
     
     enum AuthenticationState {
         case idle
         case authenticating
         case success
         case failed
     }
     
     func login() {
         // Placeholder login logic
         currentState = .authenticating
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Simulate network delay
             if self.email == "test@BBVA.com" && self.password == "password" {
                 self.isAuthenticated = true
                 self.currentState = .success
                 self.errorMessage = nil
                 // Simulate prompting for biometrics after successful login
                 self.shouldPromptForBiometricsSetup = true // Trigger the alert
                 print("Login successful")
             } else {
                 self.isAuthenticated = false
                 self.currentState = .failed
                 self.errorMessage = "Credenciales incorrectas. Intenta de nuevo."
                 print("Login failed")
             }
         }
     }
     
     func triggerBiometricAuthentication() {
          print("Triggering biometric authentication...")
         // Placeholder for LAContext evaluation
         let context = LAContext()
         var error: NSError?
         
         if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
             let reason = "Authenticate to access your BBVA account."
             context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                 DispatchQueue.main.async {
                     if success {
                         self.isAuthenticated = true
                         print("Biometric authentication successful")
                     } else {
                         // Handle authentication error
                         self.isAuthenticated = false
                         print("Biometric authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                     }
                     self.shouldTriggerBiometricAuthentication = false // Reset trigger
                 }
             }
         } else {
             // Biometrics not available or configured
             self.shouldTriggerBiometricAuthentication = false // Reset trigger
             print("Biometric authentication not available: \(error?.localizedDescription ?? "Device does not support biometrics or is not configured")")
             // Maybe show a message to the user or fallback to password
         }
     }
     
     func enableBiometrics() {
         // In a real app, you'd save a flag or handle the setup flow here.
         // For this example, we just acknowledge the user's choice and potentially
         // set a flag that influences whether to prompt next time or attempt auth.
         print("Biometrics enabled (placeholder)")
         self.shouldPromptForBiometricsSetup = false // Dismiss the setup alert
         // You might set a flag here like userDefaults.set(true, forKey: "biometricsEnabled")
     }
 }
 */
