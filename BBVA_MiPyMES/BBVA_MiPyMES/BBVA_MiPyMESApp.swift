//
//  BBVA_MiPyMESApp.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI

@main
struct BBVA_MiPyMESApp: App {
    @State private var showLaunchScreen = true //Control de aparición
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    SplashScreenView()
                        .onAppear {
                            //Temporizador para ocultar la launch screen después de X segundos
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                withAnimation {
                                    showLaunchScreen = false
                                }
                            }
                        }
                } else {
                    FinancialHealth()
                }
            }
            .ignoresSafeArea()
        }
    }
}
