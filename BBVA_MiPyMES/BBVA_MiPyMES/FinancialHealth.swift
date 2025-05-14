//
//  FinancialHealth.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

struct FinancialHealth: View {
    @StateObject private var viewModel = FinanzasViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                viewModel.colorPrincipal
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        SaldoCardView(
                            saldo: viewModel.flujoNeto,
                            colorBorde: viewModel.colorSecundario
                        )
                        
                        KPICardsView(viewModel: viewModel)
                        
                        GraficasView(viewModel: viewModel)
                        
                        HStack(spacing: 20) {
                            AccesoDirectoView(
                                icono: "chart.pie",
                                texto: "Reportes",
                                colorPrincipal: viewModel.colorSecundario
                            )
                            AccesoDirectoView(
                                icono: "doc.text",
                                texto: "Facturas",
                                colorPrincipal: viewModel.colorSecundario
                            )
                            AccesoDirectoView(
                                icono: "gear",
                                texto: "Ajustes",
                                colorPrincipal: viewModel.colorSecundario
                            )
                        }
                        .padding(.horizontal)
                        
                        listaTransacciones()
                        listaMetas()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Salud financiera")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(viewModel.colorSecundario)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func listaTransacciones() -> some View {
        VStack(alignment: .leading) {
            Text("Últimas transacciones")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.transacciones) { transaccion in
                TransaccionCardView(transaccion: transaccion)
                    .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func listaMetas() -> some View {
        VStack(alignment: .leading) {
            Text("Mis metas")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(viewModel.metas) { meta in
                MetaCardView(meta: meta, colorSecundario: viewModel.colorSecundario)
                    .padding(.horizontal)
            }
        }
    }
}

struct FinancialHealth_Previews: PreviewProvider {
    static var previews: some View {
        FinancialHealth()
    }
}
