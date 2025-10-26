# Guía de Estilo - BBVA (Modern Fintech Blue)

## Paleta de Colores

### Colores Primarios

- **Azul Principal**: `Color.BBVAPrimaryRed` - #3383FA (RGB: 51, 131, 250)
  - Uso: Botones principales, encabezados, acciones importantes
  - Más brillante y vibrante que BBVA
- **Azul Oscuro**: `Color.BBVADarkRed` - #2661BF (RGB: 38, 97, 191)

  - Uso: Estados hover, sombras, énfasis

- **Azul Claro**: `Color.BBVALightRed` - #E5F1FE (RGB: 229, 241, 254)
  - Uso: Fondos de tarjetas, áreas destacadas suaves

### Colores Neutrales

- **Gris Azulado Oscuro**: `Color.BBVACharcoal` - #212933 (RGB: 33, 41, 51)

  - Uso: Texto principal, encabezados importantes

- **Gris Medio**: `Color.BBVADarkGray` - #667385 (RGB: 102, 115, 133)

  - Uso: Texto secundario, iconos

- **Gris Claro**: `Color.BBVAMediumGray` - #A6ADB9 (RGB: 166, 173, 185)

  - Uso: Bordes, separadores, texto deshabilitado

- **Casi Blanco**: `Color.BBVALightGray` - #F5F7F9 (RGB: 245, 247, 249)
  - Uso: Fondos alternativos, áreas de input

### Colores de Acento

- **Turquesa**: `Color.BBVATeal` - #00BAD4 (RGB: 0, 186, 212)

  - Uso: Gráficas, información, acciones terciarias

- **Naranja**: `Color.BBVAOrange` - #FF9933 (RGB: 255, 153, 51)
  - Uso: Alertas, llamadas de atención positivas

### Colores de Fondo

- **Fondo Principal**: `Color.BBVABackground` - #FCFCFF (RGB: 252, 252, 255)
- **Fondo de Tarjeta**: `Color.BBVACardBackground` - White
- **Fondo Oscuro**: `Color.BBVADarkBackground` - #171C23 (RGB: 23, 28, 35)

### Colores de Texto

- **Texto Principal**: `Color.BBVATextPrimary` - #212933
- **Texto Secundario**: `Color.BBVATextSecondary` - #85909F
- **Texto Claro**: `Color.BBVATextLight` - White

### Colores de Estado

- **Éxito**: `Color.BBVASuccess` - #29CC78 (RGB: 41, 204, 120)
- **Advertencia**: `Color.BBVAWarning` - #FFB742 (RGB: 255, 183, 66)
- **Error**: `Color.BBVAError` - #F34559 (RGB: 243, 69, 89)

## Estilos de Botones

### Botón Principal (Rojo)

```swift
Button("Texto") {
    // acción
}
.BBVAPrimaryButton()
```

### Botón Secundario (Outlined)

```swift
Button("Texto") {
    // acción
}
.BBVASecondaryButton()
```

### Botón Terciario (Solo Texto)

```swift
Button("Texto") {
    // acción
}
.BBVATertiaryButton()
```

### Botón Oscuro (Charcoal)

```swift
Button("Texto") {
    // acción
}
.BBVADarkButton()
```

## Estilos de Campos de Texto

### TextField Estándar

```swift
TextField("Placeholder", text: $text)
    .BBVATextField()
```

### TextField con Foco (Rojo)

```swift
BBVAFocusedTextFieldStyle(text: $text, placeholder: "Email")
```

### Campo de Búsqueda

```swift
BBVASearchFieldStyle(text: $searchText, placeholder: "Buscar...")
```

## Tipografía

### Capital One Style

- **Títulos Grandes**: `.font(.system(size: 32, weight: .bold))`
- **Títulos**: `.font(.system(size: 24, weight: .semibold))`
- **Subtítulos**: `.font(.system(size: 18, weight: .medium))`
- **Cuerpo**: `.font(.system(size: 16, weight: .regular))`
- **Caption**: `.font(.system(size: 14, weight: .regular))`

## Espaciado

- **Padding Estándar**: 16pt
- **Padding Grande**: 24pt
- **Padding Pequeño**: 8pt
- **Border Radius**: 8pt (estándar), 12pt (tarjetas)

## Reemplazos de Código

### Buscar y Reemplazar

1. `Color("BBVAPrimaryBlue")` → `Color.BBVAPrimaryRed`
2. `Color("BBVASecondaryBlue")` → `Color.BBVADarkRed`
3. `Color("BBVADarkGray")` → `Color.BBVADarkGray`
4. `Color("BBVALightGray")` → `Color.BBVALightGray`
5. `Color("BBVATextColor")` → `Color.BBVATextPrimary`
6. `Color("BBVAErrorRed")` → `Color.BBVAError`
7. `BBVAPrimaryBlue` → `BBVAPrimaryRed`
8. `BBVASecondaryBlue` → `BBVADarkRed`
9. `"BBVA"` → `"BBVA"`
10. `"BBVA Empresas"` → `"BBVA Empresas"`

## Cambios en Textos

- "Bienvenido a BBVA" → "Tu aliado financiero"
- "BBVA MiPyMES" → "BBVA"
- Cualquier mención de "banco" → "plataforma financiera"

## Archivos Actualizados

- ✅ `ColorBBVA.swift` → Ahora incluye paleta de BBVA
- ✅ `BBVAButtonStyle.swift` → Nuevos estilos de botones
- ✅ `BBVATextFieldStyle.swift` → Nuevos estilos de campos
- ✅ `LoginView.swift` → Actualizado con colores BBVA
- ✅ `BiometricUnlockView.swift` → Actualizado con colores BBVA

## Próximos Pasos

1. Actualizar archivos de Assets:

   - Renombrar `BBVAPrimaryBlue.colorset` → `BBVAPrimaryRed.colorset`
   - Actualizar valores RGB en los colorsets
   - Reemplazar logos BBVA con logo BBVA

2. Actualizar vistas restantes:

   - HomeView.swift
   - MapView.swift
   - ChatView.swift
   - PaymentView.swift
   - Todas las vistas en `/Views/`

3. Actualizar ViewModels y lógica:

   - Cambiar referencias de texto "BBVA" a "BBVA"
   - Actualizar mensajes de usuario

4. Assets de imagen:
   - Crear nuevo logo de BBVA
   - Actualizar splash screen
   - Actualizar íconos de la app
