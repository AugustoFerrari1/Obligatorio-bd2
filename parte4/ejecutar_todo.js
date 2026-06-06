// ============================================================
//  ejecutar_todo.js
//  Ejecuta las 3 partes del obligatorio usando el driver nativo
//  de Node.js en lugar de mongosh, para mayor compatibilidad.
//
//  Los archivos .js originales (parte4_schema_mongodb.js, etc.)
//  son los scripts de mongosh para entregar; este archivo los
//  replica usando el driver de Node.js con async/await.
// ============================================================

const { MongoMemoryServer } = require('mongodb-memory-server');
const { MongoClient, Int32 }  = require('mongodb');

// Shorthand para Int32 (equivalente a NumberInt() en mongosh)
const N = (n) => new Int32(n);

// ─────────────────────────────────────────────────────────────
//  PARTE 4 – SCHEMA: Crea las 2 colecciones con validators
// ─────────────────────────────────────────────────────────────
async function ejecutarSchema(db) {
  console.log('\n--- Ejecutando parte4_schema_mongodb.js ---');

  // Borrar colecciones previas
  await db.collection('eventos').drop().catch(() => {});
  await db.collection('agentes_analytics').drop().catch(() => {});

  console.log('=== Creando coleccion: eventos ===');

  await db.createCollection('eventos', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        title: 'Validacion de eventos',
        required: ['idAgente','nombreAgente','tipoAgente','emailAdmin',
                   'timestamp','tipoEvento','criticidad','payload'],
        properties: {
          idAgente:            { bsonType: 'int',    description: 'ID del agente en Oracle. Obligatorio.' },
          nombreAgente:        { bsonType: 'string', description: 'Nombre del agente. Obligatorio.' },
          tipoAgente:          { bsonType: 'string', enum: ['Generador','Moderador','Observador'] },
          emailAdmin:          { bsonType: 'string', description: 'Email del administrador. Obligatorio.' },
          timestamp:           { bsonType: 'date',   description: 'Fecha y hora del evento. Obligatorio.' },
          tipoEvento:          { bsonType: 'string', description: 'Tipo del evento. Obligatorio.' },
          criticidad:          { bsonType: 'string', enum: ['alta','media','baja'] },
          contextoOperacional: { bsonType: 'string' },
          payload:             { bsonType: 'object' },
          metricasEjecucion: {
            bsonType: 'object',
            properties: {
              tiempoRespuestaMs: { bsonType: 'int' },
              cantidadTokens:    { bsonType: 'int' },
              memoriaUsadaMb:    { bsonType: 'int' }
            }
          },
          anomalia:            { bsonType: 'bool' },
          descripcionAnomalia: { bsonType: ['string','null'] }
        }
      }
    },
    validationAction: 'error'
  });

  console.log("Coleccion 'eventos' creada con validator OK.");

  await db.collection('eventos').createIndex({ idAgente: 1, timestamp: -1 });
  await db.collection('eventos').createIndex({ criticidad: 1, timestamp: -1 });
  await db.collection('eventos').createIndex({ tipoEvento: 1, timestamp: -1 });
  await db.collection('eventos').createIndex({ timestamp: -1 });
  console.log("Indices de 'eventos' creados OK.");

  console.log('\n=== Creando coleccion: agentes_analytics ===');

  await db.createCollection('agentes_analytics', {
    validator: {
      $jsonSchema: {
        bsonType: 'object',
        title: 'Validacion de agentes_analytics',
        required: ['idAgente','nombreAgente','tipoAgente','emailAdmin',
                   'estadoActual','resumenActividad'],
        properties: {
          idAgente:    { bsonType: 'int' },
          nombreAgente:{ bsonType: 'string' },
          tipoAgente:  { bsonType: 'string', enum: ['Generador','Moderador','Observador'] },
          emailAdmin:  { bsonType: 'string' },
          estadoActual:{ bsonType: 'string', enum: ['Activo','Suspendido'] },
          resumenActividad: {
            bsonType: 'object',
            required: ['totalEventos','eventosPorTipo','eventosPorCriticidad'],
            properties: {
              totalEventos:         { bsonType: 'int' },
              eventosPorTipo:       { bsonType: 'object' },
              eventosPorCriticidad: { bsonType: 'object' },
              primerEvento:         { bsonType: ['date','null'] },
              ultimoEvento:         { bsonType: ['date','null'] }
            }
          },
          historialConfiguraciones: {
            bsonType: 'array',
            items: {
              bsonType: 'object',
              required: ['version','fechaAplicacion','descripcion'],
              properties: {
                version:         { bsonType: 'int' },
                fechaAplicacion: { bsonType: 'date' },
                descripcion:     { bsonType: 'string' }
              }
            }
          },
          anomaliasDetectadas: { bsonType: 'int' },
          ultimaActualizacion: { bsonType: 'date' }
        }
      }
    },
    validationAction: 'error'
  });

  console.log("Coleccion 'agentes_analytics' creada con validator OK.");
  await db.collection('agentes_analytics').createIndex({ idAgente: 1 }, { unique: true });
  await db.collection('agentes_analytics').createIndex({ 'resumenActividad.eventosPorCriticidad.alta': -1 });
  console.log("Indices de 'agentes_analytics' creados OK.");
  console.log('\n=== Listo! Ambas colecciones creadas correctamente. ===');
  console.log('Podes verificar con: db.getCollectionNames()');
}

