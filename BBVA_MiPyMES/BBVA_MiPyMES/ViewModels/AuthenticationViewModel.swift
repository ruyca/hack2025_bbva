import Foundation
import Combine
import FirebaseAuth
import LocalAuthentication
import Security

// Enum to handle the authentication state
// Add Conformance to Equatable
enum AuthenticationState: Equatable {
    case unauthenticated // User needs to log in or register
    case authenticating // Authentication process is in progress (e.g., email/password login)
    case authenticated // User is logged in (fully accessible)
    case error(String) // Authentication failed (payload is the error message)
    case requiresBiometricUnlock // User exists (from Firebase), needs biometric to access content
    case authenticatingBiometric // Biometric process is in progress
}
// Note: For .error(String), Equatable conformance means two .error cases are equal
// ONLY if the associated string is also equal. This is the default behavior.

final class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = "" // For registration
    @Published var errorMessage: String?
    @Published var currentState: AuthenticationState = .unauthenticated

    // To show a prompt offering biometric setup after successful initial login/reg
    @Published var shouldPromptForBiometricsSetup = false
    // To trigger the LAContext prompt from the View
    @Published var shouldTriggerBiometricAuthentication = false

    // Computed property to access the *actual* current Firebase User
    var currentUser: User? {
        return Auth.auth().currentUser
    }

    // Listener handle to remove it on deinit
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        print("AuthenticationViewModel initialized")
        // Observe Firebase Auth state changes
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // Firebase listener handles state changes.
                // We react to the presence or absence of the 'user' object provided by Firebase.

                if let user = user {
                     print("Auth State Listener: User found (\(user.uid))")
                    // If Firebase reports a user, check if they previously enabled biometrics for this user ID
                    if KeychainService.shared.isBiometricsEnabled(for: user.uid) {
                         print("Auth State Listener: Biometrics enabled for user in Keychain.")
                        // If biometrics are enabled, user needs to unlock
                         if self.currentState != .requiresBiometricUnlock && self.currentState != .authenticatingBiometric { // Avoid triggering if already in related state
                             self.currentState = .requiresBiometricUnlock
                             // Trigger the biometric prompt when the state changes to this
                             self.shouldTriggerBiometricAuthentication = true
                         }
                    } else {
                         print("Auth State Listener: Biometrics NOT enabled for user. State -> .authenticated")
                        // If no biometric flag in Keychain, user is fully authenticated (assuming Firebase auth succeeded via email/password or a previous session).
                        self.currentState = .authenticated
                         // Ensure biometric prompt trigger is off if not needed
                         self.shouldTriggerBiometricAuthentication = false
                    }
                } else {
                     print("Auth State Listener: No user found. State -> .unauthenticated")
                    // No user logged in in Firebase
                    self.currentState = .unauthenticated
                    self.shouldPromptForBiometricsSetup = false // Reset flags
                    self.shouldTriggerBiometricAuthentication = false
                }
                self.errorMessage = nil // Clear errors on state change initiated by listener
                 print("Authentication State Updated by Listener: \(self.currentState)")

                // Clear fields when becoming unauthenticated, UNLESS we are going to requiresBiometricUnlock (as email/password fields are hidden then)
                 if self.currentState == .unauthenticated {
                    self.email = ""
                    self.password = ""
                    self.confirmPassword = ""
                }
            }
        }
         print("AuthenticationViewModel init complete. Waiting for auth state listener...")
    }

     // Clean up listener when ViewModel is deallocated
     deinit {
         if let handle = authStateDidChangeListenerHandle {
             Auth.auth().removeStateDidChangeListener(handle)
              print("Auth State Listener removed.")
         }
     }

    // --- Firebase Authentication Methods ---

    func login() {
        currentState = .authenticating // Set state to show loading indicator on login button
        errorMessage = nil
        print("Attempting login...")

        // Clear previous error message that might be from a failed biometric attempt
        // Note: Error messages are also cleared by the authStateDidChangeListener on successful login/reg
         self.errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Login failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.currentState = .error(error.localizedDescription) // Transition to error state on failure
                } else if let user = authResult?.user {
                    print("Login successful for user: \(user.uid)")
                    // Login successful via email/password.
                    // The Firebase Auth State Listener will be triggered next by Firebase
                    // and handle setting the correct 'authenticated' or 'requiresBiometricUnlock' state.

                    // After successful *initial* login/registration, we check if biometrics
                    // is *available* and *not already enabled* for this user, and then prompt setup.
                     if self?.canDeviceAuthenticateWithBiometrics() == true &&
                        KeychainService.shared.isBiometricsEnabled(for: user.uid) == false {
                          print("Login successful, prompting for biometrics setup.")
                         self?.shouldPromptForBiometricsSetup = true // This will trigger the setup alert in the View
                     } else {
                         print("Login successful, NOT prompting for biometrics setup (device capability/already enabled).")
                     }
                    // State will be set by the listener based on Keychain flag
                     // No need to set state here manually unless handling a very specific edge case
                     // that the listener doesn't cover immediately.
                     // For most cases, the listener handles the post-login state.


                } else {
                    // Should theoretically not happen if error is nil, but good practice
                    print("Login failed: No user in authResult and no error.")
                    self?.errorMessage = "Login failed unexpectedly."
                    self?.currentState = .error("Login failed unexpectedly.")
                }
                // Clear password field after attempt for security (keep email for convenience)
                self?.password = ""
            }
        }
    }

    func register() {
        currentState = .authenticating // Set state to show loading indicator
        errorMessage = nil
        print("Attempting registration...")

        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden." // More user-friendly message
            currentState = .error(errorMessage!)
             print("Registration failed: Passwords do not match.")
            return
        }
         // Clear any previous error message that might be from a failed biometric attempt
         self.errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Registration failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    self?.currentState = .error(error.localizedDescription) // Transition to error state on failure
                } else if let user = authResult?.user {
                    print("Registration successful for user: \(user.uid)")
                    // Registration successful.
                    // The Firebase Auth State Listener will be triggered next by Firebase
                    // and handle setting the 'authenticated' state.

                     // After successful registration, we check if biometrics
                     // is *available* and then prompt setup. It won't be enabled yet.
                     if self?.canDeviceAuthenticateWithBiometrics() == true {
                         print("Registration successful, prompting for biometrics setup.")
                         self?.shouldPromptForBiometricsSetup = true // This will trigger the setup alert
                     } else {
                         print("Registration successful, NOT prompting for biometrics setup (device capability).")
                     }
                     // State will be set by the listener.


                } else {
                     // Should theoretically not happen if error is nil
                     print("Registration failed: No user in authResult and no error.")
                    self?.errorMessage = "Registration failed unexpectedly."
                    self?.currentState = .error("Registration failed unexpectedly.")
                }
                 // Clear fields after attempt (success or failure)
                self?.password = ""
                self?.confirmPassword = ""
            }
        }
    }

    func signOut() {
        print("Attempting sign out...")
        // Remove the biometric flag from Keychain for the current user *before* signing out of Firebase
        // Access currentUser via the computed property
        if let userId = self.currentUser?.uid {
             let status = KeychainService.shared.removeBiometricsEnabled(for: userId)
             if status == errSecSuccess || status == errSecItemNotFound {
                 print("Biometric flag removed from Keychain for user \(userId)")
             } else {
                 print("Failed to remove biometric flag from Keychain: \(status)")
                 // Decide how to handle this error - maybe show a message but proceed with sign out
             }
         }

        do {
            try Auth.auth().signOut()
            // Firebase Auth State Listener will handle setting currentState back to .unauthenticated
            print("Firebase sign out successful.")
            // The listener will set state, clearing fields and error message.
        } catch let signOutError as NSError {
            print("Error signing out Firebase: %@", signOutError)
            self.errorMessage = signOutError.localizedDescription
            // The listener will likely set state to unauthenticated anyway, but showing the error is good.
            self.currentState = .error(signOutError.localizedDescription)
        }
    }

    // --- Biometric Setup and Authentication Methods ---

    // Check if biometrics are physically possible and enrolled on the device
     func canDeviceAuthenticateWithBiometrics() -> Bool {
         let context = LAContext()
         var error: NSError?
         // Check if biometrics is available and enrolled
         // Ensure the policy is supported first, then evaluate if it *can* be evaluated
         // The second check `canEvaluatePolicy` with error checks if it's *currently* possible (e.g. enrolled)
         return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
     }

    // Call this when the user agrees to enable biometrics after initial login/reg
    func enableBiometrics() {
         print("User agreed to enable biometrics.")
        // Access currentUser via the computed property
        guard let userId = self.currentUser?.uid else {
            print("Error: No current user to enable biometrics for.")
            self.errorMessage = "Ocurrió un error interno (usuario no encontrado)."
            self.shouldPromptForBiometricsSetup = false // Hide the prompt
            return
        }
         // Ensure device actually supports it before prompting
         guard canDeviceAuthenticateWithBiometrics() else {
              print("Error: Device does not support biometrics or not enrolled.")
             self.errorMessage = "Tu dispositivo no tiene configurada la autenticación biométrica."
             self.shouldPromptForBiometricsSetup = false // Hide the prompt if not supported
             return
         }

        let context = LAContext()
        let reason = "Permite usar Face ID / Touch ID para futuros inicios de sesión."

        // Prompt the user to *allow* using biometrics for this app (system prompt)
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
             DispatchQueue.main.async {
                if success {
                    print("Biometric consent given by user.")
                    // Biometric consent given, now save the flag in Keychain
                    let status = KeychainService.shared.setBiometricsEnabled(for: userId)
                    if status == errSecSuccess {
                        print("Biometrics enabled and saved to Keychain for user: \(userId)")
                        // No need to change state, they are already .authenticated from initial login/reg
                         self?.errorMessage = "Autenticación biométrica habilitada." // Optional success message
                    } else {
                        print("Failed to save biometric flag to Keychain: \(status)")
                        self?.errorMessage = "Error al guardar la configuración biométrica. (\(status))"
                        // Decide how to handle Keychain errors - may indicate device issues
                    }
                } else {
                    // Biometric consent denied or failed (e.g., user tapped cancel in the system prompt)
                    print("Biometric setup consent denied or failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                     // Don't set a critical error state here, user just declined or failed setup
                    self?.errorMessage = "Configuración biométrica cancelada." // Informative message
                }
                 self?.shouldPromptForBiometricsSetup = false // Hide the setup prompt after user interaction
             }
         }
    }

    // Call this when currentState is .requiresBiometricUnlock (on app launch or return)
    // This method is triggered by the View observing `shouldTriggerBiometricAuthentication`
    func triggerBiometricAuthentication() {
         print("Triggering biometric authentication...")
        // Access currentUser via the computed property
         guard let userId = self.currentUser?.uid, // Ensure Firebase still reports a user
               canDeviceAuthenticateWithBiometrics() // Ensure device supports it
         else {
             print("Cannot trigger biometric auth: Conditions not met (no user or biometrics unavailable).")
              // If we were in .requiresBiometricUnlock state but conditions changed,
              // transition back to unauthenticated.
              if self.currentState == .requiresBiometricUnlock {
                  self.currentState = .unauthenticated
                   self.errorMessage = "No se pudo usar la autenticación biométrica. Por favor, inicia sesión con tu correo y contraseña."
              }
             self.shouldTriggerBiometricAuthentication = false // Reset trigger
             return
         }

         // Set state to indicate that biometric authentication is in progress
         self.currentState = .authenticatingBiometric // New state

         let context = LAContext()
         let reason = "Accede a tu cuenta de BBVA Empresas" // Message shown in the system prompt

         context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
             DispatchQueue.main.async {
                 if success {
                     print("Biometric authentication successful!")
                     // Biometric unlock successful. Verify the user is still logged in Firebase.
                     // Firebase Auth state listener should already have confirmed currentUser is not nil.
                     // We can now transition from requiresBiometricUnlock/authenticatingBiometric to fully authenticated.
                     self?.currentState = .authenticated
                      self?.errorMessage = nil // Clear any previous error message
                     print("Authentication State Updated: \(self?.currentState ?? .unauthenticated)")

                 } else {
                     // Biometric authentication failed (e.g., incorrect face, fingerprint, user cancelled, locked out)
                     print("Biometric authentication failed: \(authenticationError?.localizedDescription ?? "Unknown error")")
                     self?.errorMessage = authenticationError?.localizedDescription ?? "Autenticación biométrica fallida."

                     // Handle different LAError codes:
                     if let error = authenticationError as? LAError {
                         switch error.code {
                         case .userCancel, .systemCancel, .appCancel, .userFallback:
                             // User cancelled, system cancelled, app cancelled, or user chose fallback (password)
                             print("Biometric auth cancelled/fallback. Transitioning to unauthenticated.")
                              // Go back to login screen to allow password login
                             self?.currentState = .unauthenticated
                             self?.errorMessage = "Inicia sesión con tu correo y contraseña." // Clear error message specifically for these cases
                             self?.email = "" // Clear fields for manual login
                             self?.password = ""
                         case .authenticationFailed:
                            // Biometric mismatch or other failure during evaluation
                            print("Biometric auth failed. Transitioning to unauthenticated.")
                             self?.errorMessage = "No se reconoció tu Face ID o Touch ID. Inténtalo de nuevo o inicia sesión con tu contraseña."
                             // Go back to unauthenticated to allow password login
                             self?.currentState = .unauthenticated
                             self?.email = ""
                             self?.password = ""
                         case .biometryNotEnrolled, .biometryLockout, .biometryNotAvailable:
                             // Biometry not configured, locked out after too many attempts, or not available on device
                             print("Biometry not available/locked out/not enrolled. Transitioning to unauthenticated.")
                             self?.errorMessage = "Problemas con la autenticación biométrica. Por favor, inicia sesión con tu correo y contraseña."
                             self?.currentState = .unauthenticated // Force password login
                              self?.email = ""
                              self?.password = ""
                         @unknown default:
                             // Unknown errors
                             print("Biometric auth unknown error. Transitioning to unauthenticated.")
                              self?.errorMessage = "Ocurrió un error con la autenticación biométrica. Por favor, inicia sesión con tu correo y contraseña."
                              self?.currentState = .unauthenticated
                               self?.email = ""
                               self?.password = ""
                         }
                     } else {
                         // Non-LAError errors
                         print("Biometric auth unexpected error. Transitioning to unauthenticated.")
                         self?.errorMessage = "Ocurrió un error inesperado. Por favor, inicia sesión con tu correo y contraseña."
                         self?.currentState = .unauthenticated
                          self?.email = ""
                          self?.password = ""
                     }
                 }
                 self?.shouldTriggerBiometricAuthentication = false // Reset the trigger after authentication attempt
             }
         }
     }
}
