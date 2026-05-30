export function ErrorBoundary({ error }: { error: Error }) {
  return (
    <div className="flex h-full flex-col items-center justify-center space-y-4 p-4 text-center">
      <h1 className="text-2xl font-bold">Oops! Algo salio mal</h1>
      <p className="text-muted-foreground">{error.message}</p>
    </div>
  );
}