import { Link } from '@tanstack/react-router';
import { Album, Menu, X } from 'lucide-react';
import { useState } from 'react';
import { ThemeToggle } from './theme-toggle';

export function Header() {
  const [isMenuOpen, setIsMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/80 backdrop-blur-sm smooth-transition">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 hover:opacity-80 smooth-transition">
            <div className="gradient-primary rounded-lg p-2 text-primary-foreground">
              <Album className="h-6 w-6" />
            </div>
            <div className="hidden sm:block">
              <h1 className="text-xl font-bold text-foreground">Album Virtual</h1>
              <p className="text-xs text-muted-foreground">Copa Mundial 2026</p>
            </div>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-8">
            <Link
              to="/"
              className="text-sm font-medium text-muted-foreground hover:text-primary smooth-transition"
              activeOptions={{ exact: true }}
              activeProps={{ className: 'text-primary font-semibold' }}
            >
              Home
            </Link>
            <a
              href="#coleccion"
              className="text-sm font-medium text-muted-foreground hover:text-primary smooth-transition"
            >
              Colección
            </a>
            <a
              href="#intercambio"
              className="text-sm font-medium text-muted-foreground hover:text-primary smooth-transition"
            >
              Intercambio
            </a>
          </nav>

          {/* Right Actions */}
          <div className="flex items-center gap-2">
            <ThemeToggle />
            <button
              onClick={() => setIsMenuOpen(!isMenuOpen)}
              className="md:hidden rounded-lg p-2.5 text-muted-foreground hover:bg-accent hover:text-accent-foreground smooth-transition"
            >
              {isMenuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {isMenuOpen && (
          <nav className="flex flex-col gap-2 border-t border-border/40 py-4 md:hidden">
            <Link
              to="/"
              className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground smooth-transition rounded-lg"
              onClick={() => setIsMenuOpen(false)}
            >
              Home
            </Link>
            <a
              href="#coleccion"
              className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground smooth-transition rounded-lg"
            >
              Colección
            </a>
            <a
              href="#intercambio"
              className="px-4 py-2 text-sm font-medium text-muted-foreground hover:bg-accent hover:text-accent-foreground smooth-transition rounded-lg"
            >
              Intercambio
            </a>
          </nav>
        )}
      </div>
    </header>
  );
}
