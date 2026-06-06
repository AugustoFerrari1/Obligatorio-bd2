# Parte 3 — Consulta SQL y Análisis del Plan de Ejecución

## 1. Pregunta de Negocio

**"¿Cuáles son los agentes más influyentes en cada comunidad, medido por el total de votos netos recibidos en sus publicaciones activas, la cantidad de comentarios que generaron y quién es el usuario humano responsable del agente?"**

Esta consulta tiene alto valor para Moltbook porque permite:

- Identificar qué agentes generan el contenido más relevante en cada comunidad.
- Conocer al usuario humano responsable de esos agentes (trazabilidad legal).
- Medir la interacción real (comentarios) que generan las publicaciones destacadas.
- Soportar decisiones de negocio: destacar comunidades activas, detectar comportamientos anómalos, etc.

---

## 2. Consulta SQL

La consulta involucra **6 tablas**: `Publicacion`, `contenido`, `Agente`, `usuarioHumano`, `comunidad` y `comentario`.

```sql
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
```

### Tablas involucradas y su rol

| Tabla | Rol en la consulta |
|---|---|
| `Publicacion` | Tabla principal; filtra por estado `'Activa'` |
| `contenido` | Vincula publicación con el agente que la generó (ISA) |
| `Agente` | Datos del agente; filtra por estado `'Activo'` |
| `usuarioHumano` | Propietario/administrador del agente |
| `comunidad` | Contexto temático; filtra por `archivado = 'N'` |
| `comentario` | JOIN para contar comentarios recibidos |

---

## 3. Plan de Ejecución (Oracle)

El plan fue obtenido con:

```sql
EXPLAIN PLAN FOR <consulta>;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

### Plan resultante

```
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
```

---

## 4. Identificación de Operaciones Principales

### 4.1 TABLE ACCESS FULL (Full Table Scan)
Aparece **solo en las tablas sin índices explotables** en este plan: `PUBLICACION` (op. 10) y `COMENTARIO` (op. 19). El motor las lee de principio a fin porque:
- La columna de filtro `estado` de `PUBLICACION` no tiene índice secundario.
- `COMENTARIO` se usa como tabla de probe en el Hash Join final (op. 4) y tampoco tiene índice en `idPublicacion`.

El resto de las tablas (`CONTENIDO`, `COMUNIDAD`, `AGENTE`, `USUARIOHUMANO`) son accedidas mediante **INDEX UNIQUE SCAN + TABLE ACCESS BY INDEX ROWID**, aprovechando sus claves primarias.

### 4.2 NESTED LOOPS (operaciones 5–9)
Oracle eligió **Nested Loop** para 5 de los 6 joins, encadenados desde la tabla `PUBLICACION` (outer) hacia las demás usando los índices de PK:
1. `PUBLICACION` ⋈ `CONTENIDO` via `PK_CONTENIDO` → resultado R1
2. R1 ⋈ `COMUNIDAD` via `PK_COMUNIDAD` (con filtro `archivado='N'`) → R2
3. R2 ⋈ `AGENTE` via `PK_AGENTE` (con filtro `estado='Activo'`) → R3
4. R3 ⋈ `USUARIOHUMANO` via `PK_USUARIOHUMANO` → R4

Este patrón es eficiente porque por cada fila de `PUBLICACION` filtrada, el acceso a las tablas relacionadas es directo por índice (O(1) por lookup).

### 4.3 HASH JOIN (operación 4)
El join con `COMENTARIO` se realiza con **Hash Join**: Oracle construye la tabla hash con el resultado R4 (pocas filas tras los NL) y hace probe contra `COMENTARIO` (TABLE ACCESS FULL). Es el único Hash Join del plan.

### 4.4 HASH GROUP BY (operación 3)
Agrupa los registros por `(com.nombre, uh.alias, uh.email, a.nombre, a.tipo)` y calcula los agregados (`SUM`, `COUNT DISTINCT`). Oracle usa una tabla hash interna para acumular grupos.

### 4.5 FILTER (operación 2)
Aplica la cláusula `HAVING SUM(votosTotales) > 0` después de la agrupación, eliminando agentes sin votos positivos netos.

### 4.6 SORT ORDER BY (operación 1)
Ordena el resultado final por `comunidad ASC` y `votos_netos_totales DESC`.

---

## 5. Relación con Algoritmos Estudiados en Clase

### 5.1 Nested Loop Join ✅ (el usado para la mayoría de los joins)
En el plan observado, Oracle **eligió Nested Loop** para 5 de los 6 joins (operaciones 5–9), aprovechando los índices de clave primaria de las tablas `CONTENIDO`, `COMUNIDAD`, `AGENTE` y `USUARIOHUMANO`.

**Funcionamiento:**
```
Para cada fila r ∈ R (outer):
    Buscar en índice de S por r.key → TABLE ACCESS BY INDEX ROWID
    Si coincide → emitir (r, s)
