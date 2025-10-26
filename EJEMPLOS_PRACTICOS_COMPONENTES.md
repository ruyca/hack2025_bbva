# 💡 Ejemplos Prácticos de Uso - Componentes Modernos

Esta guía contiene ejemplos prácticos listos para copiar y pegar en tus vistas.

---

## 🏠 Ejemplo 1: Pantalla de Login Moderna

```swift
import SwiftUI

struct ModernLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

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

            VStack(spacing: 24) {
                // Logo con animación
                Image(systemName: "building.2.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.BBVAPrimaryRed)
                    .scaleIn(delay: 0.1)

                Text("Bienvenido")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.BBVACharcoal)
                    .slideIn(delay: 0.2)

                Text("Inicia sesión en tu cuenta")
                    .font(.system(size: 16))
                    .foregroundColor(.BBVATextSecondary)
                    .slideIn(delay: 0.3)

                VStack(spacing: 16) {
                    // Campo de email
                    BBVAFloatingLabelTextField(
                        text: $email,
                        label: "Correo electrónico",
                        icon: "envelope.fill"
                    )
                    .slideIn(delay: 0.4)

                    // Campo de contraseña
                    BBVAFloatingLabelTextField(
                        text: $password,
                        label: "Contraseña",
                        isSecure: true,
                        icon: "lock.fill"
                    )
                    .slideIn(delay: 0.5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Botón de iniciar sesión
                Button(action: {
                    HapticFeedback.medium()
                    // Login action
                }) {
                    Text("Iniciar Sesión")
                }
                .BBVAPrimaryButton()
                .padding(.horizontal, 20)
                .slideIn(delay: 0.6)

                // Botón secundario
                Button("¿Olvidaste tu contraseña?") {
                    HapticFeedback.light()
                }
                .BBVATertiaryButton()
                .slideIn(delay: 0.7)

                Spacer()
            }
            .padding(.top, 80)
        }
    }
}
```

---

## 📊 Ejemplo 2: Dashboard con Estadísticas

```swift
import SwiftUI

struct DashboardView: View {
    @State private var cardsAppeared = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Tarjeta de resumen con gradiente
                GradientCardView(
                    colors: [Color.BBVAPrimaryRed, Color.BBVADarkRed]
                ) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Balance Total")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))

                            Spacer()

                            StatusBadge(text: "Activo", type: .success, size: .small)
                        }

                        HStack(alignment: .firstTextBaseline) {
                            Text("$")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)

                            Text("125,450")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)

                            Text(".00")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        HStack {
                            TrendingBadge(percentage: "+12.5%", isPositive: true)

                            Text("vs. mes anterior")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .offset(y: cardsAppeared ? 0 : 20)
                .opacity(cardsAppeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardsAppeared)

                // Grid de métricas
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    metricCard(
                        icon: "arrow.down.circle.fill",
                        title: "Ingresos",
                        value: "$85,200",
                        trend: "+8%",
                        color: .BBVASuccess
                    )

                    metricCard(
                        icon: "arrow.up.circle.fill",
                        title: "Gastos",
                        value: "$32,400",
                        trend: "-3%",
                        color: .BBVAOrange
                    )

                    metricCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Ganancia",
                        value: "$52,800",
                        trend: "+15%",
                        color: .BBVATeal
                    )

                    metricCard(
                        icon: "person.2.fill",
                        title: "Clientes",
                        value: "342",
                        trend: "+23",
                        color: .BBVAPrimaryRed
                    )
                }
                .offset(y: cardsAppeared ? 0 : 20)
                .opacity(cardsAppeared ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardsAppeared)
            }
            .padding(20)
        }
        .onAppear {
            withAnimation {
                cardsAppeared = true
            }
        }
    }

    func metricCard(icon: String, title: String, value: String, trend: String, color: Color) -> some View {
        ModernCardView(
            cornerRadius: 16,
            padding: 18,
            useGradient: true,
            gradientColors: [color.opacity(0.1), color.opacity(0.05)]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconBadge(
                        icon: icon,
                        backgroundColor: color.opacity(0.2),
                        iconColor: color,
                        size: 40,
                        cornerRadius: 10
                    )

                    Spacer()

                    TrendingBadge(
                        percentage: trend,
                        isPositive: !trend.contains("-"),
                        size: .small
                    )
                }

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.BBVATextSecondary)

                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.BBVACharcoal)
            }
        }
    }
}
```

---

## 💳 Ejemplo 3: Lista de Transacciones con Skeleton Loading

