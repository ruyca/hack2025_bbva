//
//  GraficasView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI
import Charts

struct GraficasView: View {
    @ObservedObject var viewModel: FinanzasViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Chart(viewModel.transacciones) { tx in
                BarMark(
                    x: .value("Día", tx.fecha, unit: .day),
                    y: .value("Monto", tx.tipo == "ingreso" ? tx.monto : -tx.monto)
                )
                .foregroundStyle(by: .value("Tipo", tx.tipo))
                .cornerRadius(4)
            }
            .chartForegroundStyleScale([
                "ingreso": .green,
                "egreso": .red
            ])
            .frame(height: 200)
            .padding()
            .background(Color.littleBlue)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .padding(.horizontal)
            
            Chart(viewModel.transacciones.filter { $0.tipo == "egreso" }) { tx in
                SectorMark(
                    angle: .value("Monto", tx.monto),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("Concepto", tx.descripcion))
            }
            .frame(height: 200)
            .padding()
            .background(Color.littleBlue)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .padding(.horizontal)
        }
    }
}
