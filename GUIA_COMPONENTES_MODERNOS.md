# 🎨 Guía de Componentes Modernos - BBVA

Esta guía te ayudará a usar los nuevos componentes modernizados de la aplicación BBVA.

## 📦 Componentes Disponibles

### 1. Botones Modernos (`BBVAButtonStyle.swift`)

#### Botón Principal (Primary)

```swift
Button("Continuar") {
    // Acción
}
.BBVAPrimaryButton()
```

#### Botón Secundario (Outlined)

```swift
Button("Cancelar") {
    // Acción
}
.BBVASecondaryButton()
```

#### Botón Terciario (Sutil)

```swift
Button("Ver más") {
    // Acción
}
.BBVATertiaryButton()
```

#### Botón Oscuro

```swift
Button("Modo oscuro") {
    // Acción
}
.BBVADarkButton()
```

#### Botón de Éxito

```swift
Button("Confirmar pago") {
    // Acción
}
.BBVASuccessButton()
```

#### Botón de Ícono

```swift
Button(action: {
    // Acción
}) {
    Image(systemName: "plus")
}
.BBVAIconButton(size: 48, backgroundColor: .BBVALightRed, iconColor: .BBVAPrimaryRed)
```

---

### 2. Campos de Texto Modernos (`BBVATextFieldStyle.swift`)

#### Campo de Texto Estándar

```swift
TextField("Email", text: $email)
    .BBVATextField()
```

#### Campo de Texto con Focus

```swift
BBVAFocusedTextFieldStyle(
    text: $email,
    placeholder: "Correo electrónico",
    icon: "envelope.fill"
)
```

#### Campo de Búsqueda

```swift
BBVASearchFieldStyle(text: $searchText, placeholder: "Buscar transacciones...")
```

#### Campo con Etiqueta Flotante

```swift
BBVAFloatingLabelTextField(
    text: $password,
    label: "Contraseña",
    isSecure: true,
    icon: "lock.fill"
)
```

---

### 3. Tarjetas Modernas (`ModernCardView.swift`)

#### Tarjeta Estándar

```swift
ModernCardView {
    VStack(alignment: .leading) {
        Text("Título")
            .font(.headline)
        Text("Contenido de la tarjeta")
    }
}
```

#### Tarjeta con Gradiente

```swift
ModernCardView(useGradient: true, gradientColors: [.white, Color.BBVALightBlue.opacity(0.3)]) {
    // Contenido
}
```

#### Tarjeta de Cristal (Glassmorphism)

```swift
GlassCardView {
    VStack {
        Text("Efecto glassmorphism")
        Text("Muy moderno")
    }
}
```

#### Tarjeta con Gradiente de Color

```swift
GradientCardView(colors: [Color.BBVAPrimaryRed, Color.BBVADarkRed]) {
    VStack(alignment: .leading) {
        Text("Tarjeta Premium")
            .foregroundColor(.white)
    }
}
```

#### Tarjeta con Borde

```swift
BorderedCardView(borderColor: .BBVAPrimaryRed, borderWidth: 2) {
    // Contenido
}
```

---

### 4. Badges y Chips (`ModernBadgeView.swift`)

#### Badge de Estado

```swift
StatusBadge(text: "Activo", type: .success, icon: "checkmark.circle.fill")
StatusBadge(text: "Pendiente", type: .warning, icon: "clock.fill")
StatusBadge(text: "Error", type: .error, icon: "xmark.circle.fill")
```

Tipos disponibles: `.success`, `.warning`, `.error`, `.info`, `.neutral`

#### Badge de Número (Notificaciones)

```swift
ZStack(alignment: .topTrailing) {
    Image(systemName: "bell.fill")
        .font(.system(size: 30))

    NumberBadge(count: 5)
        .offset(x: 8, y: -8)
}
```

#### Badge de Ícono

```swift
IconBadge(
    icon: "creditcard.fill",
    backgroundColor: Color.BBVATeal.opacity(0.15),
    iconColor: Color.BBVATeal,
    size: 50
)
```

#### Badge de Tendencia

```swift
TrendingBadge(percentage: "+14.5%", isPositive: true)
TrendingBadge(percentage: "-3.2%", isPositive: false)
```

#### Tags (Etiquetas)

```swift
TagBadge(text: "Finanzas", color: .BBVAPrimaryRed, isSelected: true)
TagBadge(text: "Tecnología", color: .BBVATeal, isSelected: false)
```

