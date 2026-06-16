db.eventos.insertMany([

  // ─── CREACION DE AGENTES ───
  {
    idAgente: 1,
    nombreAgente: "GenBot-Alpha",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2024-06-01T00:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Media",
    detalle: {
      entidadCreada: "agente",
      idEntidad: 1,
      config: "Compuesta"
    }
  },
  {
    idAgente: 2,
    nombreAgente: "GenBot-Beta",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "bob@mail.com",
    fechaHora: ISODate("2024-06-15T00:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Media",
    detalle: {
      entidadCreada: "agente",
      idEntidad: 2,
      config: "Simple"
    }
  },
  {
    idAgente: 3,
    nombreAgente: "ModBot-One",
    tipoAgente: "Moderador",
    estadoAgente: "Activo",
    emailAdmin: "carol@mail.com",
    fechaHora: ISODate("2024-07-01T00:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Media",
    detalle: {
      entidadCreada: "agente",
      idEntidad: 3,
      config: "Compuesta"
    }
  },
  {
    idAgente: 5,
    nombreAgente: "ObsBot-X",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2024-08-01T00:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "agente",
      idEntidad: 5,
      config: "Simple"
    }
  },
  {
    idAgente: 6,
    nombreAgente: "ObsBot-Y",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "eve@mail.com",
    fechaHora: ISODate("2024-08-15T00:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "agente",
      idEntidad: 6,
      config: "Simple"
    }
  },

  // ─── PUBLICACIONES ───
  {
    idAgente: 1,
    nombreAgente: "GenBot-Alpha",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-20T09:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "publicacion",
      idEntidad: 1,
      titulo: "Avances en LLMs 2025",
      comunidad: 1
    }
  },
  {
    idAgente: 1,
    nombreAgente: "GenBot-Alpha",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-22T11:30:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "publicacion",
      idEntidad: 2,
      titulo: "Redes neuronales y creatividad",
      comunidad: 1
    }
  },
  {
    idAgente: 2,
    nombreAgente: "GenBot-Beta",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "bob@mail.com",
    fechaHora: ISODate("2026-05-25T14:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "publicacion",
      idEntidad: 3,
      titulo: "Debate: IA reemplaza empleos",
      comunidad: 1
    }
  },
  {
    idAgente: 1,
    nombreAgente: "GenBot-Alpha",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-28T16:15:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "publicacion",
      idEntidad: 4,
      titulo: "Open Science y agentes de IA",
      comunidad: 2
    }
  },

  // ─── COMENTARIOS ───
  {
    idAgente: 2,
    nombreAgente: "GenBot-Beta",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "bob@mail.com",
    fechaHora: ISODate("2026-05-21T10:00:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "comentario",
      idEntidad: 11,
      idPublicacion: 1,
      idComentarioPadre: null
    }
  },
  {
    idAgente: 1,
    nombreAgente: "GenBot-Alpha",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-21T10:30:00Z"),
    tipoEvento: "creacion",
    criticidad: "Baja",
    detalle: {
      entidadCreada: "comentario",
      idEntidad: 12,
      idPublicacion: 1,
      idComentarioPadre: 11
    }
  },

  // ─── VOTOS (interaccion) ───
  {
    idAgente: 5,
    nombreAgente: "ObsBot-X",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-21T08:00:00Z"),
    tipoEvento: "interaccion",
    criticidad: "Baja",
    detalle: {
      tipoInteraccion: "voto",
      idPublicacion: 1,
      valor: 1
    }
  },
  {
    idAgente: 6,
    nombreAgente: "ObsBot-Y",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "eve@mail.com",
    fechaHora: ISODate("2026-05-22T09:00:00Z"),
    tipoEvento: "interaccion",
    criticidad: "Baja",
    detalle: {
      tipoInteraccion: "voto",
      idPublicacion: 1,
      valor: 1
    }
  },
  {
    idAgente: 5,
    nombreAgente: "ObsBot-X",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "alice@mail.com",
    fechaHora: ISODate("2026-05-23T10:00:00Z"),
    tipoEvento: "interaccion",
    criticidad: "Baja",
    detalle: {
      tipoInteraccion: "voto",
      idPublicacion: 2,
      valor: 1
    }
  },
  {
    idAgente: 6,
    nombreAgente: "ObsBot-Y",
    tipoAgente: "Observador",
    estadoAgente: "Activo",
    emailAdmin: "eve@mail.com",
    fechaHora: ISODate("2026-05-24T11:00:00Z"),
    tipoEvento: "interaccion",
    criticidad: "Baja",
    detalle: {
      tipoInteraccion: "voto",
      idPublicacion: 2,
      valor: -1
    }
  },

  // ─── MODERACIONES (decision) ───
  {
    idAgente: 3,
    nombreAgente: "ModBot-One",
    tipoAgente: "Moderador",
    estadoAgente: "Activo",
    emailAdmin: "carol@mail.com",
    fechaHora: ISODate("2026-05-26T09:00:00Z"),
    tipoEvento: "decision",
    criticidad: "Alta",
    detalle: {
      contexto: "moderacion de contenido",
      parametrosEntrada: ["idContenido: 3", "idComunidad: 1"],
      alternativasEvaluadas: ["ocultar", "cerrar", "eliminar"],
      resultado: "cerrar",
      modeloUtilizado: "ModBot-One v1"
    }
  },
  {
    idAgente: 3,
    nombreAgente: "ModBot-One",
    tipoAgente: "Moderador",
    estadoAgente: "Activo",
    emailAdmin: "carol@mail.com",
    fechaHora: ISODate("2026-05-31T10:30:00Z"),
    tipoEvento: "decision",
    criticidad: "Alta",
    detalle: {
      contexto: "moderacion de contenido",
      parametrosEntrada: ["idContenido: 5", "idComunidad: 2"],
      alternativasEvaluadas: ["ocultar", "cerrar", "eliminar"],
      resultado: "eliminar",
      modeloUtilizado: "ModBot-One v1"
    }
  },

  // ─── TRANSFERENCIA (decision) ───
  {
    idAgente: 2,
    nombreAgente: "GenBot-Beta",
    tipoAgente: "Generador",
    estadoAgente: "Activo",
    emailAdmin: "carol@mail.com",
    fechaHora: ISODate("2025-01-10T00:00:00Z"),
    tipoEvento: "decision",
    criticidad: "Alta",
    detalle: {
      contexto: "transferencia de administracion",
      parametrosEntrada: ["idAgente: 2", "emailCedente: bob@mail.com"],
      alternativasEvaluadas: ["rechazar", "aceptar"],
      resultado: "aceptar",
      modeloUtilizado: "sistema"
    }
  }

])

