//
//  SaldoCardView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct SaldoCardView: View {
    let saldo: Double
    let colorBorde: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(colorBorde)
                Text("Saldo Disponible")
                    .font(.headline)
            }
            
            Text(saldo, format: .currency(code: "MXN"))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .padding(.vertical, 4)
            
            HStack {
                Text("Actualizado: \(Date(), style: .date)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Button("Ver detalle") {}
                    .font(.caption.bold())
                    .foregroundColor(colorBorde)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorBorde, lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}
