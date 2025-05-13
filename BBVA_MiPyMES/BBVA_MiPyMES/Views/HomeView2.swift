//
//  HomeView2.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI

// MARK: - Home View (Destination after registration)
struct HomeView2: View {
    var body: some View {
        VStack {
            Text("¡Bienvenido!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)
            
            Text("Has completado tu registro exitosamente")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top, 50)
        .navigationBarTitle("Inicio", displayMode: .inline)
    }
}
