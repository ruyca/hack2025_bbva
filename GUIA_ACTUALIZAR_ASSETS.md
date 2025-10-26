# 🎨 Guía: Actualizar Assets en Xcode

## Paso 1: Actualizar Color Sets

### En Xcode:

1. **Abrir Assets.xcassets**

   - Navega a `BBVA_MiPyMES/BBVA_MiPyMES/Assets.xcassets`

2. **Crear nuevos ColorSets** (o modificar existentes):

#### BBVAPrimaryRed.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 227, 28, 35
  Hex: #E31C23
  Opacity: 100%
```

#### BBVADarkRed.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 179, 22, 28
  Hex: #B3161C
  Opacity: 100%
```

#### BBVACharcoal.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 51, 51, 51
  Hex: #333333
  Opacity: 100%
```

#### BBVATeal.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 0, 161, 176
  Hex: #00A1B0
  Opacity: 100%
```

#### BBVALightGray.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 242, 242, 242
  Hex: #F2F2F2
  Opacity: 100%
```

#### BBVABackground.colorset

```
Universal > Any Appearance:
  Color Space: sRGB
  RGB: 250, 250, 250
  Hex: #FAFAFA
  Opacity: 100%
```

### Modificar ColorSets Existentes (Opcional)

Si prefieres mantener los nombres de los colorsets existentes:

1. **BBVAPrimaryBlue.colorset** → Cambiar a rojo #E31C23
2. **BBVASecondaryBlue.colorset** → Cambiar a rojo oscuro #B3161C
3. **BBVADarkGray.colorset** → Ya está bien (#666666)
4. **BBVALightGray.colorset** → Cambiar a #F2F2F2

## Paso 2: Crear Logo BBVA

### Opción A: Logo de Texto (Rápido)

Ya está implementado en el código:

```swift
Text("BBVA")
    .font(.system(size: 48, weight: .bold))
    .foregroundColor(.white)
    .tracking(4)
