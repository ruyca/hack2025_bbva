import SwiftUI
import Firebase

struct HomeView: View {
    // Environment objects
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    // Usar colores globales de BBVA
    let BBVABlue = Color.BBVAPrimaryRed
    let BBVABackground = Color.BBVABackground
    
    // Estado para la selección del tab
    @State private var selectedTab = 0
    
    // Estados de animación
    @State private var cardsAppeared = false
    
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
            
            // Content or loading indicator
            if homeViewModel.isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    
                    Text("Cargando datos...")
                        .font(.headline)
                        .padding(.top, 16)
                }
            } else {
                mainContent
            }
            
            // Error message if present
            if let errorMessage = homeViewModel.errorMessage {
                VStack {
                    Spacer()
                    
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            // Reload data each time view appears
            Task {
                await homeViewModel.fetchData()
            }
            
            // Animación de entrada
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                cardsAppeared = true
            }
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            // Header con saludo y notificaciones
            headerView
            
            // Scroll View para el contenido principal
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Tarjeta de saldo
                    balanceCard
                        .offset(y: cardsAppeared ? 0 : 20)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardsAppeared)
                    
                    // Accesos rápidos
                    quickActionsView
                        .offset(y: cardsAppeared ? 0 : 20)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardsAppeared)
                    
                    // Transacciones recientes
                    recentTransactionsView
                        .offset(y: cardsAppeared ? 0 : 20)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: cardsAppeared)
                    
                    // Estadísticas
                    businessStatsView
                        .offset(y: cardsAppeared ? 0 : 20)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: cardsAppeared)
                    
                    // Productos
                    productsView
                        .offset(y: cardsAppeared ? 0 : 20)
                        .opacity(cardsAppeared ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: cardsAppeared)
                    
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                                .font(.system(size: 20))
                            
                            Text("Cerrar Sesión")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.BBVAPrimaryRed,
                                    Color.BBVADarkRed
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.BBVAPrimaryRed.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            // Barra de navegación inferior
            
        }
    }
    
    // Vista del encabezado
    var headerView: some View {
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
                        Text(greeting)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text(homeViewModel.business?.name ?? "Mi Negocio")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            print("Search tapped")
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Button(action: {
                            print("Notifications tapped")
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                // Badge de notificación
                                Circle()
                                    .fill(Color.BBVAError)
                                    .frame(width: 10, height: 10)
                                    .offset(x: 12, y: -12)
                            }
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
    
    // Greeting based on time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour < 12 {
            return "Buenos días,"
        } else if hour < 18 {
            return "Buenas tardes,"
        } else {
            return "Buenas noches,"
        }
    }
    
    // Tarjeta de saldo
    var balanceCard: some View {
        ZStack {
            // Fondo con gradiente sutil
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
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Cuenta de negocios")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.BBVATextSecondary)
                        
                        Text(homeViewModel.account?.accountNumberLastDigits ?? "**** ****")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color.BBVAMediumGray)
                            .tracking(1.5)
                    }
                    
                    Spacer()
                    
                    // Chip decorativo
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.BBVATeal.opacity(0.3),
                                        Color.BBVAPrimaryRed.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 40)
                        
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 20))
                            .foregroundColor(BBVABlue)
                    }
                }
                
                Divider()
                    .background(Color.BBVALightGray)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    if let account = homeViewModel.account {
                        let balanceComponents = formatBalance(account.balance)
                        
                        Text(balanceComponents.integer)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                        
                        Text(balanceComponents.decimal)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.BBVADarkGray)
                    } else {
                        Text("--")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print("View account details")
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.BBVATeal.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(BBVABlue)
                        }
                    }
                }
                
                Button(action: {
                    print("View all transactions")
                }) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(BBVABlue)
                        
                        Text("Ver todos los movimientos")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(BBVABlue)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14))
                            .foregroundColor(BBVABlue)
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.BBVATeal.opacity(0.1))
                    )
                }
            }
            .padding(24)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
    }
    
    // Helper to format balance
    func formatBalance(_ balance: Double) -> (integer: String, decimal: String) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: balance)
        let formattedString = formatter.string(from: number) ?? "0.00"
        
        let components = formattedString.split(separator: ".")
        
        return (
            integer: String(components[0]),
            decimal: components.count > 1 ? ".\(components[1])" : ".00"
        )
    }
    
    // Accesos rápidos
    var quickActionsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Acciones rápidas")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 16) {
                actionButton(
                    icon: "creditcard.fill",
                    text: "Cobrar",
                    color: Color.BBVATeal,
                    action: {
                        print("Navigate to Payment view")
                        selectedTab = 1
                    }
                )
                
                actionButton(
                    icon: "arrow.left.arrow.right",
                    text: "Transferir",
                    color: Color.BBVAPrimaryRed,
                    action: {
                        print("Navigate to Transfer view")
                        selectedTab = 2
                    }
                )
                
                actionButton(
                    icon: "doc.text.fill",
                    text: "Facturas",
                    color: Color.BBVAOrange,
                    action: {
                        print("Navigate to Invoices view")
                    }
                )
                
                actionButton(
                    icon: "qrcode.viewfinder",
                    text: "QR",
                    color: Color.BBVASuccess,
                    action: {
                        print("Navigate to QR code view")
                    }
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
    
    // Botones de acción modernizados
    func actionButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // Fondo con gradiente
                    LinearGradient(
                        gradient: Gradient(colors: [
                            color.opacity(0.2),
                            color.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.BBVATextPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Transacciones recientes
    var recentTransactionsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Movimientos recientes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Spacer()
                
                Button(action: {
                    print("View all transactions")
                }) {
                    HStack(spacing: 4) {
                        Text("Ver todos")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(BBVABlue)
                }
            }
            
            if homeViewModel.recentTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(Color.BBVAMediumGray)
                    
                    Text("No hay movimientos recientes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(homeViewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 62)
                        }
                        
                        transactionItem(
                            name: transaction.description,
                            desc: transaction.category ?? "Movimiento",
                            amount: formatAmount(transaction.amount),
                            date: formatDate(transaction.date),
                            isIncoming: transaction.type == .income
                        )
                    }
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
    
    // Item de transacción modernizado
    func transactionItem(name: String, desc: String, amount: String, date: String, isIncoming: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    gradient: Gradient(colors: [
                        isIncoming ? Color.BBVASuccess.opacity(0.2) : Color.BBVAOrange.opacity(0.2),
                        isIncoming ? Color.BBVASuccess.opacity(0.1) : Color.BBVAOrange.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Image(systemName: isIncoming ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isIncoming ? Color.BBVASuccess : Color.BBVAOrange)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.BBVATextPrimary)
                    .lineLimit(1)
                
                Text(desc)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isIncoming ? Color.BBVASuccess : Color.BBVACharcoal)
                
                Text(date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
            }
        }
        .padding(.vertical, 12)
    }
    
    // Helper to format transaction amount
    func formatAmount(_ amount: Double) -> String {
        let isNegative = amount < 0
        let absAmount = abs(amount)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        let formattedAmount = formatter.string(from: NSNumber(value: absAmount)) ?? "0.00"
        return (isNegative ? "-" : "+") + formattedAmount
    }
    
    // Helper to format transaction date
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Hoy"
        } else if calendar.isDateInYesterday(date) {
            return "Ayer"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    // Estadísticas del negocio
    var businessStatsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Rendimiento del negocio")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 16) {
                // Sales stats card
                statsCard(
                    title: "Ventas del mes",
                    value: formatCurrency(homeViewModel.businessStats?.totalSales ?? 0),
                    trend: "+14%",
                    isPositive: true,
                    color: Color.BBVASuccess
                )
                
                // Expenses stats card
                statsCard(
                    title: "Gastos",
                    value: formatCurrency(homeViewModel.businessStats?.totalExpenses ?? 0),
                    trend: "-5%",
                    isPositive: true,
                    color: Color.BBVAOrange
                )
            }
            
            Button(action: {
                print("View complete reports")
                selectedTab = 3
            }) {
                HStack {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 18))
                    
                    Text("Ver informes completos")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(BBVABlue)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.BBVATeal.opacity(0.1))
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
    
    // Helper to format currency
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    // Tarjeta de estadísticas modernizada
    func statsCard(title: String, value: String, trend: String, isPositive: Bool, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(trend)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                }
            }
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.BBVATextSecondary)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    color.opacity(0.08),
                    color.opacity(0.04)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // Productos
    var productsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Productos y servicios")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            VStack(spacing: 0) {
                productItem(
                    title: "Terminal punto de venta",
                    description: "Cobra con tarjetas a tus clientes",
                    icon: "creditcard.fill",
                    iconColor: Color.BBVATeal,
                    action: {
                        print("Navigate to POS terminal")
                        selectedTab = 1
                    }
                )
                
                Divider()
                    .padding(.leading, 62)
                
                productItem(
                    title: "Préstamo para tu negocio",
                    description: "Hasta $500,000 MXN pre-aprobados",
                    icon: "banknote.fill",
                    iconColor: Color.BBVASuccess,
                    action: {
                        print("Navigate to business loan")
                    }
                )
                
                Divider()
                    .padding(.leading, 62)
                
                productItem(
                    title: "Póliza de seguro",
                    description: "Protege tu negocio",
                    icon: "shield.checkered",
                    iconColor: Color.BBVAOrange,
                    action: {
                        print("Navigate to insurance")
                    }
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
    
    // Item de producto modernizado
    func productItem(title: String, description: String, icon: String, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            iconColor.opacity(0.2),
                            iconColor.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.BBVATextPrimary)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.BBVATeal.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(BBVABlue)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 12)
    }
    
    // Barra de navegación inferior
    var tabBar: some View {
        HStack {
            ForEach(0..<5) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 22))
                            .foregroundColor(selectedTab == index ? BBVABlue : Color.gray)
                        
                        Text(tabTitle(for: index))
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == index ? BBVABlue : Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    // Iconos para la barra de navegación
    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "creditcard.fill"
        case 2: return "arrow.left.arrow.right"
        case 3: return "chart.bar.fill"
        case 4: return "gear"
        default: return "house.fill"
        }
    }
    
    // Títulos para la barra de navegación
    func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Inicio"
        case 1: return "Cobrar"
        case 2: return "Operar"
        case 3: return "Gestión"
        case 4: return "Más"
        default: return "Inicio"
        }
    }
}

// Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(HomeViewModel())
    }
}
