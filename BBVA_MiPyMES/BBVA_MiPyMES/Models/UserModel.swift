//
//  UserModel.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//


import Foundation

struct UserModel: Codable {
    // Registration progress tracking (Q1-Q7)
    var q1Completed: Bool = false
    var q2Completed: Bool = false
    var q3Completed: Bool = false
    var q4Completed: Bool = false
    var q5Completed: Bool = false
    var q6Completed: Bool = false
    var q7Completed: Bool = false
    
    // Track if user has seen the onboarding carousel
    var hasSeenOnboarding: Bool = false
    
    // Calculate the overall progress (0.0 to 1.0)
    var progressPercentage: Float {
        let totalSteps = 7
        let completedSteps = [q1Completed, q2Completed, q3Completed,
                              q4Completed, q5Completed, q6Completed,
                              q7Completed].filter { $0 }.count
        
        return Float(completedSteps) / Float(totalSteps)
    }
    
    // Check if registration is complete
    var isRegistrationComplete: Bool {
        return q1Completed && q2Completed && q3Completed &&
               q4Completed && q5Completed && q6Completed && q7Completed
    }
}
