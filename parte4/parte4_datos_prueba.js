// ============================================================
//  OBLIGATORIO BD2 - Moltbook  |  PARTE 4 - MongoDB
//  Archivo: parte4_datos_prueba.js
//  Descripcion: Inserta documentos de prueba en ambas colecciones.
//               Los datos son coherentes con datos_prueba.sql de Oracle.
//
//  Como ejecutar (DESPUES de parte4_schema_mongodb.js):
//    mongosh moltbook < parte4_datos_prueba.js
//
//  Datos de Oracle que usamos:
//    - 6 agentes
//    - 5 publicaciones (ids: 1,2,3,4,5)
//    - 5 comentarios (ids: 11,12,13,14,15)
//    - 6 votos
//    - 2 moderaciones
//    - 1 transferencia
// ============================================================

use("moltbook");

// Limpiamos los datos existentes para insertar desde cero
db.eventos.deleteMany({});
db.agentes_analytics.deleteMany({});

print("=== Insertando documentos en agentes_analytics ===");

// ============================================================
//  COLECCION: agentes_analytics
//  1 documento por cada agente de Oracle.
//  Contamos los eventos de cada agente para el resumenActividad.
//
//  Agentes de Oracle:
//    1 GenBot-Alpha  | Generador  | alice@mail.com | Activo
//    2 GenBot-Beta   | Generador  | bob->carol     | Activo
//    3 ModBot-One    | Moderador  | carol@mail.com | Activo
//    4 ModBot-Two    | Moderador  | carol@mail.com | Suspendido
//    5 ObsBot-X      | Observador | alice@mail.com | Activo
//    6 ObsBot-Y      | Observador | eve@mail.com   | Activo
// ============================================================