```swift
import SwiftUI

struct TransactionsListView: View {
    @State private var transactions: [Transaction] = []
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Transacciones")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.BBVACharcoal)

                Spacer()

                Button(action: {
                    HapticFeedback.light()
                }) {
                    Image(systemName: "slider.horizontal.3")
                }
                .BBVAIconButton(size: 44)
            }
            .padding(20)

            // Barra de búsqueda
            BBVASearchFieldStyle(text: .constant(""), placeholder: "Buscar transacciones...")
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Tags de filtro
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TagBadge(text: "Todas", color: .BBVAPrimaryRed, isSelected: true)
                    TagBadge(text: "Ingresos", color: .BBVASuccess, isSelected: false)
                    TagBadge(text: "Gastos", color: .BBVAOrange, isSelected: false)
                    TagBadge(text: "Pendientes", color: .BBVAWarning, isSelected: false)
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)

            // Lista de transacciones
            ScrollView {
                VStack(spacing: 12) {
                    if isLoading {
                        // Skeleton loading
                        ForEach(0..<5, id: \.self) { _ in
                            transactionSkeleton
                        }
                    } else {
                        ForEach(transactions) { transaction in
                            transactionCard(transaction)
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color.BBVABackground)
        .onAppear {
            // Simular carga
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }

    var transactionSkeleton: some View {
        HStack(spacing: 14) {
            SkeletonView()
                .frame(width: 48, height: 48)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                SkeletonView()
                    .frame(height: 16)
                    .frame(maxWidth: 150)

                SkeletonView()
                    .frame(height: 14)
                    .frame(maxWidth: 100)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                SkeletonView()
                    .frame(width: 80, height: 16)

                SkeletonView()
                    .frame(width: 60, height: 14)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
    }

    func transactionCard(_ transaction: Transaction) -> some View {
        Button(action: {
            HapticFeedback.light()
        }) {
            HStack(spacing: 14) {
                IconBadge(
                    icon: transaction.isIncome ? "arrow.down.left" : "arrow.up.right",
                    backgroundColor: transaction.isIncome ? Color.BBVASuccess.opacity(0.15) : Color.BBVAOrange.opacity(0.15),
                    iconColor: transaction.isIncome ? .BBVASuccess : .BBVAOrange,
                    size: 48,
                    cornerRadius: 12
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.BBVACharcoal)

                    HStack(spacing: 6) {
                        Text(transaction.category)
                            .font(.system(size: 14))
                            .foregroundColor(.BBVATextSecondary)

                        StatusBadge(text: transaction.status, type: .info, size: .small)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(transaction.amount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(transaction.isIncome ? .BBVASuccess : .BBVACharcoal)

                    Text(transaction.date)
                        .font(.system(size: 14))
                        .foregroundColor(.BBVATextSecondary)
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Modelo de ejemplo
struct Transaction: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let amount: String
    let date: String
    let status: String
    let isIncome: Bool
}
```

---

## 🎯 Ejemplo 4: Formulario de Pago

```swift
import SwiftUI

struct PaymentFormView: View {
    @State private var amount = ""
    @State private var recipient = ""
    @State private var concept = ""
    @State private var selectedMethod = 0

    let paymentMethods = ["Transferencia", "Tarjeta", "Efectivo"]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.BBVAPrimaryRed,
                        Color.BBVADarkRed
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 8) {
                    Text("Nuevo Pago")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("Completa la información")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 30)
            }
            .frame(height: 120)

            ScrollView {
                VStack(spacing: 24) {
                    // Monto
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Monto")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVATextSecondary)

                        BBVAFocusedTextFieldStyle(
                            text: $amount,
                            placeholder: "$0.00",
                            icon: "dollarsign.circle.fill"
                        )
                    }

                    // Destinatario
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Destinatario")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVATextSecondary)

                        BBVAFocusedTextFieldStyle(
                            text: $recipient,
                            placeholder: "Nombre o número de cuenta",
                            icon: "person.fill"
                        )
                    }

                    // Concepto
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Concepto")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVATextSecondary)

                        BBVAFocusedTextFieldStyle(
                            text: $concept,
                            placeholder: "¿Para qué es el pago?",
                            icon: "doc.text.fill"
                        )
                    }

                    // Método de pago
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Método de pago")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.BBVATextSecondary)

                        HStack(spacing: 12) {
                            ForEach(0..<paymentMethods.count, id: \.self) { index in
                                TagBadge(
                                    text: paymentMethods[index],
                                    color: .BBVAPrimaryRed,
                                    isSelected: selectedMethod == index
                                )
                                .onTapGesture {
                                    HapticFeedback.light()
                                    withAnimation(.smoothSpring) {
                                        selectedMethod = index
                                    }
                                }
                            }
                        }
                    }

                    // Resumen
                    ModernCardView(
                        useGradient: true,
                        gradientColors: [Color.BBVALightBlue.opacity(0.3), Color.white]
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Resumen")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.BBVACharcoal)

                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text("$0.00")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.BBVATextSecondary)

                            HStack {
                                Text("Comisión")
                                Spacer()
                                Text("$0.00")
                            }
                            .font(.system(size: 14))
                            .foregroundColor(.BBVATextSecondary)

                            Divider()

                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                                Text("$0.00")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.BBVACharcoal)
                        }
                    }

                    // Botones
                    VStack(spacing: 12) {
                        Button(action: {
                            HapticFeedback.success()
                        }) {
                            Text("Realizar Pago")
                        }
                        .BBVAPrimaryButton()

                        Button("Cancelar") {
                            HapticFeedback.light()
                        }
                        .BBVASecondaryButton()
                    }
                }
                .padding(20)
            }
        }
        .background(Color.BBVABackground)
    }
}
```

