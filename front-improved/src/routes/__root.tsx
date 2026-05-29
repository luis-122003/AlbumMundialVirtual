import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet,
  Link,
  createRootRouteWithContext,
  useRouter,
  HeadContent,
  Scripts,
} from "@tanstack/react-router";

import appCss from "../styles.css?url";
import { Header, Footer } from "@/components/layout";

function NotFoundComponent() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-7xl font-bold text-foreground animate-fade-in-up">404</h1>
        <h2 className="mt-4 text-xl font-semibold text-foreground animate-fade-in-up" style={{ animationDelay: "0.1s" }}>
          Página no encontrada
        </h2>
        <p className="mt-2 text-sm text-muted-foreground animate-fade-in-up" style={{ animationDelay: "0.2s" }}>
          La página que buscas no existe o ha sido movida.
        </p>
        <div className="mt-6 animate-fade-in-up" style={{ animationDelay: "0.3s" }}>
          <Link
            to="/"
            className="inline-flex items-center justify-center rounded-lg gradient-primary px-6 py-3 text-sm font-medium text-primary-foreground transition-all hover:shadow-glow smooth-transition"
          >
            Volver al inicio
          </Link>
        </div>
      </div>
    </div>
  );
}

function ErrorComponent({ error, reset }: { error: Error; reset: () => void }) {
  console.error(error);
  const router = useRouter();

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          Algo salió mal
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Hubo un error inesperado. Intenta actualizar la página o volver al inicio.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-2">
          <button
            onClick={() => {
              router.invalidate();
              reset();
            }}
            className="inline-flex items-center justify-center rounded-lg gradient-primary px-6 py-2.5 text-sm font-medium text-primary-foreground transition-all hover:shadow-glow smooth-transition"
          >
            Intentar de nuevo
          </button>
          <a
            href="/"
            className="inline-flex items-center justify-center rounded-lg border border-border bg-background px-6 py-2.5 text-sm font-medium text-foreground transition-all hover:bg-accent hover:text-accent-foreground smooth-transition"
          >
            Ir al inicio
          </a>
        </div>
      </div>
    </div>
  );
}

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "Album Virtual - Copa Mundial 2026" },
      { name: "description", content: "Gestiona tu colección de láminas del mundial de futbol" },
      { name: "author", content: "Album Virtual" },
      { property: "og:title", content: "Album Virtual" },
      { property: "og:description", content: "Gestiona tu colección de láminas del mundial" },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary" },
    ],
    links: [
      {
        rel: "stylesheet",
        href: appCss,
      },
    ],
  }),
  shellComponent: RootShell,
  component: RootComponent,
  notFoundComponent: NotFoundComponent,
  errorComponent: ErrorComponent,
});

function RootShell({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <head>
        <HeadContent />
      </head>
      <body className="antialiased">
        {children}
        <Scripts />
      </body>
    </html>
  );
}

function RootComponent() {
  return (
    <div className="flex min-h-screen flex-col">
      <Header />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
    </div>
  );
}
