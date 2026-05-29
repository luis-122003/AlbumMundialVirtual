-- ============================================
-- TABLA: usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    foto_perfil_url VARCHAR(255),
    ciudad VARCHAR(100),
    pais VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: coleccion_usuario
-- ============================================
CREATE TABLE IF NOT EXISTS coleccion_usuario (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    lamina_id VARCHAR(10) NOT NULL REFERENCES laminas_panini_2026(id),
    pegada BOOLEAN DEFAULT TRUE,
    cantidad_repetidas INT DEFAULT 0,
    fecha_obtenida TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(usuario_id, lamina_id)
);

-- ============================================
-- TABLA: historial_escaneos
-- ============================================
CREATE TABLE IF NOT EXISTS historial_escaneos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    lamina_id VARCHAR(10) NOT NULL REFERENCES laminas_panini_2026(id),
    estado VARCHAR(12) NOT NULL CHECK (estado IN ('nueva', 'repetida')),
    cantidad_repetidas INT DEFAULT 0,
    contenido_qr TEXT,
    fecha_escaneo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: intercambios
-- ============================================
CREATE TABLE IF NOT EXISTS intercambios (
    id SERIAL PRIMARY KEY,
    usuario_emisor_id INT NOT NULL REFERENCES usuarios(id),
    usuario_receptor_id INT NOT NULL REFERENCES usuarios(id),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('presencial', 'virtual')),
    estado VARCHAR(15) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente', 'aceptado', 'rechazado', 'completado', 'cancelado')),
    punto_encuentro_lat DOUBLE PRECISION,
    punto_encuentro_lng DOUBLE PRECISION,
    punto_encuentro_desc VARCHAR(255),
    fecha_encuentro TIMESTAMP,
    metodo_envio VARCHAR(20) CHECK (metodo_envio IN ('encuentro', 'correo')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLA: intercambio_laminas
-- ============================================
CREATE TABLE IF NOT EXISTS intercambio_laminas (
    id SERIAL PRIMARY KEY,
    intercambio_id INT NOT NULL REFERENCES intercambios(id) ON DELETE CASCADE,
    lamina_id VARCHAR(10) NOT NULL REFERENCES laminas_panini_2026(id),
    direccion VARCHAR(10) NOT NULL CHECK (direccion IN ('emisor', 'receptor')),
    UNIQUE(intercambio_id, lamina_id, direccion)
);

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_coleccion_usuario ON coleccion_usuario(usuario_id);
CREATE INDEX IF NOT EXISTS idx_coleccion_lamina ON coleccion_usuario(lamina_id);
CREATE INDEX IF NOT EXISTS idx_historial_usuario_fecha ON historial_escaneos(usuario_id, fecha_escaneo DESC);
CREATE INDEX IF NOT EXISTS idx_historial_lamina ON historial_escaneos(lamina_id);
CREATE INDEX IF NOT EXISTS idx_intercambio_emisor ON intercambios(usuario_emisor_id);
CREATE INDEX IF NOT EXISTS idx_intercambio_receptor ON intercambios(usuario_receptor_id);
CREATE INDEX IF NOT EXISTS idx_intercambio_estado ON intercambios(estado);
