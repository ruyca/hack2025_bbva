import SwiftUI
import MapKit
import CoreLocation
import Combine

// --- Mantenemos las estructuras de datos existentes ---
struct TPVTransaction: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let transactionValue: Double
    let transactionCount: Int
    let date: Date
}

struct QuadrantData: Identifiable {
    let id: String
    let centerCoordinate: CLLocationCoordinate2D
    let boundingRegion: MKCoordinateRegion

    let totalTransactionValue: Double
    let totalTransactionCount: Int
    let numberOfTPVs: Int

    var averageTransactionValuePerTPV: Double {
        numberOfTPVs > 0 ? totalTransactionValue / Double(numberOfTPVs) : 0.0
    }

    var averageTicketSize: Double {
        totalTransactionCount > 0 ? totalTransactionValue / Double(totalTransactionCount) : 0.0
    }
}

enum VisualizationMode: String, CaseIterable, Identifiable {
    case totalValue = "Valor Total"
    case numberOfTPVs = "Número de TPVs"
    case averageTicketSize = "Ticket Promedio"
    case averageValuePerTPV = "Valor por TPV"

    var id: String { self.rawValue }
}

// --- Mantenemos la lógica existente para generación y procesamiento de datos ---
let cdmxReducedMinLat: Double = 19.35
let cdmxReducedMaxLat: Double = 19.48
let cdmxReducedMinLon: Double = -99.23
let cdmxReducedMaxLon: Double = -99.10

func generateSimulatedTPVData(count: Int = 3000) -> [TPVTransaction] {
    // Código existente para generar datos
    let minLat: Double = cdmxReducedMinLat
    let maxLat: Double = cdmxReducedMaxLat
    let minLon: Double = cdmxReducedMinLon
    let maxLon: Double = cdmxReducedMaxLon

    let calendar = Calendar.current
    let now = Date()
    let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)!

    var data: [TPVTransaction] = []
    for i in 0..<count {
        let randomLat = Double.random(in: minLat...maxLat)
        let randomLon = Double.random(in: minLon...maxLon)
        let randomValue = Double.random(in: 50.0...5000.0)
        let randomDate = Date.random(in: threeMonthsAgo...now)

        let transaction = TPVTransaction(
            coordinate: CLLocationCoordinate2D(latitude: randomLat, longitude: randomLon),
            transactionValue: randomValue,
            transactionCount: Int.random(in: 1...50),
            date: randomDate
        )
        data.append(transaction)
    }
    return data
}

extension Date {
    static func random(in range: ClosedRange<Date>) -> Date {
        let interval = range.upperBound.timeIntervalSince(range.lowerBound)
        let randomInterval = TimeInterval.random(in: 0...interval)
        return range.lowerBound.addingTimeInterval(randomInterval)
    }
}