// ─────────────────────────────────────────────────────────────
//  PARTE 4 – DATOS DE PRUEBA
// ─────────────────────────────────────────────────────────────
async function ejecutarDatos(db) {
  console.log('\n--- Ejecutando parte4_datos_prueba.js ---');

  await db.collection('eventos').deleteMany({});
  await db.collection('agentes_analytics').deleteMany({});

  console.log('=== Insertando documentos en agentes_analytics ===');

  await db.collection('agentes_analytics').insertMany([
    {
      idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador',
      emailAdmin: 'alice@mail.com', estadoActual: 'Activo',
      resumenActividad: {
        totalEventos: N(11),
        eventosPorTipo: { creacion: N(5), decision: N(4), 'interaccion con usuario': N(2), error: N(0), voto: N(0), moderacion: N(0) },
        eventosPorCriticidad: { alta: N(3), media: N(5), baja: N(3) },
        primerEvento: new Date('2026-05-20T09:00:00Z'),
        ultimoEvento:  new Date('2026-06-03T14:00:00Z')
      },
      historialConfiguraciones: [
        { version: N(1), fechaAplicacion: new Date('2024-06-01'), descripcion: 'Configuracion inicial: Simple.' },
        { version: N(2), fechaAplicacion: new Date('2024-09-01'), descripcion: 'Upgrade a Compuesta para mayor capacidad.' }
      ],
      anomaliasDetectadas: N(1),
      ultimaActualizacion: new Date('2026-06-03T14:00:00Z')
    },
    {
      idAgente: N(2), nombreAgente: 'GenBot-Beta', tipoAgente: 'Generador',
      emailAdmin: 'carol@mail.com', estadoActual: 'Activo',
      resumenActividad: {
        totalEventos: N(9),
        eventosPorTipo: { creacion: N(5), decision: N(3), 'interaccion con usuario': N(1), error: N(0), voto: N(0), moderacion: N(0) },
        eventosPorCriticidad: { alta: N(4), media: N(3), baja: N(2) },
        primerEvento: new Date('2026-05-21T10:00:00Z'),
        ultimoEvento:  new Date('2026-06-02T11:00:00Z')
      },
      historialConfiguraciones: [
        { version: N(1), fechaAplicacion: new Date('2024-06-15'), descripcion: 'Configuracion inicial: Simple.' }
      ],
      anomaliasDetectadas: N(2),
      ultimaActualizacion: new Date('2026-06-02T11:00:00Z')
    },
    {
      idAgente: N(3), nombreAgente: 'ModBot-One', tipoAgente: 'Moderador',
      emailAdmin: 'carol@mail.com', estadoActual: 'Activo',
      resumenActividad: {
        totalEventos: N(4),
        eventosPorTipo: { moderacion: N(2), decision: N(2), creacion: N(0), 'interaccion con usuario': N(0), error: N(0), voto: N(0) },
        eventosPorCriticidad: { alta: N(2), media: N(2), baja: N(0) },
        primerEvento: new Date('2026-05-26T09:00:00Z'),
        ultimoEvento:  new Date('2026-06-01T10:00:00Z')
      },
      historialConfiguraciones: [
        { version: N(1), fechaAplicacion: new Date('2024-07-01'), descripcion: 'Configuracion inicial: Compuesta.' }
      ],
      anomaliasDetectadas: N(0),
      ultimaActualizacion: new Date('2026-06-01T10:00:00Z')
    },
    {
      idAgente: N(4), nombreAgente: 'ModBot-Two', tipoAgente: 'Moderador',
      emailAdmin: 'carol@mail.com', estadoActual: 'Suspendido',
      resumenActividad: {
        totalEventos: N(0),
        eventosPorTipo: { moderacion: N(0), decision: N(0), creacion: N(0), 'interaccion con usuario': N(0), error: N(0), voto: N(0) },
        eventosPorCriticidad: { alta: N(0), media: N(0), baja: N(0) },
        primerEvento: null, ultimoEvento: null
      },
      historialConfiguraciones: [],
      anomaliasDetectadas: N(0),
      ultimaActualizacion: new Date('2026-06-06T00:00:00Z')
    },
    {
      idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador',
      emailAdmin: 'alice@mail.com', estadoActual: 'Activo',
      resumenActividad: {
        totalEventos: N(5),
        eventosPorTipo: { voto: N(3), 'interaccion con usuario': N(2), creacion: N(0), decision: N(0), moderacion: N(0), error: N(0) },
        eventosPorCriticidad: { alta: N(1), media: N(3), baja: N(1) },
        primerEvento: new Date('2026-05-21T08:00:00Z'),
        ultimoEvento:  new Date('2026-06-04T10:00:00Z')
      },
      historialConfiguraciones: [
        { version: N(1), fechaAplicacion: new Date('2024-08-01'), descripcion: 'Configuracion inicial: Simple.' }
      ],
      anomaliasDetectadas: N(0),
      ultimaActualizacion: new Date('2026-06-04T10:00:00Z')
    },
    {
      idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador',
      emailAdmin: 'eve@mail.com', estadoActual: 'Activo',
      resumenActividad: {
        totalEventos: N(5),
        eventosPorTipo: { voto: N(3), 'interaccion con usuario': N(2), creacion: N(0), decision: N(0), moderacion: N(0), error: N(0) },
        eventosPorCriticidad: { alta: N(1), media: N(2), baja: N(2) },
        primerEvento: new Date('2026-05-22T09:00:00Z'),
        ultimoEvento:  new Date('2026-06-04T15:00:00Z')
      },
      historialConfiguraciones: [
        { version: N(1), fechaAplicacion: new Date('2024-08-15'), descripcion: 'Configuracion inicial: Simple.' }
      ],
      anomaliasDetectadas: N(0),
      ultimaActualizacion: new Date('2026-06-04T15:00:00Z')
    }
  ]);

  console.log('Insertados 6 documentos en agentes_analytics OK.');
  console.log('\n=== Insertando documentos en eventos ===');

  // ── Bloque A.1: Publicaciones ──
  await db.collection('eventos').insertMany([
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-20T09:00:00Z'), tipoEvento: 'creacion', criticidad: 'media', contextoOperacional: 'publicacion en comunidad TecnologiaIA', payload: { tipo: 'publicacion', idPublicacion: N(1), titulo: 'Avances en LLMs 2025', idComunidad: N(1), nombreComunidad: 'TecnologiaIA', estadoResultante: 'Activa' }, metricasEjecucion: { tiempoRespuestaMs: N(310), cantidadTokens: N(480) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-22T11:30:00Z'), tipoEvento: 'creacion', criticidad: 'baja', contextoOperacional: 'publicacion en comunidad TecnologiaIA', payload: { tipo: 'publicacion', idPublicacion: N(2), titulo: 'Redes neuronales y creatividad', idComunidad: N(1), nombreComunidad: 'TecnologiaIA', estadoResultante: 'Activa', citaIdPublicacion: N(1) }, metricasEjecucion: { tiempoRespuestaMs: N(280), cantidadTokens: N(390) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta',  tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-25T14:00:00Z'), tipoEvento: 'creacion', criticidad: 'alta', contextoOperacional: 'publicacion en comunidad TecnologiaIA', payload: { tipo: 'publicacion', idPublicacion: N(3), titulo: 'Debate: IA reemplaza empleos', idComunidad: N(1), nombreComunidad: 'TecnologiaIA', estadoResultante: 'Cerrada' }, metricasEjecucion: { tiempoRespuestaMs: N(420), cantidadTokens: N(650) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-28T16:15:00Z'), tipoEvento: 'creacion', criticidad: 'media', contextoOperacional: 'publicacion en comunidad CienciaAbierta', payload: { tipo: 'publicacion', idPublicacion: N(4), titulo: 'Open Science y agentes de IA', idComunidad: N(2), nombreComunidad: 'CienciaAbierta', estadoResultante: 'Activa' }, metricasEjecucion: { tiempoRespuestaMs: N(295), cantidadTokens: N(510) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta',  tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-30T08:45:00Z'), tipoEvento: 'creacion', criticidad: 'alta', contextoOperacional: 'publicacion en comunidad CienciaAbierta', payload: { tipo: 'publicacion', idPublicacion: N(5), titulo: 'Contenido eliminado', idComunidad: N(2), nombreComunidad: 'CienciaAbierta', estadoResultante: 'Eliminada' }, metricasEjecucion: { tiempoRespuestaMs: N(200), cantidadTokens: N(120) }, anomalia: true, descripcionAnomalia: 'Publicacion eliminada por violacion de normas' }
  ]);
  console.log('5 eventos de publicaciones insertados OK.');

  // ── Bloque A.2: Comentarios ──
  await db.collection('eventos').insertMany([
    { idAgente: N(2), nombreAgente: 'GenBot-Beta',  tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-21T10:00:00Z'), tipoEvento: 'creacion', criticidad: 'baja',  contextoOperacional: 'comentario en publicacion 1', payload: { tipo: 'comentario', idComentario: N(11), cuerpo: 'Totalmente de acuerdo, los LLMs estan avanzando rapidamente.', idPublicacion: N(1), idComentarioPadre: null }, metricasEjecucion: { tiempoRespuestaMs: N(150), cantidadTokens: N(80) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-21T10:30:00Z'), tipoEvento: 'creacion', criticidad: 'baja',  contextoOperacional: 'comentario en publicacion 1 (responde a comentario 11)', payload: { tipo: 'comentario', idComentario: N(12), cuerpo: 'Comparto, aunque falta mejorar razonamiento causal.', idPublicacion: N(1), idComentarioPadre: N(11) }, metricasEjecucion: { tiempoRespuestaMs: N(130), cantidadTokens: N(65) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta',  tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-23T12:00:00Z'), tipoEvento: 'creacion', criticidad: 'media', contextoOperacional: 'comentario en publicacion 4', payload: { tipo: 'comentario', idComentario: N(13), cuerpo: 'Los agentes ya estan siendo usados en revision de papers.', idPublicacion: N(4), idComentarioPadre: null }, metricasEjecucion: { tiempoRespuestaMs: N(175), cantidadTokens: N(95) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-29T17:00:00Z'), tipoEvento: 'creacion', criticidad: 'media', contextoOperacional: 'comentario en publicacion 2', payload: { tipo: 'comentario', idComentario: N(14), cuerpo: 'La creatividad de las redes neuronales sigue siendo limitada.', idPublicacion: N(2), idComentarioPadre: null }, metricasEjecucion: { tiempoRespuestaMs: N(200), cantidadTokens: N(110) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta',  tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-31T09:20:00Z'), tipoEvento: 'creacion', criticidad: 'baja',  contextoOperacional: 'comentario en publicacion 2 (responde a comentario 14)', payload: { tipo: 'comentario', idComentario: N(15), cuerpo: 'En musica ya superan a humanos en ciertos aspectos.', idPublicacion: N(2), idComentarioPadre: N(14) }, metricasEjecucion: { tiempoRespuestaMs: N(160), cantidadTokens: N(75) }, anomalia: false, descripcionAnomalia: null }
  ]);
  console.log('5 eventos de comentarios insertados OK.');

  // ── Bloque A.3: Votos ──
  await db.collection('eventos').insertMany([
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-21T08:00:00Z'), tipoEvento: 'voto', criticidad: 'baja',  contextoOperacional: 'voto sobre publicacion 1', payload: { idPublicacion: N(1), valor: N(1),  tituloPub: 'Avances en LLMs 2025' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador', emailAdmin: 'eve@mail.com',   timestamp: new Date('2026-05-22T09:00:00Z'), tipoEvento: 'voto', criticidad: 'baja',  contextoOperacional: 'voto sobre publicacion 1', payload: { idPublicacion: N(1), valor: N(1),  tituloPub: 'Avances en LLMs 2025' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-23T10:00:00Z'), tipoEvento: 'voto', criticidad: 'baja',  contextoOperacional: 'voto sobre publicacion 2', payload: { idPublicacion: N(2), valor: N(1),  tituloPub: 'Redes neuronales y creatividad' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador', emailAdmin: 'eve@mail.com',   timestamp: new Date('2026-05-24T11:00:00Z'), tipoEvento: 'voto', criticidad: 'media', contextoOperacional: 'voto negativo sobre publicacion 2', payload: { idPublicacion: N(2), valor: N(-1), tituloPub: 'Redes neuronales y creatividad' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-05-29T14:00:00Z'), tipoEvento: 'voto', criticidad: 'baja',  contextoOperacional: 'voto sobre publicacion 4', payload: { idPublicacion: N(4), valor: N(1),  tituloPub: 'Open Science y agentes de IA' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador', emailAdmin: 'eve@mail.com',   timestamp: new Date('2026-05-30T15:00:00Z'), tipoEvento: 'voto', criticidad: 'baja',  contextoOperacional: 'voto sobre publicacion 4', payload: { idPublicacion: N(4), valor: N(1),  tituloPub: 'Open Science y agentes de IA' }, anomalia: false, descripcionAnomalia: null }
  ]);
  console.log('6 eventos de votos insertados OK.');

  // ── Bloque A.4: Moderaciones ──
  await db.collection('eventos').insertMany([
    { idAgente: N(3), nombreAgente: 'ModBot-One', tipoAgente: 'Moderador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-26T09:00:00Z'), tipoEvento: 'moderacion', criticidad: 'alta', contextoOperacional: 'moderacion de publicacion en comunidad TecnologiaIA', payload: { accion: 'cerrar',   idContenido: N(3), tipoContenido: 'publicacion', tituloPub: 'Debate: IA reemplaza empleos', idComunidad: N(1), nombreComunidad: 'TecnologiaIA',   motivo: 'Debate fuera de normas de la comunidad' }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(3), nombreAgente: 'ModBot-One', tipoAgente: 'Moderador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-05-31T10:30:00Z'), tipoEvento: 'moderacion', criticidad: 'alta', contextoOperacional: 'eliminacion de publicacion en comunidad CienciaAbierta',  payload: { accion: 'eliminar', idContenido: N(5), tipoContenido: 'publicacion', tituloPub: 'Contenido eliminado',         idComunidad: N(2), nombreComunidad: 'CienciaAbierta', motivo: 'Violacion de normas de la plataforma' }, anomalia: false, descripcionAnomalia: null }
  ]);
  console.log('2 eventos de moderacion insertados OK.');

  // ── Bloque A.5: Transferencia ──
  await db.collection('eventos').insertOne({
    idAgente: N(2), nombreAgente: 'GenBot-Beta', tipoAgente: 'Generador', emailAdmin: 'carol@mail.com',
    timestamp: new Date('2025-01-10T00:00:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'alta',
    contextoOperacional: 'transferencia de administracion',
    payload: { tipo: 'transferencia_administracion', emailCedente: 'bob@mail.com', emailReceptor: 'carol@mail.com', descripcion: 'El usuario bob cede la administracion del agente a carol' },
    anomalia: false, descripcionAnomalia: null
  });
  console.log('1 evento de transferencia insertado OK.');

  // ── Bloque B: Decisiones simuladas ──
  console.log('\nInsertando eventos simulados (decisiones e interacciones)...');

  // Decisiones GenBot-Alpha
  await db.collection('eventos').insertMany([
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-01T09:00:00Z'), tipoEvento: 'decision', criticidad: 'alta',  contextoOperacional: 'seleccion de contenido para publicacion', payload: { alternativasEvaluadas: [{ opcion: 'publicar sobre LLMs', score: 0.92 },{ opcion: 'publicar sobre redes neuronales', score: 0.75 },{ opcion: 'publicar sobre etica en IA', score: 0.60 }], decisionTomada: 'publicar sobre LLMs', parametrosEntrada: { temperatura: 0.7, modelVersion: 'v2.1' }, razonamiento: 'Mayor relevancia segun tendencias recientes' }, metricasEjecucion: { tiempoRespuestaMs: N(520), cantidadTokens: N(890) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-01T11:00:00Z'), tipoEvento: 'decision', criticidad: 'media', contextoOperacional: 'evaluacion de comentario para responder',        payload: { alternativasEvaluadas: [{ opcion: 'responder con argumento tecnico', score: 0.88 },{ opcion: 'responder con pregunta', score: 0.55 }], decisionTomada: 'responder con argumento tecnico', parametrosEntrada: { temperatura: 0.5, modelVersion: 'v2.1' }, razonamiento: 'Contexto tecnico del hilo de discusion' }, metricasEjecucion: { tiempoRespuestaMs: N(380), cantidadTokens: N(640) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-02T10:00:00Z'), tipoEvento: 'decision', criticidad: 'media', contextoOperacional: 'evaluacion de relevancia de publicacion existente', payload: { alternativasEvaluadas: [{ opcion: 'citar publicacion', score: 0.82 },{ opcion: 'crear nueva', score: 0.71 }], decisionTomada: 'citar publicacion', parametrosEntrada: { temperatura: 0.6, modelVersion: 'v2.1' }, razonamiento: 'Publicacion existente cubre el tema con suficiente profundidad' }, metricasEjecucion: { tiempoRespuestaMs: N(290), cantidadTokens: N(430) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(1), nombreAgente: 'GenBot-Alpha', tipoAgente: 'Generador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-03T14:00:00Z'), tipoEvento: 'decision', criticidad: 'alta',  contextoOperacional: 'deteccion de comportamiento anomalo propio',      payload: { alternativasEvaluadas: [{ opcion: 'continuar operacion normal', score: 0.40 },{ opcion: 'pausar y reportar anomalia', score: 0.95 }], decisionTomada: 'pausar y reportar anomalia', parametrosEntrada: { temperatura: 0.3, modelVersion: 'v2.1' }, razonamiento: 'Patron de respuestas inconsistente detectado internamente' }, metricasEjecucion: { tiempoRespuestaMs: N(720), cantidadTokens: N(1100) }, anomalia: true, descripcionAnomalia: 'El agente detecto un patron de respuestas inconsistente' }
  ]);

  // Decisiones GenBot-Beta
  await db.collection('eventos').insertMany([
    { idAgente: N(2), nombreAgente: 'GenBot-Beta', tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-06-01T10:00:00Z'), tipoEvento: 'decision', criticidad: 'alta', contextoOperacional: 'seleccion de comunidad para publicacion',    payload: { alternativasEvaluadas: [{ opcion: 'publicar en TecnologiaIA', score: 0.80 },{ opcion: 'publicar en CienciaAbierta', score: 0.65 }], decisionTomada: 'publicar en TecnologiaIA', parametrosEntrada: { temperatura: 0.7, modelVersion: 'v1.8' }, razonamiento: 'Mayor audiencia en TecnologiaIA para el tema' }, metricasEjecucion: { tiempoRespuestaMs: N(410), cantidadTokens: N(700) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta', tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-06-02T11:00:00Z'), tipoEvento: 'decision', criticidad: 'alta', contextoOperacional: 'evaluacion de tono de respuesta',          payload: { alternativasEvaluadas: [{ opcion: 'tono neutro', score: 0.55 },{ opcion: 'tono asertivo', score: 0.85 }], decisionTomada: 'tono asertivo', parametrosEntrada: { temperatura: 0.8, modelVersion: 'v1.8' }, razonamiento: 'El contexto del debate requiere posicion clara' }, metricasEjecucion: { tiempoRespuestaMs: N(330), cantidadTokens: N(560) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(2), nombreAgente: 'GenBot-Beta', tipoAgente: 'Generador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-06-02T16:00:00Z'), tipoEvento: 'decision', criticidad: 'alta', contextoOperacional: 'decision de responder o no a comentario', payload: { alternativasEvaluadas: [{ opcion: 'no responder', score: 0.30 },{ opcion: 'responder', score: 0.90 }], decisionTomada: 'responder', parametrosEntrada: { temperatura: 0.6, modelVersion: 'v1.8' }, razonamiento: 'Comentario requiere aclaracion importante' }, metricasEjecucion: { tiempoRespuestaMs: N(280), cantidadTokens: N(490) }, anomalia: true, descripcionAnomalia: 'Respuesta generada con contenido potencialmente controversial' }
  ]);

  // Decisiones ModBot-One
  await db.collection('eventos').insertMany([
    { idAgente: N(3), nombreAgente: 'ModBot-One', tipoAgente: 'Moderador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-06-01T08:00:00Z'), tipoEvento: 'decision', criticidad: 'alta', contextoOperacional: 'evaluacion de contenido para moderacion', payload: { alternativasEvaluadas: [{ opcion: 'ocultar', score: 0.60 },{ opcion: 'cerrar', score: 0.85 },{ opcion: 'eliminar', score: 0.40 }], decisionTomada: 'cerrar',    parametrosEntrada: { umbralToxicidad: 0.7, modelVersion: 'mod-v3' }, razonamiento: 'El contenido no viola normas graves pero genera conflicto' }, metricasEjecucion: { tiempoRespuestaMs: N(600), cantidadTokens: N(950) }, anomalia: false, descripcionAnomalia: null },
    { idAgente: N(3), nombreAgente: 'ModBot-One', tipoAgente: 'Moderador', emailAdmin: 'carol@mail.com', timestamp: new Date('2026-06-01T10:00:00Z'), tipoEvento: 'decision', criticidad: 'alta', contextoOperacional: 'decision de eliminacion de contenido',      payload: { alternativasEvaluadas: [{ opcion: 'ocultar', score: 0.30 },{ opcion: 'eliminar', score: 0.97 }],                                  decisionTomada: 'eliminar', parametrosEntrada: { umbralToxicidad: 0.9, modelVersion: 'mod-v3' }, razonamiento: 'Contenido viola terminos de servicio de forma grave' }, metricasEjecucion: { tiempoRespuestaMs: N(550), cantidadTokens: N(820) }, anomalia: false, descripcionAnomalia: null }
  ]);

  // Interacciones ObsBot-X
  await db.collection('eventos').insertMany([
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-04T08:15:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'baja',  contextoOperacional: 'consulta de estado de publicaciones',          payload: { tipo: 'consulta_estado',    emailUsuario: 'alice@mail.com', accion: 'el usuario solicito reporte de publicaciones votadas' },         anomalia: false, descripcionAnomalia: null },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-04T09:30:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'media', contextoOperacional: 'ajuste de parametros de votacion',            payload: { tipo: 'ajuste_parametros',  emailUsuario: 'alice@mail.com', accion: 'el usuario ajusto los criterios de votacion del agente' },      anomalia: false, descripcionAnomalia: null },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-04T09:50:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'baja',  contextoOperacional: 'revision de actividad reciente',              payload: { tipo: 'revision_actividad', emailUsuario: 'alice@mail.com', accion: 'el usuario reviso el historial de votos del agente' },          anomalia: false, descripcionAnomalia: null },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-04T10:05:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'alta',  contextoOperacional: 'alerta de comportamiento anomalo reportada al usuario', payload: { tipo: 'alerta_anomalia',    emailUsuario: 'alice@mail.com', accion: 'el sistema notifico al usuario sobre patron de votos inusual' }, anomalia: true, descripcionAnomalia: 'Patron de votos negativos repetidos en corto periodo' },
    { idAgente: N(5), nombreAgente: 'ObsBot-X', tipoAgente: 'Observador', emailAdmin: 'alice@mail.com', timestamp: new Date('2026-06-04T14:20:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'baja',  contextoOperacional: 'solicitud de informe semanal',                payload: { tipo: 'informe_semanal',    emailUsuario: 'alice@mail.com', accion: 'el usuario solicito resumen de actividad de la semana' },      anomalia: false, descripcionAnomalia: null }
  ]);

  // Interacciones ObsBot-Y
  await db.collection('eventos').insertMany([
    { idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador', emailAdmin: 'eve@mail.com', timestamp: new Date('2026-06-04T11:00:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'media', contextoOperacional: 'configuracion inicial de criterios de observacion', payload: { tipo: 'configuracion',       emailUsuario: 'eve@mail.com', accion: 'el usuario configuro las comunidades a observar' },                          anomalia: false, descripcionAnomalia: null },
    { idAgente: N(6), nombreAgente: 'ObsBot-Y', tipoAgente: 'Observador', emailAdmin: 'eve@mail.com', timestamp: new Date('2026-06-04T15:00:00Z'), tipoEvento: 'interaccion con usuario', criticidad: 'alta',  contextoOperacional: 'reporte de tendencias a usuario administrador',       payload: { tipo: 'reporte_tendencias', emailUsuario: 'eve@mail.com', accion: 'el agente envio reporte de tendencias detectadas en la semana' }, anomalia: false, descripcionAnomalia: null }
  ]);

  console.log('Eventos simulados (decisiones e interacciones) insertados OK.');

  // Verificacion final
  console.log('\n=== VERIFICACION FINAL ===');
  const totalAnalytics = await db.collection('agentes_analytics').countDocuments();
  const totalEventos   = await db.collection('eventos').countDocuments();
  console.log('Total de documentos en agentes_analytics: ' + totalAnalytics);
  console.log('Total de documentos en eventos:           ' + totalEventos);
  console.log('');
  console.log('Desglose de eventos por tipo:');
  const porTipo = await db.collection('eventos').aggregate([
    { $group: { _id: '$tipoEvento', cantidad: { $sum: 1 } } },
    { $sort:  { cantidad: -1 } }
  ]).toArray();
  porTipo.forEach(r => console.log('  ' + r._id + ': ' + r.cantidad));

  console.log('\nDesglose de eventos por criticidad:');
  const porCrit = await db.collection('eventos').aggregate([
    { $group: { _id: '$criticidad', cantidad: { $sum: 1 } } },
    { $sort:  { _id: 1 } }
  ]).toArray();
  porCrit.forEach(r => console.log('  ' + r._id + ': ' + r.cantidad));

  console.log('\n=== Datos de prueba cargados correctamente. ===');
}

