//
//  ContentView.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.

import SwiftUI

struct BancarizarView: View {
    @ObservedObject var viewModel: UserViewModel
    @State private var showOnboarding: Bool = false
    @State private var showCelebration: Bool = false
    @State private var previousCompletionState: Bool = false
    
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
                    
                    Text("Progreso: \(Int(viewModel.user.progressPercentage * 100))%")
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
                                    
                                    // Check if all steps are now completed
                                    if viewModel.user.isRegistrationComplete && !previousCompletionState {
                                        withAnimation {
                                            showCelebration = true
                                        }
                                        
                                        // Schedule to hide the celebration after a delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                            withAnimation {
                                                showCelebration = false
                                            }
                                        }
                                    }
                                    
                                    // Update the previous state
                                    previousCompletionState = viewModel.user.isRegistrationComplete
                                }
                            )
                        }
                        
                        // Add space at the bottom for the floating button
                        Spacer(minLength: 70)
                    }
                    .padding()
                }
            }
            
            // Completion button that appears when all steps are completed
            if viewModel.user.isRegistrationComplete {
                VStack {
                    Spacer()
                    
                    NavigationLink(destination: HomeView2()) {
                        Text("Completar Registro")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue) // Or Color("appPrimaryBlue")
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.user.isRegistrationComplete)
            }
            
            // Celebration animation overlay
            if showCelebration {
                CelebrationView()
                    .transition(.opacity)
                    .zIndex(2)
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
            // Initialize the previous state
            previousCompletionState = viewModel.user.isRegistrationComplete
        }
        .navigationBarTitle("Registro", displayMode: .inline)
        // For testing - add a way to reset progress and show onboarding again
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.resetProgress()
                    showOnboarding = true
                    previousCompletionState = false
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

// MARK: - Celebration Animation View
struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.blue, .green, .yellow, .red, .purple, .orange]
    
    init() {
        // Create a bunch of particles with random positions
        var initialParticles: [ConfettiParticle] = []
        for _ in 0..<100 {
            initialParticles.append(ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: -20
                ),
                color: colors.randomElement() ?? .blue,
                angle: Double.random(in: -Double.pi/4...Double.pi/4),
                scale: CGFloat.random(in: 0.5...1.5)
            ))
        }
        _particles = State(initialValue: initialParticles)
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            // Confetti particles
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: 10, height: 10)
                    .scaleEffect(particle.scale)
                    .rotationEffect(Angle(radians: particle.angle))
                    .position(particle.position)
            }
            
            // Success message
            VStack {
                Text("¡Felicidades!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("Has completado todos los pasos")
                    .font(.title2)
                    .foregroundColor(.white)
                    .shadow(radius: 3)
                    .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.8))
                    .shadow(radius: 10)
            )
            .scaleEffect(1.2)
        }
        .onAppear {
            // Animate particles falling when the view appears
            withAnimation(Animation.easeOut(duration: 3.0)) {
                for i in particles.indices {
                    particles[i].position.y = UIScreen.main.bounds.height + 20
                    particles[i].angle += Double.random(in: -Double.pi...Double.pi)
                }
            }
        }
    }
}

// Model for confetti particles
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    var angle: Double
    let scale: CGFloat
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
            return "Recibir autorización de la Secretaría de Economía para usar el nombre."
        case 2:
            return "Elaborar el acta constitutiva de la empresa con ayuda de un notario."
        case 3:
            return "Hacer el aviso de uso de denominación."
        case 4:
            return "Inscribirse en el Registro Público de Comercio."
        case 5:
            return "Inscribirse en el Registro Federal de Contribuyentes."
        case 6:
            return "Registrarse ante el IMSS."
        case 7:
            return "Darse de alta en los demás organismos requeridos."
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
