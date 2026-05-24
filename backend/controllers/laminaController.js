const { query } = require('../config/database');

const getAllLaminas = async (req, res) => {
  try {
    const rows = await query(
      `SELECT id, nombre_sticker, fecha_nacimiento, estatura_cm, peso_kg,
              equipo_actual, es_especial, foto_url, iso3, posicion
       FROM laminas_panini_2026 ORDER BY iso3, id`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getLaminaById = async (req, res) => {
  try {
    const rows = await query(
      `SELECT l.*, p.pais, p.grupo
       FROM laminas_panini_2026 l
       JOIN paises_mundial_2026 p ON l.iso3 = p.iso3
       WHERE l.id = $1`,
      [req.params.id]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'Lámina no encontrada' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getLaminasByPais = async (req, res) => {
  try {
    const rows = await query(
      `SELECT id, nombre_sticker, fecha_nacimiento, estatura_cm, peso_kg,
              equipo_actual, es_especial, foto_url, iso3, posicion
       FROM laminas_panini_2026 WHERE iso3 = $1 ORDER BY id`,
      [req.params.iso3.toUpperCase()]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getAllPaises = async (req, res) => {
  try {
    const rows = await query(
      'SELECT iso3, pais, grupo FROM paises_mundial_2026 ORDER BY grupo, pais'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getPaisById = async (req, res) => {
  try {
    const rows = await query(
      'SELECT iso3, pais, grupo FROM paises_mundial_2026 WHERE iso3 = $1',
      [req.params.iso3.toUpperCase()]
    );
    if (rows.length === 0) return res.status(404).json({ error: 'País no encontrado' });
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getAllLaminas, getLaminaById, getLaminasByPais, getAllPaises, getPaisById };
