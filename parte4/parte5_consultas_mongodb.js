// ============================================================
//  OBLIGATORIO BD2 - Moltbook  |  PARTE 5 - MongoDB
//  Archivo: parte5_consultas_mongodb.js
//  Descripcion: Las 3 consultas requeridas para la Parte 5.
//
//  Como ejecutar (DESPUES de cargar los datos de prueba):
//    mongosh moltbook < parte5_consultas_mongodb.js
//
//  Requerimientos:
//    5.1 - Eventos tipo "decision" de un agente en rango de fechas
//    5.2 - Top 5 agentes con mas eventos de criticidad "alta" en la ultima semana
//    5.3 - Eventos de "interaccion con usuario" de un agente agrupados por hora
// ============================================================

use("moltbook");

// ============================================================
//  REQUERIMIENTO 5.1
//  Dado un agente y un rango de fechas, retornar la lista
//  cronologica de todos los eventos de tipo "decision"
//  registrados para ese agente, incluyendo el contexto
//  operacional y los parametros de entrada utilizados.
//
//  Parametros que se pueden cambiar:
//    - ID_AGENTE:    id del agente a consultar
//    - FECHA_DESDE:  inicio del rango de fechas
//    - FECHA_HASTA:  fin del rango de fechas
// ============================================================

print("============================================================");
print(" REQUERIMIENTO 5.1");
print(" Eventos tipo 'decision' de GenBot-Alpha");
print(" entre 2026-06-01 y 2026-06-03");
print("============================================================\n");

// Parametros de la consulta
const ID_AGENTE_51   = 1;                          // GenBot-Alpha
const FECHA_DESDE_51 = new Date("2026-06-01T00:00:00Z");
const FECHA_HASTA_51 = new Date("2026-06-03T23:59:59Z");

// La consulta usa find() con un filtro de 3 condiciones:
//   1. idAgente igual al parametro
//   2. tipoEvento igual a "decision"
//   3. timestamp dentro del rango de fechas
//
// Con .sort() ordenamos de mas viejo a mas nuevo (orden cronologico).
// Con .project() elegimos que campos mostrar en el resultado.

const resultados51 = db.eventos.find(
  {
    idAgente:  ID_AGENTE_51,
    tipoEvento: "decision",
    timestamp: {
      $gte: FECHA_DESDE_51,  // $gte = greater than or equal (>=)
      $lte: FECHA_HASTA_51   // $lte = less than or equal    (<=)
    }
  },
  {
    // Proyeccion: 1 = mostrar, 0 = ocultar
    // _id se oculta porque no aporta informacion util
    _id:                  0,
    timestamp:            1,
    tipoEvento:           1,
    criticidad:           1,
    contextoOperacional:  1,
    // Del payload mostramos los parametros de entrada y la decision tomada
    "payload.parametrosEntrada":  1,
    "payload.decisionTomada":     1,
    "payload.alternativasEvaluadas": 1,
    "payload.razonamiento":       1
  }
).sort({ timestamp: 1 });  // 1 = ascendente (cronologico)

// Mostramos los resultados
let count51 = 0;
resultados51.forEach(doc => {
  count51++;
  print("Evento " + count51 + ":");
  print("  Fecha:              " + doc.timestamp);
  print("  Contexto:           " + doc.contextoOperacional);
  print("  Criticidad:         " + doc.criticidad);
  print("  Decision tomada:    " + doc.payload.decisionTomada);
  print("  Razonamiento:       " + doc.payload.razonamiento);
  print("  Parametros entrada: " + JSON.stringify(doc.payload.parametrosEntrada));
  print("  Alternativas evaluadas:");
  doc.payload.alternativasEvaluadas.forEach(a => {
    print("    - " + a.opcion + " (score: " + a.score + ")");
  });
  print("");
});

if (count51 === 0) {
  print("No se encontraron eventos de tipo 'decision' en el rango indicado.");
}
print("Total de eventos encontrados: " + count51);

// ============================================================
//  REQUERIMIENTO 5.2
//  Identificar los 5 agentes con mayor cantidad de eventos de
//  criticidad "alta" en la ultima semana, mostrando para cada uno:
//    - Cantidad de eventos de criticidad "alta"
//    - Proporcion que representan sobre el total de eventos del agente
//
//  Nota: "ultima semana" = los ultimos 7 dias desde hoy.
//  Para este ejercicio usamos una fecha fija como referencia
//  ya que los datos de prueba no son eventos de hoy.
// ============================================================

print("\n============================================================");
print(" REQUERIMIENTO 5.2");
print(" Top 5 agentes con mas eventos de criticidad ALTA");
print(" en los ultimos 7 dias (referencia: 2026-06-06)");
print("============================================================\n");

// Fecha de referencia: usamos la fecha mas reciente de nuestros datos
// En produccion seria: new Date() para "hoy"
const FECHA_HOY     = new Date("2026-06-06T23:59:59Z");
const FECHA_SEMANA  = new Date("2026-05-30T00:00:00Z");  // 7 dias antes

