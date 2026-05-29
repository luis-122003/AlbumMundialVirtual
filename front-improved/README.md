# Album Virtual - Frontend Improved

Una versión mejorada de la interfaz web del proyecto Album Virtual con diseño moderno y optimizado.

## 🎨 Mejoras de Diseño Implementadas

### 1. **Sistema de Colores Vibrante**
- Paleta de colores inspirada en el fútbol
- Colores primarios vibrantes (azul fútbol)
- Colores secundarios dinámicos (naranja energético)
- Acentos llamativos (verde vibrante)
- Soporte completo para dark mode

### 2. **Componentes de Layout Mejorados**
- **Header Moderno**: Navegación responsive con logo, menú y theme toggle
- **Footer Elegante**: Con enlaces rápidos y redes sociales
- **Theme Toggle**: Cambio de tema claro/oscuro sin reload
- **Animaciones Suaves**: Transiciones elegantes en toda la aplicación

### 3. **Página Principal Rediseñada**
- Hero section con llamada a la acción clara
- Sección de características con iconos
- Estadísticas destacadas
- Sección de CTA (call-to-action)
- Todas las secciones con animaciones fade-in

### 4. **Diseño Responsivo**
- Mobile-first approach
- Menú hamburguesa para dispositivos móviles
- Breakpoints optimizados (sm, md, lg)
- Imágenes y componentes adaptativos

### 5. **Componentes UI Mejorados**
- Componentes reutilizables
- Clases CSS utilities personalizadas
- Efectos glass-morphism
- Gradientes modernos
- Sombras mejoradas

### 6. **Sistema de Animaciones**
- `fadeInUp`: Animaciones de entrada desde abajo
- `slideInRight`: Deslizamiento desde la izquierda
- `pulsesoft`: Pulso suave para elementos interactivos
- Transiciones suaves en botones y enlaces (smooth-transition)

## 📁 Estructura del Proyecto

```
front-improved/
├── src/
│   ├── components/
│   │   ├── layout/          # Componentes de layout (Header, Footer)
│   │   ├── ui/              # Componentes UI shadcn
│   │   └── error-boundary.tsx
│   ├── lib/
│   │   ├── api.ts          # Cliente API
│   │   ├── error-capture.ts
│   │   ├── error-page.ts
│   │   └── utils.ts
│   ├── hooks/
│   │   └── use-mobile.tsx
│   ├── routes/
│   │   ├── __root.tsx      # Root layout mejorado
│   │   └── index.tsx       # Página principal rediseñada
│   ├── styles.css          # Sistema de diseño mejorado
│   ├── router.tsx
│   └── server.ts
├── package.json
├── tsconfig.json
├── vite.config.ts
├── eslint.config.js
├── components.json
└── README.md
```

## 🚀 Características Principales

- ✅ Diseño moderno y atractivo
- ✅ Dark mode automático
- ✅ Animaciones fluidas
- ✅ Componentes reutilizables
- ✅ Responsive design
- ✅ Rendimiento optimizado
- ✅ TypeScript type-safe
- ✅ Accesibilidad mejorada

## 🎯 Diferencias con la Versión Original

| Aspecto | Original | Mejorado |
|--------|----------|---------|
| Colores | Neutros | Vibrantes |
| Animaciones | Básicas | Complejas y suaves |
| Layout | Simple | Moderno con header/footer |
| Responsive | Basado en Tailwind | Optimizado mobile-first |
| Dark Mode | Soportado | Implementado con toggle |
| Componentes | Shadcn básicos | Personalizados y mejorados |

## 🛠️ Instalación y Desarrollo

```bash
# Instalar dependencias
npm install
# o
bun install

# Desarrollo
npm run dev

# Build producción
npm run build

# Preview
npm run preview
```

## 🎨 Personalización de Colores

Edita `src/styles.css` para personalizar los colores:

```css
:root {
  --primary: oklch(0.35 0.15 250);      /* Azul fútbol */
  --secondary: oklch(0.65 0.18 45);     /* Naranja energético */
  --accent: oklch(0.6 0.2 135);         /* Verde vibrante */
}
```

## 📱 Breakpoints Responsive

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px

## 🔧 Variables CSS Disponibles

- `--radius-*`: Esquinas redondeadas
- `--color-*`: Colores semánticos
- `--chart-*`: Colores para gráficos
- `--sidebar-*`: Colores de barra lateral

## 📚 Stack Tecnológico

- **Framework**: React 19 + TanStack Router
- **Styling**: Tailwind CSS + CSS Personalizado
- **UI Components**: Radix UI + shadcn
- **Icons**: Lucide React
- **Build Tool**: Vite + TanStack Start
- **Lenguaje**: TypeScript
- **Query**: TanStack React Query

## 🎓 Notas de Desarrollo

- Los componentes utilizan Radix UI como base
- Tailwind CSS para estilizado rápido
- Animaciones CSS personalizadas en styles.css
- Sistema de tokens de diseño en CSS variables
- Soporte para modo oscuro automático

## 📄 Licencia

Este proyecto es parte de Album Virtual - Copa Mundial 2026
