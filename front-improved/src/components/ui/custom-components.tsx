// Componentes UI reutilizables mejorados
// Estos son ejemplos de componentes que se pueden crear

import { ReactNode } from 'react';
import { cn } from '@/lib/utils';

// Card Component Mejorada
export function Card({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div
      className={cn(
        'rounded-lg border border-border/40 bg-card p-6 shadow-sm hover:shadow-md smooth-transition',
        className
      )}
    >
      {children}
    </div>
  );
}

// Button Variants Mejoradas
export function Button({
  children,
  variant = 'default',
  size = 'md',
  className,
  ...props
}: {
  children: ReactNode;
  variant?: 'default' | 'primary' | 'secondary' | 'ghost' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
} & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const variants = {
    default: 'gradient-primary text-primary-foreground hover:shadow-glow',
    primary: 'gradient-primary text-primary-foreground hover:shadow-glow',
    secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/80',
    ghost: 'hover:bg-accent hover:text-accent-foreground',
    outline: 'border border-border bg-background hover:bg-accent',
  };

  const sizes = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg',
  };

  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-lg font-medium transition-all smooth-transition',
        variants[variant],
        sizes[size],
        className
      )}
      {...props}
    >
      {children}
    </button>
  );
}

// Badge Component Mejorada
export function Badge({ children, variant = 'default', className }: 
  { children: ReactNode; variant?: 'default' | 'success' | 'warning' | 'error'; className?: string }
) {
  const variants = {
    default: 'bg-primary/10 text-primary',
    success: 'bg-accent/10 text-accent',
    warning: 'bg-yellow-100 text-yellow-700',
    error: 'bg-destructive/10 text-destructive',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full px-3 py-1 text-xs font-medium',
        variants[variant],
        className
      )}
    >
      {children}
    </span>
  );
}
