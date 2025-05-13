//
//  ContentView.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
import SwiftUI

struct BancarizarView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var showOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            // Main content background
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Progress Bar at the top
                if !showOnboarding {
                    ProgressBarView(progress: viewModel.user.progressPercentage)
                        .frame(height: 10)
                        .padding(.horizontal)
                        .animation(.easeInOut, value: viewModel.user.progressPercentage)
                    
                    Text("Registration Progress: \(Int(viewModel.user.progressPercentage * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Display the 7 registration steps
                        ForEach(1...7, id: \.self) { step in
                            RegistrationStepView(
                                step: step,
                                isCompleted: isStepCompleted(step),
                                toggleStep: {
                                    viewModel.toggleStep(step: step)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // Show onboarding only if the user hasn't seen it
            if showOnboarding {
                OnboardingView(
                    pages: viewModel.onboardingPages,
                    currentPage: $viewModel.currentOnboardingPage,
                    onCompletion: {
                        withAnimation {
                            showOnboarding = false
                        }
                        viewModel.completeOnboarding()
                    }
                )
                .transition(.opacity)
                .zIndex(1) // Ensure onboarding is on top
            }
        }
        .onAppear {
            // Check if we need to show onboarding
            showOnboarding = !viewModel.user.hasSeenOnboarding
        }
        .navigationBarTitle("Registration", displayMode: .inline)
        // For testing - add a way to reset progress and show onboarding again
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.resetProgress()
                    showOnboarding = true
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    // Helper function to check if a step is completed
    private func isStepCompleted(_ step: Int) -> Bool {
        switch step {
        case 1: return viewModel.user.q1Completed
        case 2: return viewModel.user.q2Completed
        case 3: return viewModel.user.q3Completed
        case 4: return viewModel.user.q4Completed
        case 5: return viewModel.user.q5Completed
        case 6: return viewModel.user.q6Completed
        case 7: return viewModel.user.q7Completed
        default: return false
        }
    }
}

// MARK: - Progress Bar View
struct ProgressBarView: View {
    var progress: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                    .cornerRadius(10)
                
                // Progress
                Rectangle()
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .frame(width: CGFloat(progress) * geometry.size.width)
            }
        }
    }
}

// MARK: - Registration Step View
struct RegistrationStepView: View {
    let step: Int
    let isCompleted: Bool
    let toggleStep: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Paso \(step)")
                    .font(.headline)
                    .foregroundColor(isCompleted ? .green : .primary)
                
                Text(stepDescription(for: step))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: toggleStep) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.green : Color.gray, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                            .font(.system(size: 14, weight: .bold))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // Function to return specific description for each step
    private func stepDescription(for step: Int) -> String {
        switch step {
        case 1:
            return "Verifica tu identidad subiendo una identificación oficial vigente"
        case 2:
            return "Comprueba tu domicilio con un comprobante reciente"
        case 3:
            return "Completa tu información personal y datos de contacto"
        case 4:
            return "Ingresa los detalles de tu actividad económica y negocio"
        case 5:
            return "Define tus preferencias bancarias y servicios deseados"
        case 6:
            return "Revisa y acepta los términos y condiciones del servicio"
        case 7:
            return "Programa una cita con un ejecutivo para finalizar el proceso"
        default:
            return "Completa el paso \(step) del proceso de registro"
        }
    }
}


// MARK: - Onboarding View (Carousel)
struct OnboardingView: View {
    let pages: [OnboardingPage]
    @Binding var currentPage: Int
    let onCompletion: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 450)
                .background(Color.appTerciaryBlue)
                .cornerRadius(16)
                .padding(.horizontal, 20)
                
                // Skip/Next buttons
                HStack {
                    Button("Saltar") {
                        onCompletion()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Empecemos" : "Siguiente") {
                        if currentPage == pages.count - 1 {
                            onCompletion()
                        } else {
                            currentPage += 1
                        }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

// MARK: - Individual Onboarding Page
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image would come from your assets
                Image(page.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                Text(page.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
                    // Remove any line limit to show all text
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 30)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct BancarizarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BancarizarView(viewModel: UserViewModel())
        }
    }
}
