
import SwiftUI
import CoreImage.CIFilterBuiltins

struct TransferView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Estados de la vista
    @State private var amount: String = ""
    @State private var recipientName: String = ""
    @State private var recipientAccount: String = ""
    @State private var transferDescription: String = "Transferencia"
    @State private var selectedMethod: TransferMethod = .qr
    @State private var showingQRCode = false
    @State private var showingNFCScanner = false
    @State private var showingSuccess = false
    @State private var isProcessing = false
    @State private var errorMessage: String?
    
    // Animaciones
    @State private var cardsAppeared = false
    @State private var pulseAnimation = false
    
    // Método de transferencia
    enum TransferMethod: String, CaseIterable, Identifiable {
        case qr = "Código QR"
        case nfc = "NFC"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .qr: return "qrcode"
            case .nfc: return "wave.3.right"
            }
        }
        
        var color: Color {
            switch self {
            case .qr: return Color.BBVAOrange
            case .nfc: return Color.BBVASuccess
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
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
                // Header moderno
                headerView
                
                if showingSuccess {
                    // Vista de éxito
                    successView
                } else {
                    // Contenido principal
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Tarjeta de saldo actual
                            balanceCard
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardsAppeared)
                            
                            // Selector de método
                            methodSelector
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardsAppeared)
                            
                            // Formulario de transferencia
                            transferForm
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: cardsAppeared)
                            
                            // Botón de acción
                            actionButton
                                .offset(y: cardsAppeared ? 0 : 20)
                                .opacity(cardsAppeared ? 1 : 0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: cardsAppeared)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            
            // Indicador de procesamiento
            if isProcessing {
                processingOverlay
            }
        }
        .sheet(isPresented: $showingQRCode) {
            qrCodeView
        }
        .sheet(isPresented: $showingNFCScanner) {
            nfcScannerView
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardsAppeared = true
            }
        }
    }
    
    // MARK: - Header View
    
    var headerView: some View {
        ZStack {
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
                    Text("Transferir Dinero")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text("Envía dinero rápido")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {
                    // Acción de información
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        
                        Image(systemName: "info.circle")
                            .font(.system(size: 18, weight: .medium))
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
    
    // MARK: - Balance Card
    
    var balanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Saldo Disponible")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                    
                    if let account = homeViewModel.account {
                        Text(formatCurrency(account.balance))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                    } else {
                        Text("$0.00")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.BBVATeal.opacity(0.2),
                                    Color.BBVAPrimaryRed.opacity(0.15)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color.BBVAPrimaryRed)
                }
            }
            
            Divider()
                .background(Color.BBVALightGray)
            
            HStack(spacing: 12) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 16))
                    .foregroundColor(Color.BBVASuccess)
                
                Text("Transferencias seguras y encriptadas")
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
    
    // MARK: - Method Selector
    
    var methodSelector: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Método de Transferencia")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 16) {
                ForEach(TransferMethod.allCases) { method in
                    methodCard(method: method)
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
    
    func methodCard(method: TransferMethod) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                selectedMethod = method
            }
        }) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    method.color.opacity(selectedMethod == method ? 0.3 : 0.15),
                                    method.color.opacity(selectedMethod == method ? 0.2 : 0.08)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: method.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(method.color)
                }
                
                Text(method.rawValue)
                    .font(.system(size: 15, weight: selectedMethod == method ? .bold : .medium))
                    .foregroundColor(selectedMethod == method ? Color.BBVACharcoal : Color.BBVATextSecondary)
                
                if selectedMethod == method {
                    Circle()
                        .fill(method.color)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selectedMethod == method ? method.color.opacity(0.08) : Color.BBVALightGray.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedMethod == method ? method.color : Color.clear, lineWidth: 2)
            )
        }
    }
    
    // MARK: - Transfer Form
    
    var transferForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Detalles de la Transferencia")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            // Monto
            VStack(alignment: .leading, spacing: 10) {
                Text("Monto")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVATextSecondary)
                
                HStack(spacing: 12) {
                    Text("$")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.BBVALightGray.opacity(0.5))
                )
            }
            
            // Nombre del destinatario
            VStack(alignment: .leading, spacing: 10) {
                Text("Nombre del Destinatario")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVATextSecondary)
                
                TextField("Ej: Juan Pérez", text: $recipientName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.BBVACharcoal)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.BBVALightGray.opacity(0.5))
                    )
            }
            
            // Cuenta del destinatario (opcional para QR/NFC)
            if selectedMethod == .qr || selectedMethod == .nfc {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cuenta (Opcional)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.BBVATextSecondary)
                    
                    TextField("Se detectará automáticamente", text: $recipientAccount)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.BBVACharcoal)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.BBVALightGray.opacity(0.5))
                        )
                        .disabled(true)
                }
            }
            
            // Concepto
            VStack(alignment: .leading, spacing: 10) {
                Text("Concepto")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVATextSecondary)
                
                TextField("Ej: Pago de servicio", text: $transferDescription)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.BBVACharcoal)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.BBVALightGray.opacity(0.5))
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
    
    // MARK: - Action Button
    
    var actionButton: some View {
        Button(action: {
            initiateTransfer()
        }) {
            HStack(spacing: 12) {
                Image(systemName: selectedMethod == .qr ? "qrcode.viewfinder" : "wave.3.forward")
                    .font(.system(size: 18, weight: .semibold))
                
                Text(selectedMethod == .qr ? "Generar QR" : "Activar NFC")
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(BBVAPrimaryButtonStyle())
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.5)
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
                    
                    Text("Escanea para recibir el pago")
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
                    
                    if let qrImage = generateQRCode(from: generateTransferData()) {
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
                
                // Información de la transferencia
                VStack(spacing: 12) {
                    infoRow(icon: "dollarsign.circle.fill", title: "Monto", value: "$\(amount)")
                    infoRow(icon: "person.fill", title: "Destinatario", value: recipientName)
                    infoRow(icon: "doc.text.fill", title: "Concepto", value: transferDescription)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.BBVALightGray.opacity(0.3))
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Botón de compartir
            Button(action: {
                // Compartir QR
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Compartir QR")
                        .font(.system(size: 17, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(BBVASecondaryButtonStyle())
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
                                    Color.BBVASuccess.opacity(0.6),
                                    Color.BBVASuccess.opacity(0.2)
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
                                    Color.BBVASuccess.opacity(0.2),
                                    Color.BBVASuccess.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                    
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 70, weight: .semibold))
                        .foregroundColor(Color.BBVASuccess)
                }
            }
            .onAppear {
                pulseAnimation = true
                
                // Simular detección NFC después de 3 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    processTransfer()
                }
            }
            
            VStack(spacing: 12) {
                Text("Acerca el dispositivo")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Text("Mantén tu dispositivo cerca del receptor para iniciar la transferencia")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Información de la transferencia
            VStack(spacing: 12) {
                Text("Monto a Transferir")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                
                Text("$\(amount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Color.BBVASuccess)
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
                showingNFCScanner = false
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
        VStack(spacing: 32) {
            Spacer()
            
            // Animación de éxito
            ZStack {
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
                    .scaleEffect(cardsAppeared ? 1.0 : 0.5)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6), value: cardsAppeared)
            }
            
            VStack(spacing: 12) {
                Text("¡Transferencia Exitosa!")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Text("$\(amount) MXN")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.BBVASuccess)
            }
            
            // Detalles de la transferencia
            VStack(spacing: 16) {
                detailRow(icon: "person.fill", title: "Destinatario", value: recipientName)
                detailRow(icon: "doc.text.fill", title: "Concepto", value: transferDescription)
                detailRow(icon: "clock.fill", title: "Fecha", value: formattedDate())
                detailRow(icon: selectedMethod.icon, title: "Método", value: selectedMethod.rawValue)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Botones de acción
            VStack(spacing: 12) {
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
                }
                .buttonStyle(BBVASecondaryButtonStyle())
                
                Button(action: {
                    resetForm()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Nueva Transferencia")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .buttonStyle(BBVAPrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.BBVABackground)
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
                
                Text("Procesando transferencia...")
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
        guard !recipientName.isEmpty else { return false }
        guard let balance = homeViewModel.account?.balance, amountValue <= balance else { return false }
        return true
    }
    
    func initiateTransfer() {
        if selectedMethod == .qr {
            showingQRCode = true
        } else {
            showingNFCScanner = true
        }
    }
    
    func processTransfer() {
        guard let amountValue = Double(amount) else { return }
        
        isProcessing = true
        showingNFCScanner = false
        showingQRCode = false
        
        // Simular procesamiento
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Task {
                // Guardar la transferencia
                let success = await homeViewModel.saveTransaction(
                    description: "Transferencia a \(recipientName): \(transferDescription)",
                    amount: -amountValue, // Negativo porque es salida
                    type: .expense,
                    category: "Transfer",
                    paymentMethod: selectedMethod.rawValue
                )
                
                isProcessing = false
                
                if success {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showingSuccess = true
                    }
                    
                    // Enviar notificación de transferencia completada
                    NotificationCenter.default.post(name: .refreshHomeData, object: nil)
                } else {
                    errorMessage = "Error al procesar la transferencia"
                }
            }
        }
    }
    
    func resetForm() {
        amount = ""
        recipientName = ""
        recipientAccount = ""
        transferDescription = "Transferencia"
        showingSuccess = false
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
    
    func generateTransferData() -> String {
        return """
        {
            "type": "transfer",
            "amount": "\(amount)",
            "recipient": "\(recipientName)",
            "description": "\(transferDescription)",
            "method": "\(selectedMethod.rawValue)",
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

// MARK: - Preview

struct TransferView_Previews: PreviewProvider {
    static var previews: some View {
        TransferView()
            .environmentObject(HomeViewModel())
    }
}
