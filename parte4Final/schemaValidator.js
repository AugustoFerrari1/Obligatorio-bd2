db.createCollection("eventos", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: [
                "idAgente",
                "nombreAgente",
                "tipoAgente",
                "estadoAgente",
                "emailAdmin",
                "fechaHora",
                "tipoEvento",
                "criticidad",
                "detalle"
            ],
            properties: {
                idAgente: {
                    bsonType: "int",
                    description: "id del agente, es obligatorio"
                },
                nombreAgente: {
                    bsonType: "string",
                    description: "nombre del agente, es obligatorio"
                },
                tipoAgente: {
                    bsonType: "string",
                    enum: ["Generador","Moderador","Observador"],
                    description: "tipo del agente, es obligatorio"
                },
                estadoAgente: {
                    bsonType: "string",
                    enum: ["Activo","Suspendido"],
                    description: "estado del agente, es obligatorio"
                },
                emailAdmin: {
                    bsonType: "string",
                    description: "email del administrador, es obligatorio"
                },
                fechaHora: {
                    bsonType: "date",
                    description: "fecha y hora del evento, es obligatorio"
                },
                // No es un enum cerrado porque pueden aparecer nuevos tipos en el futuro.
                tipoEvento: {
                    bsonType: "string",
                    description: "el tipo del evento, es obligatorio"
                },
                criticidad: {
                    bsonType: "string",
                    enum: ["Alta","Media","Baja"],
                    description: "nivel de criticidad del evento, es obligatorio"
                },
                detalle: {
                    bsonType: "object",
                    description: "estructura que cambia segun el tipo de evento"
                }
            }
        }
    }
})