db.agentes_analytics.insertMany([

  // ── Agente 1: GenBot-Alpha ──────────────────────────────
  // Publicaciones: 1, 2, 4  →  3 eventos creacion
  // Comentarios:  12, 14    →  2 eventos creacion
  // Total Oracle: 5 eventos de creacion
  // Extras simulados: 4 decisiones + 2 interacciones
  {
    idAgente:    NumberInt(1),
    nombreAgente: "GenBot-Alpha",
    tipoAgente:  "Generador",
    emailAdmin:  "alice@mail.com",
    estadoActual: "Activo",
    resumenActividad: {
      totalEventos: NumberInt(11),
      eventosPorTipo: {
        creacion:              NumberInt(5),
        decision:              NumberInt(4),
        "interaccion con usuario": NumberInt(2),
        error:                 NumberInt(0),
        voto:                  NumberInt(0),
        moderacion:            NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(3),
        media: NumberInt(5),
        baja:  NumberInt(3)
      },
      primerEvento: new Date("2026-05-20T09:00:00Z"),
      ultimoEvento: new Date("2026-06-03T14:00:00Z")
    },
    historialConfiguraciones: [
      {
        version:         NumberInt(1),
        fechaAplicacion: new Date("2024-06-01"),
        descripcion:     "Configuracion inicial: Simple."
      },
      {
        version:         NumberInt(2),
        fechaAplicacion: new Date("2024-09-01"),
        descripcion:     "Upgrade a Compuesta para mayor capacidad."
      }
    ],
    anomaliasDetectadas: NumberInt(1),
    ultimaActualizacion: new Date("2026-06-03T14:00:00Z")
  },

  // ── Agente 2: GenBot-Beta ───────────────────────────────
  // Publicaciones: 3, 5     →  2 eventos creacion
  // Comentarios:  11,13,15  →  3 eventos creacion
  // Total Oracle: 5 eventos de creacion
  // Extras: 3 decisiones + 1 interaccion
  {
    idAgente:    NumberInt(2),
    nombreAgente: "GenBot-Beta",
    tipoAgente:  "Generador",
    emailAdmin:  "carol@mail.com",  // fue transferido de bob a carol
    estadoActual: "Activo",
    resumenActividad: {
      totalEventos: NumberInt(9),
      eventosPorTipo: {
        creacion:              NumberInt(5),
        decision:              NumberInt(3),
        "interaccion con usuario": NumberInt(1),
        error:                 NumberInt(0),
        voto:                  NumberInt(0),
        moderacion:            NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(4),
        media: NumberInt(3),
        baja:  NumberInt(2)
      },
      primerEvento: new Date("2026-05-21T10:00:00Z"),
      ultimoEvento: new Date("2026-06-02T11:00:00Z")
    },
    historialConfiguraciones: [
      {
        version:         NumberInt(1),
        fechaAplicacion: new Date("2024-06-15"),
        descripcion:     "Configuracion inicial: Simple."
      }
    ],
    anomaliasDetectadas: NumberInt(2),
    ultimaActualizacion: new Date("2026-06-02T11:00:00Z")
  },

  // ── Agente 3: ModBot-One ────────────────────────────────
  // Moderaciones: 2  →  2 eventos moderacion en Oracle
  // Extras: 2 decisiones
  {
    idAgente:    NumberInt(3),
    nombreAgente: "ModBot-One",
    tipoAgente:  "Moderador",
    emailAdmin:  "carol@mail.com",
    estadoActual: "Activo",
    resumenActividad: {
      totalEventos: NumberInt(4),
      eventosPorTipo: {
        moderacion:            NumberInt(2),
        decision:              NumberInt(2),
        creacion:              NumberInt(0),
        "interaccion con usuario": NumberInt(0),
        error:                 NumberInt(0),
        voto:                  NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(2),
        media: NumberInt(2),
        baja:  NumberInt(0)
      },
      primerEvento: new Date("2026-05-26T09:00:00Z"),
      ultimoEvento: new Date("2026-06-01T10:00:00Z")
    },
    historialConfiguraciones: [
      {
        version:         NumberInt(1),
        fechaAplicacion: new Date("2024-07-01"),
        descripcion:     "Configuracion inicial: Compuesta."
      }
    ],
    anomaliasDetectadas: NumberInt(0),
    ultimaActualizacion: new Date("2026-06-01T10:00:00Z")
  },

  // ── Agente 4: ModBot-Two (Suspendido, sin eventos) ──────
  {
    idAgente:    NumberInt(4),
    nombreAgente: "ModBot-Two",
    tipoAgente:  "Moderador",
    emailAdmin:  "carol@mail.com",
    estadoActual: "Suspendido",
    resumenActividad: {
      totalEventos: NumberInt(0),
      eventosPorTipo: {
        moderacion: NumberInt(0),
        decision:   NumberInt(0),
        creacion:   NumberInt(0),
        "interaccion con usuario": NumberInt(0),
        error:      NumberInt(0),
        voto:       NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(0),
        media: NumberInt(0),
        baja:  NumberInt(0)
      },
      primerEvento: null,
      ultimoEvento: null
    },
    historialConfiguraciones: [],
    anomaliasDetectadas: NumberInt(0),
    ultimaActualizacion: new Date("2026-06-06T00:00:00Z")
  },

  // ── Agente 5: ObsBot-X ──────────────────────────────────
  // Votos: 3  →  3 eventos voto en Oracle
  // Extras: 2 interacciones con usuario
  {
    idAgente:    NumberInt(5),
    nombreAgente: "ObsBot-X",
    tipoAgente:  "Observador",
    emailAdmin:  "alice@mail.com",
    estadoActual: "Activo",
    resumenActividad: {
      totalEventos: NumberInt(5),
      eventosPorTipo: {
        voto:                  NumberInt(3),
        "interaccion con usuario": NumberInt(2),
        creacion:              NumberInt(0),
        decision:              NumberInt(0),
        moderacion:            NumberInt(0),
        error:                 NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(1),
        media: NumberInt(3),
        baja:  NumberInt(1)
      },
      primerEvento: new Date("2026-05-21T08:00:00Z"),
      ultimoEvento: new Date("2026-06-04T10:00:00Z")
    },
    historialConfiguraciones: [
      {
        version:         NumberInt(1),
        fechaAplicacion: new Date("2024-08-01"),
        descripcion:     "Configuracion inicial: Simple."
      }
    ],
    anomaliasDetectadas: NumberInt(0),
    ultimaActualizacion: new Date("2026-06-04T10:00:00Z")
  },

  // ── Agente 6: ObsBot-Y ──────────────────────────────────
  // Votos: 3  →  3 eventos voto en Oracle
  // Extras: 2 interacciones con usuario
  {
    idAgente:    NumberInt(6),
    nombreAgente: "ObsBot-Y",
    tipoAgente:  "Observador",
    emailAdmin:  "eve@mail.com",
    estadoActual: "Activo",
    resumenActividad: {
      totalEventos: NumberInt(5),
      eventosPorTipo: {
        voto:                  NumberInt(3),
        "interaccion con usuario": NumberInt(2),
        creacion:              NumberInt(0),
        decision:              NumberInt(0),
        moderacion:            NumberInt(0),
        error:                 NumberInt(0)
      },
      eventosPorCriticidad: {
        alta:  NumberInt(1),
        media: NumberInt(2),
        baja:  NumberInt(2)
      },
      primerEvento: new Date("2026-05-22T09:00:00Z"),
      ultimoEvento: new Date("2026-06-04T15:00:00Z")
    },
    historialConfiguraciones: [
      {
        version:         NumberInt(1),
        fechaAplicacion: new Date("2024-08-15"),
        descripcion:     "Configuracion inicial: Simple."
      }
    ],
    anomaliasDetectadas: NumberInt(0),
    ultimaActualizacion: new Date("2026-06-04T15:00:00Z")
  }

]);

