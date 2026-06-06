// ============================================================
//  OBLIGATORIO BD2 - Moltbook  |  PARTE 4 - MongoDB
//  Archivo: parte4_schema_mongodb.js
//  Descripcion: Crea las 2 colecciones con sus schema validators
//
//  Como ejecutar:
//    mongosh moltbook < parte4_schema_mongodb.js
//  (Si la base de datos "moltbook" no existe, MongoDB la crea sola)
// ============================================================

// Nos conectamos a la base de datos del proyecto
use("moltbook");

// ============================================================
//  Si las colecciones ya existen, las borramos para empezar limpio
// ============================================================
db.eventos.drop();
db.agentes_analytics.drop();

print("=== Creando coleccion: eventos ===");

// ============================================================
//  COLECCION 1: eventos
//
//  Guarda UN DOCUMENTO por cada cosa que hace un agente:
//    - crear una publicacion
//    - crear un comentario
//    - emitir un voto
//    - moderar contenido
//    - tomar una decision interna
//    - interactuar con un usuario humano
//    - etc.
//
//  El campo "payload" es LIBRE: cada tipo de evento puede tener
//  campos distintos dentro de ese objeto. Esto permite agregar
//  nuevos tipos de eventos sin cambiar el schema.
// ============================================================
db.createCollection("eventos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      title: "Validacion de eventos",
      // Campos que SIEMPRE deben estar en todo evento
      required: ["idAgente", "nombreAgente", "tipoAgente", "emailAdmin",
                 "timestamp", "tipoEvento", "criticidad", "payload"],
      properties: {

        // ID del agente en Oracle (para cruzar datos si hace falta)
        idAgente: {
          bsonType: "int",
          description: "ID del agente en Oracle. Obligatorio."
        },

        // Nombre del agente (copiado de Oracle para no tener que hacer join)
        nombreAgente: {
          bsonType: "string",
          description: "Nombre del agente. Obligatorio."
        },

        // Tipo de agente: Generador, Moderador u Observador
        tipoAgente: {
          bsonType: "string",
          enum: ["Generador", "Moderador", "Observador"],
          description: "Tipo del agente. Debe ser Generador, Moderador u Observador."
        },

        // Email del usuario humano que administra el agente
        emailAdmin: {
          bsonType: "string",
          description: "Email del administrador humano del agente. Obligatorio."
        },

        // Fecha y hora exacta del evento
        timestamp: {
          bsonType: "date",
          description: "Fecha y hora del evento. Obligatorio."
        },

        // Tipo de evento: define que hizo el agente
        // No es un enum cerrado porque pueden aparecer nuevos tipos en el futuro.
        // Los tipos conocidos son: creacion, voto, moderacion, decision,
        //   interaccion con usuario, error, acceso
        tipoEvento: {
          bsonType: "string",
          description: "Tipo del evento. Ej: creacion, voto, decision, error, etc. Obligatorio."
        },

        // Nivel de importancia del evento
        criticidad: {
          bsonType: "string",
          enum: ["alta", "media", "baja"],
          description: "Criticidad del evento: alta, media o baja. Obligatorio."
        },

        // Descripcion del contexto operacional (en que parte del sistema ocurrio)
        contextoOperacional: {
          bsonType: "string",
          description: "Contexto en el que ocurrio el evento. Opcional."
        },

        // Datos especificos del evento. Su estructura varia segun tipoEvento.
        // No se valida su interior porque es intencionalmente flexible.
        payload: {
          bsonType: "object",
          description: "Datos del evento. Su estructura depende del tipoEvento."
        },

        // Metricas de ejecucion (tiempo, tokens, memoria). Opcional.
        metricasEjecucion: {
          bsonType: "object",
          description: "Metricas de ejecucion del agente durante el evento. Opcional.",
          properties: {
            tiempoRespuestaMs: { bsonType: "int" },
            cantidadTokens:    { bsonType: "int" },
            memoriaUsadaMb:    { bsonType: "int" }
          }
        },

        // Indica si el evento fue detectado como anomalo
        anomalia: {
          bsonType: "bool",
          description: "True si el evento fue marcado como anomalo. Opcional."
        },

        // Descripcion de la anomalia si anomalia = true
        descripcionAnomalia: {
          bsonType: ["string", "null"],
          description: "Descripcion de la anomalia si aplica."
        }
      }
    }
  },
  // Que hacer si un documento no cumple el schema:
  // "error" -> rechaza la insercion (mas estricto)
  // "warn"  -> lo inserta igual pero escribe un warning
  validationAction: "error"
});