---

## 🔔 Ejemplo 5: Notificaciones con Badges

```swift
import SwiftUI

struct NotificationsView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header con badge de contador
            HStack {
                Text("Notificaciones")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.BBVACharcoal)

                NumberBadge(count: 12)

                Spacer()

                Button("Marcar todas leídas") {
                    HapticFeedback.light()
                }
                .BBVATertiaryButton()
            }
            .padding(20)

            ScrollView {
                VStack(spacing: 12) {
                    notificationCard(
                        icon: "dollarsign.circle.fill",
                        iconColor: .BBVASuccess,
                        title: "Pago recibido",
                        message: "Has recibido un pago de $1,500.00 de Cliente XYZ",
                        time: "Hace 5 min",
                        isUnread: true,
                        badge: StatusBadge(text: "Nuevo", type: .success, size: .small)
                    )

                    notificationCard(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .BBVAWarning,
                        title: "Factura pendiente",
                        message: "Tienes una factura pendiente por $850.00",
                        time: "Hace 2 horas",
                        isUnread: true,
                        badge: StatusBadge(text: "Urgente", type: .warning, size: .small)
                    )

                    notificationCard(
                        icon: "checkmark.circle.fill",
                        iconColor: .BBVATeal,
                        title: "Transferencia completada",
                        message: "Tu transferencia de $2,300.00 fue exitosa",
                        time: "Ayer",
                        isUnread: false,
                        badge: nil
                    )

                    notificationCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .BBVAPrimaryRed,
                        title: "Reporte mensual",
                        message: "Tu reporte de septiembre está disponible",
                        time: "Hace 3 días",
                        isUnread: false,
                        badge: nil
                    )
                }
                .padding(20)
            }
        }
        .background(Color.BBVABackground)
    }

    func notificationCard(
        icon: String,
        iconColor: Color,
        title: String,
        message: String,
        time: String,
        isUnread: Bool,
        badge: StatusBadge?
    ) -> some View {
        Button(action: {
            HapticFeedback.light()
        }) {
            HStack(alignment: .top, spacing: 14) {
                // Indicador de no leído
                if isUnread {
                    Circle()
                        .fill(Color.BBVAPrimaryRed)
                        .frame(width: 8, height: 8)
                        .offset(y: 20)
                }

                // Ícono
                IconBadge(
                    icon: icon,
                    backgroundColor: iconColor.opacity(0.15),
                    iconColor: iconColor,
                    size: 48,
                    cornerRadius: 12
                )

                // Contenido
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: isUnread ? .bold : .semibold))
                            .foregroundColor(.BBVACharcoal)

                        if let badge = badge {
                            badge
                        }

                        Spacer()
                    }

                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.BBVATextSecondary)
                        .lineLimit(2)

                    Text(time)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.BBVAMediumGray)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.BBVAMediumGray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isUnread ? Color.BBVALightBlue.opacity(0.3) : Color.white)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
```

---

## 🎉 Tips para Usar estos Ejemplos

1. **Copia y pega** el código en tu proyecto
2. **Personaliza** los colores y textos según tu necesidad
3. **Combina** diferentes componentes para crear diseños únicos
4. **Experimenta** con los parámetros de animación
5. **Añade** feedback háptico para mejor UX

¡Todos estos componentes están listos para usar! 🚀
