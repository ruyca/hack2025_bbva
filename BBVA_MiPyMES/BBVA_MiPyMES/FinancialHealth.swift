
import SwiftUI

struct FinancialHealth: View {
    @StateObject private var viewModel = FinanzasViewModel()
    @State private var selectedPeriod = "Mes"
    @State private var showBusinessForm = false
    
    let periods = ["Semana", "Mes", "Trimestre", "Año"]
    
    // Datos de gamificación
    let salesGoal: Double = 50000.0
    var currentSales: Double {
        viewModel.totalIngresos
    }
    var progressPercentage: Double {
        min((currentSales / salesGoal) * 100, 100)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo con gradiente azul moderno
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVABlue.opacity(0.1),
                        Color.BBVABackground
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header con selector de período
                        headerSection
                        
                        // Tarjeta de gamificación (nuevo)
                        gamificationCard
                        
                        // Tarjeta de saldo destacada
                        modernSaldoCard
                        
                        // KPIs mejorados
                        modernKPISection
                        
                        // Gráficas
                        modernGraphSection
                        
                        // Accesos directos mejorados
                        modernQuickActions
                        
                        // Transacciones recientes
                        modernTransactionsList
                        
                        // Metas financieras
                        modernGoalsList
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Salud Financiera")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.BBVACharcoal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.BBVABlue.opacity(0.15))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color.BBVABlue)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showBusinessForm) {
            BusinessFormView()
        }
    }
    
    // MARK: - Header Section
    
    var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Período")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVATextSecondary)
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(periods, id: \.self) { period in
                        periodButton(for: period)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func periodButton(for period: String) -> some View {
        let isSelected = selectedPeriod == period
        
        return Button(action: {
            withAnimation(.spring(response: 0.3)) {
                selectedPeriod = period
            }
        }) {
            Text(period)
                .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : Color.BBVABlue)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.BBVABlue : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.BBVABlue.opacity(isSelected ? 0 : 0.3), lineWidth: 1.5)
                )
                .shadow(
                    color: isSelected ? Color.BBVABlue.opacity(0.3) : Color.clear,
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
    }
    
    // MARK: - Gamification Card
    
    var gamificationCard: some View {
        Button(action: {
            showBusinessForm = true
        }) {
            VStack(spacing: 0) {
                // Fondo con gradiente
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.BBVAOrange.opacity(0.9),
                            Color.BBVASuccess.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .leading, spacing: 18) {
                        // Header con icono y título
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.25))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Meta de Ventas")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("¡Sigue así!")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Estadísticas
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Total Ventas")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                Text(currentSales, format: .currency(code: "MXN"))
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("Meta")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                Text(salesGoal, format: .currency(code: "MXN"))
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Barra de progreso
                        VStack(spacing: 8) {
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Fondo de la barra
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 12)
                                    
                                    // Progreso
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(
                                            width: geometry.size.width * (progressPercentage / 100),
                                            height: 12
                                        )
                                }
                            }
                            .frame(height: 12)
                            
                            HStack {
                                Text("\(Int(progressPercentage))% Completado")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                let remaining = salesGoal - currentSales
                                if remaining > 0 {
                                    Text("Faltan \(remaining, format: .currency(code: "MXN"))")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))
                                } else {
                                    Text("¡Meta Alcanzada! 🎉")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        // Badge de acción
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12, weight: .bold))
                                
                                Text("Crear tu sitio web")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.25))
                            )
                            
                            Spacer()
                        }
                    }
                    .padding(24)
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.BBVAOrange.opacity(0.4), radius: 20, x: 0, y: 10)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
    
    // MARK: - Modern Saldo Card
    
    var modernSaldoCard: some View {
        VStack(spacing: 0) {
            // Fondo con gradiente azul
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVABlue,
                        Color.BBVATeal
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Flujo Neto")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            Text(viewModel.flujoNeto, format: .currency(code: "MXN"))
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: viewModel.flujoNeto >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(viewModel.flujoNeto >= 0 ? "+12.5%" : "-8.3%")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Actualizado: \(Date(), style: .date)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("Ver detalle")
                                    .font(.system(size: 13, weight: .bold))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11, weight: .bold))
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(24)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.BBVABlue.opacity(0.3), radius: 20, x: 0, y: 10)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Modern KPI Section
    
    enum KPIFormat {
        case currency
        case percent
        case number
    }
    
    var modernKPISection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Indicadores Clave")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    modernKPICard(
                        titulo: "Ingresos",
                        valor: viewModel.totalIngresos,
                        icono: "arrow.down.circle.fill",
                        color: Color.BBVASuccess,
                        formato: .currency
                    )
                    
                    modernKPICard(
                        titulo: "Egresos",
                        valor: viewModel.totalEgresos,
                        icono: "arrow.up.circle.fill",
                        color: Color.BBVAError,
                        formato: .currency
                    )
                    
                    modernKPICard(
                        titulo: "Margen",
                        valor: viewModel.margenBeneficio,
                        icono: "percent",
                        color: Color.BBVAOrange,
                        formato: .percent
                    )
                    
                    modernKPICard(
                        titulo: "Transacciones",
                        valor: Double(viewModel.transacciones.count),
                        icono: "list.bullet.circle.fill",
                        color: Color.BBVATeal,
                        formato: .number
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    func modernKPICard(titulo: String, valor: Double, icono: String, color: Color, formato: KPIFormat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icono)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(titulo)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.BBVATextSecondary)
                
                Group {
                    switch formato {
                    case .currency:
                        Text(valor, format: .currency(code: "MXN"))
                    case .percent:
                        Text(valor / 100, format: .percent)
                    case .number:
                        Text("\(Int(valor))")
                    }
                }
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            }
        }
        .padding(18)
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Modern Graph Section
    
    var modernGraphSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Análisis Financiero")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Ver todo")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color.BBVABlue)
                }
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 0) {
                GraficasView(viewModel: viewModel)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Modern Quick Actions
    
    var modernQuickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Accesos Rápidos")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
                .padding(.horizontal, 20)
            
            HStack(spacing: 14) {
                modernQuickActionButton(
                    icono: "chart.pie.fill",
                    texto: "Reportes",
                    color: Color.BBVABlue
                )
                
                modernQuickActionButton(
                    icono: "doc.text.fill",
                    texto: "Facturas",
                    color: Color.BBVATeal
                )
                
                modernQuickActionButton(
                    icono: "gearshape.fill",
                    texto: "Ajustes",
                    color: Color.BBVAOrange
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    func modernQuickActionButton(icono: String, texto: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    color.opacity(0.2),
                                    color.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 70)
                    
                    Image(systemName: icono)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(texto)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.BBVACharcoal)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Modern Transactions List
    
    var modernTransactionsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Transacciones Recientes")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Spacer()
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("Ver todas")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(Color.BBVABlue)
                }
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(viewModel.transacciones.prefix(5)) { transaccion in
                    TransaccionCardView(transaccion: transaccion)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Modern Goals List
    
    var modernGoalsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Metas Financieras")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.BBVACharcoal)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.BBVABlue)
                }
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(viewModel.metas) { meta in
                    MetaCardView(meta: meta, colorSecundario: Color.BBVABlue)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 80)
        }
    }
}

struct FinancialHealth_Previews: PreviewProvider {
    static var previews: some View {
        FinancialHealth()
    }
}
