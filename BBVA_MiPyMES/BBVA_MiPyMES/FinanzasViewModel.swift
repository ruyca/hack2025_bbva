//
//  FinanzasViewModel.swift
//  BBVA_MiPyMES
//
//  Created by Carolina Sotelo on 13/05/25.
//

import SwiftUI

class FinanzasViewModel: ObservableObject {
    @Published var transacciones: [Transaccion] = []
    @Published var metas: [MetaFinanciera] = []
    
    let colorPrincipal = Color.white
    let colorSecundario = Color(red: 7/255, green: 33/255, blue: 70/255) // Azul BBVA
    
    init() {
        cargarDatosEjemplo()
    }
    
    func cargarDatosEjemplo() {
        let hoy = Date()
        let calendario = Calendar.current
        
        transacciones = [
            Transaccion(
                descripcion: "Venta POS Tienda",
                monto: 20000,
                fecha: calendario.date(byAdding: .day, value: -1, to: hoy)!,
                tipo: "ingreso",
                icono: "creditcard.fill"
            ),
            Transaccion(
                descripcion: "Venta POS Tienda",
                monto: 12200,
                fecha: calendario.date(byAdding: .day, value: -2, to: hoy)!,
                tipo: "ingreso",
                icono: "creditcard.fill"
            ),
            Transaccion(
                descripcion: "Pago a proveedor",
                monto: 9200,
                fecha: calendario.date(byAdding: .day, value: -2, to: hoy)!,
                tipo: "egreso",
                icono: "arrow.up.square.fill"
            ),
            Transaccion(
                descripcion: "Pago de electricidad",
                monto: 2150,
                fecha: calendario.date(byAdding: .day, value: -3, to: hoy)!,
                tipo: "egreso",
                icono: "bolt.circle.fill"
            ),
            Transaccion(
                descripcion: "Pago de renta",
                monto: 5000,
                fecha: calendario.date(byAdding: .day, value: -3, to: hoy)!,
                tipo: "egreso",
                icono: "house.fill"
            )
        ]
        
        metas = [
            MetaFinanciera(
                nombre: "Fondo de emergencia",
                progreso: 0.45,
                icono: "shield.fill"
            ),
            MetaFinanciera(
                nombre: "Pago de impuestos",
                progreso: 0.82,
                icono: "shield.fill"
            )
        ]
    }
    
    // KPIs calculados
    var totalIngresos: Double {
        transacciones.filter { $0.tipo == "ingreso" }.reduce(0) { $0 + $1.monto }
    }
    
    var totalEgresos: Double {
        transacciones.filter { $0.tipo == "egreso" }.reduce(0) { $0 + $1.monto }
    }
    
    var flujoNeto: Double {
        totalIngresos - totalEgresos
    }
    
    var margenBeneficio: Double {
        guard totalIngresos > 0 else { return 0 }
        return (flujoNeto / totalIngresos) * 100
    }
}
