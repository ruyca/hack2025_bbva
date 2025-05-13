//
//  RegistroPublicoComercio_4.swift
//  BBVA_MiPyMES
//
//  Created by Ruy Cabello on 13/05/25.
//

import SwiftUI


struct RegistroComercioView_4: View {
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            // Blue header background that extends to top edge
            VStack {
                Color("primaryBlue")
                    .frame(height: 150)
                    .edgesIgnoringSafeArea(.top)
                Spacer()
            }
            
            // Main content
            VStack(spacing: 0) {
                // Header title
                VStack {
                    Spacer().frame(height: 60)
                    Text("Autorización de Denominación")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(height: 120)
                .padding(.horizontal)
                
                // Scrollable content with white background
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Your content goes here
                        Group {
                            Text("Información sobre la autorización de denominación")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            Text("Aquí puedes agregar los detalles sobre el proceso de autorización de nombres por la Secretaría de Economía.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 20)
                            
                            // Example content - replace with your actual content
                            ForEach(1...3, id: \.self) { index in
                                HStack(alignment: .top) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("appPrimaryBlue"))
                                        .font(.title2)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Paso \(index)")
                                            .font(.headline)
                                        
                                        Text("Descripción del paso \(index) para obtener la autorización de denominación.")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.bottom, 15)
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Button to mark step as completed
                        Button(action: {
                            viewModel.toggleStep(step: 1)
                        }) {
                            Text(viewModel.user.q1Completed ? "Actualizar" : "Completar Paso")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("appPrimaryBlue"))
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                }
                .background(Color.white)
                .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                .padding(.top, -20)
            }
        }
        // Hide the default navigation bar title but keep the back button
        .navigationBarTitle("", displayMode: .inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        // Change the navigation bar appearance for better contrast with our blue header
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