func getQuadrantData(from tpvData: [TPVTransaction],
                       startDate: Date,
                       endDate: Date,
                       gridRows: Int,
                       gridColumns: Int) -> [QuadrantData] {
    // Código existente para procesar datos en cuadrantes
    let minLat: Double = cdmxReducedMinLat
    let maxLat: Double = cdmxReducedMaxLat
    let minLon: Double = cdmxReducedMinLon
    let maxLon: Double = cdmxReducedMaxLon

    let latStep = (maxLat - minLat) / Double(gridRows)
    let lonStep = (maxLon - minLon) / Double(gridColumns)

    let filteredData = tpvData.filter { $0.date >= startDate && $0.date <= endDate }

    struct TempQuadrantAggregation {
        var totalValue: Double = 0.0
        var totalCount: Int = 0
        var tpvIDs: Set<UUID> = []
    }

    var aggregatedData: [String: TempQuadrantAggregation] = [:]

    for transaction in filteredData {
        let lat = transaction.coordinate.latitude
        let lon = transaction.coordinate.longitude

        guard lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon else { continue }

        let row = Int(floor((lat - minLat) / latStep))
        let col = Int(floor((lon - minLon) / lonStep))

        let safeRow = max(0, min(row, gridRows - 1))
        let safeCol = max(0, min(col, gridColumns - 1))
        let quadrantKey = "\(safeRow)_\(safeCol)"

        if aggregatedData[quadrantKey] == nil {
            aggregatedData[quadrantKey] = TempQuadrantAggregation()
        }

        aggregatedData[quadrantKey]?.totalValue += transaction.transactionValue
        aggregatedData[quadrantKey]?.totalCount += transaction.transactionCount
        aggregatedData[quadrantKey]?.tpvIDs.insert(transaction.id)
    }

    var quadrantDataArray: [QuadrantData] = []
    for (key, aggregation) in aggregatedData {
        let components = key.split(separator: "_").map { Int($0)! }
        let row = components[0]
        let col = components[1]

        let centerLat = minLat + (Double(row) + 0.5) * latStep
        let centerLon = minLon + (Double(col) + 0.5) * lonStep

        let centerCoord = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)

        let boundingRegion = MKCoordinateRegion(
            center: centerCoord,
            span: MKCoordinateSpan(latitudeDelta: latStep, longitudeDelta: lonStep)
        )

        let quadrant = QuadrantData(
            id: key,
            centerCoordinate: centerCoord,
            boundingRegion: boundingRegion,
            totalTransactionValue: aggregation.totalValue,
            totalTransactionCount: aggregation.totalCount,
            numberOfTPVs: aggregation.tpvIDs.count
        )
        quadrantDataArray.append(quadrant)
    }

    return quadrantDataArray
}

// --- VISTA PRINCIPAL MODERNIZADA CON ESTILO BBVA ---
struct QuadrantHeatmapView: View {
    // BBVA Colors modernos
    let BBVAPrimaryRed = Color.BBVAPrimaryRed
    let BBVADarkRed = Color.BBVADarkRed
    let BBVATeal = Color.BBVATeal
    let BBVACharcoal = Color.BBVACharcoal
    let BBVABackground = Color.BBVABackground
    
