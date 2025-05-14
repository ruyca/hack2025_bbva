import SwiftUI
import LocalAuthentication // Needed to check biometryType

struct BiometricUnlockView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            // --- Logo Area ---
            Image(systemName: "building.columns.fill") // Placeholder icon
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color("BBVAPrimaryBlue"))
                .padding(.bottom, 20)

            Text("BBVA Empresas")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("BBVATextColor"))

            // --- Message based on state ---
             if authViewModel.currentState == .authenticatingBiometric {
                  ProgressView("Autenticando...")
                     .foregroundColor(Color("BBVATextColor"))
             } else { // .requiresBiometricUnlock state
                Text("Desbloquea con \(LAContext().biometryType == .faceID ? "Face ID" : "Touch ID") para continuar")
                    .font(.headline)
                    .foregroundColor(Color("BBVADarkGray"))
                    .padding(.bottom, 20)

                 // --- Biometric Icon Button ---
                 Button {
                     // Trigger the biometric prompt again if the user taps the icon
                     authViewModel.shouldTriggerBiometricAuthentication = true
                 } label: {
                     Image(systemName: LAContext().biometryType == .faceID ? "faceid" : "touchid.fill")
                         .resizable()
                         .scaledToFit()
                         .frame(width: 60, height: 60) // Larger icon
                         .foregroundColor(Color("BBVAPrimaryBlue"))
                 }
                 // Only allow tapping if not already authenticating
                 .disabled(authViewModel.currentState == .authenticatingBiometric)
             }


            // --- Error Message ---
            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(Color("BBVAErrorRed"))
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }

            Spacer() // Pushes content to top

            // --- Option to use password instead ---
            Button("Usar correo y contraseña") {
                // Transition to the unauthenticated state to show the full login form
                authViewModel.currentState = .unauthenticated
                 // Also clear any pending biometric trigger request
                 authViewModel.shouldTriggerBiometricAuthentication = false
                 authViewModel.errorMessage = nil // Clear biometric error message
            }
            .foregroundColor(Color("BBVAPrimaryBlue"))
            .padding(.bottom, 40)

        }
        .padding(.horizontal, 30)
        // --- Trigger Biometric Prompt Automatically on Appear ---
        // This ensures the prompt shows when the view is presented,
        // and also if the state becomes .requiresBiometricUnlock while the view is already visible
        .onAppear {
            if authViewModel.currentState == .requiresBiometricUnlock {
                authViewModel.shouldTriggerBiometricAuthentication = true
            }
        }
        // Observe the ViewModel's trigger state (though `onAppear` handles the main case)
        // This onChange is necessary if the state could change *to* .requiresBiometricUnlock
        // while this view is already the active view.
        .onChange(of: authViewModel.shouldTriggerBiometricAuthentication) { shouldTrigger in
            if shouldTrigger {
                authViewModel.triggerBiometricAuthentication() // Call the ViewModel method
            }
        }
         // We don't need to observe authViewModel.currentState here for navigation,
         // as the App struct handles switching away from this view when state is .authenticated or .unauthenticated.
    }
}

struct BiometricUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide EnvironmentObject with different states for previewing
        BiometricUnlockView()
            .environmentObject(AuthenticationViewModel()) // Default state will likely be unauthenticated or requiresBiometricUnlock if keychain has a flag

        // Example preview for requires unlock state
         BiometricUnlockView()
             .environmentObject({
                 let vm = AuthenticationViewModel()
                 vm.currentState = .requiresBiometricUnlock
                 // vm.errorMessage = "Intentos fallidos, intenta de nuevo." // Optional: add a preview error message
                 return vm
             }())

         // Example preview for authenticating state
          BiometricUnlockView()
              .environmentObject({
                  let vm = AuthenticationViewModel()
                  vm.currentState = .authenticatingBiometric
                  return vm
              }())
    }
}