---

### 5. Animaciones Modernas (`ModernAnimations.swift`)

#### Efecto Shimmer (Brillo)

```swift
Text("Cargando...")
    .shimmer()
```

#### Efecto Pulse (Pulso)

```swift
Circle()
    .fill(Color.BBVATeal)
    .frame(width: 60, height: 60)
    .pulse()
```

#### Efecto Flotante

```swift
Image(systemName: "cloud.fill")
    .floating(offset: 10)
```

#### Slide In (Deslizar hacia dentro)

```swift
VStack {
    Text("Animado")
}
.slideIn(delay: 0.2)
```

#### Scale In (Escalar hacia dentro)

```swift
VStack {
    Text("Animado")
}
.scaleIn(delay: 0.1)
```

#### Rotación

```swift
Image(systemName: "arrow.clockwise")
    .rotate(duration: 1.0, repeatForever: true)
```

#### Skeleton Loading (Carga de esqueleto)

```swift
SkeletonView()
    .frame(height: 20)
    .cornerRadius(10)
```

#### Animaciones Predefinidas

```swift
withAnimation(.smoothSpring) {
    // Código animado
}

withAnimation(.quickSpring) {
    // Código animado
}

withAnimation(.bouncy) {
    // Código animado
}
```

#### Feedback Háptico

```swift
Button("Presionar") {
    HapticFeedback.light()    // Ligero
    HapticFeedback.medium()   // Medio
    HapticFeedback.heavy()    // Fuerte
    HapticFeedback.success()  // Éxito
    HapticFeedback.warning()  // Advertencia
    HapticFeedback.error()    // Error
}
```

---

## 🎨 Paleta de Colores

### Colores Principales

- `Color.BBVAPrimaryRed` / `Color.BBVABlue` - Azul principal (#1C4874)
- `Color.BBVADarkRed` / `Color.BBVADarkBlue` - Azul oscuro (#142959)
- `Color.BBVALightRed` / `Color.BBVALightBlue` - Azul claro (#E0EBF4)

### Colores Neutrales

- `Color.BBVACharcoal` - Gris azulado oscuro (#212933)
- `Color.BBVADarkGray` - Gris medio (#667385)
- `Color.BBVAMediumGray` - Gris claro (#A6ADB9)
- `Color.BBVALightGray` - Casi blanco (#F5F7F9)

### Colores de Acento

- `Color.BBVATeal` - Azul cyan (#3399CC)
- `Color.BBVAOrange` - Naranja suave (#FF9933)

### Colores de Estado

- `Color.BBVASuccess` - Verde (#29CC78)
- `Color.BBVAWarning` - Amarillo/Naranja (#FFB742)
- `Color.BBVAError` - Rojo coral (#F34559)

### Fondos

- `Color.BBVABackground` - Fondo principal (#FCFCFF)
- `Color.BBVACardBackground` - Fondo de tarjetas (blanco)
- `Color.BBVADarkBackground` - Fondo oscuro (#171C23)

### Textos

- `Color.BBVATextPrimary` - Texto principal (#212933)
- `Color.BBVATextSecondary` - Texto secundario (#85909F)
- `Color.BBVATextLight` - Texto claro (blanco)

---

## 📱 Ejemplos de Uso en HomeView

El `HomeView.swift` ha sido completamente modernizado con:

1. **Fondo con gradiente sutil**
2. **Header con diseño glassmorphism**
3. **Tarjetas con sombras sofisticadas**
4. **Animaciones de entrada suaves**
5. **Botones de acción con colores diferenciados**
6. **Transacciones con iconos coloridos**
7. **Estadísticas con badges de tendencia**
8. **Productos con iconos personalizados**

---

## 🚀 Tips de Uso

1. **Consistencia**: Usa los mismos estilos de componentes en toda la app
2. **Colores**: Mantén la paleta de colores definida
3. **Animaciones**: No abuses de las animaciones, úsalas con propósito
4. **Accesibilidad**: Los componentes tienen buen contraste de colores
5. **Performance**: Las animaciones están optimizadas para 60fps

---

## 📝 Notas

- Todos los componentes son reutilizables
- Los estilos siguen las guías de Material Design y iOS Human Interface Guidelines
- Los componentes son compatibles con Dark Mode (si se implementa)
- Todos los componentes tienen previews para desarrollo fácil

---

¡Disfruta construyendo UIs modernas con estos componentes! 🎉
