import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel // Use AuthenticationViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Crea tu cuenta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("BBVATextColor"))
                    .padding(.top, 40)

                Text("Completa tus datos para empezar")
                    .font(.headline)
                    .foregroundColor(Color("BBVADarkGray"))
                    .padding(.bottom, 20)

                // --- Email Field ---
                TextField("Correo electrónico", text: $authViewModel.email)
                    .textFieldStyle(BBVATextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress) // Hint for autofill


                // --- Password Field ---
                SecureField("Contraseña", text: $authViewModel.password)
                    .textFieldStyle(BBVATextFieldStyle())
                     .textContentType(.newPassword) // Hint for autofill on registration


                // --- Confirm Password Field ---
                SecureField("Confirmar Contraseña", text: $authViewModel.confirmPassword)
                    .textFieldStyle(BBVATextFieldStyle())
                     .textContentType(.newPassword) // Hint for autofill


                // --- Error Message ---
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(Color("BBVAErrorRed"))
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }

                // --- Register Button ---
                Button {
                    authViewModel.register()
                } label: {
                    if authViewModel.currentState == .authenticating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Registrarse")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(BBVAButtonStyle())
                .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty || authViewModel.confirmPassword.isEmpty || authViewModel.currentState == .authenticating || authViewModel.password != authViewModel.confirmPassword) // Disable if passwords don't match


                // --- Link back to Login ---
                HStack {
                    Text("¿Ya tienes cuenta?")
                         .foregroundColor(Color("BBVATextColor"))
                    Button("Inicia sesión") {
                        // Clear fields and dismiss the sheet
                        authViewModel.email = ""
                        authViewModel.password = ""
                        authViewModel.confirmPassword = ""
                        authViewModel.errorMessage = nil
                        authViewModel.currentState = .unauthenticated // Ensure state is reset
                        presentationMode.wrappedValue.dismiss()
                    }
                     .foregroundColor(Color("BBVAPrimaryBlue"))
                }
                .font(.callout)
                .padding(.top, 20)


                Spacer() // Pushes content to top

            }
            .padding(.horizontal, 30)
            .navigationBarItems(trailing:
                 Button("Cancelar") {
                     // Clear fields and dismiss the sheet
                     authViewModel.email = ""
                     authViewModel.password = ""
                     authViewModel.confirmPassword = ""
                     authViewModel.errorMessage = nil
                     authViewModel.currentState = .unauthenticated // Ensure state is reset
                     presentationMode.wrappedValue.dismiss()
                 }
                 .foregroundColor(Color("BBVAPrimaryBlue"))
             )
        }
        // Dismiss the sheet automatically on successful registration (state becomes .authenticated)
        .onChange(of: authViewModel.currentState) { state in
            if state == .authenticated {
                presentationMode.wrappedValue.dismiss()
            }
        }
         // The prompt for biometrics setup is handled by LoginView since it's where the user lands after auth
    }
}

// --- Preview Provider ---
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthenticationViewModel()) // Provide the environment object for preview
    }
}