```
- **Costo**: O(|R| × log|S|) con índice (en este caso O(1) con INDEX UNIQUE SCAN sobre PK).
- **Por qué se usó aquí**: Las claves primarias (`PK_CONTENIDO`, `PK_COMUNIDAD`, `PK_AGENTE`, `PK_USUARIOHUMANO`) proveen acceso directo por índice. Con pocas filas en `PUBLICACION` activas, el NL es más eficiente que construir una tabla hash.

### 5.2 Hash Join ✅ (usado para el join con COMENTARIO)
Oracle eligió Hash Join **únicamente para el join con `COMENTARIO`** (operación 4), ya que esta tabla no tiene índice en `idPublicacion` y se accede mediante TABLE ACCESS FULL.

**Fase Build:** El resultado de los Nested Loops (pocas filas) se carga en una tabla hash en memoria usando `idContenido` como clave.

**Fase Probe:** Se recorre `COMENTARIO` completo y por cada fila se busca en el hash la publicación correspondiente.

```
Build Phase:
  Para cada fila r ∈ R_inner (resultado NL, pocas filas):
      h = hash(r.idContenido)
      insertar r en bucket[h]

Probe Phase:
  Para cada fila s ∈ COMENTARIO (TABLE ACCESS FULL):
      h = hash(s.idPublicacion)
      Para cada r en bucket[h]:
          Si r.idContenido = s.idPublicacion → emitir (r, s)
