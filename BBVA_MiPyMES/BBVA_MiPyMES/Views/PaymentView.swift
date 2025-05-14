import SwiftUI

struct BBVAPaymentView: View {
    // Estados para controlar el flujo del pago
    @State private var isShowingNFCAnimation = false
    @State private var isPaymentSuccessful = false
    @State private var isAnimating = false
    @State private var isEditingAmount = false
    @State private var showReceiptOptions = false
    
    // Estados para los datos del pago
    @State private var amount: String = "350.00"
    @State private var paymentDescription: String = "Venta"
    @State private var selectedPaymentMethod: PaymentMethod = .card
    
    // Estado para feedback háptico
    @State private var isButtonPressed = false
    
    // Enumerar métodos de pago disponibles
    enum PaymentMethod: String, CaseIterable, Identifiable {
        case card = "Tarjeta"
        case qr = "Código QR"
        case nfc = "NFC"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .card: return "creditcard.fill"
            case .qr: return "qrcode"
            case .nfc: return "wave.3.right"
            }
        }
    }
    
    // Colores BBVA
    let bbvaBlue = Color(red: 0.004, green: 0.345, blue: 0.663)
    let bbvaDarkBlue = Color(red: 0, green: 0.216, blue: 0.416)
    let bbvaLightBlue = Color(red: 0.188, green: 0.573, blue: 0.851)
    let bbvaAqua = Color(red: 0, green: 0.8, blue: 0.8)
    let bbvaBackground = Color(red: 0.95, green: 0.97, blue: 0.98)
    
    var body: some View {
        ZStack {
            // Fondo
            bbvaBackground.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Barra superior
                headerBar
                
                // Contenido principal
                ScrollView {
                    VStack(spacing: 24) {
                        // Tarjeta de monto
                        amountCard
                        
                        // Método de pago
                        paymentMethodCard
                        
                        // Espacio para la animación de pago o resultado
                        paymentStatusView
                            .frame(height: 300)
                            .padding(.vertical)
                        
                        // Información adicional
                        if !isShowingNFCAnimation && !isPaymentSuccessful {
                            infoCard
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Espacio para el botón
                }
                
                Spacer()
                
                // Botón de acción (fijo en la parte inferior)
                actionButton
            }
        }
        .sheet(isPresented: $showReceiptOptions) {
            receiptOptionsView
        }
    }
    
    // Barra superior con logo y volver
    var headerBar: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    // Acción para volver atrás
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Terminal de Venta")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    // Podría ser un menú de opciones
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 16)
            .background(bbvaBlue)
            
            // Barra de progreso del proceso
            if !isPaymentSuccessful {
                processIndicator
            }
        }
    }
    
    // Indicador de proceso (Configurar > Cobrar > Completar)
    var processIndicator: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { step in
                VStack(spacing: 4) {
                    // Círculos de progreso
                    ZStack {
                        Circle()
                            .fill(getStepColor(for: step))
                            .frame(width: 24, height: 24)
                        
                        if step < (isShowingNFCAnimation ? 1 : 0) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step + 1)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(step == (isShowingNFCAnimation ? 1 : 0) ? bbvaDarkBlue : .white)
                        }
                    }
                    
                    // Etiqueta del paso
                    Text(getStepLabel(for: step))
                        .font(.system(size: 12))
                        .foregroundColor(step == (isShowingNFCAnimation ? 1 : 0) ? bbvaBlue : Color.gray)
                }
                
                // Línea conectora entre círculos (excepto después del último)
                if step < 2 {
                    Rectangle()
                        .fill(step < (isShowingNFCAnimation ? 1 : 0) ? bbvaBlue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    // Obtener color para cada paso del proceso
    func getStepColor(for step: Int) -> Color {
        let currentStep = isShowingNFCAnimation ? 1 : 0
        
        if step < currentStep {
            return bbvaBlue // Completado
        } else if step == currentStep {
            return bbvaLightBlue.opacity(0.8) // Actual
        } else {
            return Color.gray.opacity(0.3) // Pendiente
        }
    }
    
    // Obtener etiqueta para cada paso
    func getStepLabel(for step: Int) -> String {
        switch step {
        case 0: return "Configurar"
        case 1: return "Cobrar"
        case 2: return "Completar"
        default: return ""
        }
    }
    
    // Tarjeta de monto
    var amountCard: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Importe a cobrar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(bbvaDarkBlue)
                
                Spacer()
                
                Button(action: {
                    isEditingAmount.toggle()
                }) {
                    Image(systemName: isEditingAmount ? "checkmark.circle.fill" : "pencil.circle")
                        .font(.system(size: 20))
                        .foregroundColor(bbvaBlue)
                }
            }
            
            // Campo de monto (editable o no)
            HStack(alignment: .firstTextBaseline) {
                Text("$")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(bbvaDarkBlue)
                
                if isEditingAmount {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(bbvaDarkBlue)
                        .multilineTextAlignment(.center)
                } else {
                    Text(amount)
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(bbvaDarkBlue)
                }
                
                Text("MXN")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.leading, 4)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Descripción del pago
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Descripción:")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                    
                    TextField("Descripción", text: $paymentDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaDarkBlue)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Selección de método de pago
    var paymentMethodCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Método de pago")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(bbvaDarkBlue)
            
            HStack(spacing: 15) {
                ForEach(PaymentMethod.allCases) { method in
                    Button(action: {
                        withAnimation {
                            selectedPaymentMethod = method
                        }
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(selectedPaymentMethod == method ? bbvaBlue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: method.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedPaymentMethod == method ? bbvaBlue : Color.gray)
                            }
                            
                            Text(method.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(selectedPaymentMethod == method ? bbvaDarkBlue : Color.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedPaymentMethod == method ? bbvaBlue : Color.clear, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedPaymentMethod == method ? bbvaBlue.opacity(0.05) : Color.clear)
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Vista condicional del status del pago
    var paymentStatusView: some View {
        Group {
            if isShowingNFCAnimation {
                nfcAnimationView
            } else if isPaymentSuccessful {
                paymentSuccessView
            } else {
                nfcReadyView
            }
        }
    }
    
    // Vista para lector NFC listo
    var nfcReadyView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(bbvaLightBlue, lineWidth: 3)
                    .frame(width: 160, height: 160)
                
                Circle()
                    .fill(bbvaLightBlue.opacity(0.1))
                    .frame(width: 150, height: 150)
                
                Image(systemName: selectedPaymentMethod.icon)
                    .font(.system(size: 60))
                    .foregroundColor(bbvaLightBlue)
            }
            
            Text("Terminal lista")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            Text("Configure todos los datos y pulse el botón cobrar")
                .font(.system(size: 15))
                .foregroundColor(Color.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Animación del proceso NFC
    var nfcAnimationView: some View {
        VStack(spacing: 20) {
            ZStack {
                // Círculos animados
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(bbvaAqua.opacity(0.5), lineWidth: 3)
                        .frame(width: 160 + CGFloat(i * 40), height: 160 + CGFloat(i * 40))
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .opacity(isAnimating ? 0 : 1)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.3),
                            value: isAnimating
                        )
                }
                
                Circle()
                    .fill(bbvaLightBlue.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                Image(systemName: selectedPaymentMethod.icon)
                    .font(.system(size: 60))
                    .foregroundColor(bbvaLightBlue)
            }
            .onAppear {
                isAnimating = true
                
                // Simulación del proceso de pago
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isShowingNFCAnimation = false
                        isPaymentSuccessful = true
                    }
                }
            }
            
            Text("Procesando pago...")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            if selectedPaymentMethod == .card {
                Text("Aproxime la tarjeta al dispositivo")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
            } else if selectedPaymentMethod == .qr {
                Text("Mostrando código QR para pago")
                    .font(.system(size: 15))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Vista de pago exitoso
    var paymentSuccessView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }
            
            Text("Pago completado")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            VStack(spacing: 8) {
                Text("$\(amount) MXN")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(bbvaDarkBlue)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 14))
                    
                    Text("Transacción aprobada")
                        .font(.system(size: 15))
                        .foregroundColor(Color.green)
                }
                
                Button(action: {
                    showReceiptOptions = true
                }) {
                    HStack {
                        Image(systemName: "printer")
                            .font(.system(size: 14))
                        
                        Text("Enviar comprobante")
                            .font(.system(size: 15))
                    }
                    .foregroundColor(bbvaBlue)
                    .padding(.top, 12)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Tarjeta de información adicional
    var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(bbvaLightBlue)
                
                Text("Información")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(bbvaDarkBlue)
            }
            
            Divider()
            
            infoRow(icon: "lock.fill", text: "Transacción segura encriptada")
            infoRow(icon: "creditcard.fill", text: "Se aceptan tarjetas de crédito, débito y monederos")
            infoRow(icon: "printer.fill", text: "Comprobante disponible por correo o impresión")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Fila de información
    func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(bbvaBlue)
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    // Botón de acción principal
    var actionButton: some View {
        VStack {
            if isPaymentSuccessful {
                // Botón para nuevo cobro
                Button(action: {
                    // Reiniciar el proceso
                    isPaymentSuccessful = false
                    isShowingNFCAnimation = false
                }) {
                    Text("Nuevo cobro")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(bbvaBlue)
                        )
                        .shadow(color: bbvaBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            } else if isShowingNFCAnimation {
                // Botón para cancelar el proceso
                Button(action: {
                    isShowingNFCAnimation = false
                }) {
                    Text("Cancelar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.8))
                        )
                }
            } else {
                // Botón para iniciar el pago
                Button(action: {
                    isButtonPressed = true
                    
                    // Feedback háptico simulado
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isButtonPressed = false
                        isShowingNFCAnimation = true
                    }
                }) {
                    Text("Cobrar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(bbvaAqua)
                        )
                        .scaleEffect(isButtonPressed ? 0.97 : 1.0)
                        .shadow(color: bbvaAqua.opacity(0.3), radius: 6, x: 0, y: 3)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    // Vista de opciones de comprobante
    var receiptOptionsView: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("Enviar comprobante")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(bbvaDarkBlue)
                
                Spacer()
                
                Button(action: {
                    showReceiptOptions = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray)
                }
            }
            .padding(.bottom, 8)
            
            // Opciones
            VStack(spacing: 16) {
                receiptOption(icon: "printer.fill", title: "Imprimir", subtitle: "Enviar a impresora conectada")
                
                receiptOption(icon: "envelope.fill", title: "Correo electrónico", subtitle: "Enviar por email al cliente")
                
                receiptOption(icon: "message.fill", title: "SMS", subtitle: "Enviar mensaje de texto")
                
                receiptOption(icon: "qrcode", title: "Código QR", subtitle: "Generar código para escanear")
            }
            
            Spacer()
            
            // Botón cancelar
            Button(action: {
                showReceiptOptions = false
            }) {
                Text("Cerrar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(bbvaBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(bbvaBlue, lineWidth: 1)
                    )
            }
        }
        .padding()
    }
    
    // Opción de comprobante
    func receiptOption(icon: String, title: String, subtitle: String) -> some View {
        Button(action: {
            // Acción para esta opción
            showReceiptOptions = false
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(bbvaBlue)
                    .frame(width: 30, height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaDarkBlue)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

// Vista previa
struct BBVAPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        BBVAPaymentView()
    }
}