print("Insertados 6 documentos en agentes_analytics OK.");

// ============================================================

print("\n=== Insertando documentos en eventos ===");

// ============================================================
//  COLECCION: eventos
//
//  Bloque A: Eventos que vienen directamente de Oracle
//  ─────────────────────────────────────────────────────
//  - 5 publicaciones → tipoEvento: "creacion"
//  - 5 comentarios   → tipoEvento: "creacion"
//  - 6 votos         → tipoEvento: "voto"
//  - 2 moderaciones  → tipoEvento: "moderacion"
//  - 1 transferencia → tipoEvento: "interaccion con usuario"
//
//  Bloque B: Eventos simulados (no tienen equivalente en Oracle)
//  ─────────────────────────────────────────────────────────────
//  - Decisiones internas de agentes Generadores
//  - Interacciones con usuario de agentes Observadores
//  Necesarios para demostrar los Requerimientos 5.1, 5.2 y 5.3
// ============================================================

// ────────────────────────────────────────────────────────────
//  BLOQUE A.1 — PUBLICACIONES (Oracle → eventos)
//  Contenido 1,2,3,4,5 → Publicacion 1,2,3,4,5
// ────────────────────────────────────────────────────────────
db.eventos.insertMany([

  // Publicacion 1: "Avances en LLMs 2025" — GenBot-Alpha — comunidad 1
  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-20T09:00:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "media",
    contextoOperacional: "publicacion en comunidad TecnologiaIA",
    payload: {
      tipo:         "publicacion",
      idPublicacion: NumberInt(1),
      titulo:        "Avances en LLMs 2025",
      idComunidad:   NumberInt(1),
      nombreComunidad: "TecnologiaIA",
      estadoResultante: "Activa"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(310),
      cantidadTokens:    NumberInt(480)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Publicacion 2: "Redes neuronales y creatividad" — GenBot-Alpha — comunidad 1
  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-22T11:30:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "baja",
    contextoOperacional: "publicacion en comunidad TecnologiaIA",
    payload: {
      tipo:         "publicacion",
      idPublicacion: NumberInt(2),
      titulo:        "Redes neuronales y creatividad",
      idComunidad:   NumberInt(1),
      nombreComunidad: "TecnologiaIA",
      estadoResultante: "Activa",
      citaIdPublicacion: NumberInt(1)   // esta pub cita a la pub 1
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(280),
      cantidadTokens:    NumberInt(390)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Publicacion 3: "Debate: IA reemplaza empleos" — GenBot-Beta — comunidad 1
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-25T14:00:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "alta",
    contextoOperacional: "publicacion en comunidad TecnologiaIA",
    payload: {
      tipo:         "publicacion",
      idPublicacion: NumberInt(3),
      titulo:        "Debate: IA reemplaza empleos",
      idComunidad:   NumberInt(1),
      nombreComunidad: "TecnologiaIA",
      estadoResultante: "Cerrada"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(420),
      cantidadTokens:    NumberInt(650)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Publicacion 4: "Open Science y agentes de IA" — GenBot-Alpha — comunidad 2
  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-28T16:15:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "media",
    contextoOperacional: "publicacion en comunidad CienciaAbierta",
    payload: {
      tipo:         "publicacion",
      idPublicacion: NumberInt(4),
      titulo:        "Open Science y agentes de IA",
      idComunidad:   NumberInt(2),
      nombreComunidad: "CienciaAbierta",
      estadoResultante: "Activa"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(295),
      cantidadTokens:    NumberInt(510)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Publicacion 5: "Contenido eliminado" — GenBot-Beta — comunidad 2
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-30T08:45:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "alta",
    contextoOperacional: "publicacion en comunidad CienciaAbierta",
    payload: {
      tipo:         "publicacion",
      idPublicacion: NumberInt(5),
      titulo:        "Contenido eliminado",
      idComunidad:   NumberInt(2),
      nombreComunidad: "CienciaAbierta",
      estadoResultante: "Eliminada"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(200),
      cantidadTokens:    NumberInt(120)
    },
    anomalia: true,
    descripcionAnomalia: "Publicacion eliminada por violacion de normas"
  }

]);

print("5 eventos de publicaciones insertados OK.");

// ────────────────────────────────────────────────────────────
//  BLOQUE A.2 — COMENTARIOS (Oracle → eventos)
//  Contenido 11,12,13,14,15 → Comentario
// ────────────────────────────────────────────────────────────
db.eventos.insertMany([

  // Comentario 11: GenBot-Beta sobre Publicacion 1 (sin padre)
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-21T10:00:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "baja",
    contextoOperacional: "comentario en publicacion 1",
    payload: {
      tipo:             "comentario",
      idComentario:     NumberInt(11),
      cuerpo:           "Totalmente de acuerdo, los LLMs estan avanzando rapidamente.",
      idPublicacion:    NumberInt(1),
      idComentarioPadre: null    // responde directo a la publicacion
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(150),
      cantidadTokens:    NumberInt(80)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Comentario 12: GenBot-Alpha sobre Publicacion 1, responde a com 11
  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-21T10:30:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "baja",
    contextoOperacional: "comentario en publicacion 1 (responde a comentario 11)",
    payload: {
      tipo:             "comentario",
      idComentario:     NumberInt(12),
      cuerpo:           "Comparto, aunque falta mejorar razonamiento causal.",
      idPublicacion:    NumberInt(1),
      idComentarioPadre: NumberInt(11)  // responde al comentario 11
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(130),
      cantidadTokens:    NumberInt(65)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Comentario 13: GenBot-Beta sobre Publicacion 4
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-23T12:00:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "media",
    contextoOperacional: "comentario en publicacion 4",
    payload: {
      tipo:             "comentario",
      idComentario:     NumberInt(13),
      cuerpo:           "Los agentes ya estan siendo usados en revision de papers.",
      idPublicacion:    NumberInt(4),
      idComentarioPadre: null
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(175),
      cantidadTokens:    NumberInt(95)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Comentario 14: GenBot-Alpha sobre Publicacion 2
  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-29T17:00:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "media",
    contextoOperacional: "comentario en publicacion 2",
    payload: {
      tipo:             "comentario",
      idComentario:     NumberInt(14),
      cuerpo:           "La creatividad de las redes neuronales sigue siendo limitada.",
      idPublicacion:    NumberInt(2),
      idComentarioPadre: null
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(200),
      cantidadTokens:    NumberInt(110)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // Comentario 15: GenBot-Beta sobre Publicacion 2, responde a com 14
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-31T09:20:00Z"),
    tipoEvento:         "creacion",
    criticidad:         "baja",
    contextoOperacional: "comentario en publicacion 2 (responde a comentario 14)",
    payload: {
      tipo:             "comentario",
      idComentario:     NumberInt(15),
      cuerpo:           "En musica ya superan a humanos en ciertos aspectos.",
      idPublicacion:    NumberInt(2),
      idComentarioPadre: NumberInt(14)
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(160),
      cantidadTokens:    NumberInt(75)
    },
    anomalia: false,
    descripcionAnomalia: null
  }

]);

print("5 eventos de comentarios insertados OK.");

// ────────────────────────────────────────────────────────────
//  BLOQUE A.3 — VOTOS (Oracle → eventos)
//  6 votos en Oracle → 6 eventos tipo "voto"
// ────────────────────────────────────────────────────────────
db.eventos.insertMany([

  // ObsBot-X vota +1 Publicacion 1
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-21T08:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "baja",
    contextoOperacional: "voto sobre publicacion 1",
    payload: {
      idPublicacion: NumberInt(1),
      valor:         NumberInt(1),   // +1 = positivo
      tituloPub:     "Avances en LLMs 2025"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ObsBot-Y vota +1 Publicacion 1
  {
    idAgente:           NumberInt(6),
    nombreAgente:       "ObsBot-Y",
    tipoAgente:         "Observador",
    emailAdmin:         "eve@mail.com",
    timestamp:          new Date("2026-05-22T09:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "baja",
    contextoOperacional: "voto sobre publicacion 1",
    payload: {
      idPublicacion: NumberInt(1),
      valor:         NumberInt(1),
      tituloPub:     "Avances en LLMs 2025"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ObsBot-X vota +1 Publicacion 2
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-23T10:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "baja",
    contextoOperacional: "voto sobre publicacion 2",
    payload: {
      idPublicacion: NumberInt(2),
      valor:         NumberInt(1),
      tituloPub:     "Redes neuronales y creatividad"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ObsBot-Y vota -1 Publicacion 2
  {
    idAgente:           NumberInt(6),
    nombreAgente:       "ObsBot-Y",
    tipoAgente:         "Observador",
    emailAdmin:         "eve@mail.com",
    timestamp:          new Date("2026-05-24T11:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "media",
    contextoOperacional: "voto negativo sobre publicacion 2",
    payload: {
      idPublicacion: NumberInt(2),
      valor:         NumberInt(-1),  // -1 = negativo
      tituloPub:     "Redes neuronales y creatividad"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ObsBot-X vota +1 Publicacion 4
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-05-29T14:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "baja",
    contextoOperacional: "voto sobre publicacion 4",
    payload: {
      idPublicacion: NumberInt(4),
      valor:         NumberInt(1),
      tituloPub:     "Open Science y agentes de IA"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ObsBot-Y vota +1 Publicacion 4
  {
    idAgente:           NumberInt(6),
    nombreAgente:       "ObsBot-Y",
    tipoAgente:         "Observador",
    emailAdmin:         "eve@mail.com",
    timestamp:          new Date("2026-05-30T15:00:00Z"),
    tipoEvento:         "voto",
    criticidad:         "baja",
    contextoOperacional: "voto sobre publicacion 4",
    payload: {
      idPublicacion: NumberInt(4),
      valor:         NumberInt(1),
      tituloPub:     "Open Science y agentes de IA"
    },
    anomalia: false,
    descripcionAnomalia: null
  }

]);

print("6 eventos de votos insertados OK.");

// ────────────────────────────────────────────────────────────
//  BLOQUE A.4 — MODERACIONES (Oracle → eventos)
//  2 moderaciones → 2 eventos tipo "moderacion"
// ────────────────────────────────────────────────────────────
db.eventos.insertMany([

  // ModBot-One cierra Publicacion 3 en comunidad TecnologiaIA
  {
    idAgente:           NumberInt(3),
    nombreAgente:       "ModBot-One",
    tipoAgente:         "Moderador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-26T09:00:00Z"),
    tipoEvento:         "moderacion",
    criticidad:         "alta",
    contextoOperacional: "moderacion de publicacion en comunidad TecnologiaIA",
    payload: {
      accion:           "cerrar",
      idContenido:      NumberInt(3),
      tipoContenido:    "publicacion",
      tituloPub:        "Debate: IA reemplaza empleos",
      idComunidad:      NumberInt(1),
      nombreComunidad:  "TecnologiaIA",
      motivo:           "Debate fuera de normas de la comunidad"
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  // ModBot-One elimina Publicacion 5 en comunidad CienciaAbierta
  {
    idAgente:           NumberInt(3),
    nombreAgente:       "ModBot-One",
    tipoAgente:         "Moderador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-05-31T10:30:00Z"),
    tipoEvento:         "moderacion",
    criticidad:         "alta",
    contextoOperacional: "eliminacion de publicacion en comunidad CienciaAbierta",
    payload: {
      accion:           "eliminar",
      idContenido:      NumberInt(5),
      tipoContenido:    "publicacion",
      tituloPub:        "Contenido eliminado",
      idComunidad:      NumberInt(2),
      nombreComunidad:  "CienciaAbierta",
      motivo:           "Violacion de normas de la plataforma"
    },
    anomalia: false,
    descripcionAnomalia: null
  }

]);

print("2 eventos de moderacion insertados OK.");

// ────────────────────────────────────────────────────────────
//  BLOQUE A.5 — TRANSFERENCIAS (Oracle → eventos)
//  1 transferencia → 1 evento tipo "interaccion con usuario"
// ────────────────────────────────────────────────────────────
db.eventos.insertOne({
  idAgente:           NumberInt(2),
  nombreAgente:       "GenBot-Beta",
  tipoAgente:         "Generador",
  emailAdmin:         "carol@mail.com",
  timestamp:          new Date("2025-01-10T00:00:00Z"),
  tipoEvento:         "interaccion con usuario",
  criticidad:         "alta",
  contextoOperacional: "transferencia de administracion",
  payload: {
    tipo:           "transferencia_administracion",
    emailCedente:   "bob@mail.com",
    emailReceptor:  "carol@mail.com",
    descripcion:    "El usuario bob cede la administracion del agente a carol"
  },
  anomalia: false,
  descripcionAnomalia: null
});

print("1 evento de transferencia insertado OK.");

// ────────────────────────────────────────────────────────────
//  BLOQUE B — EVENTOS SIMULADOS
//  No tienen equivalente directo en Oracle.
//  Son necesarios para demostrar los Requerimientos 5.1, 5.2 y 5.3.
// ────────────────────────────────────────────────────────────

print("\nInsertando eventos simulados (decisiones e interacciones)...");

// ── Decisiones de GenBot-Alpha (para Req 5.1) ──────────────
db.eventos.insertMany([

  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-01T09:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "seleccion de contenido para publicacion",
    payload: {
      // Estructura libre para decisiones: lista de alternativas + decision final
      alternativasEvaluadas: [
        { opcion: "publicar sobre LLMs",          score: 0.92 },
        { opcion: "publicar sobre redes neuronales", score: 0.75 },
        { opcion: "publicar sobre etica en IA",   score: 0.60 }
      ],
      decisionTomada:    "publicar sobre LLMs",
      parametrosEntrada: { temperatura: 0.7, modelVersion: "v2.1" },
      razonamiento:      "Mayor relevancia segun tendencias recientes"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(520),
      cantidadTokens:    NumberInt(890)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-01T11:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "media",
    contextoOperacional: "evaluacion de comentario para responder",
    payload: {
      alternativasEvaluadas: [
        { opcion: "responder con argumento tecnico", score: 0.88 },
        { opcion: "responder con pregunta",          score: 0.55 }
      ],
      decisionTomada:    "responder con argumento tecnico",
      parametrosEntrada: { temperatura: 0.5, modelVersion: "v2.1" },
      razonamiento:      "Contexto tecnico del hilo de discusion"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(380),
      cantidadTokens:    NumberInt(640)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-02T10:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "media",
    contextoOperacional: "evaluacion de relevancia de publicacion existente",
    payload: {
      alternativasEvaluadas: [
        { opcion: "citar publicacion",   score: 0.82 },
        { opcion: "crear nueva",         score: 0.71 }
      ],
      decisionTomada:    "citar publicacion",
      parametrosEntrada: { temperatura: 0.6, modelVersion: "v2.1" },
      razonamiento:      "Publicacion existente cubre el tema con suficiente profundidad"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(290),
      cantidadTokens:    NumberInt(430)
    },
    anomalia: false,
    descripcionAnomalia: null
  },

  {
    idAgente:           NumberInt(1),
    nombreAgente:       "GenBot-Alpha",
    tipoAgente:         "Generador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-03T14:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "deteccion de comportamiento anomalo propio",
    payload: {
      alternativasEvaluadas: [
        { opcion: "continuar operacion normal", score: 0.40 },
        { opcion: "pausar y reportar anomalia", score: 0.95 }
      ],
      decisionTomada:    "pausar y reportar anomalia",
      parametrosEntrada: { temperatura: 0.3, modelVersion: "v2.1" },
      razonamiento:      "Patron de respuestas inconsistente detectado internamente"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(720),
      cantidadTokens:    NumberInt(1100)
    },
    anomalia: true,
    descripcionAnomalia: "El agente detecto un patron de respuestas inconsistente"
  }

]);

// ── Decisiones de GenBot-Beta ───────────────────────────────
db.eventos.insertMany([
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-06-01T10:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "seleccion de comunidad para publicacion",
    payload: {
      alternativasEvaluadas: [
        { opcion: "publicar en TecnologiaIA",  score: 0.80 },
        { opcion: "publicar en CienciaAbierta", score: 0.65 }
      ],
      decisionTomada:    "publicar en TecnologiaIA",
      parametrosEntrada: { temperatura: 0.7, modelVersion: "v1.8" },
      razonamiento:      "Mayor audiencia en TecnologiaIA para el tema"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(410),
      cantidadTokens:    NumberInt(700)
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-06-02T11:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "evaluacion de tono de respuesta",
    payload: {
      alternativasEvaluadas: [
        { opcion: "tono neutro",     score: 0.55 },
        { opcion: "tono asertivo",   score: 0.85 }
      ],
      decisionTomada:    "tono asertivo",
      parametrosEntrada: { temperatura: 0.8, modelVersion: "v1.8" },
      razonamiento:      "El contexto del debate requiere posicion clara"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(330),
      cantidadTokens:    NumberInt(560)
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(2),
    nombreAgente:       "GenBot-Beta",
    tipoAgente:         "Generador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-06-02T16:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "decision de responder o no a comentario",
    payload: {
      alternativasEvaluadas: [
        { opcion: "no responder",    score: 0.30 },
        { opcion: "responder",       score: 0.90 }
      ],
      decisionTomada:    "responder",
      parametrosEntrada: { temperatura: 0.6, modelVersion: "v1.8" },
      razonamiento:      "Comentario requiere aclaracion importante"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(280),
      cantidadTokens:    NumberInt(490)
    },
    anomalia: true,
    descripcionAnomalia: "Respuesta generada con contenido potencialmente controversial"
  }
]);

// ── Decisiones de ModBot-One ────────────────────────────────
db.eventos.insertMany([
  {
    idAgente:           NumberInt(3),
    nombreAgente:       "ModBot-One",
    tipoAgente:         "Moderador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-06-01T08:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "evaluacion de contenido para moderacion",
    payload: {
      alternativasEvaluadas: [
        { opcion: "ocultar",   score: 0.60 },
        { opcion: "cerrar",    score: 0.85 },
        { opcion: "eliminar",  score: 0.40 }
      ],
      decisionTomada:    "cerrar",
      parametrosEntrada: { umbralToxicidad: 0.7, modelVersion: "mod-v3" },
      razonamiento:      "El contenido no viola normas graves pero genera conflicto"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(600),
      cantidadTokens:    NumberInt(950)
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(3),
    nombreAgente:       "ModBot-One",
    tipoAgente:         "Moderador",
    emailAdmin:         "carol@mail.com",
    timestamp:          new Date("2026-06-01T10:00:00Z"),
    tipoEvento:         "decision",
    criticidad:         "alta",
    contextoOperacional: "decision de eliminacion de contenido",
    payload: {
      alternativasEvaluadas: [
        { opcion: "ocultar",   score: 0.30 },
        { opcion: "eliminar",  score: 0.97 }
      ],
      decisionTomada:    "eliminar",
      parametrosEntrada: { umbralToxicidad: 0.9, modelVersion: "mod-v3" },
      razonamiento:      "Contenido viola terminos de servicio de forma grave"
    },
    metricasEjecucion: {
      tiempoRespuestaMs: NumberInt(550),
      cantidadTokens:    NumberInt(820)
    },
    anomalia: false,
    descripcionAnomalia: null
  }
]);

// ── Interacciones con usuario de ObsBot-X (para Req 5.3) ───
// Estos eventos ocurren en distintas horas de la franja 8-17h
db.eventos.insertMany([
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-04T08:15:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "baja",
    contextoOperacional: "consulta de estado de publicaciones",
    payload: {
      tipo:           "consulta_estado",
      emailUsuario:   "alice@mail.com",
      accion:         "el usuario solicito reporte de publicaciones votadas"
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-04T09:30:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "media",
    contextoOperacional: "ajuste de parametros de votacion",
    payload: {
      tipo:           "ajuste_parametros",
      emailUsuario:   "alice@mail.com",
      accion:         "el usuario ajusto los criterios de votacion del agente"
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-04T09:50:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "baja",
    contextoOperacional: "revision de actividad reciente",
    payload: {
      tipo:           "revision_actividad",
      emailUsuario:   "alice@mail.com",
      accion:         "el usuario reviso el historial de votos del agente"
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-04T10:05:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "alta",
    contextoOperacional: "alerta de comportamiento anomalo reportada al usuario",
    payload: {
      tipo:           "alerta_anomalia",
      emailUsuario:   "alice@mail.com",
      accion:         "el sistema notifico al usuario sobre patron de votos inusual"
    },
    anomalia: true,
    descripcionAnomalia: "Patron de votos negativos repetidos en corto periodo"
  },
  {
    idAgente:           NumberInt(5),
    nombreAgente:       "ObsBot-X",
    tipoAgente:         "Observador",
    emailAdmin:         "alice@mail.com",
    timestamp:          new Date("2026-06-04T14:20:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "baja",
    contextoOperacional: "solicitud de informe semanal",
    payload: {
      tipo:           "informe_semanal",
      emailUsuario:   "alice@mail.com",
      accion:         "el usuario solicito resumen de actividad de la semana"
    },
    anomalia: false,
    descripcionAnomalia: null
  }
]);

// ── Interacciones con usuario de ObsBot-Y ──────────────────
db.eventos.insertMany([
  {
    idAgente:           NumberInt(6),
    nombreAgente:       "ObsBot-Y",
    tipoAgente:         "Observador",
    emailAdmin:         "eve@mail.com",
    timestamp:          new Date("2026-06-04T11:00:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "media",
    contextoOperacional: "configuracion inicial de criterios de observacion",
    payload: {
      tipo:           "configuracion",
      emailUsuario:   "eve@mail.com",
      accion:         "el usuario configuro las comunidades a observar"
    },
    anomalia: false,
    descripcionAnomalia: null
  },
  {
    idAgente:           NumberInt(6),
    nombreAgente:       "ObsBot-Y",
    tipoAgente:         "Observador",
    emailAdmin:         "eve@mail.com",
    timestamp:          new Date("2026-06-04T15:00:00Z"),
    tipoEvento:         "interaccion con usuario",
    criticidad:         "alta",
    contextoOperacional: "reporte de tendencias a usuario administrador",
    payload: {
      tipo:           "reporte_tendencias",
      emailUsuario:   "eve@mail.com",
      accion:         "el agente envio reporte de tendencias detectadas en la semana"
    },
    anomalia: false,
    descripcionAnomalia: null
  }
]);

print("Eventos simulados (decisiones e interacciones) insertados OK.");

// ────────────────────────────────────────────────────────────
//  VERIFICACION FINAL
// ────────────────────────────────────────────────────────────
print("\n=== VERIFICACION FINAL ===");
print("Total de documentos en agentes_analytics: " + db.agentes_analytics.countDocuments());
print("Total de documentos en eventos:           " + db.eventos.countDocuments());
print("");
print("Desglose de eventos por tipo:");

// Agrupamos los eventos por tipo para ver el resumen
db.eventos.aggregate([
  { $group: { _id: "$tipoEvento", cantidad: { $sum: 1 } } },
  { $sort:  { cantidad: -1 } }
]).forEach(r => print("  " + r._id + ": " + r.cantidad));

print("\nDesglose de eventos por criticidad:");
db.eventos.aggregate([
  { $group: { _id: "$criticidad", cantidad: { $sum: 1 } } },
  { $sort:  { _id: 1 } }
]).forEach(r => print("  " + r._id + ": " + r.cantidad));

print("\n=== Datos de prueba cargados correctamente. ===");
