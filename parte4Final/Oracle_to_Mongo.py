#PARTE1

import oracledb
from pymongo import MongoClient
from datetime import datetime

#PARTE2
#Conectamos con Oracle
conexion_oracle = oracledb.connect(
    user="AGUS_O",
    password="tricolor",
    dsn="localhost:1521/XE"
)
cursor= conexion_oracle.cursor()
print("Conectado a Oracle")

#PARTE3
#Conectamos con MongoDB
cliente_mongo=MongoClient("mongodb://localhost:27017")
db_mongo = cliente_mongo["moltbook"]
coleccion_eventos = db_mongo ["eventos"]
print("Conectado a MongoDB")

#Mover Agentes
print("Moviendo Agentes...")
cursor.execute("""
    SELECT a.idAgente, a.nombre, a.tipo, a.estado, a.emailAdmin, a.fechaCreacion
    FROM Agente a
""")
filas = cursor.fetchall()
for fila in filas:
    documento = {
        "idAgente": fila[0],
        "nombreAgente": fila[1],
        "tipoAgente": fila[2],
        "estadoAgente": fila[3],
        "emailAdmin": fila[4],
        "fechaHora": datetime.combine(fila[5], datetime.min.time()),
        "tipoEvento": "creacion",
        "criticidad": "Media",
        "detalle": {
            "entidadCreada": "agente",
            "idEntidad": fila [0],
            "config": "Simple"
        }
    }
    coleccion_eventos.insert_one(documento)

print("Agentes migrados: " + str(len(filas)))

#Mover Publicaciones
print ("Moviendo Publicaciones...")
cursor.execute("""
    SELECT p.idContenido, p.titulo, p.idComunidad,
           c.idAgente, c.fechaCreacion, c.horaCreacion,
           a.nombre, a.tipo, a.estado, a.emailAdmin
    FROM Publicacion p
    JOIN contenido c ON c.idContenido = p.idContenido
    JOIN Agente a ON a.idAgente = c.idAgente 
""")
filas = cursor.fetchall()

for fila in filas:
    documento = {
        "idAgente": fila[3],
        "nombreAgente": fila[6],
        "tipoAgente": fila[7],
        "estadoAgente": fila[8],
        "emailAdmin": fila[9],
        "fechaHora": datetime.strptime(str(fila[4].date()) + " " + fila[5], "%Y-%m-%d %H:%M:%S"),
        "tipoEvento": "creacion",
        "criticidad": "Baja",
        "detalle": {
            "entidadCreada": "publicacion",
            "idEntidad": fila[0],
            "titulo": fila[1],
            "comunidad": fila[2]
        }
    }
    coleccion_eventos.insert_one(documento)

print("Publicaciones migradas: " + str(len(filas)))

#Mover Comentarios
print("Moviendo Comentarios...")
cursor.execute("""
    SELECT co.idContenido, co.cuerpo, co.idPublicacion,
           c.idAgente, c.fechaCreacion, c.horaCreacion,
           a.nombre, a.tipo, a.estado, a.emailAdmin
    FROM comentario co
    JOIN contenido c ON c.idContenido = co.idContenido
    JOIN agente a ON a.idAgente = c.idAgente
""")
filas = cursor.fetchall()

for fila in filas:
    documento = {
        "idAgente": fila[3],
        "nombreAgente": fila[6],
        "tipoAgente": fila[7],
        "estadoAgente": fila[8],
        "emailAdmin": fila[9],
        "fechaHora": datetime.strptime(str(fila[4].date()) + " " + fila[5], "%Y-%m-%d %H:%M:%S"),
        "tipoEvento": "creacion",
        "criticidad": "Baja",
        "detalle": {
            "entidadCreada": "comentario",
            "idEntidad": fila[0],
            "cuerpo": fila[1],
            "idPublicacion": fila[2]
        }
    }
    coleccion_eventos.insert_one(documento)

print("Comentarios migrados: " + str(len(filas)))

#Moviendo Votos
print("Moviendo Votos...")
cursor.execute("""
    SELECT v.idAgente, v.idPublicacion, v.tipoVoto, v.fecha, v.hora,
           a.nombre, a.tipo, a.estado, a.emailAdmin
    FROM vota v
    JOIN agente a ON a.idAgente = v.idAgente
""")
filas = cursor.fetchall()

for fila in filas:
    documento = {
        "idAgente": fila[0],
        "nombreAgente": fila[5],
        "tipoAgente": fila[6],
        "estadoAgente": fila[7],
        "emailAdmin": fila[8],
        "fechaHora": datetime.strptime(str(fila[3].date()) + " " + fila[4], "%Y-%m-%d %H:%M:%S"),
        "tipoEvento": "interaccion",
        "criticidad": "Baja",
        "detalle": {
            "tipoInteraccion": "voto",
            "idPublicacion": fila[1],
            "valor": fila[2]
        }
    }
    coleccion_eventos.insert_one(documento)

print("Votos migrados: " + str(len(filas)))

#Moviendo Modera
print("Moviendo Moderaciones...")
cursor.execute("""
    SELECT m.idAgente, m.idContenido, m.idComunidad, m.fecha, m.hora, m.accion,
           a.nombre, a.tipo, a.estado, a.emailAdmin
    FROM modera m
    JOIN agente a ON a.idAgente = m.idAgente
""")
filas = cursor.fetchall()

for fila in filas:
    documento = {
        "idAgente": fila[0],
        "nombreAgente": fila[6],
        "tipoAgente": fila[7],
        "estadoAgente": fila[8],
        "emailAdmin": fila[9],
        "fechaHora": datetime.strptime(str(fila[3].date()) + " " + fila[4], "%Y-%m-%d %H:%M:%S"),
        "tipoEvento": "decision",
        "criticidad": "Alta",
        "detalle": {
            "contexto": "moderacion de contenido",
            "parametrosEntrada": [fila[1],fila[2]],
            "alternativasEvaluadas": ["ocultar", "cerrar", "eliminar"],
            "resultado": fila[5]
        }
    }
    coleccion_eventos.insert_one(documento)

print("Moderaciones migradas: " + str(len(filas)))

#Moviendo transferencia
print("Moviendo Transferencias...")
cursor.execute("""
    SELECT t.idAgente, t.emailCedente, t.emailReceptor, t.fecha,
           a.nombre, a.tipo, a.estado, a.emailAdmin
    FROM transferencia t
    JOIN agente a ON a.idAgente = t.idAgente
""")
filas = cursor.fetchall()

for fila in filas:
    documento = {
        "idAgente": fila[0],
        "nombreAgente": fila[4],
        "tipoAgente": fila[5],
        "estadoAgente": fila[6],
        "emailAdmin": fila[7],
        "fechaHora": datetime.combine(fila[3], datetime.min.time()),
        "tipoEvento": "decision",
        "criticidad": "Alta",
        "detalle": {
            "contexto": "transferencia de administracion",
            "parametrosEntrada": [fila[1],fila[2]],
            "alternativasEvaluadas": ["rechazar", "aceptar"],
            "resultado": "aceptar"
        }
    }
    coleccion_eventos.insert_one(documento)

print("Transferencias migradas: " + str(len(filas)))

#Cerramos las conexiones
cursor.close()
conexion_oracle.close()
cliente_mongo.close()
print("Conexiones cerradas correctamente")