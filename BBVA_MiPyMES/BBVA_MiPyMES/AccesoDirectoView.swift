//
//  AccesoDirectoView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct AccesoDirectoView: View {
    let icono: String
    let texto: String
    let colorPrincipal: Color
    
    var body: some View {
        VStack {
            Image(systemName: icono)
                .font(.title2)
                .frame(width: 50, height: 50)
                .background(colorPrincipal.opacity(0.1))
                .foregroundColor(colorPrincipal)
                .clipShape(Circle())
            
            Text(texto)
                .font(.caption)
        }
    }
}
