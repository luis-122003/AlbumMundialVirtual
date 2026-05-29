export function renderErrorPage(): string {
  return `<!doctype html>
<html lang="es">
  <head>
    <meta charset="utf-8" />
    <title>Algo salió mal</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
      body { font: 15px/1.5 system-ui, -apple-system, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; display: grid; place-items: center; min-height: 100vh; margin: 0; padding: 1.5rem; }
      .card { max-width: 28rem; width: 100%; text-align: center; padding: 3rem 2rem; background: rgba(255, 255, 255, 0.95); color: #111; border-radius: 1rem; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); }
      h1 { font-size: 1.5rem; margin: 0 0 0.5rem; font-weight: 700; }
      p { color: #4b5563; margin: 0 0 2rem; }
      .actions { display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap; }
      a, button { padding: 0.75rem 1.5rem; border-radius: 0.5rem; font: inherit; cursor: pointer; text-decoration: none; border: none; font-weight: 600; transition: all 0.2s; }
      .primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; }
      .primary:hover { transform: translateY(-2px); box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4); }
      .secondary { background: #f3f4f6; color: #111; border: 2px solid #e5e7eb; }
      .secondary:hover { background: #e5e7eb; }
    </style>
  </head>
  <body>
    <div class="card">
      <h1>⚠️ Algo salió mal</h1>
      <p>Tuvimos un error inesperado. Puedes intentar actualizar la página o volver al inicio.</p>
      <div class="actions">
        <button class="primary" onclick="location.reload()">Intentar de nuevo</button>
        <a class="secondary" href="/">Ir al inicio</a>
      </div>
    </div>
  </body>
</html>`;
}