    // Estado del mapa y datos
    @State private var mapCameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.415, longitude: -99.165),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    @State private var rawTPVData: [TPVTransaction] = []
    @State private var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var endDate: Date = Date()
    @State private var quadrantData: [QuadrantData] = []
    @State private var selectedQuadrant: QuadrantData? = nil
    @State private var selectedVisualizationMode: VisualizationMode = .totalValue
    @State private var isLoading: Bool = false
    
    // Estado para el menú de filtros
    @State private var showFilterMenu: Bool = false
    @State private var isFilterApplied: Bool = false
    @State private var showLegend: Bool = false
    
    // Animación
    @State private var headerAppeared = false
    
    // Configuración del grid
    let gridRows = 20
    let gridColumns = 20
    
    // Cálculo de valores máximos
    private var maxTotalValue: Double { quadrantData.map { $0.totalTransactionValue }.max() ?? 0.0 }
    private var maxNumberOfTPVs: Int { quadrantData.map { $0.numberOfTPVs }.max() ?? 0 }
    private var maxAverageTicketSize: Double { quadrantData.map { $0.averageTicketSize }.max() ?? 0.0 }
    private var maxAverageValuePerTPV: Double { quadrantData.map { $0.averageTransactionValuePerTPV }.max() ?? 0.0 }
    
    init() {
        _rawTPVData = State(initialValue: generateSimulatedTPVData(count: 5000))
        _quadrantData = State(initialValue: getQuadrantData(from: generateSimulatedTPVData(count: 5000), startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, endDate: Date(), gridRows: 20, gridColumns: 20))
    }
    
    var body: some View {
        ZStack {
            // Gradiente de fondo sutil
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.BBVABackground,
                    Color.BBVALightBlue.opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header moderno
                modernHeader
                
                // Mapa con overlay
                ZStack {
                    Map(position: $mapCameraPosition) {
                        ForEach(quadrantData) { quadrant in
                            Annotation("", coordinate: quadrant.centerCoordinate) {
                                Rectangle()
                                    .foregroundColor(colorForQuadrant(quadrant, mode: selectedVisualizationMode))
                                    .frame(width: squareSizeForQuadrant(quadrant, mode: selectedVisualizationMode),
                                          height: squareSizeForQuadrant(quadrant, mode: selectedVisualizationMode))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                                    .onTapGesture {
                                        selectedQuadrant = quadrant
                                    }
                            }
                        }
                    }
                    .cornerRadius(0)
                    
                    // Estadísticas flotantes en la parte superior del mapa
                    VStack {
                        HStack(spacing: 12) {
                            quickStatCard(
                                icon: "chart.bar.fill",
                                title: "Zonas Activas",
                                value: "\(quadrantData.count)",
                                color: .BBVATeal
                            )
                            
                            quickStatCard(
                                icon: "creditcard.fill",
                                title: "Total TPVs",
                                value: "\(quadrantData.reduce(0) { $0 + $1.numberOfTPVs })",
                                color: .BBVAOrange
                            )
                            
                            quickStatCard(
                                icon: "dollarsign.circle.fill",
                                title: "Valor Total",
                                value: formatCurrency(quadrantData.reduce(0) { $0 + $1.totalTransactionValue }),
                                color: .BBVASuccess
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        
                        Spacer()
                        
                        // Leyenda compacta en la parte inferior
                        if showLegend {
                            modernLegendView
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            
            // Panel de filtros deslizable
            if showFilterMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showFilterMenu = false
                        }
                    }
                
                HStack {
                    Spacer()
                    
                    modernFilterPanel
                        .frame(width: 340)
                        .transition(.move(edge: .trailing))
                }
                .zIndex(10)
            }
            
            // Indicador de carga
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Actualizando datos...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.BBVACharcoal.opacity(0.95))
                    )
                }
                .zIndex(15)
            }
        }
        .sheet(item: $selectedQuadrant) { quadrant in
            modernQuadrantDetailView(quadrant: quadrant)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            if quadrantData.isEmpty {
                updateQuadrantData()
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                headerAppeared = true
            }
        }
    }
    
    // Función para actualizar los datos de los cuadrantes
    private func updateQuadrantData() {
        quadrantData = getQuadrantData(from: rawTPVData, startDate: startDate, endDate: endDate, gridRows: gridRows, gridColumns: gridColumns)
    }
    
    // MARK: - Modern UI Components
    
    // Header moderno con gradiente
    private var modernHeader: some View {
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
            
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mapa de Calor")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                    
                    Text("Análisis Geográfico")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showLegend.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: showLegend ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showFilterMenu.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(isFilterApplied ? 0.3 : 0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
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
        .offset(y: headerAppeared ? 0 : -100)
        .opacity(headerAppeared ? 1 : 0)
    }
    
    // Panel de filtros moderno
    private var modernFilterPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header del panel
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Filtros Avanzados")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.BBVACharcoal)
                    
                    Text("Personaliza tu análisis")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.BBVATextSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        showFilterMenu = false
                    }
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
            .padding(24)
            .background(Color.white)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Período de análisis
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Período de Análisis", systemImage: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.BBVACharcoal)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Desde:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.BBVATextSecondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .accentColor(Color.BBVAPrimaryRed)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.BBVALightGray.opacity(0.3))
                            )
                            
                            HStack {
                                Text("Hasta:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.BBVATextSecondary)
                                    .frame(width: 60, alignment: .leading)
                                
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .accentColor(Color.BBVAPrimaryRed)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.BBVALightGray.opacity(0.3))
                            )
                        }
                    }
                    
                    Divider()
                    
                    // Métrica a visualizar
                    VStack(alignment: .leading, spacing: 14) {
                        Label("Métrica de Visualización", systemImage: "chart.bar.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.BBVACharcoal)
                        
                        VStack(spacing: 10) {
                            ForEach(VisualizationMode.allCases) { mode in
                                Button(action: {
                                    selectedVisualizationMode = mode
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: iconForMode(mode))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(selectedVisualizationMode == mode ? Color.BBVAPrimaryRed : Color.BBVATextSecondary)
                                            .frame(width: 24)
                                        
                                        Text(mode.rawValue)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(selectedVisualizationMode == mode ? Color.BBVACharcoal : Color.BBVATextSecondary)
                                        
                                        Spacer()
                                        
                                        if selectedVisualizationMode == mode {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(Color.BBVAPrimaryRed)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedVisualizationMode == mode ? Color.BBVAPrimaryRed.opacity(0.1) : Color.BBVALightGray.opacity(0.3))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedVisualizationMode == mode ? Color.BBVAPrimaryRed.opacity(0.3) : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.white)
            
            // Botón aplicar
            VStack(spacing: 0) {
                Divider()
                
                Button(action: {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        updateQuadrantData()
                        isLoading = false
                        isFilterApplied = true
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showFilterMenu = false
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Aplicar Filtros")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                }
                .buttonStyle(BBVAPrimaryButtonStyle())
                .padding(20)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .bottomLeft])
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: -10, y: 0)
    }
    
    // Leyenda moderna
    private var modernLegendView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Intensidad de Actividad")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color.BBVACharcoal)
            
            HStack(spacing: 16) {
                legendItem(color: .white.opacity(0.5), text: "Baja", icon: "circle.fill")
                legendItem(color: .yellow.opacity(0.5), text: "Media", icon: "circle.fill")
                legendItem(color: .orange.opacity(0.5), text: "Alta", icon: "circle.fill")
                legendItem(color: .red.opacity(0.5), text: "Muy Alta", icon: "circle.fill")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.95))
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private func legendItem(color: Color, text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.BBVATextPrimary)
        }
    }
    
    // Tarjeta de estadística rápida
    private func quickStatCard(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.BBVATextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.95))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    // Helper para formatear moneda
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        
        if value >= 1_000_000 {
            return "$\(String(format: "%.1f", value / 1_000_000))M"
        } else if value >= 1_000 {
            return "$\(String(format: "%.1f", value / 1_000))K"
        }
        
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    // Icono para cada modo de visualización
    private func iconForMode(_ mode: VisualizationMode) -> String {
        switch mode {
        case .totalValue: return "dollarsign.circle.fill"
        case .numberOfTPVs: return "creditcard.fill"
        case .averageTicketSize: return "cart.fill"
        case .averageValuePerTPV: return "building.2.fill"
        }
    }
    
    // Vista de detalle del cuadrante modernizada
    private func modernQuadrantDetailView(quadrant: QuadrantData) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header con gradiente
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.BBVAPrimaryRed,
                            Color.BBVADarkRed
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Análisis de Zona")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                        
                        Text("Cuadrante \(quadrant.id)")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 14))
                            
                            Text("Lat: \(String(format: "%.4f", quadrant.centerCoordinate.latitude)), Lon: \(String(format: "%.4f", quadrant.centerCoordinate.longitude))")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: 140)
                
                // Contenido
                VStack(spacing: 16) {
                    // Estadísticas principales
                    HStack(spacing: 12) {
                        statBox(
                            title: "TPVs",
                            value: "\(quadrant.numberOfTPVs)",
                            icon: "creditcard.fill",
                            color: .BBVATeal
                        )
                        
                        statBox(
                            title: "Valor Total",
                            value: formatCurrency(quadrant.totalTransactionValue),
                            icon: "dollarsign.circle.fill",
                            color: .BBVASuccess
                        )
                    }
                    
                    HStack(spacing: 12) {
                        statBox(
                            title: "Transacciones",
                            value: "\(quadrant.totalTransactionCount)",
                            icon: "arrow.left.arrow.right",
                            color: .BBVAOrange
                        )
                        
                        statBox(
                            title: "Ticket Promedio",
                            value: formatCurrency(quadrant.averageTicketSize),
                            icon: "chart.line.uptrend.xyaxis",
                            color: .BBVAPrimaryRed
                        )
                    }
                    
                    // Mini mapa
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ubicación en el Mapa")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.BBVACharcoal)
                        
                        Map(initialPosition: .region(quadrant.boundingRegion)) {
                            Annotation("", coordinate: quadrant.centerCoordinate) {
                                Rectangle()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(Color.BBVAPrimaryRed.opacity(0.3))
                                    .overlay(
                                        Rectangle()
                                            .stroke(Color.BBVAPrimaryRed, lineWidth: 3)
                                            .frame(width: 150, height: 150)
                                    )
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(16)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(20)
                .background(Color.BBVABackground)
            }
        }
        .background(Color.BBVABackground)
        .edgesIgnoringSafeArea(.top)
    }
    
    // Caja de estadística
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color.BBVATextSecondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.BBVACharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // Funciones para cálculos de valores normalizados y visualización
    private func normalizedValue(for quadrant: QuadrantData, mode: VisualizationMode) -> Double {
        let value: Double
        let maxValue: Double

        switch mode {
            case .totalValue:
                value = quadrant.totalTransactionValue
                maxValue = maxTotalValue
            case .numberOfTPVs:
                value = Double(quadrant.numberOfTPVs)
                maxValue = Double(maxNumberOfTPVs)
            case .averageTicketSize:
                value = quadrant.averageTicketSize
                maxValue = maxAverageTicketSize
            case .averageValuePerTPV:
                value = quadrant.averageTransactionValuePerTPV
                maxValue = maxAverageValuePerTPV
        }

        guard maxValue > 0 else { return 0.0 }
        return min(value / maxValue, 1.0)
    }
    
    private func colorForQuadrant(_ quadrant: QuadrantData, mode: VisualizationMode) -> Color {
        let normalized = normalizedValue(for: quadrant, mode: mode)
        
        // Escala de colores BBVA - Con menor opacidad
        if normalized < 0.2 {
            return .white.opacity(0.3) // Baja actividad
        } else if normalized < 0.5 {
            return .yellow.opacity(0.3) // Media-baja
        } else if normalized < 0.8 {
            return .orange.opacity(0.3) // Media-alta
        } else {
            return .red.opacity(0.3) // Alta actividad
        }
    }
    
    private func squareSizeForQuadrant(_ quadrant: QuadrantData, mode: VisualizationMode) -> CGFloat {
        let normalized = normalizedValue(for: quadrant, mode: mode)
        let minSize: CGFloat = 8
        let maxSize: CGFloat = 40
        return minSize + (maxSize - minSize) * CGFloat(normalized)
    }
}