// Esta consulta usa el Aggregation Pipeline de MongoDB.
// Un pipeline es una serie de etapas que procesan los documentos
// de forma secuencial (como un pipeline de produccion).
//
// Etapas:
//   $match  → filtra los documentos (como WHERE en SQL)
//   $group  → agrupa y calcula totales (como GROUP BY en SQL)
//   $sort   → ordena los resultados
//   $limit  → limita la cantidad de resultados

let idx52 = 1;
db.eventos.aggregate([
  // ETAPA 1: Filtrar solo eventos de la ultima semana
  {
    $match: {
      timestamp: { $gte: FECHA_SEMANA, $lte: FECHA_HOY }
    }
  },
  // ETAPA 2: Agrupar por agente y calcular:
  {
    $group: {
      _id: {
        idAgente:     "$idAgente",
        nombreAgente: "$nombreAgente",
        tipoAgente:   "$tipoAgente"
      },
      totalEventos: { $sum: 1 },
      eventosAlta: {
        $sum: { $cond: [{ $eq: ["$criticidad", "alta"] }, 1, 0] }
      }
    }
  },
  // ETAPA 3: Calcular la proporcion de eventos alta sobre el total
  {
    $addFields: {
      proporcion: {
        $round: [
          { $divide: ["$eventosAlta", "$totalEventos"] },
          4
        ]
      },
      porcentaje: {
        $concat: [
          {
            $toString: {
              $round: [
                { $multiply: [{ $divide: ["$eventosAlta", "$totalEventos"] }, 100] },
                1
              ]
            }
          },
          "%"
        ]
      }
    }
  },
  // ETAPA 4: Ordenar por cantidad de eventos de criticidad alta (de mayor a menor)
  { $sort: { eventosAlta: -1 } },
  // ETAPA 5: Tomar solo los primeros 5
  { $limit: 5 },
  // ETAPA 6: Dar formato a la salida
  {
    $project: {
      _id:          0,
      idAgente:     "$_id.idAgente",
      nombreAgente: "$_id.nombreAgente",
      tipoAgente:   "$_id.tipoAgente",
      totalEventos:  1,
      eventosAlta:   1,
      proporcion:    1,
      porcentaje:    1
    }
  }
]).forEach(doc => {
  print("Puesto " + idx52 + ": " + doc.nombreAgente + " (" + doc.tipoAgente + ", id:" + doc.idAgente + ")");
  print("  Eventos criticos (alta): " + doc.eventosAlta + " de " + doc.totalEventos + " totales");
  print("  Proporcion:              " + doc.proporcion + "  (" + doc.porcentaje + ")");
  print("");
  idx52++;
});

// ============================================================
//  REQUERIMIENTO 5.3
//  Dado un agente y una franja horaria (8 a 17 horas),
//  devolver todos los eventos de tipo "interaccion con usuario"
//  agrupados por hora, indicando la cantidad total en cada hora.
//
//  Parametros que se pueden cambiar:
//    - ID_AGENTE_53: id del agente a consultar
//    - HORA_DESDE:   inicio de la franja horaria (inclusive)
//    - HORA_HASTA:   fin de la franja horaria (inclusive)
// ============================================================

print("\n============================================================");
print(" REQUERIMIENTO 5.3");
print(" Eventos de 'interaccion con usuario' de ObsBot-X");
print(" en la franja horaria de 8 a 17 horas");
print("============================================================\n");

const ID_AGENTE_53 = 5;   // ObsBot-X
const HORA_DESDE   = 8;   // desde las 8h
const HORA_HASTA   = 17;  // hasta las 17h

db.eventos.aggregate([

  // ETAPA 1: Filtrar por agente y tipo de evento
  {
    $match: {
      idAgente:   ID_AGENTE_53,
      tipoEvento: "interaccion con usuario"
    }
  },

  // ETAPA 2: Extraer la hora del campo timestamp
  // $hour es una funcion de fecha de MongoDB que extrae la hora (0-23)
  // Usamos $addFields para agregar un campo calculado "hora"
  {
    $addFields: {
      hora: { $hour: "$timestamp" }
    }
  },

  // ETAPA 3: Filtrar solo los eventos dentro de la franja horaria
  {
    $match: {
      hora: {
        $gte: HORA_DESDE,  // >= 8
        $lte: HORA_HASTA   // <= 17
      }
    }
  },

  // ETAPA 4: Agrupar por hora y contar cuantos eventos hay en cada hora
  {
    $group: {
      _id: "$hora",
      totalInteracciones: { $sum: 1 }
    }
  },

  // ETAPA 5: Ordenar por hora de menor a mayor
  { $sort: { _id: 1 } },

  // ETAPA 6: Formato de salida
  {
    $project: {
      _id:                0,
      hora:               "$_id",
      totalInteracciones: 1
    }
  }

]).forEach(doc => {
  // Formateamos la hora como "08:00 - 08:59"
  const horaStr = String(doc.hora).padStart(2, "0");
  const horaFin = String(doc.hora).padStart(2, "0");
  print("  " + horaStr + ":00 - " + horaFin + ":59  →  " + doc.totalInteracciones + " interaccion(es)");
});

print("\n=== Consultas de Parte 5 ejecutadas correctamente. ===");

quit();
