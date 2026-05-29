export type Usuario = {
  id: number;
  nombre: string;
  email: string;
  foto_perfil_url: string | null;
  ciudad: string | null;
  pais: string | null;
  created_at: string;
};

export type Pais = {
  iso3: string;
  pais: string;
  grupo: string;
};

export type Lamina = {
  id: string;
  nombre_sticker: string;
  fecha_nacimiento: string | null;
  estatura_cm: number | null;
  peso_kg: number | null;
  equipo_actual: string | null;
  es_especial: boolean;
  foto_url: string | null;
  iso3: string;
  posicion: string | null;
};

export type ColeccionItem = {
  id: number;
  usuario_id: number;
  lamina_id: string;
  pegada: boolean;
  cantidad_repetidas: number;
  fecha_obtenida: string;
  lamina: Lamina;
};

export type ProgresoPais = Pais & {
  total_laminas: number;
  laminas_obtenidas: number;
  porcentaje: number;
};

export type Progreso = {
  total_laminas: number;
  laminas_obtenidas: number;
  porcentaje: number;
  por_pais: ProgresoPais[];
};

export type HistorialEscaneo = {
  id: number;
  usuario_id: number;
  lamina_id: string;
  estado: "nueva" | "repetida";
  cantidad_repetidas: number;
  contenido_qr: string;
  fecha_escaneo: string;
  lamina: Lamina;
};

export type ScanResponse = {
  estado: "nueva" | "repetida";
  cantidad_repetidas: number;
  fecha_escaneo: string;
  lamina: Lamina;
};

type AuthResponse = {
  usuario: Usuario;
  token: string;
};

type RequestOptions = {
  auth?: boolean;
  method?: "GET" | "POST" | "PUT";
  body?: Record<string, unknown>;
};

const TOKEN_KEY = "panini_web_token";
const USER_KEY = "panini_web_user";

export const API_BASE_URL = (
  import.meta.env.VITE_API_URL ?? "http://localhost:8080/api"
).replace(/\/$/, "");

export const API_HEALTH_URL = API_BASE_URL.endsWith("/api")
  ? `${API_BASE_URL.slice(0, -4)}/health`
  : `${API_BASE_URL}/health`;

const isBrowser = () => typeof window !== "undefined";

export class ApiError extends Error {
  statusCode: number;

  constructor(statusCode: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.statusCode = statusCode;
  }
}

export const authStorage = {
  getToken() {
    if (!isBrowser()) return null;
    return window.localStorage.getItem(TOKEN_KEY);
  },
  getUser() {
    if (!isBrowser()) return null;
    const raw = window.localStorage.getItem(USER_KEY);
    if (!raw) return null;

    try {
      return JSON.parse(raw) as Usuario;
    } catch {
      window.localStorage.removeItem(USER_KEY);
      return null;
    }
  },
  setSession(token: string, user: Usuario) {
    if (!isBrowser()) return;
    window.localStorage.setItem(TOKEN_KEY, token);
    window.localStorage.setItem(USER_KEY, JSON.stringify(user));
  },
  clear() {
    if (!isBrowser()) return;
    window.localStorage.removeItem(TOKEN_KEY);
    window.localStorage.removeItem(USER_KEY);
  },
};

async function readJson<T>(response: Response): Promise<T | null> {
  if (response.status === 204) return null;
  const text = await response.text();
  if (!text) return null;
  return JSON.parse(text) as T;
}

async function request<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const token = options.auth ? authStorage.getToken() : null;
  const response = await fetch(`${API_BASE_URL}${path}`, {
    method: options.method ?? "GET",
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  });

  const data = await readJson<{ error?: string } | T>(response);

  if (!response.ok) {
    const errorMessage =
      data && typeof data === "object" && "error" in data && data.error
        ? String(data.error)
        : "Error del servidor";
    throw new ApiError(response.status, errorMessage);
  }

  return data as T;
}

export const api = {
  async health() {
    const response = await fetch(API_HEALTH_URL);
    const data = await readJson<{ status?: string }>(response);
    if (!response.ok) {
      throw new ApiError(response.status, "Backend no disponible");
    }
    return data ?? { status: "ok" };
  },
  login(email: string, password: string) {
    return request<AuthResponse>("/auth/login", {
      method: "POST",
      body: { email: email.trim(), password },
    });
  },
  register(input: {
    nombre: string;
    email: string;
    password: string;
    ciudad?: string;
    pais?: string;
  }) {
    return request<AuthResponse>("/auth/register", {
      method: "POST",
      body: {
        nombre: input.nombre.trim(),
        email: input.email.trim(),
        password: input.password,
        ...(input.ciudad?.trim() ? { ciudad: input.ciudad.trim() } : {}),
        ...(input.pais?.trim() ? { pais: input.pais.trim() } : {}),
      },
    });
  },
  profile() {
    return request<Usuario>("/auth/profile", { auth: true });
  },
  paises() {
    return request<Pais[]>("/paises");
  },
  laminas() {
    return request<Lamina[]>("/laminas");
  },
  coleccion() {
    return request<ColeccionItem[]>("/coleccion", { auth: true });
  },
  repetidas() {
    return request<ColeccionItem[]>("/coleccion/repetidas", { auth: true });
  },
  faltantes() {
    return request<Lamina[]>("/coleccion/faltantes", { auth: true });
  },
  progreso() {
    return request<Progreso>("/coleccion/progreso", { auth: true });
  },
  historial(limit = 20) {
    return request<HistorialEscaneo[]>(`/coleccion/historial?limit=${limit}`, {
      auth: true,
    });
  },
  escanearLamina(equipoIso3: string, laminaNumero: number) {
    const iso3 = equipoIso3.trim().toUpperCase();

    return request<ScanResponse>("/coleccion/escanear", {
      auth: true,
      method: "POST",
      body: {
        equipo_iso3: iso3,
        equipo_id: iso3,
        lamina_numero: laminaNumero,
      },
    });
  },
};
