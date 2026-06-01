const { query } = require('../config/database');

const enrichIntercambio = async (row) => {
  const laminas = await query(
    `SELECT il.id, il.intercambio_id, il.lamina_id, il.direccion,
            l.nombre_sticker, l.iso3, l.foto_url, l.es_especial, l.posicion
     FROM intercambio_laminas il
     JOIN laminas_panini_2026 l ON il.lamina_id = l.id
     WHERE il.intercambio_id = $1`,
    [row.id]
  );
  return { ...row, laminas };
};

const getIntercambios = async (req, res) => {
  try {
    const { estado } = req.query;
    let sql = `
      SELECT i.*,
             ue.nombre AS emisor_nombre, ue.email AS emisor_email,
             ur.nombre AS receptor_nombre, ur.email AS receptor_email
      FROM intercambios i
      JOIN usuarios ue ON i.usuario_emisor_id = ue.id
      JOIN usuarios ur ON i.usuario_receptor_id = ur.id
      WHERE (i.usuario_emisor_id = $1 OR i.usuario_receptor_id = $1)
    `;
    const params = [req.userId];
    if (estado) {
      sql += ` AND i.estado = $2`;
      params.push(estado);
    }
    sql += ` ORDER BY i.updated_at DESC`;

    const rows = await query(sql, params);
    const enriched = await Promise.all(rows.map(enrichIntercambio));
    res.json(enriched);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const createIntercambio = async (req, res) => {
  try {
    const { receptor_id, tipo, laminas_emisor, laminas_receptor } = req.body;

    if (!receptor_id || !tipo || !laminas_emisor?.length || !laminas_receptor?.length) {
      return res.status(400).json({ error: 'receptor_id, tipo, laminas_emisor y laminas_receptor son requeridos' });
    }
    if (!['presencial', 'virtual'].includes(tipo)) {
      return res.status(400).json({ error: 'tipo debe ser presencial o virtual' });
    }
    if (parseInt(receptor_id) === req.userId) {
      return res.status(400).json({ error: 'No puedes intercambiar contigo mismo' });
    }

    for (const laminaId of laminas_emisor) {
      const rows = await query(
        'SELECT cantidad_repetidas FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
        [req.userId, laminaId]
      );
      if (!rows.length || rows[0].cantidad_repetidas < 1) {
        return res.status(400).json({ error: `No tienes repetidas de la lámina ${laminaId}` });
      }
    }

    for (const laminaId of laminas_receptor) {
      const rows = await query(
        'SELECT cantidad_repetidas FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
        [parseInt(receptor_id), laminaId]
      );
      if (!rows.length || rows[0].cantidad_repetidas < 1) {
        return res.status(400).json({ error: `El otro usuario no tiene repetidas de la lámina ${laminaId}` });
      }
    }

    const result = await query(
      `INSERT INTO intercambios (usuario_emisor_id, usuario_receptor_id, tipo, estado)
       VALUES ($1, $2, $3, 'pendiente') RETURNING *`,
      [req.userId, parseInt(receptor_id), tipo]
    );
    const intercambio = result[0];

    for (const laminaId of laminas_emisor) {
      await query(
        'INSERT INTO intercambio_laminas (intercambio_id, lamina_id, direccion) VALUES ($1, $2, $3)',
        [intercambio.id, laminaId, 'emisor']
      );
    }
    for (const laminaId of laminas_receptor) {
      await query(
        'INSERT INTO intercambio_laminas (intercambio_id, lamina_id, direccion) VALUES ($1, $2, $3)',
        [intercambio.id, laminaId, 'receptor']
      );
    }

    res.status(201).json(await enrichIntercambio(intercambio));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const aceptarIntercambio = async (req, res) => {
  try {
    const { id } = req.params;
    const rows = await query('SELECT * FROM intercambios WHERE id = $1', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Intercambio no encontrado' });
    const intercambio = rows[0];

    if (intercambio.usuario_receptor_id !== req.userId) {
      return res.status(403).json({ error: 'Solo el receptor puede aceptar' });
    }
    if (intercambio.estado !== 'pendiente') {
      return res.status(400).json({ error: `No se puede aceptar en estado ${intercambio.estado}` });
    }

    const updated = await query(
      `UPDATE intercambios SET estado = 'aceptado', updated_at = NOW() WHERE id = $1 RETURNING *`,
      [id]
    );
    res.json(await enrichIntercambio(updated[0]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const rechazarIntercambio = async (req, res) => {
  try {
    const { id } = req.params;
    const rows = await query('SELECT * FROM intercambios WHERE id = $1', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Intercambio no encontrado' });
    const intercambio = rows[0];

    if (intercambio.usuario_emisor_id !== req.userId && intercambio.usuario_receptor_id !== req.userId) {
      return res.status(403).json({ error: 'No autorizado' });
    }
    if (!['pendiente', 'aceptado'].includes(intercambio.estado)) {
      return res.status(400).json({ error: `No se puede rechazar en estado ${intercambio.estado}` });
    }

    const updated = await query(
      `UPDATE intercambios SET estado = 'rechazado', updated_at = NOW() WHERE id = $1 RETURNING *`,
      [id]
    );
    res.json(await enrichIntercambio(updated[0]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const completarIntercambio = async (req, res) => {
  try {
    const { id } = req.params;
    const rows = await query('SELECT * FROM intercambios WHERE id = $1', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Intercambio no encontrado' });
    const intercambio = rows[0];

    if (intercambio.usuario_emisor_id !== req.userId && intercambio.usuario_receptor_id !== req.userId) {
      return res.status(403).json({ error: 'No autorizado' });
    }
    if (!['pendiente', 'aceptado'].includes(intercambio.estado)) {
      return res.status(400).json({ error: `No se puede completar en estado ${intercambio.estado}` });
    }

    const laminas = await query(
      'SELECT * FROM intercambio_laminas WHERE intercambio_id = $1',
      [id]
    );

    const emisorId = intercambio.usuario_emisor_id;
    const receptorId = intercambio.usuario_receptor_id;

    for (const laminaRow of laminas.filter(l => l.direccion === 'emisor')) {
      const laminaId = laminaRow.lamina_id;
      await query(
        `UPDATE coleccion_usuario SET cantidad_repetidas = cantidad_repetidas - 1
         WHERE usuario_id = $1 AND lamina_id = $2 AND cantidad_repetidas > 0`,
        [emisorId, laminaId]
      );
      const existente = await query(
        'SELECT id FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
        [receptorId, laminaId]
      );
      if (!existente.length) {
        await query(
          'INSERT INTO coleccion_usuario (usuario_id, lamina_id, pegada, cantidad_repetidas) VALUES ($1, $2, true, 0)',
          [receptorId, laminaId]
        );
      } else {
        await query(
          'UPDATE coleccion_usuario SET cantidad_repetidas = cantidad_repetidas + 1 WHERE usuario_id = $1 AND lamina_id = $2',
          [receptorId, laminaId]
        );
      }
    }

    for (const laminaRow of laminas.filter(l => l.direccion === 'receptor')) {
      const laminaId = laminaRow.lamina_id;
      await query(
        `UPDATE coleccion_usuario SET cantidad_repetidas = cantidad_repetidas - 1
         WHERE usuario_id = $1 AND lamina_id = $2 AND cantidad_repetidas > 0`,
        [receptorId, laminaId]
      );
      const existente = await query(
        'SELECT id FROM coleccion_usuario WHERE usuario_id = $1 AND lamina_id = $2',
        [emisorId, laminaId]
      );
      if (!existente.length) {
        await query(
          'INSERT INTO coleccion_usuario (usuario_id, lamina_id, pegada, cantidad_repetidas) VALUES ($1, $2, true, 0)',
          [emisorId, laminaId]
        );
      } else {
        await query(
          'UPDATE coleccion_usuario SET cantidad_repetidas = cantidad_repetidas + 1 WHERE usuario_id = $1 AND lamina_id = $2',
          [emisorId, laminaId]
        );
      }
    }

    const updated = await query(
      `UPDATE intercambios SET estado = 'completado', updated_at = NOW() WHERE id = $1 RETURNING *`,
      [id]
    );
    res.json(await enrichIntercambio(updated[0]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const buscarUsuarios = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({ error: 'La búsqueda debe tener al menos 2 caracteres' });
    }
    const rows = await query(
      `SELECT id, nombre, email, ciudad, pais
       FROM usuarios
       WHERE id != $1 AND (LOWER(nombre) LIKE LOWER($2) OR LOWER(email) LIKE LOWER($2))
       ORDER BY nombre LIMIT 20`,
      [req.userId, `%${q.trim()}%`]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const compararColecciones = async (req, res) => {
  try {
    const otroId = parseInt(req.params.userId);

    const yoTengoElOtroNecesita = await query(
      `SELECT cu.lamina_id, cu.cantidad_repetidas,
              l.nombre_sticker, l.iso3, l.foto_url, l.es_especial, l.posicion
       FROM coleccion_usuario cu
       JOIN laminas_panini_2026 l ON cu.lamina_id = l.id
       WHERE cu.usuario_id = $1 AND cu.cantidad_repetidas > 0
         AND cu.lamina_id NOT IN (
           SELECT lamina_id FROM coleccion_usuario WHERE usuario_id = $2
         )`,
      [req.userId, otroId]
    );

    const otroTieneYoNecesito = await query(
      `SELECT cu.lamina_id, cu.cantidad_repetidas,
              l.nombre_sticker, l.iso3, l.foto_url, l.es_especial, l.posicion
       FROM coleccion_usuario cu
       JOIN laminas_panini_2026 l ON cu.lamina_id = l.id
       WHERE cu.usuario_id = $1 AND cu.cantidad_repetidas > 0
         AND cu.lamina_id NOT IN (
           SELECT lamina_id FROM coleccion_usuario WHERE usuario_id = $2
         )`,
      [otroId, req.userId]
    );

    const usuarioRows = await query(
      'SELECT id, nombre, email, ciudad, pais FROM usuarios WHERE id = $1',
      [otroId]
    );
    if (!usuarioRows.length) return res.status(404).json({ error: 'Usuario no encontrado' });

    res.json({
      otro_usuario: usuarioRows[0],
      yo_tengo_el_otro_necesita: yoTengoElOtroNecesita,
      otro_tiene_yo_necesito: otroTieneYoNecesito,
      matches: Math.min(yoTengoElOtroNecesita.length, otroTieneYoNecesito.length),
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getOfertas = async (req, res) => {
  try {
    const rows = await query(
      `SELECT u.id, u.nombre, u.email, u.ciudad, u.pais,
              COUNT(cu.id)::int AS total_repetidas,
              SUM(CASE WHEN cu.lamina_id NOT IN (
                SELECT lamina_id FROM coleccion_usuario WHERE usuario_id = $1
              ) THEN 1 ELSE 0 END)::int AS tiene_para_mi,
              SUM(CASE WHEN cu.lamina_id IN (
                SELECT cu2.lamina_id FROM coleccion_usuario cu2
                WHERE cu2.usuario_id = $1 AND cu2.cantidad_repetidas > 0
                  AND cu2.lamina_id NOT IN (
                    SELECT lamina_id FROM coleccion_usuario WHERE usuario_id = u.id
                  )
              ) THEN 1 ELSE 0 END)::int AS necesita_de_mi
       FROM usuarios u
       JOIN coleccion_usuario cu ON cu.usuario_id = u.id AND cu.cantidad_repetidas > 0
       WHERE u.id != $1
       GROUP BY u.id, u.nombre, u.email, u.ciudad, u.pais
       ORDER BY tiene_para_mi DESC, necesita_de_mi DESC
       LIMIT 50`,
      [req.userId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const coordinarEncuentro = async (req, res) => {
  try {
    const { id } = req.params;
    const { lat, lng, descripcion, fecha_encuentro, metodo_envio } = req.body;

    const rows = await query('SELECT * FROM intercambios WHERE id = $1', [id]);
    if (!rows.length) return res.status(404).json({ error: 'Intercambio no encontrado' });
    const intercambio = rows[0];

    if (intercambio.usuario_emisor_id !== req.userId && intercambio.usuario_receptor_id !== req.userId) {
      return res.status(403).json({ error: 'No autorizado' });
    }
    if (intercambio.estado !== 'aceptado') {
      return res.status(400).json({ error: 'El intercambio debe estar aceptado para coordinar encuentro' });
    }

    const updated = await query(
      `UPDATE intercambios
       SET punto_encuentro_lat = $1, punto_encuentro_lng = $2,
           punto_encuentro_desc = $3, fecha_encuentro = $4,
           metodo_envio = $5, updated_at = NOW()
       WHERE id = $6 RETURNING *`,
      [lat || null, lng || null, descripcion || null, fecha_encuentro || null, metodo_envio || 'encuentro', id]
    );
    res.json(await enrichIntercambio(updated[0]));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getEstadisticas = async (req, res) => {
  try {
    const [{ total }] = await query(
      `SELECT COUNT(*)::int AS total FROM intercambios
       WHERE (usuario_emisor_id = $1 OR usuario_receptor_id = $1) AND estado = 'completado'`,
      [req.userId]
    );
    const [{ presenciales }] = await query(
      `SELECT COUNT(*)::int AS presenciales FROM intercambios
       WHERE (usuario_emisor_id = $1 OR usuario_receptor_id = $1) AND estado = 'completado' AND tipo = 'presencial'`,
      [req.userId]
    );
    const [{ virtuales }] = await query(
      `SELECT COUNT(*)::int AS virtuales FROM intercambios
       WHERE (usuario_emisor_id = $1 OR usuario_receptor_id = $1) AND estado = 'completado' AND tipo = 'virtual'`,
      [req.userId]
    );
    res.json({ total_completados: total, presenciales, virtuales });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = {
  getIntercambios,
  createIntercambio,
  aceptarIntercambio,
  rechazarIntercambio,
  completarIntercambio,
  buscarUsuarios,
  compararColecciones,
  getOfertas,
  coordinarEncuentro,
  getEstadisticas,
};
