//
//  SplashScreenView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    //Control de etapas
    @State private var currentStage = 0
    //Animaciones
    @State private var barsHeight: [CGFloat] = [10, 30, 50, 20]
    @State private var logoOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 1.2
    
    let stageIcons = ["CashLaunchScreen", "chart.bar.fill", "CompanyLaunchScreen"]
    
    var body: some View {
        ZStack {
            Color(.backgroundApp)
            
            //Contenido de las etapas
            Group {
                if currentStage == 0 {
                    Image(stageIcons[0])
                        .resizable()
                        .scaledToFit()
                     
                    
                } else if currentStage == 1 {
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(0..<barsHeight.count, id: \.self) { index in
                            Rectangle()
                                .fill(Color.littleBlue)
                                .frame(width: 30, height: barsHeight[index])
                        }
                    }
                    
                } else {
                    Image(stageIcons[2])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 340)
                }
            }
            .padding(.top, 50)
            
            
            Image("LogoBBVALaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .scaleEffect(logoScale)
                .offset(y: logoOffset)
        }
        .ignoresSafeArea()
        .onAppear {
            //1.Animación inicial del logo
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOffset = -250
            }
            
            //2.Mostrar contenido de la etapa 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.2)) {
                }
                
                //3.Transición a etapa 1 (barras)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation {
                        currentStage = 1
                        withAnimation(.easeInOut(duration: 1.5)) {
                            barsHeight = [120, 180, 150, 200]
                        }
                    }
                    
                    //4.Transición a etapa 2 (edificio)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            currentStage = 2
                        }
                    }
                }
            }
        }
    }
}
