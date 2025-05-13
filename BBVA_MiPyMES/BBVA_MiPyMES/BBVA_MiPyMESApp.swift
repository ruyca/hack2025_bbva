//
//  BBVA_MiPyMESApp.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI

@main
struct BBVA_MiPyMESApp: App {
    // Create a shared instance of UserViewModel that can be used throughout the app
    @StateObject private var userViewModel = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                BancarizarView(viewModel: userViewModel)
            }
        }
    }
}
