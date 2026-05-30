// API placeholder - Connect to your backend
export const API_BASE_URL =
  process.env.VITE_API_URL || "http://localhost:3000/api";

export type Usuario = {
  id: number;
  nombre: string;
  email: string;
  foto_perfil_url: string | null;
  ciudad: string | null;
  pais: string | null;
  created_at: string;
};

export type Lamina = {
  id: string;
  nombre_sticker: string;
  fecha_nacimiento: string | null;
  club: string;
  pais: string;
  numero: number;
  posicion: string;
  imagen_url: string;
  rarity: "common" | "rare" | "epic" | "legendary";
};

export type ColeccionItem = {
  id: string;
  usuario_id: number;
  lamina_id: string;
  cantidad: number;
  condition: "perfect" | "good" | "fair" | "poor";
  created_at: string;
};

export class ApiError extends Error {
  constructor(
    public status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export const api = {
  async get<T>(path: string): Promise<T> {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      headers: this.getHeaders(),
    });
    if (!response.ok)
      throw new ApiError(response.status, `Failed to fetch ${path}`);
    return response.json();
  },

  async post<T>(path: string, data: unknown): Promise<T> {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      method: "POST",
      headers: this.getHeaders(),
      body: JSON.stringify(data),
    });
    if (!response.ok)
      throw new ApiError(response.status, `Failed to post to ${path}`);
    return response.json();
  },

  getHeaders() {
    const token = authStorage.getToken();
    return {
      "Content-Type": "application/json",
      ...(token && { Authorization: `Bearer ${token}` }),
    };
  },
};

export const authStorage = {
  setToken(token: string) {
    localStorage.setItem("auth_token", token);
  },
  getToken(): string | null {
    return localStorage.getItem("auth_token");
  },
  removeToken() {
    localStorage.removeItem("auth_token");
  },
};
