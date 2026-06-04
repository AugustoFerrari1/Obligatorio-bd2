
EXPLAIN PLAN FOR
SELECT
    com.nombre                              AS comunidad,
    uh.alias                                AS admin_alias,
    uh.email                                AS admin_email,
    a.nombre                                AS nombre_agente,
    a.tipo                                  AS tipo_agente,
    COUNT(DISTINCT p.idPublicacion)         AS total_publicaciones,
    SUM(p.votosTotales)                     AS votos_netos_totales,
    COUNT(DISTINCT cm.idComentario)         AS total_comentarios_recibidos,
    CASE 
        WHEN COUNT(DISTINCT p.idPublicacion) = 0 THEN 0
        ELSE ROUND(SUM(p.votosTotales) / COUNT(DISTINCT p.idPublicacion), 2)
    END                                     AS promedio_votos_por_pub
FROM Publicacion p
JOIN contenido  c       ON c.idContenido  = p.idPublicacion
JOIN Agente     a       ON a.idAgente     = c.idAgente
JOIN usuarioHumano uh   ON uh.email     = a.emailAdmin
JOIN comunidad  com     ON com.idComunidad = p.idComunidad
JOIN comentario cm      ON cm.idPublicacion = p.idPublicacion
WHERE p.estado        = 'Activa'
    AND a.estado    = 'Activo'
    AND com.archivado = 'N'
GROUP BY
    com.nombre,
    uh.alias,
    uh.email,
    a.nombre,
    a.tipo
HAVING
    SUM(p.votosTotales) > 0
ORDER BY
    com.nombre          ASC,
    votos_netos_totales DESC;


-- Visualizar el plan almacenado:
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


-- RESULTADOS - export.xml es el archivo dado por oracle con el plan
/*
Plan hash value: 165572356

-------------------------------------------------------------------------------------------
| Id  | Operation                 | Name          | Rows  | Bytes | Cost (%CPU)| Time     |
-------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT          |               |     4 |  1520 |    20  (10)| 00:00:01 |
|   1 |  SORT ORDER BY            |               |     4 |  1520 |    20  (10)| 00:00:01 |
|*  2 |   FILTER                  |               |       |       |            |          |
|   3 |    HASH GROUP BY          |               |     4 |  1520 |    20  (10)| 00:00:01 |
|*  4 |     HASH JOIN             |               |     4 |  1520 |    18   (0)| 00:00:01 |
|*  5 |      HASH JOIN            |               |     4 |  1204 |    15   (0)| 00:00:01 |
|*  6 |       HASH JOIN           |               |     4 |   664 |    12   (0)| 00:00:01 |
|*  7 |        HASH JOIN          |               |     4 |   560 |     9   (0)| 00:00:01 |
|*  8 |         HASH JOIN         |               |     4 |   456 |     6   (0)| 00:00:01 |
|*  9 |          TABLE ACCESS FULL| COMUNIDAD     |     3 |   204 |     3   (0)| 00:00:01 |
|* 10 |          TABLE ACCESS FULL| PUBLICACION   |     4 |   184 |     3   (0)| 00:00:01 |
|  11 |         TABLE ACCESS FULL | COMENTARIO    |     4 |   104 |     3   (0)| 00:00:01 |
|  12 |        TABLE ACCESS FULL  | CONTENIDO     |    11 |   286 |     3   (0)| 00:00:01 |
|* 13 |       TABLE ACCESS FULL   | AGENTE        |     6 |   810 |     3   (0)| 00:00:01 |
|  14 |      TABLE ACCESS FULL    | USUARIOHUMANO |     5 |   395 |     3   (0)| 00:00:01 |
-------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(SUM("P"."VOTOSTOTALES")>0)
   4 - access("UH"."EMAIL"="A"."EMAILADMIN")
   5 - access("A"."IDAGENTE"="C"."IDAGENTE")
   6 - access("C"."IDCONTENIDO"="P"."IDPUBLICACION")
   7 - access("CM"."IDPUBLICACION"="P"."IDPUBLICACION")
   8 - access("COM"."IDCOMUNIDAD"="P"."IDCOMUNIDAD")
   9 - filter("COM"."ARCHIVADO"='N')
  10 - filter("P"."ESTADO"='Activa')
  13 - filter("A"."ESTADO"='Activo')

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - this is an adaptive plan
*/
