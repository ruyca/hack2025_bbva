
import Foundation
import SwiftUI

// Modern Fintech color palette - Blues & Neutrals
extension Color {
    // Primary Colors - Custom Blue Palette
    static let BBVAPrimaryRed = Color(red: 0.11, green: 0.28, blue: 0.45) // #1C4874 (Azul personalizado)
    static let BBVADarkRed = Color(red: 0.08, green: 0.21, blue: 0.35) // #142959 (Azul más oscuro)
    static let BBVALightRed = Color(red: 0.88, green: 0.92, blue: 0.96) // #E0EBF4 (Azul muy claro)
    
    // Alias más intuitivos
    static let BBVABlue = BBVAPrimaryRed
    static let BBVADarkBlue = BBVADarkRed
    static let BBVALightBlue = BBVALightRed
    
    // Secondary Colors - Modern neutrals
    static let BBVACharcoal = Color(red: 0.13, green: 0.16, blue: 0.2) // #212933 (Gris azulado oscuro)
    static let BBVADarkGray = Color(red: 0.4, green: 0.45, blue: 0.52) // #667385 (Gris medio)
    static let BBVAMediumGray = Color(red: 0.65, green: 0.68, blue: 0.73) // #A6ADB9 (Gris claro)
    static let BBVALightGray = Color(red: 0.96, green: 0.97, blue: 0.98) // #F5F7F9 (Casi blanco)
    
    // Accent Colors
    static let BBVATeal = Color(red: 0.2, green: 0.6, blue: 0.8) // #3399CC (Azul cyan complementario)
    static let BBVAOrange = Color(red: 1.0, green: 0.6, blue: 0.2) // #FF9933 (Naranja suave)
    
    // Background & Surface
    static let BBVABackground = Color(red: 0.99, green: 0.99, blue: 1.0) // #FCFCFF (Blanco con tinte azul)
    static let BBVACardBackground = Color.white
    static let BBVADarkBackground = Color(red: 0.09, green: 0.11, blue: 0.14) // #171C23 (Casi negro con tinte azul)
    
    // Text Colors
    static let BBVATextPrimary = Color(red: 0.13, green: 0.16, blue: 0.2) // #212933 (Gris azulado)
    static let BBVATextSecondary = Color(red: 0.52, green: 0.56, blue: 0.63) // #85909F (Gris medio)
    static let BBVATextLight = Color.white
    
    // Status Colors
    static let BBVASuccess = Color(red: 0.16, green: 0.8, blue: 0.47) // #29CC78 (Verde brillante)
    static let BBVAWarning = Color(red: 1.0, green: 0.72, blue: 0.26) // #FFB742 (Amarillo/Naranja)
    static let BBVAError = Color(red: 0.95, green: 0.27, blue: 0.35) // #F34559 (Rojo coral)
    
    // Legacy compatibility (transitional)
    static let appPrimaryBlue = BBVAPrimaryRed
    static let appSecondaryBlue = BBVADarkRed
    static let appBackground = BBVABackground
    static let appBoxBlue = BBVALightRed
    static let appBoxText = BBVATextPrimary
    static let appTerciaryBlue = BBVATeal
}
