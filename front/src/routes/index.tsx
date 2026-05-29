import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { createFileRoute } from "@tanstack/react-router";
import {
  Album,
  BadgeCheck,
  CheckCircle2,
  CircleAlert,
  ClipboardList,
  Filter,
  ImageOff,
  Loader2,
  LogIn,
  LogOut,
  RefreshCw,
  Repeat2,
  Rows3,
  ScanLine,
  Search,
  ShieldCheck,
  Star,
  Trophy,
  UserPlus,
  Wifi,
  WifiOff,
} from "lucide-react";
import {
  useCallback,
  useEffect,
  useMemo,
  useState,
  type FormEvent,
} from "react";

import {
  API_BASE_URL,
  ApiError,
  api,
  authStorage,
  type ColeccionItem,
  type Lamina,
  type ScanResponse,
  type Usuario,
} from "@/lib/api";

export const Route = createFileRoute("/")({
  component: Index,
});

type AuthMode = "login" | "register";
type ViewMode = "catalogo" | "coleccion" | "faltantes" | "repetidas";

const viewOptions: Array<{
  id: ViewMode;
  label: string;
  icon: typeof Rows3;
}> = [
  { id: "catalogo", label: "Catalogo", icon: Rows3 },
  { id: "coleccion", label: "Coleccion", icon: CheckCircle2 },
  { id: "faltantes", label: "Faltantes", icon: ClipboardList },
  { id: "repetidas", label: "Repetidas", icon: Repeat2 },
];

const inputClass =
  "h-10 w-full rounded-md border border-zinc-300 bg-white px-3 text-sm text-zinc-950 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-100";

const selectClass =
  "h-10 w-full rounded-md border border-zinc-300 bg-white px-3 text-sm text-zinc-950 outline-none transition focus:border-red-500 focus:ring-2 focus:ring-red-100";

const primaryButtonClass =
  "inline-flex h-10 items-center justify-center gap-2 rounded-md bg-red-600 px-4 text-sm font-semibold text-white transition hover:bg-red-700 disabled:cursor-not-allowed disabled:bg-red-300";

const secondaryButtonClass =
  "inline-flex h-10 items-center justify-center gap-2 rounded-md border border-zinc-300 bg-white px-4 text-sm font-semibold text-zinc-900 transition hover:border-zinc-400 hover:bg-zinc-50 disabled:cursor-not-allowed disabled:opacity-60";

