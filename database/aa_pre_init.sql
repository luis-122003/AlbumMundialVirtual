-- Pre-init: crea las tablas vacías para que los DROP TABLE del script
-- del profesor no fallen en la primera ejecución (no usa IF EXISTS).
CREATE TABLE IF NOT EXISTS paises_mundial_2026 (
    iso3 VARCHAR(3) PRIMARY KEY,
    pais VARCHAR(100) NOT NULL,
    grupo CHAR(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS laminas_panini_2026 (
    id VARCHAR(10) NOT NULL PRIMARY KEY,
    nombre_sticker VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    estatura_cm INT,
    peso_kg INT,
    equipo_actual VARCHAR(100),
    es_especial BOOLEAN DEFAULT FALSE,
    foto_url VARCHAR(255),
    iso3 VARCHAR(3),
    posicion VARCHAR(15)
);
