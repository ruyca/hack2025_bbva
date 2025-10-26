import SwiftUI
import CoreImage.CIFilterBuiltins

struct BBVAPaymentView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Modo de operación
    @State private var transactionMode: TransactionMode = .receive
    
    // Estados para controlar el flujo del pago
    @State private var isShowingNFCAnimation = false
    @State private var isPaymentSuccessful = false
    @State private var isAnimating = false
    @State private var isEditingAmount = false
    @State private var showReceiptOptions = false
    @State private var showingQRCode = false
    @State private var isProcessing = false
    
    // Estados para los datos del pago
    @State private var amount: String = "350.00"
    @State private var paymentDescription: String = "Venta"
    @State private var selectedPaymentMethod: PaymentMethod = .card
    @State private var clientName: String = ""
    
    // Estado para feedback háptico
    @State private var isButtonPressed = false
    
    // Estados de animación
    @State private var cardsAppeared = false
    @State private var pulseAnimation = false
    
    // Modo de transacción
    enum TransactionMode: String, CaseIterable, Identifiable {
        case receive = "Cobrar"
        case send = "Pagar"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .receive: return "arrow.down.circle.fill"
            case .send: return "arrow.up.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .receive: return Color.BBVASuccess
            case .send: return Color.BBVAError
            }
        }
        
        var description: String {
            switch self {
            case .receive: return "Recibir dinero de un cliente"
            case .send: return "Enviar dinero a un proveedor"
            }
        }
    }
    
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
        
        var color: Color {
            switch self {
            case .card: return Color.BBVATeal
            case .qr: return Color.BBVAOrange
            case .nfc: return Color.BBVASuccess
            }
        }
    }
    
    // Usar colores globales de BBVA
    let BBVABlue = Color.BBVAPrimaryRed
    let BBVABackground = Color.BBVABackground
    
    var body: some View {
        ZStack {
            // Fondo con gradiente sutil
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.BBVABackground,
                    Color.BBVALightBlue.opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Barra superior
                headerBar
                
                if isPaymentSuccessful {
                    // Vista de éxito
                    successView
                } else {
                    // Contenido principal
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Selector de modo (Cobrar/Pagar)
                            modeSelector
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardsAppeared)
                            
                            // Tarjeta de saldo
                            balanceCard
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardsAppeared)
                            
                            // Tarjeta de monto
                            amountCard
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: cardsAppeared)
                            
                            // Método de pago
                            paymentMethodCard
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: cardsAppeared)
                            
                            // Espacio para la animación de pago o resultado
                            if !isShowingNFCAnimation {
                                // Información adicional
                                infoCard
                                    .offset(y: cardsAppeared ? 0 : 20)
                                    .opacity(cardsAppeared ? 1 : 0)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: cardsAppeared)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                    
                    Spacer()
                    
                    // Botón de acción (fijo en la parte inferior)
                    actionButton
                }
            }
            
            // Overlay de procesamiento
            if isProcessing {
                processingOverlay
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardsAppeared = true
            }
        }
        .sheet(isPresented: $showReceiptOptions) {
            receiptOptionsView
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingQRCode) {
            qrCodeView
        }
        .sheet(isPresented: $isShowingNFCAnimation) {
            nfcScannerView
        }
    }
    
    // Barra superior con logo y volver
    var headerBar: some View {
        VStack(spacing: 0) {
            ZStack {
                // Gradiente de fondo
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVAPrimaryRed,
                        Color.BBVADarkRed
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Terminal de Pagos")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text(transactionMode.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Menú de opciones
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .frame(height: 100)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Mode Selector
    
    var modeSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tipo de Operación")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 16) {
                ForEach(TransactionMode.allCases) { mode in
                    modeCard(mode: mode)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    func modeCard(mode: TransactionMode) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                transactionMode = mode
                // Resetear estados si cambia el modo
                isShowingNFCAnimation = false
                isPaymentSuccessful = false
                showingQRCode = false
            }
        }) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    mode.color.opacity(transactionMode == mode ? 0.3 : 0.15),
                                    mode.color.opacity(transactionMode == mode ? 0.2 : 0.08)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(mode.color)
                }
                
                Text(mode.rawValue)
                    .font(.system(size: 15, weight: transactionMode == mode ? .bold : .medium))
                    .foregroundColor(transactionMode == mode ? Color.BBVACharcoal : Color.BBVATextSecondary)
                
                if transactionMode == mode {
                    Circle()
                        .fill(mode.color)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(transactionMode == mode ? mode.color.opacity(0.08) : Color.BBVALightGray.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(transactionMode == mode ? mode.color : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Balance Card
    
    var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                balanceInfo
                
                Spacer()
                
                transactionModeIcon
            }
            
            Divider()
                .background(Color.BBVALightGray)
            
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(transactionMode.color)
                
                Text(transactionMode.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Información del saldo
    var balanceInfo: some View {
        let balanceText: String = {
            if let account = homeViewModel.account {
                return formatCurrency(account.balance)
            } else {
                return "$0.00"
            }
        }()
        
        return VStack(alignment: .leading, spacing: 6) {
            Text("Saldo Disponible")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.BBVATextSecondary)
            
            Text(balanceText)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
        }
    }
    
    // Ícono del modo de transacción
    var transactionModeIcon: some View {
        let modeColor = transactionMode.color
        let iconGradient = LinearGradient(
            gradient: Gradient(colors: [
                modeColor.opacity(0.2),
                modeColor.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return ZStack {
            Circle()
                .fill(iconGradient)
                .frame(width: 60, height: 60)
            
            Image(systemName: transactionMode.icon)
                .font(.system(size: 26))
                .foregroundColor(modeColor)
        }
    }
    
    // Indicador de proceso (Configurar > Cobrar > Completar)
    var processIndicator: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { step in
                VStack(spacing: 6) {
                    // Círculos de progreso
                    ZStack {
                        Circle()
                            .fill(getStepColor(for: step))
                            .frame(width: 32, height: 32)
                            .shadow(
                                color: step == (isShowingNFCAnimation ? 1 : 0) ? Color.BBVATeal.opacity(0.3) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                        
                        if step < (isShowingNFCAnimation ? 1 : 0) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(step + 1)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(step == (isShowingNFCAnimation ? 1 : 0) ? .white : Color.BBVADarkGray)
                        }
                    }
                    
                    // Etiqueta del paso
                    Text(getStepLabel(for: step))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(step == (isShowingNFCAnimation ? 1 : 0) ? BBVABlue : Color.BBVATextSecondary)
                }
                
                // Línea conectora entre círculos (excepto después del último)
                if step < 2 {
                    Rectangle()
                        .fill(step < (isShowingNFCAnimation ? 1 : 0) ? BBVABlue : Color.BBVALightGray)
                        .frame(height: 3)
                        .cornerRadius(1.5)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    // Obtener color para cada paso del proceso
    func getStepColor(for step: Int) -> Color {
        let currentStep = isShowingNFCAnimation ? 1 : 0
        
        if step < currentStep {
            return BBVABlue // Completado
        } else if step == currentStep {
            return Color.BBVATeal.opacity(0.8) // Actual
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
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.BBVALightBlue.opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Importe a cobrar")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color.BBVATextSecondary)
                        
                        Text("MXN - Peso Mexicano")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.BBVAMediumGray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditingAmount.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(isEditingAmount ? Color.BBVASuccess.opacity(0.15) : Color.BBVATeal.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: isEditingAmount ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(isEditingAmount ? Color.BBVASuccess : BBVABlue)
                        }
                    }
                }
                
                // Campo de monto (editable o no)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    if isEditingAmount {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text(amount)
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                
                Divider()
                    .background(Color.BBVALightGray)
                
                // Descripción del pago
                VStack(alignment: .leading, spacing: 8) {
                    Text("Concepto de pago")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.BBVATextSecondary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 16))
                            .foregroundColor(BBVABlue)
                        
                        TextField("Descripción del pago", text: $paymentDescription)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.BBVACharcoal)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.BBVALightGray.opacity(0.5))
                    )
                }
            }
            .padding(24)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Selección de método de pago
    var paymentMethodCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Método de pago")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 12) {
                ForEach(PaymentMethod.allCases) { method in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPaymentMethod = method
                        }
                    }) {
                        VStack(spacing: 14) {
                            ZStack {
                                // Fondo con gradiente
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        selectedPaymentMethod == method ? method.color.opacity(0.25) : method.color.opacity(0.15),
                                        selectedPaymentMethod == method ? method.color.opacity(0.15) : method.color.opacity(0.08)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                
                                Image(systemName: method.icon)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(selectedPaymentMethod == method ? method.color : method.color.opacity(0.7))
                                
                                // Checkmark cuando está seleccionado
                                if selectedPaymentMethod == method {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(method.color)
                                                    .frame(width: 24, height: 24)
                                                
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            }
                                            .offset(x: 8, y: -8)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            
                            Text(method.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(selectedPaymentMethod == method ? Color.BBVACharcoal : Color.BBVATextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedPaymentMethod == method ? Color.white : Color.white.opacity(0.5))
                                .shadow(
                                    color: selectedPaymentMethod == method ? method.color.opacity(0.2) : Color.clear,
                                    radius: selectedPaymentMethod == method ? 12 : 0,
                                    x: 0,
                                    y: selectedPaymentMethod == method ? 6 : 0
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedPaymentMethod == method ? method.color : Color.clear, lineWidth: 2)
                        )
                        .scaleEffect(selectedPaymentMethod == method ? 1.02 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
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
        VStack(spacing: 24) {
            ZStack {
                // Círculos decorativos
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                selectedPaymentMethod.color.opacity(0.5),
                                selectedPaymentMethod.color.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 180, height: 180)
                
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                selectedPaymentMethod.color.opacity(0.15),
                                selectedPaymentMethod.color.opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 170, height: 170)
                
                Image(systemName: selectedPaymentMethod.icon)
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundColor(selectedPaymentMethod.color)
            }
            .padding(.top, 20)
            
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.BBVASuccess)
                    
                    Text("Terminal lista")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                }
                
                Text("Configure todos los datos y pulse el botón cobrar")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Información del método seleccionado
            HStack(spacing: 12) {
                IconBadge(
                    icon: selectedPaymentMethod.icon,
                    backgroundColor: selectedPaymentMethod.color.opacity(0.15),
                    iconColor: selectedPaymentMethod.color,
                    size: 44,
                    cornerRadius: 12
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Método seleccionado")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.BBVATextSecondary)
                    
                    Text(selectedPaymentMethod.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.BBVACharcoal)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedPaymentMethod.color.opacity(0.08))
            )
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Animación del proceso NFC
    var nfcAnimationView: some View {
        VStack(spacing: 24) {
            nfcAnimationCircles
            
            VStack(spacing: 12) {
                Text("Procesando pago...")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                paymentMethodDescription
            }
            
            // Loading indicator
            loadingDots
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Círculos animados de NFC
    var nfcAnimationCircles: some View {
        ZStack {
            // Círculos animados con gradiente
            ForEach(0..<3) { i in
                animatedCircle(index: i)
            }
            
            // Fondo central
            centralNFCCircle
            
            // Ícono
            Image(systemName: selectedPaymentMethod.icon)
                .font(.system(size: 70, weight: .semibold))
                .foregroundColor(selectedPaymentMethod.color)
        }
        .padding(.top, 20)
    }
    
    // Círculo animado individual
    func animatedCircle(index: Int) -> some View {
        let gradient = LinearGradient(
            gradient: Gradient(colors: [
                selectedPaymentMethod.color.opacity(0.6),
                selectedPaymentMethod.color.opacity(0.3)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return Circle()
            .stroke(gradient, lineWidth: 3)
            .frame(width: 180 + CGFloat(index * 50), height: 180 + CGFloat(index * 50))
            .scaleEffect(isAnimating ? 1.3 : 0.7)
            .opacity(isAnimating ? 0 : 0.8)
            .animation(
                Animation.easeInOut(duration: 2)
                    .repeatForever(autoreverses: false)
                    .delay(Double(index) * 0.4),
                value: isAnimating
            )
    }
    
    // Círculo central de NFC
    var centralNFCCircle: some View {
        let gradient = LinearGradient(
            gradient: Gradient(colors: [
                selectedPaymentMethod.color.opacity(0.2),
                selectedPaymentMethod.color.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        return Circle()
            .fill(gradient)
            .frame(width: 180, height: 180)
            .pulse()
    }
    
    // Descripción según método de pago
    var paymentMethodDescription: some View {
        Group {
            if selectedPaymentMethod == .card {
                Text("Aproxime la tarjeta al dispositivo")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
            } else if selectedPaymentMethod == .qr {
                Text("Mostrando código QR para pago")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("Acerque el dispositivo NFC")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // Puntos de carga
    var loadingDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(selectedPaymentMethod.color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(i) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .padding(.top, 8)
    }
    
    // Vista de pago exitoso
    var paymentSuccessView: some View {
        VStack(spacing: 24) {
            ZStack {
                // Círculos de celebración
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.BBVASuccess.opacity(0.15),
                                Color.BBVASuccess.opacity(0.08)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 180, height: 180)
                
                Circle()
                    .stroke(Color.BBVASuccess.opacity(0.3), lineWidth: 4)
                    .frame(width: 190, height: 190)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 90))
                    .foregroundColor(.BBVASuccess)
                    .scaleIn()
            }
            
            VStack(spacing: 12) {
                Text("¡Pago completado!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                VStack(spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.BBVASuccess)
                        
                        Text(amount)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.BBVASuccess)
                        
                        Text("MXN")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.BBVATextSecondary)
                    }
                    
                    StatusBadge(text: "Transacción aprobada", type: .success, size: .medium, icon: "checkmark.circle.fill")
                }
                .padding(.vertical, 8)
                
                // Detalles de la transacción
                VStack(spacing: 10) {
                    HStack {
                        Text("Método de pago:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.BBVATextSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: selectedPaymentMethod.icon)
                                .font(.system(size: 12))
                            
                            Text(selectedPaymentMethod.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.BBVACharcoal)
                    }
                    
                    HStack {
                        Text("Concepto:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.BBVATextSecondary)
                        
                        Spacer()
                        
                        Text(paymentDescription)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVACharcoal)
                    }
                    
                    HStack {
                        Text("Fecha:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.BBVATextSecondary)
                        
                        Spacer()
                        
                        Text(Date(), style: .time)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVACharcoal)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.BBVALightGray.opacity(0.5))
                )
                
                Button(action: {
                    showReceiptOptions = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 16))
                        
                        Text("Enviar comprobante")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(BBVABlue)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.BBVATeal.opacity(0.1))
                    )
                }
                .padding(.top, 8)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Tarjeta de información adicional
    var infoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                IconBadge(
                    icon: "info.circle.fill",
                    backgroundColor: Color.BBVATeal.opacity(0.15),
                    iconColor: Color.BBVATeal,
                    size: 40,
                    cornerRadius: 10
                )
                
                Text("Información importante")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
            }
            
            Divider()
                .background(Color.BBVALightGray)
            
            VStack(spacing: 14) {
                infoRow(
                    icon: "lock.shield.fill",
                    text: "Transacción segura encriptada",
                    color: .BBVASuccess
                )
                
                infoRow(
                    icon: "creditcard.fill",
                    text: "Se aceptan tarjetas de crédito, débito y monederos",
                    color: .BBVATeal
                )
                
                infoRow(
                    icon: "doc.text.fill",
                    text: "Comprobante disponible por correo o impresión",
                    color: .BBVAOrange
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Fila de información modernizada
    func infoRow(icon: String, text: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.BBVATextPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
    }
    
    // Botón de acción principal
    var actionButton: some View {
        VStack {
            Button(action: {
                initiateTransaction()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: getActionIcon())
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(getActionText())
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(BBVAPrimaryButtonStyle())
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1.0 : 0.5)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    // Vista de opciones de comprobante
    var receiptOptionsView: some View {
        VStack(spacing: 24) {
            // Header modernizado
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enviar comprobante")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    Text("Selecciona cómo compartir el recibo")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    showReceiptOptions = false
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.BBVALightGray.opacity(0.3))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.BBVATextSecondary)
                    }
                }
            }
            .padding(.bottom, 8)
            
            // Opciones modernizadas
            VStack(spacing: 12) {
                receiptOption(
                    icon: "printer.fill",
                    title: "Imprimir",
                    subtitle: "Enviar a impresora conectada",
                    color: .BBVATeal
                )
                
                receiptOption(
                    icon: "envelope.fill",
                    title: "Correo electrónico",
                    subtitle: "Enviar por email al cliente",
                    color: .BBVAOrange
                )
                
                receiptOption(
                    icon: "message.fill",
                    title: "SMS",
                    subtitle: "Enviar mensaje de texto",
                    color: .BBVASuccess
                )
                
                receiptOption(
                    icon: "qrcode",
                    title: "Código QR",
                    subtitle: "Generar código para escanear",
                    color: .BBVABlue
                )
            }
            
            Spacer()
            
            // Botón cancelar modernizado
            Button(action: {
                showReceiptOptions = false
            }) {
                Text("Cerrar")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(BBVATertiaryButtonStyle())
        }
        .padding(24)
    }
    
    // Opción de comprobante modernizada
    func receiptOption(icon: String, title: String, subtitle: String, color: Color) -> some View {
        Button(action: {
            // Acción para esta opción
            showReceiptOptions = false
        }) {
            HStack(spacing: 16) {
                IconBadge(
                    icon: icon,
                    backgroundColor: color.opacity(0.15),
                    iconColor: color,
                    size: 48,
                    cornerRadius: 14
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVATextSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    // MARK: - QR Code View
    
    var qrCodeView: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Código QR")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    Text(transactionMode == .receive ? "Escanea para pagar" : "Código para recibir")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingQRCode = false
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.BBVALightGray.opacity(0.3))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.BBVATextSecondary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // QR Code
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .frame(width: 280, height: 280)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    if let qrImage = generateQRCode(from: generateTransactionData()) {
                        Image(uiImage: qrImage)
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 240, height: 240)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 60))
                                .foregroundColor(Color.BBVAMediumGray)
                            
                            Text("Generando QR...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.BBVATextSecondary)
                        }
                    }
                }
                
                // Información de la transacción
                VStack(spacing: 12) {
                    infoRow(icon: "dollarsign.circle.fill", title: "Monto", value: "$\(amount)")
                    infoRow(icon: "doc.text.fill", title: "Concepto", value: paymentDescription)
                    infoRow(icon: transactionMode.icon, title: "Tipo", value: transactionMode.rawValue)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.BBVALightGray.opacity(0.3))
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Botón de confirmar (simula escaneo después de 3 segundos)
            Button(action: {
                showingQRCode = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    processTransaction()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Simular Escaneo")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(BBVAPrimaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.BBVABackground)
    }
    
    // MARK: - NFC Scanner View
    
    var nfcScannerView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animación NFC
            ZStack {
                // Círculos animados
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    selectedPaymentMethod.color.opacity(0.6),
                                    selectedPaymentMethod.color.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 180 + CGFloat(i * 50), height: 180 + CGFloat(i * 50))
                        .scaleEffect(pulseAnimation ? 1.3 : 0.7)
                        .opacity(pulseAnimation ? 0 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.4),
                            value: pulseAnimation
                        )
                }
                
                // Ícono central
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    selectedPaymentMethod.color.opacity(0.2),
                                    selectedPaymentMethod.color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: selectedPaymentMethod.icon)
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundColor(selectedPaymentMethod.color)
                }
            }
            .onAppear {
                pulseAnimation = true
                
                // Simular detección NFC después de 3 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isShowingNFCAnimation = false
                    processTransaction()
                }
            }
            .onDisappear {
                pulseAnimation = false
            }
            
            VStack(spacing: 12) {
                Text(transactionMode == .receive ? "Acerca la tarjeta" : "Acerca el dispositivo")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Text(transactionMode == .receive ? "Mantén la tarjeta cerca del lector" : "Mantén cerca el dispositivo receptor")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Información de la transacción
            VStack(spacing: 12) {
                Text(transactionMode == .receive ? "Monto a Cobrar" : "Monto a Pagar")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                
                Text("$\(amount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(transactionMode.color)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Botón cancelar
            Button(action: {
                isShowingNFCAnimation = false
                pulseAnimation = false
            }) {
                Text("Cancelar")
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(BBVATertiaryButtonStyle())
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.BBVABackground)
    }
    
    // MARK: - Success View
    
    var successView: some View {
        VStack(spacing: 0) {
            // Fondo con gradiente azul BBVA
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVABlue.opacity(0.95),
                        Color.BBVATeal.opacity(0.85)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Animación de éxito con colores azules
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.12)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 180, height: 180)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.4), lineWidth: 4)
                            .frame(width: 190, height: 190)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 90))
                            .foregroundColor(.white)
                            .scaleEffect(cardsAppeared ? 1.0 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: cardsAppeared)
                    }
                    
                    VStack(spacing: 12) {
                        Text(transactionMode == .receive ? "¡Cobro Exitoso!" : "¡Pago Exitoso!")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("$\(amount) MXN")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Botones de acción con estilos mejorados
                    VStack(spacing: 14) {
                        Button(action: {
                            // Compartir comprobante
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text("Compartir Comprobante")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .foregroundColor(Color.BBVABlue)
                        }
                        
                        Button(action: {
                            resetForm()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text(transactionMode == .receive ? "Nuevo Cobro" : "Nuevo Pago")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    // Detalles de la transacción con fondo blanco
                    VStack(spacing: 16) {
                        detailRow(icon: "doc.text.fill", title: "Concepto", value: paymentDescription)
                        detailRow(icon: "clock.fill", title: "Fecha", value: formattedDate())
                        detailRow(icon: selectedPaymentMethod.icon, title: "Método", value: selectedPaymentMethod.rawValue)
                        detailRow(icon: transactionMode.icon, title: "Tipo", value: transactionMode.rawValue)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: 15)
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
        }
    }
    
    // MARK: - Processing Overlay
    
    var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text(transactionMode == .receive ? "Procesando cobro..." : "Procesando pago...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.BBVACharcoal.opacity(0.95))
            )
        }
    }
    
    // MARK: - Helper Views
    
    func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.BBVATeal)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.BBVATextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.BBVACharcoal)
        }
    }
    
    func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.BBVATeal.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.BBVATeal)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.BBVACharcoal)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    
    var isFormValid: Bool {
        guard let amountValue = Double(amount), amountValue > 0 else { return false }
        
        // Si es pago (send), validar que haya saldo suficiente
        if transactionMode == .send {
            guard let balance = homeViewModel.account?.balance, amountValue <= balance else { return false }
        }
        
        return true
    }
    
    func getActionText() -> String {
        switch selectedPaymentMethod {
        case .qr:
            return transactionMode == .receive ? "Generar QR para Cobrar" : "Generar QR para Pagar"
        case .nfc:
            return transactionMode == .receive ? "Activar NFC para Cobrar" : "Activar NFC para Pagar"
        case .card:
            return transactionMode == .receive ? "Cobrar con Tarjeta" : "Pagar con Tarjeta"
        }
    }
    
    func getActionIcon() -> String {
        switch selectedPaymentMethod {
        case .qr:
            return "qrcode.viewfinder"
        case .nfc:
            return "wave.3.forward"
        case .card:
            return "creditcard"
        }
    }
    
    func initiateTransaction() {
        if selectedPaymentMethod == .qr {
            showingQRCode = true
        } else {
            isShowingNFCAnimation = true
        }
    }
    
    func processTransaction() {
        guard let amountValue = Double(amount) else { return }
        
        isProcessing = true
        
        // Simular procesamiento
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Task {
                // Determinar el tipo de transacción y el monto
                let transactionType: TransactionType = transactionMode == .receive ? .income : .expense
                let transactionAmount = transactionMode == .receive ? amountValue : -amountValue
                
                // Guardar la transacción
                let success = await homeViewModel.saveTransaction(
                    description: paymentDescription.isEmpty ? (transactionMode == .receive ? "Cobro" : "Pago") : paymentDescription,
                    amount: transactionAmount,
                    type: transactionType,
                    category: transactionMode == .receive ? "Sales" : "Payment",
                    paymentMethod: selectedPaymentMethod.rawValue
                )
                
                isProcessing = false
                
                if success {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isPaymentSuccessful = true
                        cardsAppeared = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            cardsAppeared = true
                        }
                    }
                    
                    // Enviar notificación de actualización
                    NotificationCenter.default.post(name: .refreshHomeData, object: nil)
                }
            }
        }
    }
    
    func resetForm() {
        amount = "0.00"
        paymentDescription = transactionMode == .receive ? "Venta" : "Pago"
        clientName = ""
        isPaymentSuccessful = false
        showingQRCode = false
        isShowingNFCAnimation = false
        cardsAppeared = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardsAppeared = true
            }
        }
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: Date())
    }
    
    func generateTransactionData() -> String {
        return """
        {
            "type": "\(transactionMode == .receive ? "receive" : "send")",
            "amount": "\(amount)",
            "description": "\(paymentDescription)",
            "method": "\(selectedPaymentMethod.rawValue)",
            "timestamp": "\(Date().timeIntervalSince1970)"
        }
        """
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return nil
    }
}


// Vista previa
struct BBVAPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        BBVAPaymentView()
            .environmentObject(HomeViewModel())
    }
}
