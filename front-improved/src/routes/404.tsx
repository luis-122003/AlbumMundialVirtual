import { createFileRoute } from "@tanstack/react-router";
import { AlertCircle, ArrowLeft } from "lucide-react";
import { useRouter } from "@tanstack/react-router";

export const Route = createFileRoute("/404")({
  component: NotFound,
});

function NotFound() {
  const router = useRouter();

  return (
    <div className="flex min-h-screen items-center justify-center px-4 py-12">
      <div className="max-w-md text-center animate-fade-in-up">
        <div className="mb-6 inline-flex rounded-lg bg-destructive/10 p-4 text-destructive">
          <AlertCircle className="h-8 w-8" />
        </div>

        <h1 className="text-6xl font-bold text-foreground mb-2">404</h1>
        <h2 className="text-2xl font-semibold text-foreground mb-4">
          Página no encontrada
        </h2>

        <p className="text-muted-foreground mb-8">
          La página que buscas no existe o ha sido movida. Regresa al inicio
          para continuar.
        </p>

        <div className="flex flex-col gap-3">
          <button
            onClick={() => router.history.back()}
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-border bg-background px-6 py-3 text-sm font-medium text-foreground transition-all hover:bg-accent hover:text-accent-foreground smooth-transition"
          >
            <ArrowLeft className="h-4 w-4" />
            Volver atrás
          </button>

          <button
            onClick={() => router.navigate({ to: "/" })}
            className="inline-flex items-center justify-center rounded-lg gradient-primary px-6 py-3 text-sm font-medium text-primary-foreground transition-all hover:shadow-glow smooth-transition"
          >
            Ir al inicio
          </button>
        </div>
      </div>
    </div>
  );
}
