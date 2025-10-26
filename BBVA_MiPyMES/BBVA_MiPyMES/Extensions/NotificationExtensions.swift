//
//  NotificationExtensions.swift
//  BBVA_MiPyMES
//
//  Created by GitHub Copilot on 25/10/25.
//

import Foundation

extension Notification.Name {
    /// Se dispara cuando se completa una transacción exitosamente
    static let transactionCompleted = Notification.Name("transactionCompleted")
    
    /// Se dispara cuando se necesita refrescar los datos del home
    static let refreshHomeData = Notification.Name("refreshHomeData")
}

/// Datos de la notificación de transacción completada
struct TransactionCompletedData {
    let amount: Double
    let description: String
    let type: TransactionType
    let paymentMethod: String?
}
