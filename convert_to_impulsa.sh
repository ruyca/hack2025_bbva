#!/bin/bash

# Script para convertir BBVA → BBVA en todos los archivos Swift
# Uso: ./convert_to_BBVA.sh

echo "🚀 Iniciando conversión de BBVA a BBVA..."
echo ""

# Directorio base
BASE_DIR="BBVA_MiPyMES/BBVA_MiPyMES"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para reemplazar en todos los archivos Swift
replace_in_swift() {
    local search="$1"
    local replace="$2"
    local description="$3"
    
    echo -e "${YELLOW}Reemplazando:${NC} $description"
    echo "  $search → $replace"
    
    find "$BASE_DIR" -name "*.swift" -type f -exec sed -i '' "s/$search/$replace/g" {} +
    
    # Contar ocurrencias
    local count=$(grep -r "$replace" --include="*.swift" "$BASE_DIR" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${GREEN}✓${NC} $count referencias actualizadas"
    echo ""
}

echo "======================================"
echo "1️⃣  Actualizando Referencias de Colores"
echo "======================================"
echo ""

# Colores desde Asset Catalog
replace_in_swift 'Color("BBVAPrimaryBlue")' 'Color.BBVAPrimaryRed' "Color BBVAPrimaryBlue"
replace_in_swift 'Color("BBVASecondaryBlue")' 'Color.BBVADarkRed' "Color BBVASecondaryBlue"
replace_in_swift 'Color("BBVADarkGray")' 'Color.BBVADarkGray' "Color BBVADarkGray"
replace_in_swift 'Color("BBVALightGray")' 'Color.BBVALightGray' "Color BBVALightGray"
replace_in_swift 'Color("BBVATextColor")' 'Color.BBVATextPrimary' "Color BBVATextColor"
replace_in_swift 'Color("BBVAErrorRed")' 'Color.BBVAError' "Color BBVAErrorRed"
replace_in_swift 'Color("BackgroundApp")' 'Color.BBVABackground' "Color BackgroundApp"

echo "======================================"
echo "2️⃣  Actualizando Variables Locales de Color"
echo "======================================"
echo ""

# Variables locales (cuidado con orden para evitar reemplazos parciales)
replace_in_swift 'BBVASecondaryBlue' 'BBVADarkRed' "Variable BBVASecondaryBlue"
replace_in_swift 'BBVADarkBlue' 'BBVACharcoal' "Variable BBVADarkBlue"
replace_in_swift 'BBVALightBlue' 'BBVATeal' "Variable BBVALightBlue"
replace_in_swift 'BBVAAqua' 'BBVATeal' "Variable BBVAAqua"
replace_in_swift 'BBVADarkGray' 'BBVADarkGray' "Variable BBVADarkGray"
replace_in_swift 'BBVALightGray' 'BBVALightGray' "Variable BBVALightGray"
replace_in_swift 'BBVATextColor' 'BBVATextPrimary' "Variable BBVATextColor"
replace_in_swift 'BBVAErrorRed' 'BBVAError' "Variable BBVAErrorRed"

echo "======================================"
echo "3️⃣  Actualizando Textos y Strings"
echo "======================================"
echo ""

# Strings de texto
replace_in_swift '"BBVA Empresas"' '"BBVA Empresas"' "Texto 'BBVA Empresas'"
replace_in_swift '"BBVA MiPyMES"' '"BBVA"' "Texto 'BBVA MiPyMES'"
replace_in_swift '"BBVA"' '"BBVA"' "Texto 'BBVA'"
replace_in_swift 'Bienvenido a BBVA' 'Tu aliado financiero' "Texto 'Bienvenido a BBVA'"

echo "======================================"
echo "4️⃣  Actualizando Comentarios"
echo "======================================"
echo ""

# Comentarios
replace_in_swift '// BBVA' '// BBVA' "Comentarios BBVA"
replace_in_swift '/// BBVA' '/// BBVA' "Comentarios de documentación BBVA"
replace_in_swift 'MARK: - BBVA' 'MARK: - BBVA' "Marcadores BBVA"

echo "======================================"
echo "5️⃣  Verificando Cambios"
echo "======================================"
echo ""

# Contar referencias restantes de BBVA
remaining_BBVA=$(grep -r "BBVA" --include="*.swift" "$BASE_DIR" 2>/dev/null | grep -v "BBVA" | wc -l | tr -d ' ')
remaining_colors=$(grep -r 'Color("BBV' --include="*.swift" "$BASE_DIR" 2>/dev/null | wc -l | tr -d ' ')

echo "Referencias 'BBVA' restantes: $remaining_BBVA"
echo "Referencias Color(\"BBV...\") restantes: $remaining_colors"
echo ""

if [ "$remaining_BBVA" -gt 0 ] || [ "$remaining_colors" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Advertencia:${NC} Aún quedan algunas referencias de BBVA"
    echo "Revisa manualmente los siguientes archivos:"
    grep -l "BBVA" --include="*.swift" -r "$BASE_DIR" 2>/dev/null | head -10
else
    echo -e "${GREEN}✅ ¡Conversión completada exitosamente!${NC}"
fi

echo ""
echo "======================================"
echo "✨ Resumen"
echo "======================================"
echo ""
echo "Los siguientes cambios se han aplicado:"
echo "  • Colores BBVA → BBVA (rojo Capital One)"
echo "  • Textos 'BBVA' → 'BBVA'"
echo "  • Variables de color actualizadas"
echo "  • Comentarios actualizados"
echo ""
echo "Próximos pasos:"
echo "  1. Actualizar Assets (colorsets e imágenes)"
echo "  2. Compilar el proyecto en Xcode"
echo "  3. Revisar visualmente todas las pantallas"
echo "  4. Actualizar tests si es necesario"
echo ""
echo -e "${GREEN}¡Listo! Tu app ahora es BBVA 🚀${NC}"