print("Coleccion 'eventos' creada con validator OK.");

// Creamos los indices para hacer las consultas rapido
// Sin indices, MongoDB tendria que leer todos los documentos para filtrar

// Indice compuesto: buscar eventos de un agente ordenados por fecha
db.eventos.createIndex({ idAgente: 1, timestamp: -1 });

// Indice para filtrar por criticidad y fecha (Requerimiento 5.2)
db.eventos.createIndex({ criticidad: 1, timestamp: -1 });

// Indice para filtrar por tipo de evento (Requerimiento 5.1 y 5.3)
db.eventos.createIndex({ tipoEvento: 1, timestamp: -1 });

// Indice para ordenar todos los eventos por fecha (vista general)
db.eventos.createIndex({ timestamp: -1 });

print("Indices de 'eventos' creados OK.");

// ============================================================

print("\n=== Creando coleccion: agentes_analytics ===");

// ============================================================
//  COLECCION 2: agentes_analytics
//
//  Guarda UN DOCUMENTO por cada agente con un resumen de su actividad.
//
//  Por que tener esta coleccion ademas de "eventos"?
//  Si quisieramos saber "cuantos eventos de criticidad alta tiene cada agente"
//  tendriamos que recorrer miles de eventos en "eventos".
//  Con esta coleccion, la respuesta ya esta calculada y es instantanea.
//
//  Esta tecnica se llama "Computed Pattern" en MongoDB.
// ============================================================
db.createCollection("agentes_analytics", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      title: "Validacion de agentes_analytics",
      required: ["idAgente", "nombreAgente", "tipoAgente", "emailAdmin",
                 "estadoActual", "resumenActividad"],
      properties: {

        idAgente: {
          bsonType: "int",
          description: "ID del agente en Oracle. Obligatorio y unico."
        },

        nombreAgente: {
          bsonType: "string",
          description: "Nombre del agente."
        },

        tipoAgente: {
          bsonType: "string",
          enum: ["Generador", "Moderador", "Observador"]
        },

        emailAdmin: {
          bsonType: "string",
          description: "Email del administrador actual del agente."
        },

        estadoActual: {
          bsonType: "string",
          enum: ["Activo", "Suspendido"],
          description: "Estado del agente."
        },

        // Resumen de actividad pre-calculado
        resumenActividad: {
          bsonType: "object",
          required: ["totalEventos", "eventosPorTipo", "eventosPorCriticidad"],
          properties: {
            totalEventos:          { bsonType: "int" },
            eventosPorTipo:        { bsonType: "object" },
            eventosPorCriticidad:  { bsonType: "object" },
            primerEvento:          { bsonType: ["date", "null"] },
            ultimoEvento:          { bsonType: ["date", "null"] }
          }
        },

        // Historial de configuraciones del agente (copiado de Oracle)
        // Es un array de objetos embebidos (no es una coleccion separada)
        historialConfiguraciones: {
          bsonType: "array",
          description: "Historial de configuraciones del agente desde Oracle.",
          items: {
            bsonType: "object",
            required: ["version", "fechaAplicacion", "descripcion"],
            properties: {
              version:         { bsonType: "int" },
              fechaAplicacion: { bsonType: "date" },
              descripcion:     { bsonType: "string" }
            }
          }
        },

        anomaliasDetectadas: {
          bsonType: "int",
          description: "Cantidad total de anomalias detectadas para este agente."
        },

        ultimaActualizacion: {
          bsonType: "date",
          description: "Fecha de la ultima actualizacion de este documento."
        }
      }
    }
  },
  validationAction: "error"
});

print("Coleccion 'agentes_analytics' creada con validator OK.");

// Un solo indice: buscar por idAgente (debe ser unico, 1 doc por agente)
db.agentes_analytics.createIndex({ idAgente: 1 }, { unique: true });

// Indice para el ranking de criticidad alta (Requerimiento 5.2)
db.agentes_analytics.createIndex({ "resumenActividad.eventosPorCriticidad.alta": -1 });

print("Indices de 'agentes_analytics' creados OK.");

print("\n=== Listo! Ambas colecciones creadas correctamente. ===");
print("Podes verificar con: db.getCollectionNames()");
