const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../config/database');

const generateToken = (userId, email) => {
  const secret = process.env.JWT_SECRET || 'panini_jwt_secret_2026';
  return jwt.sign({ userId, email }, secret, { expiresIn: '7d' });
};

const register = async (req, res) => {
  try {
    const { nombre, email, password, ciudad, pais } = req.body;
    if (!nombre || !email || !password) {
      return res.status(400).json({ error: 'nombre, email y password son requeridos' });
    }

    const existing = await query('SELECT id FROM usuarios WHERE email = $1', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ error: 'El email ya está registrado' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const result = await query(
      `INSERT INTO usuarios (nombre, email, password_hash, ciudad, pais)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, nombre, email, foto_perfil_url, ciudad, pais, created_at`,
      [nombre, email, passwordHash, ciudad || null, pais || null]
    );

    const usuario = result[0];
    const token = generateToken(usuario.id, email);
    res.status(201).json({ usuario, token });
  } catch (err) {
    res.status(500).json({ error: 'Error interno: ' + err.message });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'email y password son requeridos' });
    }

    const result = await query(
      'SELECT id, nombre, email, password_hash, foto_perfil_url, ciudad, pais, created_at FROM usuarios WHERE email = $1',
      [email]
    );
    if (result.length === 0) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const user = result[0];
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const { password_hash, ...usuario } = user;
    const token = generateToken(usuario.id, email);
    res.json({ usuario, token });
  } catch (err) {
    res.status(500).json({ error: 'Error interno: ' + err.message });
  }
};

const getProfile = async (req, res) => {
  try {
    const result = await query(
      'SELECT id, nombre, email, foto_perfil_url, ciudad, pais, created_at FROM usuarios WHERE id = $1',
      [req.userId]
    );
    if (result.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(result[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error interno: ' + err.message });
  }
};

const updateProfile = async (req, res) => {
  try {
    const { nombre, ciudad, pais, foto_perfil_url } = req.body;
    const updates = [];
    const values = [];
    let i = 1;

    if (nombre !== undefined)        { updates.push(`nombre = $${i++}`);          values.push(nombre); }
    if (ciudad !== undefined)        { updates.push(`ciudad = $${i++}`);          values.push(ciudad); }
    if (pais !== undefined)          { updates.push(`pais = $${i++}`);            values.push(pais); }
    if (foto_perfil_url !== undefined) { updates.push(`foto_perfil_url = $${i++}`); values.push(foto_perfil_url); }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No hay campos para actualizar' });
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(req.userId);

    const result = await query(
      `UPDATE usuarios SET ${updates.join(', ')} WHERE id = $${i}
       RETURNING id, nombre, email, foto_perfil_url, ciudad, pais, created_at`,
      values
    );
    if (result.length === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(result[0]);
  } catch (err) {
    res.status(500).json({ error: 'Error interno: ' + err.message });
  }
};

module.exports = { register, login, getProfile, updateProfile };
