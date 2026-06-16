//Requerimiento 5.1
db.eventos.find(
    {
        idAgente: 3,
        tipoEvento: "decision",
        fechaHora: {
            $gte: ISODate("2026-01-01T00:00:00Z"),
            $lte: ISODate("2026-12-31T00:00:00Z") 
        }
    },
    {
        fechaHora: 1,
        criticidad: 1,
        detalle: 1
    }
).sort({fechaHora: 1})

//Requerimiento 5.2
db.eventos.aggregate ([
    {
        $match: {
            fechaHora:{
                $gte: new Date(new Date() - 7 * 24 * 60 * 60 * 1000) 
            }
        }
    },
    {
        $group: {
            _id: "$idAgente",
            nombreAgente: { $first: "$nombreAgente"},
            totalEventos: {$sum : 1},
            altaEventos: {$sum: {$cond: [{$eq: ["$criticidad", "Alta"]} ,1,0]}}
        }
    },
    {
        $project: {
            nombreAgente: 1,
            totalEventos: 1,
            altaEventos: 1, 
            proporcion: {$round: [{$divide: ["$altaEventos", "$totalEventos"]}, 2]}
        }
    },
    {
        $sort: {
            altaEventos: -1
        }
    },
    {
        $limit: 5
    }
    
])

//Requerimiento 5.3
db.eventos.aggregate ([
    {
        $match: {
            idAgente: 2,
            tipoEvento: "interaccion",
            "detalle.tipoInteraccion": "interaccion con usuario"            
        }
    },

    {
        $project: {
            hora: {$hour: "$fechaHora"},
            detalle: 1              
        }
    },

    {
        $match:{
            hora: { $gte: 8, $lte: 17}
        }
    },
    {
        $group:{
            _id: "$hora",
            cantIteracciones: {$sum: 1}
        }
    },
    {
        $sort: {_id: 1}
    }
])