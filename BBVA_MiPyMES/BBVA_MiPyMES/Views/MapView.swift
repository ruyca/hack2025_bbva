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

// --- VISTA PRINCIPAL REDISEÑADA CON ESTILO BBVA Y PANTALLA COMPLETA ---
struct QuadrantHeatmapView: View {
    // BBVA Colors
    let bbvaPrimaryBlue = Color(red: 0.004, green: 0.345, blue: 0.663)  // Azul principal
    let bbvaDarkBlue = Color(red: 0, green: 0.216, blue: 0.416)         // Azul oscuro
    let bbvaLightBlue = Color(red: 0.188, green: 0.573, blue: 0.851)    // Azul claro
    let bbvaAqua = Color(red: 0, green: 0.8, blue: 0.8)                 // Aqua
    let bbvaBackground = Color(red: 0.95, green: 0.97, blue: 0.98)      // Fondo
    
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
    
    // Estado para el menú hamburguesa
    @State private var showFilterMenu: Bool = false
    @State private var isFilterApplied: Bool = false
    
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
            // Mapa a pantalla completa
            Map(position: $mapCameraPosition) {
                ForEach(quadrantData) { quadrant in
                    Annotation("", coordinate: quadrant.centerCoordinate) {
                        Rectangle()
                            .foregroundColor(colorForQuadrant(quadrant, mode: selectedVisualizationMode))
                            .frame(width: squareSizeForQuadrant(quadrant, mode: selectedVisualizationMode),
                                  height: squareSizeForQuadrant(quadrant, mode: selectedVisualizationMode))
                            .cornerRadius(3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(bbvaDarkBlue.opacity(0.2), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            .onTapGesture {
                                selectedQuadrant = quadrant
                            }
                    }
                }
            }
            .ignoresSafeArea(edges: [.horizontal, .bottom])
            
            // Header BBVA Style - Mantener solo la barra superior
            VStack {
                // Top Bar
                HStack {
                    // Título
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Análisis Geográfico")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Icono de Leyenda
                    Button(action: {
                        // Mostrar leyenda en un popover (o similar)
                    }) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    
                    // Botón hamburguesa para mostrar filtros
                    Button(action: {
                        withAnimation {
                            showFilterMenu.toggle()
                        }
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(bbvaPrimaryBlue)
                
                Spacer()
                
                // Pequeño indicador de filtro en la esquina inferior
                if isFilterApplied {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(selectedVisualizationMode.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(bbvaPrimaryBlue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding()
                    }
                }
            }
            
            // Panel de filtros (desplegable)
            if showFilterMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showFilterMenu = false
                        }
                    }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        FilterMenuPanel(
                            bbvaPrimaryBlue: bbvaPrimaryBlue,
                            bbvaDarkBlue: bbvaDarkBlue,
                            startDate: $startDate,
                            endDate: $endDate,
                            selectedVisualizationMode: $selectedVisualizationMode,
                            isLoading: $isLoading,
                            showFilterMenu: $showFilterMenu,
                            isFilterApplied: $isFilterApplied,
                            applyFilters: {
                                isLoading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    updateQuadrantData()
                                    isLoading = false
                                    isFilterApplied = true
                                    showFilterMenu = false
                                }
                            }
                        )
                        .frame(width: 300)
                        .background(bbvaBackground)
                        .customCornerRadius(12, corners: [.topLeft, .bottomLeft])
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: 0)
                        .transition(.move(edge: .trailing))
                    }
                }
                .zIndex(2)
            }
            
            // Leyenda pequeña en la esquina inferior izquierda
            VStack {
                Spacer()
                
                HStack {
                    LegendView(bbvaDarkBlue: bbvaDarkBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .padding()
                    
                    Spacer()
                }
            }
            
            // Indicador de carga cuando aplica filtros
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
            }
        }
        .sheet(item: $selectedQuadrant) { quadrant in
            QuadrantDetailView(
                quadrant: quadrant,
                bbvaPrimaryBlue: bbvaPrimaryBlue,
                bbvaDarkBlue: bbvaDarkBlue,
                bbvaLightBlue: bbvaLightBlue
            )
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            // Asegurarnos que los datos están cargados
            if quadrantData.isEmpty {
                updateQuadrantData()
            }
        }
    }
    
    // Función para actualizar los datos de los cuadrantes
    private func updateQuadrantData() {
        quadrantData = getQuadrantData(from: rawTPVData, startDate: startDate, endDate: endDate, gridRows: gridRows, gridColumns: gridColumns)
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
    let bbvaPrimaryBlue: Color
    let bbvaDarkBlue: Color
    
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
                    .foregroundColor(bbvaDarkBlue)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showFilterMenu = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(bbvaDarkBlue)
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
                    .foregroundColor(bbvaDarkBlue)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Desde:")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(bbvaPrimaryBlue)
                    }
                    
                    HStack {
                        Text("Hasta:")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                        
                        Spacer()
                        
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(bbvaPrimaryBlue)
                    }
                }
            }
            
            Divider()
            
            // Selección de visualización
            VStack(alignment: .leading, spacing: 12) {
                Text("Métrica a visualizar")
                    .font(.headline)
                    .foregroundColor(bbvaDarkBlue)
                
                VStack(spacing: 10) {
                    ForEach(VisualizationMode.allCases) { mode in
                        Button(action: {
                            selectedVisualizationMode = mode
                        }) {
                            HStack {
                                Text(mode.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(selectedVisualizationMode == mode ? bbvaPrimaryBlue : .gray)
                                
                                Spacer()
                                
                                if selectedVisualizationMode == mode {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(bbvaPrimaryBlue)
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedVisualizationMode == mode ? bbvaPrimaryBlue.opacity(0.1) : Color.clear)
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
                .background(bbvaPrimaryBlue)
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
    let bbvaDarkBlue: Color
    
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
                        .stroke(bbvaDarkBlue.opacity(0.3), lineWidth: 0.5)
                )
            
            Text(text)
                .font(.system(size: 9))
                .foregroundColor(bbvaDarkBlue)
        }
    }
}

// --- VISTA DE DETALLE REDISEÑADA CON ESTILO BBVA ---
struct QuadrantDetailView: View {
    let quadrant: QuadrantData
    let bbvaPrimaryBlue: Color
    let bbvaDarkBlue: Color
    let bbvaLightBlue: Color
    
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
                .background(bbvaPrimaryBlue)
                
                // Contenido
                VStack(spacing: 16) {
                    // Tarjeta de resumen
                    VStack {
                        Text("Resumen de actividad")
                            .font(.headline)
                            .foregroundColor(bbvaDarkBlue)
                            .padding(.bottom, 8)
                        
                        HStack(spacing: 30) {
                            // Puntos de venta
                            VStack {
                                Text("\(quadrant.numberOfTPVs)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(bbvaPrimaryBlue)
                                
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
                                    .foregroundColor(bbvaPrimaryBlue)
                                
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
                                    .foregroundColor(bbvaPrimaryBlue)
                                
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
                            .foregroundColor(bbvaDarkBlue)
                        
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
                            .foregroundColor(bbvaDarkBlue)
                        
                        // Mapa
                        Map(initialPosition: .region(quadrant.boundingRegion)) {
                            Annotation("", coordinate: quadrant.centerCoordinate) {
                                Rectangle()
                                    .frame(width: 180, height: 180)
                                    .foregroundColor(bbvaPrimaryBlue.opacity(0.2))
                                    .overlay(
                                        Rectangle()
                                            .stroke(bbvaPrimaryBlue, lineWidth: 2)
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
                            .foregroundColor(bbvaLightBlue)
                        
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
                .foregroundColor(bbvaPrimaryBlue)
                .font(.system(size: 18))
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(bbvaDarkBlue)
            
            Spacer()
            
            Text(value)
                .foregroundColor(bbvaPrimaryBlue)
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

// Extensión para el panel lateral - usamos un nombre diferente para evitar conflictos
extension View {
    func customCornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Para previews
struct QuadrantHeatmapView_Previews: PreviewProvider {
    static var previews: some View {
        QuadrantHeatmapView()
    }
}
