//
//  TransaccionCardView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct TransaccionCardView: View {
    let transaccion: Transaccion
    
    var colorMonto: Color {
        transaccion.tipo == "ingreso" ? .green : .red
    }
    
    var body: some View {
        HStack {
            Image(systemName: transaccion.icono)
                .frame(width: 40, height: 40)
                .background(colorMonto.opacity(0.1))
                .foregroundColor(colorMonto)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(transaccion.descripcion)
                    .font(.subheadline)
                Text(transaccion.fecha, style: .date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if transaccion.tipo != "noticia" {
                Text(transaccion.monto, format: .currency(code: "MXN"))
                    .font(.subheadline.bold())
                    .foregroundColor(colorMonto)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
