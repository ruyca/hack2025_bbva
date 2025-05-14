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
                    .foregroundColor(Color("BBVATextColor"))
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
                        .foregroundColor(Color("BBVAErrorRed"))
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
    
    // Define BBVA brand colors
    let bbvaPrimaryBlue = Color("BBVAPrimaryBlue")
    let bbvaDarkBlue = Color("BBVADarkBlue")
    
    var body: some View {
        ZStack {
            // Background with gradient
            bbvaPrimaryBlue
                .ignoresSafeArea()
            
            // Background city image with opacity
            Image("Bellasartes")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.15)
            
            // Content
            VStack(spacing: 0) {
                // Top white space
                
                
                // BBVA Logo centered in blue bar
                ZStack {
                    Rectangle()
                        .opacity(0)
                        .frame(height: 40)
                    
                    Text("BBVA")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                    
                    
                    
                    Text("Bienvenido a Impulsa")
                        .font(.system(size: 30, ))
                        .foregroundColor(.white).padding(.top, 100)
                }
                
                // Main content area
                VStack(spacing: 32) { // Increased spacing slightly
                    Spacer().frame(height: 160)
                    
                    // Login button
                    Button {
                        showingLoginSheet = true
                    } label: {
                        Text("Iniciar sesión")
                            .font(.headline)
                            .foregroundColor(bbvaPrimaryBlue)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                            .background(Color.white)
                    }
                    .padding(.horizontal, 400) // This horizontal padding seems very large, adjust if needed
                    
                    // Registration text
                    Text("Si ya eres cliente de BBVA pero no eres usuario online.")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // Create access link
                    Button {
                        showingRegistrationSheet = true
                    } label: {
                        Text("Crear clave de acceso")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .underline()
                    }
                    
                    Spacer() // Pushes content up
                    
                    // Quick links section and Language button
                    VStack(spacing: 24) { // Vertical stack for bottom elements
                        // Quick links
                        HStack(spacing: 36) {
                            QuickLinkView(iconName: "building.columns.fill", label: "Oficinas y cajeros")
                            QuickLinkView(iconName: "house.fill", label: "BBVA valora casas")
                            QuickLinkView(iconName: "car.fill", label: "BBVA valora coches")
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


// MARK: - Custom Styles (remain unchanged)

// Custom text field style for BBVA app
struct BBVATextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// Custom button style for BBVA app
struct BBVAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color("BBVAPrimaryBlue").opacity(0.8) : Color("BBVAPrimaryBlue"))
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

// MARK: - Helper Extensions (remain unchanged)

// Extension to create rounded corners only on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// Custom shape for specific corner rounding
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
             if self.email == "test@bbva.com" && self.password == "password" {
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