// Panel de filtros deslizable
struct FilterMenuPanel: View {
    let BBVAPrimaryRed: Color
    let BBVACharcoal: Color
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var selectedVisualizationMode: VisualizationMode
    @Binding var isLoading: Bool
    @Binding var showFilterMenu: Bool
    @Binding var isFilterApplied: Bool
    
    var applyFilters: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header del panel
            HStack {
                Text("Filtros")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(BBVACharcoal)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showFilterMenu = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(BBVACharcoal)
                        .padding(8)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Rango de fechas
            VStack(alignment: .leading, spacing: 12) {
                Text("Período de análisis")
                    .font(.headline)
                    .foregroundColor(BBVACharcoal)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Desde:")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(BBVAPrimaryRed)
                    }
                    
                    HStack {
                        Text("Hasta:")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(BBVAPrimaryRed)
                    }
                }
            }
            
            Divider()
            
            // Selección de visualización
            VStack(alignment: .leading, spacing: 12) {
                Text("Métrica a visualizar")
                    .font(.headline)
                    .foregroundColor(BBVACharcoal)
                
                VStack(spacing: 10) {
                    ForEach(VisualizationMode.allCases) { mode in
                        Button(action: {
                            selectedVisualizationMode = mode
                        }) {
                            HStack {
                                Text(mode.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(selectedVisualizationMode == mode ? BBVAPrimaryRed : .gray)
                                
                                Spacer()
                                
                                if selectedVisualizationMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(BBVAPrimaryRed)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedVisualizationMode == mode ? BBVAPrimaryRed.opacity(0.1) : Color.clear)
                            )
                        }
                    }
                }
            }
            
            Spacer()
            
            // Botón aplicar
            Button(action: applyFilters) {
                HStack {
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Aplicar Filtros")
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(BBVAPrimaryRed)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(isLoading)
        }
        .padding()
    }
}

