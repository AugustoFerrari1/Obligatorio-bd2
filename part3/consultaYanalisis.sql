
EXPLAIN PLAN FOR
SELECT
    com.nombre                              AS comunidad,
    uh.alias                                AS admin_alias,
    uh.email                                AS admin_email,
    a.nombre                                AS nombre_agente,
    a.tipo                                  AS tipo_agente,
    COUNT(DISTINCT p.idContenido)           AS total_publicaciones,
    SUM(p.votosTotales)                     AS votos_netos_totales,
    COUNT(DISTINCT cm.idContenido)          AS total_comentarios_recibidos,
    CASE 
        WHEN COUNT(DISTINCT p.idContenido) = 0 THEN 0
        ELSE ROUND(SUM(p.votosTotales) / COUNT(DISTINCT p.idContenido), 2)
    END                                     AS promedio_votos_por_pub
FROM Publicacion p
JOIN contenido  c       ON c.idContenido  = p.idContenido
JOIN Agente     a       ON a.idAgente     = c.idAgente
JOIN usuarioHumano uh   ON uh.email     = a.emailAdmin
JOIN comunidad  com     ON com.idComunidad = p.idComunidad
JOIN comentario cm      ON cm.idPublicacion = p.idContenido
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
Plan hash value: 4221167918

---------------------------------------------------------------------------------------------------------
| Id  | Operation                            | Name             | Rows  | Bytes | Cost (%CPU)| Time     |
---------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                     |                  |     4 |  1520 |    20  (10)| 00:00:01 |
|   1 |  SORT ORDER BY                       |                  |     4 |  1520 |    20  (10)| 00:00:01 |
|*  2 |   FILTER                             |                  |       |       |            |          |
|   3 |    HASH GROUP BY                     |                  |     4 |  1520 |    20  (10)| 00:00:01 |
|*  4 |     HASH JOIN                        |                  |     4 |  1520 |    18   (0)| 00:00:01 |
|   5 |      NESTED LOOPS                    |                  |     3 |  1062 |    15   (0)| 00:00:01 |
|   6 |       NESTED LOOPS                   |                  |     3 |  1062 |    15   (0)| 00:00:01 |
|   7 |        NESTED LOOPS                  |                  |     3 |   825 |    12   (0)| 00:00:01 |
|   8 |         NESTED LOOPS                 |                  |     3 |   420 |     9   (0)| 00:00:01 |
|   9 |          NESTED LOOPS                |                  |     3 |   216 |     6   (0)| 00:00:01 |
|* 10 |           TABLE ACCESS FULL          | PUBLICACION      |     3 |   138 |     3   (0)| 00:00:01 |
|  11 |           TABLE ACCESS BY INDEX ROWID| CONTENIDO        |     1 |    26 |     1   (0)| 00:00:01 |
|* 12 |            INDEX UNIQUE SCAN         | PK_CONTENIDO     |     1 |       |     0   (0)| 00:00:01 |
|* 13 |          TABLE ACCESS BY INDEX ROWID | COMUNIDAD        |     1 |    68 |     1   (0)| 00:00:01 |
|* 14 |           INDEX UNIQUE SCAN          | PK_COMUNIDAD     |     1 |       |     0   (0)| 00:00:01 |
|* 15 |         TABLE ACCESS BY INDEX ROWID  | AGENTE           |     1 |   135 |     1   (0)| 00:00:01 |
|* 16 |          INDEX UNIQUE SCAN           | PK_AGENTE        |     1 |       |     0   (0)| 00:00:01 |
|* 17 |        INDEX UNIQUE SCAN             | PK_USUARIOHUMANO |     1 |       |     0   (0)| 00:00:01 |
|  18 |       TABLE ACCESS BY INDEX ROWID    | USUARIOHUMANO    |     1 |    79 |     1   (0)| 00:00:01 |
|  19 |      TABLE ACCESS FULL               | COMENTARIO       |     4 |   104 |     3   (0)| 00:00:01 |
---------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   2 - filter(SUM("P"."VOTOSTOTALES")>0)
   4 - access("CM"."IDPUBLICACION"="P"."IDCONTENIDO")
  10 - filter("P"."ESTADO"='Activa')
  12 - access("C"."IDCONTENIDO"="P"."IDCONTENIDO")
  13 - filter("COM"."ARCHIVADO"='N')
  14 - access("COM"."IDCOMUNIDAD"="P"."IDCOMUNIDAD")
  15 - filter("A"."ESTADO"='Activo')
  16 - access("A"."IDAGENTE"="C"."IDAGENTE")
  17 - access("UH"."EMAIL"="A"."EMAILADMIN")

Note
-----
   - dynamic statistics used: dynamic sampling (level=2)
   - this is an adaptive plan
*/
