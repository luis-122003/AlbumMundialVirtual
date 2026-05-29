const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'panini_mundial',
  user: process.env.DB_USER || 'panini_user',
  password: process.env.DB_PASSWORD || 'panini_pass',
});

pool.on('error', (err) => {
  console.error('Error inesperado en el pool de PostgreSQL:', err.message);
});

const query = async (text, params) => {
  const result = await pool.query(text, params);
  return result.rows;
};

const initDatabase = async () => {
  try {
    await pool.query('SELECT 1');
    await pool.query(`
      CREATE TABLE IF NOT EXISTS historial_escaneos (
        id SERIAL PRIMARY KEY,
        usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
        lamina_id VARCHAR(10) NOT NULL REFERENCES laminas_panini_2026(id),
        estado VARCHAR(12) NOT NULL CHECK (estado IN ('nueva', 'repetida')),
        cantidad_repetidas INT DEFAULT 0,
        contenido_qr TEXT,
        fecha_escaneo TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_historial_usuario_fecha
      ON historial_escaneos(usuario_id, fecha_escaneo DESC)
    `);
    await pool.query(`
      CREATE INDEX IF NOT EXISTS idx_historial_lamina
      ON historial_escaneos(lamina_id)
    `);
    console.log('Conexión a PostgreSQL establecida correctamente.');
  } catch (err) {
    console.error('Error al conectar a la base de datos:', err.message);
    throw err;
  }
};

module.exports = { query, initDatabase, pool };
