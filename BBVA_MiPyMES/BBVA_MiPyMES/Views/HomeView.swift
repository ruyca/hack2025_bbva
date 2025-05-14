import SwiftUI
import Firebase

struct HomeView: View {
    // Environment object for authentication
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    // State object for home data
    @StateObject private var homeViewModel = HomeViewModel()
    
    // Colores BBVA
    let bbvaBlue = Color(red: 0.004, green: 0.345, blue: 0.663)
    let bbvaDarkBlue = Color(red: 0, green: 0.216, blue: 0.416)
    let bbvaLightBlue = Color(red: 0.188, green: 0.573, blue: 0.851)
    let bbvaAqua = Color(red: 0, green: 0.8, blue: 0.8)
    let bbvaBackground = Color(red: 0.95, green: 0.97, blue: 0.98)
    
    // Estado para la selección del tab
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Fondo
            bbvaBackground.edgesIgnoringSafeArea(.all)
            
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
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            // Header con saludo y notificaciones
            headerView
            
            // Scroll View para el contenido principal
            ScrollView {
                VStack(spacing: 24) {
                    // Tarjeta de saldo
                    balanceCard
                    
                    // Accesos rápidos
                    quickActionsView
                    
                    // Transacciones recientes
                    recentTransactionsView
                    
                    // Estadísticas
                    businessStatsView
                    
                    // Productos
                    productsView
                    
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Cerrar Sesión")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(bbvaBlue)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
                .padding(.bottom, 80)
            }
            
            // Barra de navegación inferior
            
        }
    }
    
    // Vista del encabezado
    var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(greeting)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(homeViewModel.business?.name ?? "Mi Negocio")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: {
                        print("Search tapped")
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        print("Notifications tapped")
                    }) {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .background(bbvaBlue)
            
            // Logo de BBVA
            HStack {
                Image(systemName: "b.circle.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                
                Text("BBVA Negocios")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 16)
            .background(bbvaBlue)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Cuenta de negocios")
                .font(.system(size: 16))
                .foregroundColor(Color.gray.opacity(0.8))
            
            HStack(alignment: .firstTextBaseline) {
                Text("$")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(bbvaDarkBlue)
                
                if let account = homeViewModel.account {
                    let balanceComponents = formatBalance(account.balance)
                    
                    Text(balanceComponents.integer)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(bbvaDarkBlue)
                    
                    Text(balanceComponents.decimal)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(bbvaDarkBlue)
                } else {
                    Text("--")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(bbvaDarkBlue)
                }
                
                Spacer()
                
                Button(action: {
                    print("View account details")
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(bbvaBlue)
                }
            }
            
            Text(homeViewModel.account?.accountNumberLastDigits ?? "**** ****")
                .font(.system(size: 16))
                .foregroundColor(Color.gray)
            
            Divider()
            
            Button(action: {
                print("View all transactions")
            }) {
                HStack {
                    Text("Ver movimientos")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaBlue)
                    
                    Image(systemName: "list.bullet")
                        .foregroundColor(bbvaBlue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.top, 16)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Acciones rápidas")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            HStack(spacing: 20) {
                actionButton(icon: "creditcard", text: "Cobrar", action: {
                    print("Navigate to Payment view")
                    selectedTab = 1 // Switch to the Cobrar tab
                })
                
                actionButton(icon: "arrow.right", text: "Transferir", action: {
                    print("Navigate to Transfer view")
                    selectedTab = 2 // Switch to the Operar tab
                })
                
                actionButton(icon: "doc.text", text: "Facturas", action: {
                    print("Navigate to Invoices view")
                })
                
                actionButton(icon: "qrcode", text: "QR", action: {
                    print("Navigate to QR code view")
                })
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Botones de acción
    func actionButton(icon: String, text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(bbvaLightBlue.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(bbvaBlue)
                }
                
                Text(text)
                    .font(.system(size: 14))
                    .foregroundColor(bbvaDarkBlue)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // Transacciones recientes
    var recentTransactionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Movimientos recientes")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(bbvaDarkBlue)
                
                Spacer()
                
                Button(action: {
                    print("View all transactions")
                }) {
                    Text("Ver todos")
                        .font(.system(size: 14))
                        .foregroundColor(bbvaBlue)
                }
            }
            
            if homeViewModel.recentTransactions.isEmpty {
                Text("No hay movimientos recientes")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(Array(homeViewModel.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                    if index > 0 {
                        Divider()
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
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Item de transacción
    func transactionItem(name: String, desc: String, amount: String, date: String, isIncoming: Bool) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(isIncoming ? bbvaAqua.opacity(0.2) : bbvaLightBlue.opacity(0.2))
                    .frame(width: 46, height: 46)
                
                Image(systemName: isIncoming ? "arrow.down.left.circle" : "arrow.up.right.circle")
                    .font(.system(size: 20))
                    .foregroundColor(isIncoming ? bbvaAqua : bbvaLightBlue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(bbvaDarkBlue)
                
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isIncoming ? Color.green : bbvaDarkBlue)
                
                Text(date)
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray)
            }
        }
        .padding(.vertical, 4)
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Rendimiento del negocio")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            HStack(spacing: 20) {
                // Sales stats card
                statsCard(
                    title: "Ventas del mes",
                    value: formatCurrency(homeViewModel.businessStats?.totalSales ?? 0),
                    trend: "+14%",
                    isPositive: true
                )
                
                // Expenses stats card
                statsCard(
                    title: "Gastos",
                    value: formatCurrency(homeViewModel.businessStats?.totalExpenses ?? 0),
                    trend: "-5%",
                    isPositive: true
                )
            }
            
            Button(action: {
                print("View complete reports")
                selectedTab = 3 // Switch to the Gestión tab
            }) {
                HStack {
                    Text("Ver informes completos")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaBlue)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(bbvaBlue)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Helper to format currency
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    // Tarjeta de estadísticas
    func statsCard(title: String, value: String, trend: String, isPositive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .font(.system(size: 12))
                    .foregroundColor(isPositive ? Color.green : Color.red)
                
                Text(trend)
                    .font(.system(size: 14))
                    .foregroundColor(isPositive ? Color.green : Color.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.97, green: 0.98, blue: 1.0))
        .cornerRadius(8)
    }
    
    // Productos
    var productsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Productos y servicios")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(bbvaDarkBlue)
            
            VStack(spacing: 16) {
                productItem(
                    title: "Terminal punto de venta",
                    description: "Cobra con tarjetas a tus clientes",
                    icon: "creditcard.fill",
                    action: {
                        print("Navigate to POS terminal")
                        selectedTab = 1 // Switch to the Cobrar tab
                    }
                )
                
                Divider()
                
                productItem(
                    title: "Préstamo para tu negocio",
                    description: "Hasta $500,000 MXN pre-aprobados",
                    icon: "chart.line.uptrend.xyaxis",
                    action: {
                        print("Navigate to business loan")
                    }
                )
                
                Divider()
                
                productItem(
                    title: "Póliza de seguro",
                    description: "Protege tu negocio",
                    icon: "lock.shield.fill",
                    action: {
                        print("Navigate to insurance")
                    }
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // Item de producto
    func productItem(title: String, description: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(bbvaLightBlue.opacity(0.2))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(bbvaBlue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaDarkBlue)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(bbvaBlue)
            }
        }
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
                            .foregroundColor(selectedTab == index ? bbvaBlue : Color.gray)
                        
                        Text(tabTitle(for: index))
                            .font(.system(size: 12))
                            .foregroundColor(selectedTab == index ? bbvaBlue : Color.gray)
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
    }
}
