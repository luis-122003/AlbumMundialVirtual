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
    console.log('Conexión a PostgreSQL establecida correctamente.');
  } catch (err) {
    console.error('Error al conectar a la base de datos:', err.message);
    throw err;
  }
};

module.exports = { query, initDatabase, pool };
