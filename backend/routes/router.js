const { Router } = require('express');
const auth      = require('../controllers/authController');
const laminas   = require('../controllers/laminaController');
const coleccion = require('../controllers/coleccionController');
const intercambios = require('../controllers/intercambioController');
const authMiddleware = require('../middleware/authMiddleware');

const router = Router();

// Auth
router.post('/auth/register', auth.register);
router.post('/auth/login',    auth.login);
router.get('/auth/profile',   authMiddleware, auth.getProfile);
router.put('/auth/profile',   authMiddleware, auth.updateProfile);

// Láminas y países (públicas)
router.get('/laminas',            laminas.getAllLaminas);
router.get('/laminas/pais/:iso3', laminas.getLaminasByPais);
router.get('/laminas/:id',        laminas.getLaminaById);
router.get('/paises',             laminas.getAllPaises);
router.get('/paises/:iso3',       laminas.getPaisById);

// Colección (protegidas)
router.get('/coleccion',           authMiddleware, coleccion.getColeccion);
router.post('/coleccion/escanear', authMiddleware, coleccion.escanearLamina);
router.get('/coleccion/repetidas', authMiddleware, coleccion.getLaminasRepetidas);
router.get('/coleccion/faltantes', authMiddleware, coleccion.getLaminasFaltantes);
router.get('/coleccion/progreso',  authMiddleware, coleccion.getProgreso);

// Intercambios (protegidas)
router.get('/intercambios',                   authMiddleware, intercambios.getIntercambios);
router.post('/intercambios',                  authMiddleware, intercambios.createIntercambio);
router.put('/intercambios/:id/aceptar',       authMiddleware, intercambios.aceptarIntercambio);
router.put('/intercambios/:id/rechazar',      authMiddleware, intercambios.rechazarIntercambio);
router.put('/intercambios/:id/completar',     authMiddleware, intercambios.completarIntercambio);

module.exports = router;