function Index() {
  const queryClient = useQueryClient();
  const [isClient, setIsClient] = useState(false);
  const [authMode, setAuthMode] = useState<AuthMode>("login");
  const [token, setToken] = useState<string | null>(null);
  const [user, setUser] = useState<Usuario | null>(null);
  const [authError, setAuthError] = useState<string | null>(null);
  const [scanError, setScanError] = useState<string | null>(null);
  const [scanResult, setScanResult] = useState<ScanResponse | null>(null);
  const [credentials, setCredentials] = useState({
    nombre: "",
    email: "",
    password: "",
    ciudad: "",
    pais: "",
  });
  const [selectedPais, setSelectedPais] = useState("todos");
  const [search, setSearch] = useState("");
  const [viewMode, setViewMode] = useState<ViewMode>("catalogo");
  const [scanIso3, setScanIso3] = useState("");
  const [scanNumber, setScanNumber] = useState(1);

  useEffect(() => {
    setIsClient(true);
    setToken(authStorage.getToken());
    setUser(authStorage.getUser());
  }, []);

  const authenticated = Boolean(token);

  const healthQuery = useQuery({
    queryKey: ["backend-health"],
    queryFn: api.health,
    enabled: isClient,
    retry: 1,
    refetchInterval: 30000,
  });

  const paisesQuery = useQuery({
    queryKey: ["paises"],
    queryFn: api.paises,
    enabled: isClient,
  });

  const laminasQuery = useQuery({
    queryKey: ["laminas"],
    queryFn: api.laminas,
    enabled: isClient,
  });

  const profileQuery = useQuery({
    queryKey: ["profile", token],
    queryFn: api.profile,
    enabled: isClient && authenticated,
    retry: false,
  });

  const coleccionQuery = useQuery({
    queryKey: ["coleccion", token],
    queryFn: api.coleccion,
    enabled: isClient && authenticated,
  });

  const repetidasQuery = useQuery({
    queryKey: ["repetidas", token],
    queryFn: api.repetidas,
    enabled: isClient && authenticated,
  });

  const faltantesQuery = useQuery({
    queryKey: ["faltantes", token],
    queryFn: api.faltantes,
    enabled: isClient && authenticated,
  });

  const progresoQuery = useQuery({
    queryKey: ["progreso", token],
    queryFn: api.progreso,
    enabled: isClient && authenticated,
  });

  const historialQuery = useQuery({
    queryKey: ["historial", token],
    queryFn: () => api.historial(24),
    enabled: isClient && authenticated,
  });

  const handleLogout = useCallback(() => {
    authStorage.clear();
    setToken(null);
    setUser(null);
    setScanResult(null);
    setAuthError(null);
    setScanError(null);
    queryClient.removeQueries({ queryKey: ["profile"] });
    queryClient.removeQueries({ queryKey: ["coleccion"] });
    queryClient.removeQueries({ queryKey: ["repetidas"] });
    queryClient.removeQueries({ queryKey: ["faltantes"] });
    queryClient.removeQueries({ queryKey: ["progreso"] });
    queryClient.removeQueries({ queryKey: ["historial"] });
  }, [queryClient]);

  useEffect(() => {
    if (!profileQuery.data || !token) return;
    setUser(profileQuery.data);
    authStorage.setSession(token, profileQuery.data);
  }, [profileQuery.data, token]);

  useEffect(() => {
    if (
      profileQuery.error instanceof ApiError &&
      profileQuery.error.statusCode === 401
    ) {
      handleLogout();
      setAuthError("Sesion expirada. Vuelve a iniciar sesion.");
    }
  }, [handleLogout, profileQuery.error]);

  const handleAuthSuccess = useCallback(
    (session: { token: string; usuario: Usuario }) => {
      authStorage.setSession(session.token, session.usuario);
      setToken(session.token);
      setUser(session.usuario);
      setAuthError(null);
      queryClient.invalidateQueries({ queryKey: ["profile"] });
      queryClient.invalidateQueries({ queryKey: ["coleccion"] });
      queryClient.invalidateQueries({ queryKey: ["repetidas"] });
      queryClient.invalidateQueries({ queryKey: ["faltantes"] });
      queryClient.invalidateQueries({ queryKey: ["progreso"] });
      queryClient.invalidateQueries({ queryKey: ["historial"] });
    },
    [queryClient],
  );

  const loginMutation = useMutation({
    mutationFn: (input: { email: string; password: string }) =>
      api.login(input.email, input.password),
    onSuccess: handleAuthSuccess,
    onError: (error) => setAuthError(getErrorMessage(error)),
  });

  const registerMutation = useMutation({
    mutationFn: (input: typeof credentials) => api.register(input),
    onSuccess: handleAuthSuccess,
    onError: (error) => setAuthError(getErrorMessage(error)),
  });

  const scanMutation = useMutation({
    mutationFn: (input: { iso3: string; numero: number }) =>
      api.escanearLamina(input.iso3, input.numero),
    onSuccess: async (result) => {
      setScanResult(result);
      setScanError(null);
      await Promise.all([
        queryClient.invalidateQueries({ queryKey: ["coleccion"] }),
        queryClient.invalidateQueries({ queryKey: ["repetidas"] }),
        queryClient.invalidateQueries({ queryKey: ["faltantes"] }),
        queryClient.invalidateQueries({ queryKey: ["progreso"] }),
        queryClient.invalidateQueries({ queryKey: ["historial"] }),
      ]);
    },
    onError: (error) => setScanError(getErrorMessage(error)),
  });

  const paises = paisesQuery.data ?? [];
  const laminas = laminasQuery.data ?? [];
  const coleccion = coleccionQuery.data ?? [];
  const repetidas = repetidasQuery.data ?? [];
  const faltantes = faltantesQuery.data ?? [];
  const progreso = progresoQuery.data;
  const historial = historialQuery.data ?? [];

  useEffect(() => {
    if (scanIso3 || paises.length === 0) return;
    setScanIso3(paises[0].iso3);
  }, [paises, scanIso3]);

  const collectionById = useMemo(() => {
    return new Map(coleccion.map((item) => [item.lamina_id, item]));
  }, [coleccion]);

  const repeatedById = useMemo(() => {
    return new Map(repetidas.map((item) => [item.lamina_id, item]));
  }, [repetidas]);

  const visibleLaminas = useMemo(() => {
    let source: Lamina[] = laminas;
    if (viewMode === "coleccion") {
      source = coleccion.map((item) => item.lamina);
    }
    if (viewMode === "faltantes") {
      source = faltantes;
    }
    if (viewMode === "repetidas") {
      source = repetidas.map((item) => item.lamina);
    }

    const normalizedSearch = search.trim().toLowerCase();

    return source.filter((lamina) => {
      const matchesCountry =
        selectedPais === "todos" || lamina.iso3 === selectedPais;
      const matchesSearch =
        normalizedSearch.length === 0 ||
        lamina.id.toLowerCase().includes(normalizedSearch) ||
        lamina.nombre_sticker.toLowerCase().includes(normalizedSearch) ||
        lamina.iso3.toLowerCase().includes(normalizedSearch) ||
        (lamina.posicion ?? "").toLowerCase().includes(normalizedSearch);

      return matchesCountry && matchesSearch;
    });
  }, [coleccion, faltantes, laminas, repetidas, search, selectedPais, viewMode]);

  const repeatedTotal = repetidas.reduce(
    (sum, item) => sum + item.cantidad_repetidas,
    0,
  );
  const totalLaminas = progreso?.total_laminas ?? laminas.length;
  const obtainedTotal = progreso?.laminas_obtenidas ?? coleccion.length;
  const missingTotal =
    progreso && totalLaminas > 0
      ? totalLaminas - obtainedTotal
      : faltantes.length;
  const progressPercent =
    progreso?.porcentaje ??
    (totalLaminas > 0 ? Number(((obtainedTotal / totalLaminas) * 100).toFixed(1)) : 0);
  const authPending = loginMutation.isPending || registerMutation.isPending;
  const publicLoading = paisesQuery.isLoading || laminasQuery.isLoading;
  const protectedLoading =
    coleccionQuery.isLoading ||
    repetidasQuery.isLoading ||
    faltantesQuery.isLoading ||
    progresoQuery.isLoading ||
    historialQuery.isLoading;

  const refreshAll = () => {
    queryClient.invalidateQueries({ queryKey: ["backend-health"] });
    queryClient.invalidateQueries({ queryKey: ["paises"] });
    queryClient.invalidateQueries({ queryKey: ["laminas"] });
    if (!authenticated) return;
    queryClient.invalidateQueries({ queryKey: ["profile"] });
    queryClient.invalidateQueries({ queryKey: ["coleccion"] });
    queryClient.invalidateQueries({ queryKey: ["repetidas"] });
    queryClient.invalidateQueries({ queryKey: ["faltantes"] });
    queryClient.invalidateQueries({ queryKey: ["progreso"] });
    queryClient.invalidateQueries({ queryKey: ["historial"] });
  };

  const handleAuthSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setAuthError(null);

    if (authMode === "login") {
      loginMutation.mutate({
        email: credentials.email,
        password: credentials.password,
      });
      return;
    }

    registerMutation.mutate(credentials);
  };

  const handleScanSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const numero = Number(scanNumber);

    if (!scanIso3 || !Number.isInteger(numero) || numero < 1 || numero > 20) {
      setScanError("Selecciona un pais y un numero entre 1 y 20.");
      return;
    }

    scanMutation.mutate({ iso3: scanIso3, numero });
  };

  return (
    <main className="min-h-screen bg-[#f5f7fb] text-zinc-950">
      <header className="border-b border-zinc-200 bg-white">
        <div className="mx-auto flex max-w-7xl flex-col gap-4 px-4 py-4 sm:px-6 lg:flex-row lg:items-center lg:justify-between lg:px-8">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md bg-red-600 text-white">
              <Album className="h-6 w-6" aria-hidden="true" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-zinc-950">
                Album Mundial Virtual
              </h1>
              <p className="text-sm text-zinc-600">{API_BASE_URL}</p>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <HealthBadge
              loading={healthQuery.isLoading}
              online={healthQuery.data?.status === "ok"}
              error={Boolean(healthQuery.error)}
            />
            <button
              type="button"
              className="inline-flex h-10 w-10 items-center justify-center rounded-md border border-zinc-300 bg-white text-zinc-800 transition hover:bg-zinc-50"
              onClick={refreshAll}
              aria-label="Actualizar datos"
              title="Actualizar datos"
            >
              <RefreshCw
                className={`h-4 w-4 ${
                  healthQuery.isFetching ||
                  paisesQuery.isFetching ||
                  laminasQuery.isFetching ||
                  protectedLoading
                    ? "animate-spin"
                    : ""
                }`}
                aria-hidden="true"
              />
            </button>
            {authenticated && user ? (
              <div className="flex items-center gap-2">
                <div className="rounded-md border border-zinc-200 bg-zinc-50 px-3 py-2 text-sm">
                  <span className="font-semibold text-zinc-900">{user.nombre}</span>
                  <span className="ml-2 text-zinc-500">{user.email}</span>
                </div>
                <button
                  type="button"
                  className={secondaryButtonClass}
                  onClick={handleLogout}
                >
                  <LogOut className="h-4 w-4" aria-hidden="true" />
                  Salir
                </button>
              </div>
            ) : null}
          </div>
        </div>
      </header>

      <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">
        <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
          <StatCard
            label="Progreso"
            value={`${progressPercent}%`}
            detail={`${obtainedTotal} de ${totalLaminas || 0} laminas`}
            icon={Trophy}
            tone="red"
          />
          <StatCard
            label="Coleccion"
            value={String(obtainedTotal)}
            detail={authenticated ? "Obtenidas" : "Inicia sesion"}
            icon={BadgeCheck}
            tone="green"
          />
          <StatCard
            label="Faltantes"
            value={String(Math.max(missingTotal, 0))}
            detail="Pendientes"
            icon={ClipboardList}
            tone="blue"
          />
          <StatCard
            label="Repetidas"
            value={String(repeatedTotal)}
            detail={`${repetidas.length} laminas distintas`}
            icon={Repeat2}
            tone="amber"
          />
        </section>

        <section className="mt-4 rounded-md border border-zinc-200 bg-white p-4">
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <div className="min-w-0">
              <div className="flex items-center gap-2 text-sm font-semibold text-zinc-900">
                <ShieldCheck className="h-4 w-4 text-red-600" aria-hidden="true" />
                Estado del album
              </div>
              <div className="mt-2 h-3 overflow-hidden rounded-md bg-zinc-100">
                <div
                  className="h-full rounded-md bg-red-600"
                  style={{ width: `${Math.min(Math.max(progressPercent, 0), 100)}%` }}
                />
              </div>
            </div>
            <div className="text-sm text-zinc-600">
              {publicLoading ? "Cargando catalogo..." : `${laminas.length} laminas en catalogo`}
            </div>
          </div>
        </section>

        <div className="mt-6 grid gap-6 lg:grid-cols-[360px_1fr]">
          {authenticated ? (
            <ScannerPanel
              paises={paises}
              scanIso3={scanIso3}
              scanNumber={scanNumber}
              scanResult={scanResult}
              error={scanError}
              loading={scanMutation.isPending}
              onIso3Change={setScanIso3}
              onNumberChange={setScanNumber}
              onSubmit={handleScanSubmit}
            />
          ) : (
            <AuthPanel
              mode={authMode}
              credentials={credentials}
              error={authError}
              loading={authPending}
              onModeChange={setAuthMode}
              onCredentialsChange={setCredentials}
              onSubmit={handleAuthSubmit}
            />
          )}

          <section className="min-w-0">
            <div className="flex flex-col gap-3 rounded-md border border-zinc-200 bg-white p-4">
              <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
                <div>
                  <h2 className="text-xl font-bold text-zinc-950">
                    Laminas del album
                  </h2>
                  <p className="text-sm text-zinc-600">
                    {visibleLaminas.length} resultado
                    {visibleLaminas.length === 1 ? "" : "s"}
                  </p>
                </div>

                <div className="grid gap-2 sm:grid-cols-[180px_1fr] xl:min-w-[520px]">
                  <label className="relative block">
                    <Filter
                      className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-500"
                      aria-hidden="true"
                    />
                    <select
                      className={`${selectClass} pl-9`}
                      value={selectedPais}
                      onChange={(event) => setSelectedPais(event.target.value)}
                    >
                      <option value="todos">Todos los paises</option>
                      {paises.map((pais) => (
                        <option key={pais.iso3} value={pais.iso3}>
                          {pais.iso3} - {pais.pais}
                        </option>
                      ))}
                    </select>
                  </label>

                  <label className="relative block">
                    <Search
                      className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-500"
                      aria-hidden="true"
                    />
                    <input
                      className={`${inputClass} pl-9`}
                      value={search}
                      onChange={(event) => setSearch(event.target.value)}
                      placeholder="Buscar por nombre, codigo o posicion"
                    />
                  </label>
                </div>
              </div>

              <div className="grid gap-2 sm:grid-cols-2 xl:grid-cols-4">
                {viewOptions.map((option) => {
                  const Icon = option.icon;
                  const active = viewMode === option.id;

                  return (
                    <button
                      key={option.id}
                      type="button"
                      className={`inline-flex h-10 items-center justify-center gap-2 rounded-md border px-3 text-sm font-semibold transition ${
                        active
                          ? "border-red-600 bg-red-50 text-red-700"
                          : "border-zinc-300 bg-white text-zinc-800 hover:bg-zinc-50"
                      } ${!authenticated && option.id !== "catalogo" ? "opacity-60" : ""}`}
                      onClick={() => setViewMode(option.id)}
                      disabled={!authenticated && option.id !== "catalogo"}
                    >
                      <Icon className="h-4 w-4" aria-hidden="true" />
                      {option.label}
                    </button>
                  );
                })}
              </div>
            </div>

            <ApiNotice
              publicError={paisesQuery.error ?? laminasQuery.error}
              protectedError={
                authenticated
                  ? coleccionQuery.error ??
                    repetidasQuery.error ??
                    faltantesQuery.error ??
                    progresoQuery.error ??
                    historialQuery.error
                  : null
              }
            />

            <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4">
              {visibleLaminas.map((lamina) => (
                <LaminaCard
                  key={lamina.id}
                  lamina={lamina}
                  item={collectionById.get(lamina.id)}
                  repeatedItem={repeatedById.get(lamina.id)}
                />
              ))}
            </div>

            {!publicLoading && visibleLaminas.length === 0 ? (
              <EmptyState />
            ) : null}
          </section>
        </div>

        {authenticated ? (
          <section className="mt-6 grid gap-6 lg:grid-cols-[1fr_420px]">
            <ProgressByCountry progress={progreso?.por_pais ?? []} />
            <HistoryPanel loading={historialQuery.isLoading} historial={historial} />
          </section>
        ) : null}
      </div>
    </main>
  );
}