// Leyenda pequeña
struct LegendView: View {
    let BBVACharcoal: Color
    
    var body: some View {
        HStack(spacing: 10) {
            legendItem(color: .white.opacity(0.3), text: "Baja")
            legendItem(color: .yellow.opacity(0.3), text: "Media")
            legendItem(color: .orange.opacity(0.3), text: "Alta")
            legendItem(color: .red.opacity(0.3), text: "Muy Alta")
        }
    }
    
    // Función auxiliar para elementos de leyenda
    func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(BBVACharcoal.opacity(0.3), lineWidth: 0.5)
                )
            
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(BBVACharcoal)
        }
    }
}

// --- VISTA DE DETALLE REDISEÑADA CON ESTILO BBVA ---
struct QuadrantDetailView: View {
    let quadrant: QuadrantData
    let BBVAPrimaryRed: Color
    let BBVACharcoal: Color
    let BBVATeal: Color
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Análisis de Zona")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Cuadrante \(quadrant.id)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BBVAPrimaryRed)
                
                // Contenido
                VStack(spacing: 16) {
                    // Tarjeta de resumen
                    VStack {
                        Text("Resumen de actividad")
                            .font(.headline)
                            .foregroundColor(BBVACharcoal)
                            .padding(.bottom, 8)
                        
                        HStack(spacing: 30) {
                            // Puntos de venta
                            VStack {
                                Text("\(quadrant.numberOfTPVs)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(BBVAPrimaryRed)
                                
                                Text("TPVs")
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            // Valor total
                            VStack {
                                Text(formattedCurrency(quadrant.totalTransactionValue))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(BBVAPrimaryRed)
                                
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            // Transacciones
                            VStack {
                                Text("\(quadrant.totalTransactionCount)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(BBVAPrimaryRed)
                                
                                Text("Transacciones")
                                    .font(.caption)
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Tarjeta de promedios
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Datos promedio")
                            .font(.headline)
                            .foregroundColor(BBVACharcoal)
                        
                        Divider()
                        
                        // Métricas
                        VStack(spacing: 16) {
                            metricRow(
                                icon: "creditcard.fill",
                                title: "Ticket promedio",
                                value: formattedCurrency(quadrant.averageTicketSize)
                            )
                            
                            Divider()
                            
                            metricRow(
                                icon: "building.fill",
                                title: "Valor por TPV",
                                value: formattedCurrency(quadrant.averageTransactionValuePerTPV)
                            )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Mini mapa
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ubicación")
                            .font(.headline)
                            .foregroundColor(BBVACharcoal)
                        
                        // Mapa
                        Map(initialPosition: .region(quadrant.boundingRegion)) {
                            Annotation("", coordinate: quadrant.centerCoordinate) {
                                Rectangle()
                                    .frame(width: 180, height: 180)
                                    .foregroundColor(BBVAPrimaryRed.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .stroke(BBVAPrimaryRed, lineWidth: 2)
                                            .frame(width: 180, height: 180)
                                    )
                            }
                        }
                        .frame(height: 180)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Nota informativa
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(BBVATeal)
                        
                        Text("Datos agregados y anónimos para la zona de análisis.")
                            .font(.caption)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        .edgesIgnoringSafeArea(.top)
    }
    
    // Función helper para mostrar una fila de métrica
    func metricRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(BBVAPrimaryRed)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(BBVACharcoal)
            
            Spacer()
            
            Text(value)
                .foregroundColor(BBVAPrimaryRed)
                .fontWeight(.semibold)
        }
    }
    
    // Helper para formatear moneda
    func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}

// Para previews
struct QuadrantHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        QuadrantHeatmapView()
    }
}