```

- **Costo**: O(|R| + |S|) en condiciones ideales.
- **Por qué aquí**: Sin índice en `comentario.idPublicacion`, el Hash Join es más eficiente que un Nested Loop que requeriría un Full Scan por cada publicación.

### 5.3 Sort-Merge Join (no elegido)
```
1. Ordenar R por la clave de join
2. Ordenar S por la clave de join
3. Fusionar en un único recorrido lineal
```
- **Costo**: O(|R| log|R| + |S| log|S| + |R| + |S|)
- **Por qué no se eligió**: No hay datos pre-ordenados ni índices que lo favorezcan.

### 5.4 External Sort — SORT ORDER BY (operación 1)
Corresponde al algoritmo de **ordenación externa por bloques** estudiado en clase (External Merge Sort). Oracle divide los datos en *runs* que caben en memoria, los ordena internamente y luego los fusiona.

### 5.5 Resumen comparativo

| Algoritmo (clase) | Equivalente en plan | ¿Seleccionado? |
|---|---|---|
| Nested Loop Join | NESTED LOOPS (ops 5–9) | ✅ Sí (joins con índice de PK) |
| Hash Join | HASH JOIN (op 4) | ✅ Sí (join con COMENTARIO, sin índice) |
| Sort-Merge Join | MERGE JOIN | No |
| External Sort | SORT ORDER BY | ✅ Sí (ORDER BY final) |
| Hash Aggregation | HASH GROUP BY | ✅ Sí (GROUP BY) |

---

## 6. Análisis de Eficiencia

El plan de ejecución presenta un costo estimado de 20 unidades, lo que resulta adecuado para el volumen de datos utilizado durante las pruebas.

A diferencia de otros planes posibles, Oracle aprovecha los índices primarios de varias tablas mediante operaciones INDEX UNIQUE SCAN y TABLE ACCESS BY INDEX ROWID, reduciendo la cantidad de lecturas necesarias. Sin embargo, las tablas PUBLICACION y COMENTARIO continúan siendo recorridas mediante TABLE ACCESS FULL, lo que podría generar un mayor costo si la cantidad de registros aumenta considerablemente.

La mayor parte de las uniones se realizan mediante NESTED LOOPS, una estrategia eficiente cuando existen índices que permiten localizar rápidamente los registros relacionados. Además, Oracle utiliza un HASH JOIN para combinar el resultado intermedio con la tabla COMENTARIO.

Por otra parte, el conteo de comentarios se realiza después del JOIN con la tabla COMENTARIO, generando más filas intermedias antes de la agrupación. Aunque esto produce resultados correctos, puede afectar el rendimiento cuando el número de comentarios por publicación es elevado.

---

## 7. Propuestas de Mejora

### 7.1 Creación de Índices

Una posible mejora consiste en crear índices sobre las columnas utilizadas con frecuencia en filtros y operaciones de JOIN.

```sql
CREATE INDEX idx_pub_estado_com ON Publicacion (idComunidad, estado);
CREATE INDEX idx_agente_estado ON Agente (estado, emailAdmin);
CREATE INDEX idx_comunidad_archivado ON comunidad (archivado, idComunidad);
CREATE INDEX idx_contenido_agente ON contenido (idAgente);
CREATE INDEX idx_comentario_pub ON comentario (idPublicacion);
```

Estos índices podrían reducir aún más el costo de ejecución y evitar algunos recorridos completos de tabla.

### 7.2 Aprovechamiento del atributo votosTotales

La consulta utiliza el atributo votosTotales, mantenido automáticamente por el trigger TRG-05.

Gracias a este diseño, no es necesario realizar un JOIN adicional con la tabla de votos en cada ejecución, reduciendo la cantidad de datos procesados y mejorando el rendimiento de la consulta.

### 7.3 Optimización del conteo de comentarios

Actualmente, el conteo de comentarios se realiza después del JOIN con la tabla COMENTARIO, aumentando la cantidad de filas intermedias procesadas.

Una alternativa consiste en calcular previamente la cantidad de comentarios por publicación mediante una subconsulta agrupada y luego unir dicho resultado con la consulta principal. Esto permitiría reducir el volumen de datos procesados y disminuir el costo de la agregación final.

### 7.4 Materializar como vista
Para consultas ejecutadas frecuentemente con datos que no cambian en tiempo real:

```sql
CREATE MATERIALIZED VIEW mv_ranking_agentes
BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
AS <consulta principal>;
```

---

## 8. Conclusiones

1. **Oracle eligió Nested Loop Join con INDEX UNIQUE SCAN** para 5 de los 6 joins, aprovechando los índices de clave primaria de `CONTENIDO`, `COMUNIDAD`, `AGENTE` y `USUARIOHUMANO`. Esto demuestra que cuando existen índices en las claves de join, el Nested Loop es preferido sobre el Hash Join para tablas con pocas filas.

2. **El único Hash Join** aparece para el join con `COMENTARIO`, tabla que carece de índice en `idPublicacion`. Esto confirma el comportamiento esperado del optimizador: prefiere Hash Join cuando no hay índice y el tamaño relativo de las tablas lo justifica.

3. **El Full Table Scan se limita a `PUBLICACION` y `COMENTARIO`**, que son los cuellos de botella. La creación de índices en `Publicacion.estado` y `comentario.idPublicacion` tendría el mayor impacto de mejora.

4. **El HASH GROUP BY** refleja el algoritmo de agregación por hash estudiado: acumula grupos en memoria sin necesidad de ordenación previa, siendo más eficiente que Sort-Merge Aggregation.

5. **El atributo derivado `votosTotales`** (mantenido por trigger) es una decisión de desnormalización que mejora el rendimiento, evitando un join adicional costoso con la tabla `vota`.

6. **Separar el JOIN** de comentarios en una subconsulta (agrupando por publicación antes del join principal) evitaría multiplicar filas innecesariamente y permitiría reemplazar `COUNT(DISTINCT)` por `COUNT()`, mejorando el rendimiento en escenarios con alta tasa de comentarios por publicación.
