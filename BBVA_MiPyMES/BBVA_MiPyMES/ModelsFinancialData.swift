//
//  ModelsFinancialData.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import Foundation

struct Transaccion: Identifiable {
    let id = UUID()
    let descripcion: String
    let monto: Double
    let fecha: Date
    let tipo: String
    let icono: String
}

struct MetaFinanciera: Identifiable {
    let id = UUID()
    let nombre: String
    let progreso: Double
    let icono: String
}
