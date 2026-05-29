import { createFileRoute } from "@tanstack/react-router";
import {
  Trophy,
  Zap,
  Users,
  Target,
  ArrowRight,
  CheckCircle,
  Sparkles,
} from "lucide-react";

export const Route = createFileRoute("/")({
  component: Index,
});

function Index() {
  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="relative px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <div className="grid gap-12 lg:grid-cols-2 lg:gap-8 items-center">
            {/* Left Content */}
            <div className="animate-fade-in-up">
              <div className="inline-flex items-center gap-2 rounded-full bg-accent/10 px-4 py-2 text-sm font-medium text-accent mb-6">
                <Sparkles className="h-4 w-4" />
                <span>Nueva versión con diseño mejorado</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-foreground mb-6">
                Tu colección de láminas del
                <span className="block gradient-primary bg-clip-text text-transparent">
                  Mundial 2026
                </span>
              </h1>

              <p className="text-lg text-muted-foreground mb-8 max-w-md">
                Gestiona, comparte e intercambia láminas con otros coleccionistas. Una experiencia moderna y fluida para tu pasión por el futbol.
              </p>

              <div className="flex flex-col sm:flex-row gap-4">
                <button className="inline-flex items-center justify-center gap-2 rounded-lg gradient-primary px-8 py-3 text-base font-medium text-primary-foreground transition-all hover:shadow-glow smooth-transition">
                  Comenzar ahora
                  <ArrowRight className="h-5 w-5" />
                </button>
                <button className="inline-flex items-center justify-center rounded-lg border-2 border-primary px-8 py-3 text-base font-medium text-primary transition-all hover:bg-primary/10 smooth-transition">
                  Ver demo
                </button>
              </div>
            </div>

            {/* Right Illustration */}
            <div className="relative animate-fade-in-up" style={{ animationDelay: "0.2s" }}>
              <div className="absolute inset-0 bg-gradient-to-br from-primary/20 to-accent/20 rounded-2xl blur-3xl opacity-60"></div>
              <div className="relative bg-gradient-to-br from-card to-card/50 rounded-2xl p-8 border border-border/50 shadow-xl">
                <div className="grid grid-cols-2 gap-4">
                  {[1, 2, 3, 4].map((i) => (
                    <div
                      key={i}
                      className="aspect-square rounded-lg bg-gradient-to-br from-primary/20 to-accent/20 border border-border flex items-center justify-center"
                    >
                      <div className="text-center">
                        <div className="text-2xl font-bold text-primary">#{i}</div>
                        <div className="text-xs text-muted-foreground mt-1">Lámina</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 bg-card/30 backdrop-blur-sm">
        <div className="mx-auto max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-4">
              Características principales
            </h2>
            <p className="text-muted-foreground max-w-2xl mx-auto">
              Todo lo que necesitas para gestionar tu colección de láminas
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {features.map((feature, i) => (
              <div
                key={i}
                className="group relative rounded-xl border border-border/40 bg-background p-8 hover:border-primary/50 hover:shadow-glow smooth-transition animate-fade-in-up"
                style={{ animationDelay: `${i * 0.1}s` }}
              >
                <div className="mb-4 inline-flex rounded-lg bg-primary/10 p-3 text-primary group-hover:bg-primary/20 smooth-transition">
                  <feature.icon className="h-6 w-6" />
                </div>
                <h3 className="text-lg font-semibold text-foreground mb-2">
                  {feature.title}
                </h3>
                <p className="text-sm text-muted-foreground">
                  {feature.description}
                </p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="px-4 py-20 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-7xl">
          <div className="grid md:grid-cols-3 gap-8">
            {stats.map((stat, i) => (
              <div
                key={i}
                className="text-center animate-fade-in-up"
                style={{ animationDelay: `${i * 0.1}s` }}
              >
                <div className="text-4xl sm:text-5xl font-bold text-primary mb-2">
                  {stat.value}
                </div>
                <p className="text-muted-foreground">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="px-4 py-20 sm:px-6 lg:px-8 bg-gradient-to-r from-primary/10 to-accent/10 backdrop-blur-sm">
        <div className="mx-auto max-w-2xl text-center animate-fade-in-up">
          <h2 className="text-3xl sm:text-4xl font-bold text-foreground mb-6">
            ¿Listo para comenzar?
          </h2>
          <p className="text-muted-foreground mb-8">
            Únete a miles de coleccionistas que ya están usando Album Virtual
          </p>
          <button className="inline-flex items-center justify-center gap-2 rounded-lg gradient-primary px-8 py-3 text-base font-medium text-primary-foreground transition-all hover:shadow-glow smooth-transition">
            Crear cuenta gratis
            <ArrowRight className="h-5 w-5" />
          </button>
        </div>
      </section>
    </div>
  );
}

const features = [
  {
    icon: Trophy,
    title: "Gestiona tu colección",
    description: "Organiza y visualiza todas tus láminas en un solo lugar con búsqueda avanzada.",
  },
  {
    icon: Users,
    title: "Intercambia con otros",
    description: "Conecta con otros coleccionistas y realiza intercambios de láminas fácilmente.",
  },
  {
    icon: Zap,
    title: "Interfaz moderna",
    description: "Diseño fluido y responsivo que funciona perfectamente en todos los dispositivos.",
  },
  {
    icon: Target,
    title: "Estadísticas detalladas",
    description: "Visualiza el progreso de tu colección y las estadísticas de tu participación.",
  },
  {
    icon: CheckCircle,
    title: "Verificación segura",
    description: "Sistema seguro de autenticación para proteger tu cuenta y datos.",
  },
  {
    icon: Sparkles,
    title: "Notificaciones en tiempo real",
    description: "Mantente actualizado con notificaciones sobre intercambios y nuevas láminas.",
  },
];

const stats = [
  { value: "10K+", label: "Coleccionistas activos" },
  { value: "50K+", label: "Láminas en circulación" },
  { value: "100%", label: "Seguridad garantizada" },
];
