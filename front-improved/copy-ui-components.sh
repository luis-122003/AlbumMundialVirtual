#!/bin/bash

# Script para copiar componentes UI desde el proyecto original
# Este script copia todos los componentes UI de shadcn del proyecto original

echo "🎨 Copiando componentes UI del proyecto original..."

if [ -d "../front/src/components/ui" ]; then
    echo "✅ Encontrada carpeta de componentes UI"
    
    for file in ../front/src/components/ui/*.tsx; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "📦 Copiando $filename..."
            cp "$file" "./src/components/ui/"
        fi
    done
    
    echo "✨ Componentes copiados exitosamente"
else
    echo "❌ No se encontró la carpeta front/src/components/ui"
    echo "   Asegúrate de ejecutar este script desde la carpeta front-improved"
fi
