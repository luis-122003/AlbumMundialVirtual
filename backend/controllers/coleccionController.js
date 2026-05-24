const { query } = require('../config/database');

const formatItem = (r) => ({
  id: r.id,
  usuario_id: r.usuario_id,
  lamina_id: r.lamina_id,
  pegada: r.pegada,
  cantidad_repetidas: r.cantidad_repetidas,
  fecha_obtenida: r.fecha_obtenida,
  lamina: {
    id: r.lamina_id,
    nombre_sticker: r.nombre_sticker,
    fecha_nacimiento: r.fecha_nacimiento,
    estatura_cm: r.estatura_cm,
    peso_kg: r.peso_kg,
    equipo_actual: r.equipo_actual,
    es_especial: r.es_especial,
    foto_url: r.foto_url,
    iso3: r.iso3,
    posicion: r.posicion,
  },
});

const getColeccion = async (req, res) => {
  try {
    const rows = await query(
      `SELECT cu.id, cu.usuario_id, cu.lamina_id, cu.pegada,
              cu.cantidad_repetidas, cu.fecha_obtenida,
              l.nombre_sticker, l.fecha_nacimiento, l.estatura_cm,
              l.peso_kg, l.equipo_actual, l.es_especial, l.foto_url,
              l.iso3, l.posicion
       FROM coleccion_usuario cu
       JOIN laminas_panini_2026 l ON cu.lamina_id = l.id
       WHERE cu.usuario_id = $1
       ORDER BY l.iso3, l.id`,
      [req.userId]
    );
    res.json(rows.map(formatItem));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const escanearLamina = async (req, res) => {
  try {
    const { equipo_iso3, lamina_numero } = req.body;
    if (!equipo_iso3 || lamina_numero === undefined) {
      return res.status(400).json({ error: 'equipo_iso3 y lamina_numero son requeridos' });
    }

    const laminaId = `${String(equipo_iso3).toUpperCase()}${lamina_numero}`;

    const laminaRows = await query(
      'SELECT * FROM laminas_panini_2026 WHERE id = $1',
      [laminaId]
    );
    if (laminaRows.length === 0) {
      return res.status(404).json({ error: `Lámina ${laminaId} no encontrada` });
    }
    const lamina = laminaRows[0];

    const existing = await query(
      'SELECT id, cantidad_repetidas FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
      [req.userId, laminaId]
    );

    let estado, cantidadRepetidas;
    if (existing.length === 0) {
      await query(
        'INSERT INTO coleccion_usuario (usuario_id, lamina_id, pegada, cantidad_repetidas) VALUES ($1, $2, true, 0)',
        [req.userId, laminaId]
      );
      estado = 'nueva';
      cantidadRepetidas = 0;
    } else {
      cantidadRepetidas = existing[0].cantidad_repetidas + 1;
      await query(
        'UPDATE coleccion_usuario SET cantidad_repetidas = $1 WHERE usuario_id = $2 AND lamina_id = $3',
        [cantidadRepetidas, req.userId, laminaId]
      );
      estado = 'repetida';
    }

    res.json({ estado, cantidad_repetidas: cantidadRepetidas, lamina });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getLaminasRepetidas = async (req, res) => {
  try {
    const rows = await query(
      `SELECT cu.id, cu.usuario_id, cu.lamina_id, cu.pegada,
              cu.cantidad_repetidas, cu.fecha_obtenida,
              l.nombre_sticker, l.fecha_nacimiento, l.estatura_cm,
              l.peso_kg, l.equipo_actual, l.es_especial, l.foto_url,
              l.iso3, l.posicion
       FROM coleccion_usuario cu
       JOIN laminas_panini_2026 l ON cu.lamina_id = l.id
       WHERE cu.usuario_id = $1 AND cu.cantidad_repetidas > 0
       ORDER BY l.iso3, l.id`,
      [req.userId]
    );
    res.json(rows.map(formatItem));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getLaminasFaltantes = async (req, res) => {
  try {
    const rows = await query(
      `SELECT id, nombre_sticker, fecha_nacimiento, estatura_cm, peso_kg,
              equipo_actual, es_especial, foto_url, iso3, posicion
       FROM laminas_panini_2026
       WHERE id NOT IN (
         SELECT lamina_id FROM coleccion_usuario WHERE usuario_id = $1
       )
       ORDER BY iso3, id`,
      [req.userId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getProgreso = async (req, res) => {
  try {
    const [{ total }] = await query('SELECT COUNT(*) AS total FROM laminas_panini_2026');
    const [{ total: obtenidas }] = await query(
      'SELECT COUNT(*) AS total FROM coleccion_usuario WHERE usuario_id = $1',
      [req.userId]
    );

    const porPais = await query(
      `SELECT p.iso3, p.pais, p.grupo,
              COUNT(l.id)::int  AS total_laminas,
              COUNT(cu.id)::int AS laminas_obtenidas
       FROM paises_mundial_2026 p
       JOIN laminas_panini_2026 l ON l.iso3 = p.iso3
       LEFT JOIN coleccion_usuario cu ON cu.lamina_id = l.id AND cu.usuario_id = $1
       GROUP BY p.iso3, p.pais, p.grupo
       ORDER BY p.grupo, p.pais`,
      [req.userId]
    );

    const t = parseInt(total);
    const o = parseInt(obtenidas);

    res.json({
      total_laminas: t,
      laminas_obtenidas: o,
      porcentaje: t > 0 ? parseFloat((o / t * 100).toFixed(1)) : 0,
      por_pais: porPais.map((r) => ({
        ...r,
        porcentaje: r.total_laminas > 0
          ? parseFloat((r.laminas_obtenidas / r.total_laminas * 100).toFixed(1))
          : 0,
      })),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getColeccion, escanearLamina, getLaminasRepetidas, getLaminasFaltantes, getProgreso };
