import { Github, Globe, Mail } from 'lucide-react';

export function Footer() {
  return (
    <footer className="border-t border-border/40 bg-background/50 backdrop-blur-sm smooth-transition">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-3">
          {/* About */}
          <div>
            <h3 className="font-semibold text-foreground">Album Virtual</h3>
            <p className="mt-2 text-sm text-muted-foreground">
              La mejor plataforma para gestionar tu colección de láminas del mundial de futbol.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-semibold text-foreground">Enlaces rápidos</h3>
            <ul className="mt-2 space-y-2 text-sm">
              <li>
                <a href="#" className="text-muted-foreground hover:text-primary smooth-transition">
                  Inicio
                </a>
              </li>
              <li>
                <a href="#" className="text-muted-foreground hover:text-primary smooth-transition">
                  Ayuda
                </a>
              </li>
              <li>
                <a href="#" className="text-muted-foreground hover:text-primary smooth-transition">
                  Contacto
                </a>
              </li>
            </ul>
          </div>

          {/* Social */}
          <div>
            <h3 className="font-semibold text-foreground">Síguenos</h3>
            <div className="mt-2 flex gap-4">
              <a
                href="#"
                className="text-muted-foreground hover:text-primary smooth-transition"
                aria-label="GitHub"
              >
                <Github className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-primary smooth-transition"
                aria-label="Website"
              >
                <Globe className="h-5 w-5" />
              </a>
              <a
                href="#"
                className="text-muted-foreground hover:text-primary smooth-transition"
                aria-label="Email"
              >
                <Mail className="h-5 w-5" />
              </a>
            </div>
          </div>
        </div>

        <div className="mt-8 border-t border-border/40 pt-8">
          <p className="text-center text-sm text-muted-foreground">
            &copy; {new Date().getFullYear()} Album Virtual. Todos los derechos reservados.
          </p>
        </div>
      </div>
    </footer>
  );
}
