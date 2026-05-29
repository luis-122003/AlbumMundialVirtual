const { query, pool } = require('../config/database');

const formatLamina = (r) => ({
  id: r.lamina_id || r.id,
  nombre_sticker: r.nombre_sticker,
  fecha_nacimiento: r.fecha_nacimiento,
  estatura_cm: r.estatura_cm,
  peso_kg: r.peso_kg,
  equipo_actual: r.equipo_actual,
  es_especial: r.es_especial,
  foto_url: r.foto_url,
  iso3: r.iso3,
  posicion: r.posicion,
});

const formatItem = (r) => ({
  id: r.id,
  usuario_id: r.usuario_id,
  lamina_id: r.lamina_id,
  pegada: r.pegada,
  cantidad_repetidas: r.cantidad_repetidas,
  fecha_obtenida: r.fecha_obtenida,
  lamina: formatLamina(r),
});

const formatHistorial = (r) => ({
  id: r.historial_id,
  usuario_id: r.usuario_id,
  lamina_id: r.lamina_id,
  estado: r.estado,
  cantidad_repetidas: r.cantidad_repetidas,
  contenido_qr: r.contenido_qr,
  fecha_escaneo: r.fecha_escaneo,
  lamina: formatLamina(r),
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
  const client = await pool.connect();
  try {
    const equipoRaw = req.body.equipo_iso3 || req.body.equipo_id || req.body.iso3;
    const numeroRaw = req.body.lamina_numero ?? req.body.numero;
    const equipoIso3 = String(equipoRaw || '').trim().toUpperCase();
    const laminaNumero = Number.parseInt(String(numeroRaw), 10);

    if (!/^[A-Z]{3}$/.test(equipoIso3) || !Number.isInteger(laminaNumero) || laminaNumero < 1 || laminaNumero > 20) {
      return res.status(400).json({ error: 'QR invalido: usa equipo_iso3/equipo_id y lamina_numero entre 1 y 20' });
    }

    const laminaId = `${equipoIso3}${laminaNumero}`;
    const contenidoQr = req.body.contenido_qr
      ? String(req.body.contenido_qr)
      : JSON.stringify({ equipo_iso3: equipoIso3, lamina_numero: laminaNumero });

    await client.query('BEGIN');

    const laminaRows = await client.query(
      'SELECT * FROM laminas_panini_2026 WHERE id = $1',
      [laminaId]
    );
    if (laminaRows.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: `Lamina ${laminaId} no encontrada` });
    }
    const lamina = laminaRows.rows[0];

    const existing = await client.query(
      'SELECT id, cantidad_repetidas FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
      [req.userId, laminaId]
    );

    let estado;
    let cantidadRepetidas;
    if (existing.rows.length === 0) {
      await client.query(
        'INSERT INTO coleccion_usuario (usuario_id, lamina_id, pegada, cantidad_repetidas) VALUES ($1, $2, true, 0)',
        [req.userId, laminaId]
      );
      estado = 'nueva';
      cantidadRepetidas = 0;
    } else {
      cantidadRepetidas = existing.rows[0].cantidad_repetidas + 1;
      await client.query(
        'UPDATE coleccion_usuario SET cantidad_repetidas = $1 WHERE usuario_id = $2 AND lamina_id = $3',
        [cantidadRepetidas, req.userId, laminaId]
      );
      estado = 'repetida';
    }

    const historial = await client.query(
      `INSERT INTO historial_escaneos
       (usuario_id, lamina_id, estado, cantidad_repetidas, contenido_qr)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING fecha_escaneo`,
      [req.userId, laminaId, estado, cantidadRepetidas, contenidoQr]
    );

    await client.query('COMMIT');

    res.json({
      estado,
      cantidad_repetidas: cantidadRepetidas,
      fecha_escaneo: historial.rows[0].fecha_escaneo,
      lamina: formatLamina(lamina),
    });
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    res.status(500).json({ error: err.message });
  } finally {
    client.release();
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

const getHistorialEscaneos = async (req, res) => {
  try {
    const requestedLimit = Number.parseInt(req.query.limit || '40', 10);
    const limit = Number.isInteger(requestedLimit)
      ? Math.min(Math.max(requestedLimit, 1), 100)
      : 40;

    const rows = await query(
      `SELECT he.id AS historial_id, he.usuario_id, he.lamina_id,
              he.estado, he.cantidad_repetidas, he.contenido_qr,
              he.fecha_escaneo,
              l.nombre_sticker, l.fecha_nacimiento, l.estatura_cm,
              l.peso_kg, l.equipo_actual, l.es_especial, l.foto_url,
              l.iso3, l.posicion
       FROM historial_escaneos he
       JOIN laminas_panini_2026 l ON he.lamina_id = l.id
       WHERE he.usuario_id = $1
       ORDER BY he.fecha_escaneo DESC
       LIMIT $2`,
      [req.userId, limit]
    );
    res.json(rows.map(formatHistorial));
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
      porcentaje: t > 0 ? parseFloat(((o / t) * 100).toFixed(1)) : 0,
      por_pais: porPais.map((r) => ({
        ...r,
        porcentaje: r.total_laminas > 0
          ? parseFloat(((r.laminas_obtenidas / r.total_laminas) * 100).toFixed(1))
          : 0,
      })),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  getColeccion,
  escanearLamina,
  getLaminasRepetidas,
  getLaminasFaltantes,
  getHistorialEscaneos,
  getProgreso,
};