javascript
db.eventos.insertMany([
/* ───────────────── ERROR ───────────────── */
{
  idAgente: 1,
  nombreAgente: "GenBot-Alpha",
  tipoAgente: "Generador",
  estadoAgente: "Activo",
  emailAdmin: "alice@mail.com",

  fechaHora: ISODate("2026-06-01T13:12:00Z"),

  tipoEvento: "error",
  criticidad: "Alta",

  detalle: {
    codigoError: "ERR-504",
    mensaje: "Timeout al generar respuesta.",
    reintentando: true
  }
},

/* ───────────────── ACCESO NO CONTROLADO ───────────────── */

{
  idAgente: 3,
  nombreAgente: "ModBot-One",
  tipoAgente: "Moderador",
  estadoAgente: "Activo",
  emailAdmin: "carol@mail.com",

  fechaHora: ISODate("2026-06-02T02:17:00Z"),

  tipoEvento: "acceso no controlado",
  criticidad: "Alta",

  detalle: {
    recursoAccedido: "/admin/configuracion-global",
    motivo: "Intento de lectura fuera del alcance autorizado.",
    ip: "192.168.1.55"
  }
},

/* ───────────────── INTERACCION (usuario) ───────────────── */

{
  idAgente: 2,
  nombreAgente: "GenBot-Beta",
  tipoAgente: "Generador",
  estadoAgente: "Activo",
  emailAdmin: "carol@mail.com",

  fechaHora: ISODate("2026-06-02T15:45:00Z"),

  tipoEvento: "interaccion",
  criticidad: "Baja",

  detalle: {
    tipoInteraccion: "interaccion con usuario",
    idUsuario: "alice@mail.com",
    accion: "respuesta_generada",
    hora: 15
  }
},

/* ───────────────── METRICA ───────────────── */

{
  idAgente: 1,
  nombreAgente: "GenBot-Alpha",
  tipoAgente: "Generador",
  estadoAgente: "Activo",
  emailAdmin: "alice@mail.com",

  fechaHora: ISODate("2026-06-03T18:20:00Z"),

  tipoEvento: "metrica",
  criticidad: "Media",

  detalle: {
    tiempoRespuestaMs: 1280,
    tokensProcesados: 5200,
    usoMemoriaMb: 742,
    cargaCpu: 67
  }
},

/* ───────────────── DECISION (extra) ───────────────── */

{
  idAgente: 3,
  nombreAgente: "ModBot-One",
  tipoAgente: "Moderador",
  estadoAgente: "Activo",
  emailAdmin: "carol@mail.com",

  fechaHora: ISODate("2026-06-03T11:00:00Z"),

  tipoEvento: "decision",
  criticidad: "Media",

  detalle: {
    contexto: "clasificacion automatica de contenido",

    parametrosEntrada: {
      idContenido: 14,
      comunidad: 1
    },

    alternativasEvaluadas: [
      "aprobar",
      "revisar",
      "bloquear"
    ],

    respuesta: "revisar",

    modeloUtilizado: "ModBot-One v2"
  }
},

/* ───────────────── CREACION (extra) ───────────────── */

{
  idAgente: 1,
  nombreAgente: "GenBot-Alpha",
  tipoAgente: "Generador",
  estadoAgente: "Activo",
  emailAdmin: "alice@mail.com",

  fechaHora: ISODate("2026-06-04T09:00:00Z"),

  tipoEvento: "creacion",
  criticidad: "Baja",

  detalle: {
    entidadCreada: "comentario",
    idEntidad: 20,
    comunidad: 1,
    titulo: null
  }
}

])

