//
//  KPICardsView.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct KPICardsView: View {
    @ObservedObject var viewModel: FinanzasViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                KPICard(
                    titulo: "Ingresos",
                    valor: viewModel.totalIngresos,
                    icono: "arrow.down.circle.fill",
                    color: .green
                )
                KPICard(
                    titulo: "Egresos",
                    valor: viewModel.totalEgresos,
                    icono: "arrow.up.circle.fill",
                    color: .red
                )
                KPICard(
                    titulo: "Flujo neto",
                    valor: viewModel.flujoNeto,
                    icono: "arrow.left.arrow.right.circle.fill",
                    color: viewModel.flujoNeto >= 0 ? .blue : .orange
                )
                KPICard(
                    titulo: "Margen %",
                    valor: viewModel.margenBeneficio,
                    icono: "percent",
                    color: .purple,
                    formato: "%.1f%%"
                )
            }
            .padding(.horizontal)
        }
    }
}

struct KPICard: View {
    let titulo: String
    let valor: Double
    let icono: String
    let color: Color
    var formato: String = "%.2f"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icono)
                    .foregroundColor(color)
                Text(titulo)
                    .font(.caption)
            }
            
            Text(String(format: formato, valor))
                .font(.title3.bold())
        }
        .padding(12)
        .frame(width: 150, alignment: .leading)
        .background(Color.littleBlue)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