```

### Opción B: Logo como Imagen (Profesional)

1. **Crear en Figma/Sketch/Illustrator**:

   ```
   Texto: "BBVA"
   Font: SF Pro Bold (o similar sans-serif bold)
   Color: Blanco / Rojo #E31C23
   Tracking: +4pt
   Tamaño: 512x512px para el asset
   ```

2. **Exportar en 3 resoluciones**:

   - `BBVA-logo.png` (1x)
   - `BBVA-logo@2x.png` (2x)
   - `BBVA-logo@3x.png` (3x)

3. **Agregar a Assets**:

   - Clic derecho en Assets.xcassets
   - New Image Set
   - Nombrar: "BBVALogo"
   - Arrastrar los 3 archivos

4. **Actualizar código**:

   ```swift
   // Reemplazar:
   Image("LogoBBVALaunch")

   // Con:
   Image("BBVALogo")
   ```

## Paso 3: Actualizar App Icon

### Crear App Icon

1. **Diseño Base** (1024x1024px):

   ```
   Fondo: Gradiente rojo (#E31C23 → #B3161C)
   Texto: "I" o "BBVA" en blanco
   Estilo: Moderno, minimalista
   ```

2. **Herramientas recomendadas**:

   - [AppIconMaker.co](https://appiconmaker.co)
   - [MakeAppIcon.com](https://makeappicon.com)
   - Xcode (arrastrar 1024x1024 y genera automático)

3. **En Xcode**:
   - Navegar a `Assets.xcassets/AppIcon.appiconset`
   - Arrastrar el icono 1024x1024
   - Xcode generará todos los tamaños

### Especificaciones del Icono

```
iPhone App:
  - 60x60pt (@2x: 120x120, @3x: 180x180)

iPad App:
  - 76x76pt (@2x: 152x152)
  - 83.5x83.5pt (@2x: 167x167)

App Store:
  - 1024x1024pt (sin alpha channel)
```

## Paso 4: Imágenes de Splash/Launch

### Actualizar Launch Screen

1. **Si usas LaunchScreen.storyboard**:

   - Reemplazar logo BBVA con logo BBVA
   - Cambiar color de fondo a rojo #E31C23

2. **Si usas Assets (recomendado iOS 14+)**:

   - Crear `LaunchImage.imageset`
   - Fondo rojo con logo "BBVA"

3. **Actualizar SplashScreenView.swift** (Ya hecho ✅):
   ```swift
   // Ya implementado con gradiente rojo y texto "BBVA"
   ```

## Paso 5: Otros Assets

### Imágenes a Considerar

1. **Reemplazar**:

   ```
   □ BBVA_logo1.imageset → BBVA_logo1
   □ BBVA_logo2.imageset → BBVA_logo2
   □ BBVA_logo3.imageset → BBVA_logo3
   □ LogoBBVALaunch.imageset → LogoBBVALaunch
   ```

2. **Mantener** (son genéricas):
   ```
   ✓ Bellasartes.imageset (fondo ciudad)
   ✓ CashLaunchScreen.imageset
   ✓ CompanyLaunchScreen.imageset
   ✓ gato_gordo.imageset
   ✓ registrar_progreso.imageset
   ```

## Paso 6: Verificación

### Checklist

```bash
□ Colores se ven correctamente en todas las pantallas
□ Logo "BBVA" aparece en splash screen
□ App icon muestra nuevo diseño
□ No hay referencias visuales a BBVA
□ Contraste de texto es legible
□ Gradientes se renderizan suavemente
□ Imágenes tienen resolución correcta (@2x, @3x)
```

### Comando para verificar assets faltantes

```bash
# Buscar referencias a assets que ya no existen
cd /Users/alexgrim/GitHub/hack2025_BBVA
grep -r "LogoBBVALaunch\|BBVA_logo" --include="*.swift" BBVA_MiPyMES/
```

## Paso 7: Build y Test

1. **Limpiar build folder**:

   ```
   Xcode > Product > Clean Build Folder (Cmd+Shift+K)
   ```

2. **Rebuild**:

   ```
   Xcode > Product > Build (Cmd+B)
   ```

3. **Run en simulador**:

   ```
   Xcode > Product > Run (Cmd+R)
   ```

4. **Verificar**:
   - Splash screen con nuevo branding
   - Login con gradiente rojo
   - Navegación muestra colores BBVA
   - No hay errores de assets faltantes

## Recursos Adicionales

### Herramientas de Diseño

- **Figma** (gratis): figma.com
- **Canva** (fácil): canva.com
- **Sketch** (Mac): sketch.com

### Generadores de Iconos

- **AppIcon.co**: Genera todos los tamaños
- **MakeAppIcon**: Sencillo y rápido
- **Icon Kitchen**: Para Android también

### Paleta de Colores BBVA

Guarda estos valores en tu herramienta de diseño:

```css
/* Primarios */
--BBVA-red: #E31C23
--BBVA-dark-red: #B3161C
--BBVA-light-red: #F2D9DA

/* Neutrales */
--BBVA-charcoal: #333333
--BBVA-dark-gray: #666666
--BBVA-medium-gray: #999999
--BBVA-light-gray: #F2F2F2

/* Acentos */
--BBVA-teal: #00A1B0
--BBVA-orange: #FF9400

/* Estados */
--BBVA-success: #00B26B
--BBVA-warning: #FFC000
--BBVA-error: #E31C23
```

## Ejemplo: Actualizar un Asset paso a paso

### 1. Clic derecho en Assets.xcassets

### 2. New > Image Set

### 3. Nombrar "BBVALogo"

### 4. Arrastrar imágenes:

```
- BBVA-logo.png      (1x slot)
- BBVA-logo@2x.png   (2x slot)
- BBVA-logo@3x.png   (3x slot)
```

### 5. En el código:

```swift
Image("BBVALogo")
    .resizable()
    .scaledToFit()
    .frame(width: 250)
```

---

## ⚠️ Importante

- **Mantén los assets originales** hasta verificar que todo funciona
- **Haz un backup** antes de eliminar assets BBVA
- **Prueba en varios dispositivos** (iPhone, iPad)
- **Verifica en modo claro y oscuro**

## ✅ Resultado Esperado

Después de seguir esta guía:

- ✅ App tiene nuevos colores rojos Capital One
- ✅ Logo "BBVA" en splash y login
- ✅ App icon con branding BBVA
- ✅ No hay rastros visuales de BBVA
- ✅ Todos los assets se cargan correctamente

---

**Tiempo estimado**: 1-2 horas
**Dificultad**: Media
**Requiere**: Xcode, herramienta de diseño básica
