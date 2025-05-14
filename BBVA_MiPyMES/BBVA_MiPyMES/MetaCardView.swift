//
//  MetaCardView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct MetaCardView: View {
    let meta: MetaFinanciera
    let colorSecundario: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: meta.icono)
                    .foregroundColor(colorSecundario)
                Text(meta.nombre)
                    .font(.subheadline)
            }
            
            ProgressView(value: meta.progreso)
                .tint(colorSecundario)
            
            Text("\(Int(meta.progreso * 100))% completado")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
