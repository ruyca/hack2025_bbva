//
//  UserViewModel.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//


import Foundation
import SwiftUI
import Combine

class UserViewModel: ObservableObject {
    @Published var user: UserModel
    @Published var currentOnboardingPage: Int = 0
    
    // Content for onboarding carousel
    let onboardingPages = [
        OnboardingPage(title: "Bienvenido", description: "Bancarizarse nunca ha sido tan fácil", image: "bbva_logo3"),
        OnboardingPage(title: "Registra tu progreso", description: "Nuestra interfaz step-by-step te ayuda a reunir los pasos necesarios para formalizar tu negocio.", image: "registrar_progreso"),
        OnboardingPage(title: "¿Necesitas ayuda?", description: "Pregúntale a Pym nuestro asistente virtual.", image: "Jimmy")
    ]
    
    init(user: UserModel = UserModel()) {
        self.user = user
        
        // Load saved user data from UserDefaults or other persistence
        loadUserData()
    }
    
    // Toggle completion status of a specific step
    func toggleStep(step: Int) {
        switch step {
        case 1:
            user.q1Completed.toggle()
        case 2:
            user.q2Completed.toggle()
        case 3:
            user.q3Completed.toggle()
        case 4:
            user.q4Completed.toggle()
        case 5:
            user.q5Completed.toggle()
        case 6:
            user.q6Completed.toggle()
        case 7:
            user.q7Completed.toggle()
        default:
            break
        }
        
        // Save changes
        saveUserData()
    }
    
    // Mark onboarding as seen
    func completeOnboarding() {
        user.hasSeenOnboarding = true
        saveUserData()
    }
    
    // Reset all progress (for testing)
    func resetProgress() {
        user = UserModel()
        saveUserData()
    }
    
    // MARK: - Data Persistence
    // We should firebase HERE
    
    private func saveUserData() {
        // Simple persistence using UserDefaults
        // In a real app, consider using Core Data or another persistence method
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "savedUserData")
        }
    }
    
    private func loadUserData() {
        if let savedData = UserDefaults.standard.data(forKey: "savedUserData"),
           let loadedUser = try? JSONDecoder().decode(UserModel.self, from: savedData) {
            user = loadedUser
        }
    }
}

// Model for onboarding carousel pages
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let image: String // Image name from Assets
}

// Note: UserModel should conform to Codable in its own file
