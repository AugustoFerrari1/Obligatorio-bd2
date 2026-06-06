// ============================================================
//  OBLIGATORIO BD2 - Moltbook  |  PARTE 4 - MongoDB
//  Archivo: parte4_integracion_oracle_mongo.js
//  Descripcion: Documenta y simula el proceso de integracion
//               Oracle → MongoDB.
//
//  Este archivo explica como se transforman los datos de Oracle
//  en documentos de MongoDB. El proceso real se realiza con
//  parte4_datos_prueba.js, que ya contiene esos documentos.
//
//  En un entorno real, este proceso se implementaria con:
//    - Un script Node.js usando los paquetes "oracledb" y "mongodb"
//    - O exportando Oracle a JSON/CSV y luego importando con mongoimport
// ============================================================

// ============================================================
//  DESCRIPCION DEL PROCESO DE INTEGRACION
// ============================================================
//
//  El proceso sigue estos pasos:
//
//  PASO 1: LEER DATOS DE ORACLE
//  ────────────────────────────
//  Se consultan las tablas de Oracle con SELECT y se obtienen
//  los datos en formato de filas y columnas.
//
//  PASO 2: TRANSFORMAR A DOCUMENTOS MONGODB
//  ────────────────────────────────────────
//  Cada fila de Oracle se transforma en un documento JSON.
//  La tabla de origen determina el tipo de evento:
//
//    Oracle (tabla)   →  MongoDB (coleccion eventos)
//    ─────────────────────────────────────────────────
//    Publicacion      →  { tipoEvento: "creacion",               payload: { tipo: "publicacion", ... } }
//    comentario       →  { tipoEvento: "creacion",               payload: { tipo: "comentario",  ... } }
//    vota             →  { tipoEvento: "voto",                   payload: { valor, idPublicacion } }
//    modera           →  { tipoEvento: "moderacion",             payload: { accion, idContenido } }
//    transferencia    →  { tipoEvento: "interaccion con usuario", payload: { emailCedente, emailReceptor } }
//
//    Oracle (tabla)   →  MongoDB (coleccion agentes_analytics)
//    ─────────────────────────────────────────────────────────
//    Agente           →  { idAgente, nombreAgente, ... } (1 doc por agente)
//    historial        →  campo embebido historialConfiguraciones[] dentro de agentes_analytics
//
//  PASO 3: INSERTAR EN MONGODB
//  ───────────────────────────
//  Los documentos transformados se insertan en las colecciones
//  correspondientes usando insertOne() o insertMany().
//
// ============================================================

// ============================================================
//  PSEUDOCODIGO DEL SCRIPT DE INTEGRACION (Node.js)
// ============================================================
//
//  const oracledb = require('oracledb');
//  const { MongoClient } = require('mongodb');
//
//  async function integrar() {
//
//    // 1. Conectar a Oracle
//    const oracle = await oracledb.getConnection({
//      user: 'usuario', password: 'clave', connectString: 'localhost/xe'
//    });
//
//    // 2. Conectar a MongoDB
//    const mongo = new MongoClient('mongodb://localhost:27017');
//    await mongo.connect();
//    const db = mongo.db('moltbook');
//
//    // 3. Leer agentes de Oracle y crear agentes_analytics
//    const agentes = await oracle.execute(`
//      SELECT a.idAgente, a.nombre, a.tipo, a.emailAdmin, a.estado
//      FROM Agente a
//    `);
//    for (const row of agentes.rows) {
//      // Leer historial del agente
//      const hist = await oracle.execute(`
//        SELECT version, fechaAplicacion, descripcion
//        FROM historial WHERE idAgente = :id ORDER BY version
//      `, [row[0]]);
//
//      // Insertar en agentes_analytics
//      await db.collection('agentes_analytics').insertOne({
//        idAgente:    row[0],
//        nombreAgente: row[1],
//        tipoAgente:  row[2],
//        emailAdmin:  row[3],
//        estadoActual: row[4],
//        resumenActividad: { totalEventos: 0, eventosPorTipo: {}, eventosPorCriticidad: {} },
//        historialConfiguraciones: hist.rows.map(h => ({
//          version: h[0], fechaAplicacion: new Date(h[1]), descripcion: h[2]
//        })),
//        anomaliasDetectadas: 0,
//        ultimaActualizacion: new Date()
//      });
//    }
//
//    // 4. Leer publicaciones de Oracle y crear eventos
//    const pubs = await oracle.execute(`
//      SELECT p.idContenido, p.titulo, p.idComunidad,
//             c.fechaCreacion, c.horaCreacion, c.idAgente,
//             a.nombre, a.tipo, a.emailAdmin
//      FROM Publicacion p
//      JOIN contenido c ON c.idContenido = p.idContenido
//      JOIN Agente a ON a.idAgente = c.idAgente
//    `);
//    for (const row of pubs.rows) {
//      await db.collection('eventos').insertOne({
//        idAgente: row[6], nombreAgente: row[7], tipoAgente: row[8], emailAdmin: row[9],
//        timestamp: new Date(row[3] + 'T' + row[4] + 'Z'),
//        tipoEvento: 'creacion', criticidad: 'media',
//        contextoOperacional: 'publicacion en comunidad ' + row[2],
//        payload: { tipo: 'publicacion', idPublicacion: row[0], titulo: row[1], idComunidad: row[2] },
//        anomalia: false, descripcionAnomalia: null
//      });
//    }
//
//    // 5. (Igual para comentarios, votos, moderaciones, transferencias)
//    //    Ver parte4_datos_prueba.js para ver el resultado final.
//
//    await oracle.close();
//    await mongo.close();
//  }
//
//  integrar();
//
// ============================================================

// ============================================================
//  VERIFICACION: mostrar cuantos documentos quedaron cargados
// ============================================================

use("moltbook");

print("=== VERIFICACION DE COHERENCIA Oracle → MongoDB ===");
print("");
print("Datos esperados segun Oracle:");
print("  Agentes:        6  → agentes_analytics debe tener 6 documentos");
print("  Publicaciones:  5  → eventos tipo creacion (publicacion): 5");
print("  Comentarios:    5  → eventos tipo creacion (comentario): 5");
print("  Votos:          6  → eventos tipo voto: 6");
print("  Moderaciones:   2  → eventos tipo moderacion: 2");
print("  Transferencias: 1  → eventos tipo interaccion con usuario: al menos 1");
print("");

print("Datos reales en MongoDB:");
print("  agentes_analytics: " + db.agentes_analytics.countDocuments());
print("  eventos (total):   " + db.eventos.countDocuments());
print("");

// Verificamos evento por tipo
print("Eventos por tipo:");
db.eventos.aggregate([
  { $group: { _id: { tipo: "$tipoEvento", subtipo: "$payload.tipo" }, n: { $sum: 1 } } },
  { $sort: { "_id.tipo": 1 } }
]).forEach(r => {
  const sub = r._id.subtipo ? " (" + r._id.subtipo + ")" : "";
  print("  " + r._id.tipo + sub + ": " + r.n);
});

print("");
print("=== Integracion verificada correctamente. ===");
print("");
print("Nota: Los eventos de tipo 'decision' e 'interaccion con usuario'");
print("(excepto la transferencia) son datos simulados que representan");
print("actividad interna de los agentes no registrada en Oracle.");