function AuthPanel({
  mode,
  credentials,
  error,
  loading,
  onModeChange,
  onCredentialsChange,
  onSubmit,
}: {
  mode: AuthMode;
  credentials: {
    nombre: string;
    email: string;
    password: string;
    ciudad: string;
    pais: string;
  };
  error: string | null;
  loading: boolean;
  onModeChange: (mode: AuthMode) => void;
  onCredentialsChange: (next: typeof credentials) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  const isRegister = mode === "register";

  return (
    <aside className="rounded-md border border-zinc-200 bg-white p-5">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-md bg-red-50 text-red-600">
          {isRegister ? (
            <UserPlus className="h-5 w-5" aria-hidden="true" />
          ) : (
            <LogIn className="h-5 w-5" aria-hidden="true" />
          )}
        </div>
        <div>
          <h2 className="text-lg font-bold text-zinc-950">
            {isRegister ? "Crear cuenta" : "Iniciar sesion"}
          </h2>
          <p className="text-sm text-zinc-600">Coleccion personal y escaneo</p>
        </div>
      </div>

      <div className="mt-5 grid grid-cols-2 gap-2">
        <button
          type="button"
          className={`h-10 rounded-md border text-sm font-semibold transition ${
            mode === "login"
              ? "border-red-600 bg-red-50 text-red-700"
              : "border-zinc-300 bg-white text-zinc-800 hover:bg-zinc-50"
          }`}
          onClick={() => onModeChange("login")}
        >
          Login
        </button>
        <button
          type="button"
          className={`h-10 rounded-md border text-sm font-semibold transition ${
            mode === "register"
              ? "border-red-600 bg-red-50 text-red-700"
              : "border-zinc-300 bg-white text-zinc-800 hover:bg-zinc-50"
          }`}
          onClick={() => onModeChange("register")}
        >
          Registro
        </button>
      </div>

      <form className="mt-5 space-y-3" onSubmit={onSubmit}>
        {isRegister ? (
          <label className="block">
            <span className="text-sm font-semibold text-zinc-800">Nombre</span>
            <input
              className={`${inputClass} mt-1`}
              value={credentials.nombre}
              onChange={(event) =>
                onCredentialsChange({
                  ...credentials,
                  nombre: event.target.value,
                })
              }
              required={isRegister}
            />
          </label>
        ) : null}

        <label className="block">
          <span className="text-sm font-semibold text-zinc-800">Email</span>
          <input
            className={`${inputClass} mt-1`}
            type="email"
            value={credentials.email}
            onChange={(event) =>
              onCredentialsChange({
                ...credentials,
                email: event.target.value,
              })
            }
            required
          />
        </label>

        <label className="block">
          <span className="text-sm font-semibold text-zinc-800">Password</span>
          <input
            className={`${inputClass} mt-1`}
            type="password"
            value={credentials.password}
            onChange={(event) =>
              onCredentialsChange({
                ...credentials,
                password: event.target.value,
              })
            }
            required
            minLength={3}
          />
        </label>

        {isRegister ? (
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-1">
            <label className="block">
              <span className="text-sm font-semibold text-zinc-800">Ciudad</span>
              <input
                className={`${inputClass} mt-1`}
                value={credentials.ciudad}
                onChange={(event) =>
                  onCredentialsChange({
                    ...credentials,
                    ciudad: event.target.value,
                  })
                }
              />
            </label>

            <label className="block">
              <span className="text-sm font-semibold text-zinc-800">Pais</span>
              <input
                className={`${inputClass} mt-1`}
                value={credentials.pais}
                onChange={(event) =>
                  onCredentialsChange({
                    ...credentials,
                    pais: event.target.value,
                  })
                }
              />
            </label>
          </div>
        ) : null}

        {error ? <InlineAlert message={error} /> : null}

        <button className={`${primaryButtonClass} w-full`} disabled={loading}>
          {loading ? (
            <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
          ) : isRegister ? (
            <UserPlus className="h-4 w-4" aria-hidden="true" />
          ) : (
            <LogIn className="h-4 w-4" aria-hidden="true" />
          )}
          {isRegister ? "Crear cuenta" : "Entrar"}
        </button>
      </form>
    </aside>
  );
}

function ScannerPanel({
  paises,
  scanIso3,
  scanNumber,
  scanResult,
  error,
  loading,
  onIso3Change,
  onNumberChange,
  onSubmit,
}: {
  paises: Array<{ iso3: string; pais: string }>;
  scanIso3: string;
  scanNumber: number;
  scanResult: ScanResponse | null;
  error: string | null;
  loading: boolean;
  onIso3Change: (iso3: string) => void;
  onNumberChange: (number: number) => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  return (
    <aside className="rounded-md border border-zinc-200 bg-white p-5">
      <div className="flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-md bg-red-50 text-red-600">
          <ScanLine className="h-5 w-5" aria-hidden="true" />
        </div>
        <div>
          <h2 className="text-lg font-bold text-zinc-950">Escanear lamina</h2>
          <p className="text-sm text-zinc-600">QR manual compatible con el API</p>
        </div>
      </div>

      <form className="mt-5 space-y-3" onSubmit={onSubmit}>
        <label className="block">
          <span className="text-sm font-semibold text-zinc-800">Pais</span>
          <select
            className={`${selectClass} mt-1`}
            value={scanIso3}
            onChange={(event) => onIso3Change(event.target.value)}
            required
          >
            {paises.map((pais) => (
              <option key={pais.iso3} value={pais.iso3}>
                {pais.iso3} - {pais.pais}
              </option>
            ))}
          </select>
        </label>

        <label className="block">
          <span className="text-sm font-semibold text-zinc-800">Numero</span>
          <input
            className={`${inputClass} mt-1`}
            type="number"
            min={1}
            max={20}
            value={scanNumber}
            onChange={(event) => onNumberChange(Number(event.target.value))}
            required
          />
        </label>

        {error ? <InlineAlert message={error} /> : null}

        <button className={`${primaryButtonClass} w-full`} disabled={loading}>
          {loading ? (
            <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
          ) : (
            <ScanLine className="h-4 w-4" aria-hidden="true" />
          )}
          Guardar lamina
        </button>
      </form>

      {scanResult ? (
        <div className="mt-5 rounded-md border border-green-200 bg-green-50 p-4">
          <div className="flex items-center gap-2 text-sm font-bold text-green-800">
            <CheckCircle2 className="h-4 w-4" aria-hidden="true" />
            {scanResult.estado === "nueva" ? "Lamina nueva" : "Lamina repetida"}
          </div>
          <p className="mt-2 text-sm text-green-900">
            {scanResult.lamina.id} - {scanResult.lamina.nombre_sticker}
          </p>
          <p className="mt-1 text-xs text-green-800">
            Repetidas: {scanResult.cantidad_repetidas}
          </p>
        </div>
      ) : null}
    </aside>
  );
}

function LaminaCard({
  lamina,
  item,
  repeatedItem,
}: {
  lamina: Lamina;
  item?: ColeccionItem;
  repeatedItem?: ColeccionItem;
}) {
  const photoUrl =
    lamina.foto_url && !lamina.foto_url.includes("example.com")
      ? lamina.foto_url
      : null;

  return (
    <article className="min-h-[264px] rounded-md border border-zinc-200 bg-white p-3 shadow-sm">
      <div className="relative flex aspect-[4/3] items-center justify-center overflow-hidden rounded-md bg-zinc-100">
        {photoUrl ? (
          <img
            src={photoUrl}
            alt={lamina.nombre_sticker}
            className="h-full w-full object-cover"
            loading="lazy"
          />
        ) : (
          <div className="flex h-full w-full flex-col items-center justify-center bg-[linear-gradient(135deg,#fef2f2,#eff6ff)] text-center">
            <ImageOff className="h-8 w-8 text-zinc-500" aria-hidden="true" />
            <span className="mt-2 text-3xl font-black text-zinc-800">
              {lamina.iso3}
            </span>
          </div>
        )}
        {item ? (
          <span className="absolute left-2 top-2 inline-flex items-center gap-1 rounded-md bg-green-600 px-2 py-1 text-xs font-bold text-white">
            <CheckCircle2 className="h-3 w-3" aria-hidden="true" />
            Obtenida
          </span>
        ) : null}
        {lamina.es_especial ? (
          <span className="absolute right-2 top-2 inline-flex items-center gap-1 rounded-md bg-amber-400 px-2 py-1 text-xs font-bold text-zinc-950">
            <Star className="h-3 w-3" aria-hidden="true" />
            Especial
          </span>
        ) : null}
      </div>

      <div className="mt-3">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h3 className="line-clamp-2 text-sm font-bold text-zinc-950">
              {lamina.nombre_sticker}
            </h3>
            <p className="mt-1 text-xs font-semibold text-red-700">{lamina.id}</p>
          </div>
          <span className="shrink-0 rounded-md bg-zinc-100 px-2 py-1 text-xs font-bold text-zinc-700">
            {lamina.posicion ?? "N/A"}
          </span>
        </div>

        <div className="mt-3 grid grid-cols-2 gap-2 text-xs text-zinc-600">
          <span className="rounded-md bg-zinc-50 px-2 py-1">
            Equipo: {lamina.equipo_actual ?? lamina.iso3}
          </span>
          <span className="rounded-md bg-zinc-50 px-2 py-1">
            Repetidas: {repeatedItem?.cantidad_repetidas ?? item?.cantidad_repetidas ?? 0}
          </span>
        </div>
      </div>
    </article>
  );
}

function ProgressByCountry({ progress }: { progress: Array<{
  iso3: string;
  pais: string;
  grupo: string;
  total_laminas: number;
  laminas_obtenidas: number;
  porcentaje: number;
}> }) {
  return (
    <section className="rounded-md border border-zinc-200 bg-white p-4">
      <div className="flex items-center gap-2">
        <Trophy className="h-5 w-5 text-red-600" aria-hidden="true" />
        <h2 className="text-lg font-bold text-zinc-950">Progreso por pais</h2>
      </div>
      <div className="mt-4 grid gap-3 md:grid-cols-2">
        {progress.map((item) => (
          <div key={item.iso3} className="rounded-md border border-zinc-200 p-3">
            <div className="flex items-center justify-between gap-3">
              <div className="min-w-0">
                <p className="truncate text-sm font-bold text-zinc-950">
                  {item.iso3} - {item.pais}
                </p>
                <p className="text-xs text-zinc-500">Grupo {item.grupo}</p>
              </div>
              <span className="rounded-md bg-zinc-100 px-2 py-1 text-xs font-bold text-zinc-800">
                {item.porcentaje}%
              </span>
            </div>
            <div className="mt-3 h-2 overflow-hidden rounded-md bg-zinc-100">
              <div
                className="h-full rounded-md bg-red-600"
                style={{ width: `${Math.min(Math.max(item.porcentaje, 0), 100)}%` }}
              />
            </div>
            <p className="mt-2 text-xs text-zinc-600">
              {item.laminas_obtenidas} de {item.total_laminas}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}

function HistoryPanel({
  loading,
  historial,
}: {
  loading: boolean;
  historial: Array<{
    id: number;
    estado: "nueva" | "repetida";
    cantidad_repetidas: number;
    fecha_escaneo: string;
    lamina: Lamina;
  }>;
}) {
  return (
    <section className="rounded-md border border-zinc-200 bg-white p-4">
      <div className="flex items-center gap-2">
        <ClipboardList className="h-5 w-5 text-red-600" aria-hidden="true" />
        <h2 className="text-lg font-bold text-zinc-950">Historial</h2>
      </div>

      <div className="mt-4 space-y-3">
        {loading ? (
          <div className="flex items-center gap-2 text-sm text-zinc-600">
            <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
            Cargando escaneos...
          </div>
        ) : null}

        {!loading && historial.length === 0 ? (
          <p className="text-sm text-zinc-600">Sin escaneos registrados.</p>
        ) : null}

        {historial.map((row) => (
          <div key={row.id} className="rounded-md border border-zinc-200 p-3">
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <p className="truncate text-sm font-bold text-zinc-950">
                  {row.lamina.id} - {row.lamina.nombre_sticker}
                </p>
                <p className="text-xs text-zinc-500">
                  {new Date(row.fecha_escaneo).toLocaleString()}
                </p>
              </div>
              <span
                className={`shrink-0 rounded-md px-2 py-1 text-xs font-bold ${
                  row.estado === "nueva"
                    ? "bg-green-100 text-green-800"
                    : "bg-amber-100 text-amber-800"
                }`}
              >
                {row.estado}
              </span>
            </div>
            <p className="mt-2 text-xs text-zinc-600">
              Repetidas acumuladas: {row.cantidad_repetidas}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}

function StatCard({
  label,
  value,
  detail,
  icon: Icon,
  tone,
}: {
  label: string;
  value: string;
  detail: string;
  icon: typeof Trophy;
  tone: "red" | "green" | "blue" | "amber";
}) {
  const toneClass = {
    red: "bg-red-50 text-red-700",
    green: "bg-green-50 text-green-700",
    blue: "bg-blue-50 text-blue-700",
    amber: "bg-amber-50 text-amber-700",
  }[tone];

  return (
    <div className="rounded-md border border-zinc-200 bg-white p-4 shadow-sm">
      <div className="flex items-center justify-between gap-3">
        <div>
          <p className="text-sm font-semibold text-zinc-600">{label}</p>
          <p className="mt-1 text-3xl font-black text-zinc-950">{value}</p>
        </div>
        <div className={`flex h-11 w-11 items-center justify-center rounded-md ${toneClass}`}>
          <Icon className="h-5 w-5" aria-hidden="true" />
        </div>
      </div>
      <p className="mt-3 text-sm text-zinc-500">{detail}</p>
    </div>
  );
}

function HealthBadge({
  loading,
  online,
  error,
}: {
  loading: boolean;
  online: boolean;
  error: boolean;
}) {
  if (loading) {
    return (
      <span className="inline-flex h-10 items-center gap-2 rounded-md border border-zinc-200 bg-zinc-50 px-3 text-sm font-semibold text-zinc-700">
        <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
        Verificando
      </span>
    );
  }

  if (online && !error) {
    return (
      <span className="inline-flex h-10 items-center gap-2 rounded-md border border-green-200 bg-green-50 px-3 text-sm font-semibold text-green-800">
        <Wifi className="h-4 w-4" aria-hidden="true" />
        Backend activo
      </span>
    );
  }

  return (
    <span className="inline-flex h-10 items-center gap-2 rounded-md border border-red-200 bg-red-50 px-3 text-sm font-semibold text-red-800">
      <WifiOff className="h-4 w-4" aria-hidden="true" />
      Backend sin respuesta
    </span>
  );
}

function ApiNotice({
  publicError,
  protectedError,
}: {
  publicError: unknown;
  protectedError: unknown;
}) {
  const message = getErrorMessage(publicError ?? protectedError);
  if (!message) return null;

  return (
    <div className="mt-4">
      <InlineAlert message={message} />
    </div>
  );
}

function InlineAlert({ message }: { message: string }) {
  return (
    <div className="flex items-start gap-2 rounded-md border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-800">
      <CircleAlert className="mt-0.5 h-4 w-4 shrink-0" aria-hidden="true" />
      <span>{message}</span>
    </div>
  );
}

function EmptyState() {
  return (
    <div className="mt-4 rounded-md border border-dashed border-zinc-300 bg-white p-8 text-center">
      <Search className="mx-auto h-8 w-8 text-zinc-400" aria-hidden="true" />
      <p className="mt-3 text-sm font-semibold text-zinc-800">
        No hay laminas con esos filtros.
      </p>
    </div>
  );
}

function getErrorMessage(error: unknown): string | null {
  if (!error) return null;
  if (error instanceof ApiError) return error.message;
  if (error instanceof Error) return error.message;
  return "No se pudo completar la operacion.";
}