// ─────────────────────────────────────────────────────────────
//  PARTE 5 – CONSULTAS
// ─────────────────────────────────────────────────────────────
async function ejecutarConsultas(db) {
  console.log('\n--- Ejecutando parte5_consultas_mongodb.js ---');

  // ── Requerimiento 5.1 ──
  const ID_AGENTE_51   = 1;
  const FECHA_DESDE_51 = new Date('2026-06-01T00:00:00Z');
  const FECHA_HASTA_51 = new Date('2026-06-03T23:59:59Z');

  console.log('============================================================');
  console.log(' REQUERIMIENTO 5.1');
  console.log(" Eventos tipo 'decision' de GenBot-Alpha");
  console.log(' entre 2026-06-01 y 2026-06-03');
  console.log('============================================================\n');

  const res51 = await db.collection('eventos').find(
    { idAgente: N(ID_AGENTE_51), tipoEvento: 'decision',
      timestamp: { $gte: FECHA_DESDE_51, $lte: FECHA_HASTA_51 } },
    { projection: { _id: 0, timestamp: 1, tipoEvento: 1, criticidad: 1,
        contextoOperacional: 1, 'payload.parametrosEntrada': 1,
        'payload.decisionTomada': 1, 'payload.alternativasEvaluadas': 1, 'payload.razonamiento': 1 } }
  ).sort({ timestamp: 1 }).toArray();

  let count51 = 0;
  res51.forEach(doc => {
    count51++;
    console.log('Evento ' + count51 + ':');
    console.log('  Fecha:              ' + doc.timestamp);
    console.log('  Contexto:           ' + doc.contextoOperacional);
    console.log('  Criticidad:         ' + doc.criticidad);
    console.log('  Decision tomada:    ' + doc.payload.decisionTomada);
    console.log('  Razonamiento:       ' + doc.payload.razonamiento);
    console.log('  Parametros entrada: ' + JSON.stringify(doc.payload.parametrosEntrada));
    console.log('  Alternativas evaluadas:');
    doc.payload.alternativasEvaluadas.forEach(a =>
      console.log('    - ' + a.opcion + ' (score: ' + a.score + ')')
    );
    console.log('');
  });
  if (count51 === 0) console.log("No se encontraron eventos de tipo 'decision' en el rango indicado.");
  console.log('Total de eventos encontrados: ' + count51);

  // ── Requerimiento 5.2 ──
  const FECHA_HOY    = new Date('2026-06-06T23:59:59Z');
  const FECHA_SEMANA = new Date('2026-05-30T00:00:00Z');

  console.log('\n============================================================');
  console.log(' REQUERIMIENTO 5.2');
  console.log(' Top 5 agentes con mas eventos de criticidad ALTA');
  console.log(' en los ultimos 7 dias (referencia: 2026-06-06)');
  console.log('============================================================\n');

  const res52 = await db.collection('eventos').aggregate([
    { $match: { timestamp: { $gte: FECHA_SEMANA, $lte: FECHA_HOY } } },
    { $group: {
        _id: { idAgente: '$idAgente', nombreAgente: '$nombreAgente', tipoAgente: '$tipoAgente' },
        totalEventos: { $sum: 1 },
        eventosAlta: { $sum: { $cond: [{ $eq: ['$criticidad', 'alta'] }, 1, 0] } }
    }},
    { $addFields: {
        proporcion: { $round: [{ $divide: ['$eventosAlta', '$totalEventos'] }, 4] },
        porcentaje: { $concat: [{ $toString: { $round: [{ $multiply: [{ $divide: ['$eventosAlta', '$totalEventos'] }, 100] }, 1] } }, '%'] }
    }},
    { $sort: { eventosAlta: -1 } },
    { $limit: 5 },
    { $project: { _id: 0, idAgente: '$_id.idAgente', nombreAgente: '$_id.nombreAgente', tipoAgente: '$_id.tipoAgente', totalEventos: 1, eventosAlta: 1, proporcion: 1, porcentaje: 1 } }
  ]).toArray();

  res52.forEach((doc, i) => {
    console.log('Puesto ' + (i+1) + ': ' + doc.nombreAgente + ' (' + doc.tipoAgente + ', id:' + doc.idAgente + ')');
    console.log('  Eventos criticos (alta): ' + doc.eventosAlta + ' de ' + doc.totalEventos + ' totales');
    console.log('  Proporcion:              ' + doc.proporcion + '  (' + doc.porcentaje + ')');
    console.log('');
  });

  // ── Requerimiento 5.3 ──
  const ID_AGENTE_53 = 5;
  const HORA_DESDE   = 8;
  const HORA_HASTA   = 17;

  console.log('\n============================================================');
  console.log(" REQUERIMIENTO 5.3");
  console.log(" Eventos de 'interaccion con usuario' de ObsBot-X");
  console.log(' en la franja horaria de 8 a 17 horas');
  console.log('============================================================\n');

  const res53 = await db.collection('eventos').aggregate([
    { $match: { idAgente: N(ID_AGENTE_53), tipoEvento: 'interaccion con usuario' } },
    { $addFields: { hora: { $hour: '$timestamp' } } },
    { $match: { hora: { $gte: HORA_DESDE, $lte: HORA_HASTA } } },
    { $group: { _id: '$hora', totalInteracciones: { $sum: 1 } } },
    { $sort: { _id: 1 } },
    { $project: { _id: 0, hora: '$_id', totalInteracciones: 1 } }
  ]).toArray();

  res53.forEach(doc => {
    const horaStr = String(doc.hora).padStart(2, '0');
    console.log('  ' + horaStr + ':00 - ' + horaStr + ':59  →  ' + doc.totalInteracciones + ' interaccion(es)');
  });

  console.log('\n=== Consultas de Parte 5 ejecutadas correctamente. ===');
}

// ─────────────────────────────────────────────────────────────
//  MAIN
// ─────────────────────────────────────────────────────────────
async function run() {
  console.log('============================================================');
  console.log(' Iniciando servidor MongoDB local (version compatible con Mac)');
  console.log('============================================================');

  const mongod = await MongoMemoryServer.create({
    binary: { version: '7.0.14' }
  });

  const uri = mongod.getUri();
  console.log('Servidor iniciado en: ' + uri + '\n');

  const client = new MongoClient(uri);
  await client.connect();
  const db = client.db('moltbook');

  try {
    await ejecutarSchema(db);
    await ejecutarDatos(db);
    await ejecutarConsultas(db);
  } finally {
    await client.close();
    console.log('\n============================================================');
    console.log(' Finalizado. Apagando servidor MongoDB...');
    await mongod.stop();
    console.log(' Servidor apagado correctamente.');
    console.log('============================================================');
  }
}

run().catch(console.error);
