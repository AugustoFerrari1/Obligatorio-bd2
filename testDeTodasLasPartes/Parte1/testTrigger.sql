
-- ============================================================
-- TRG-01 | trg_contenido_before_insert
-- ============================================================

-- [OK] Agente 1 (GenBot-Alpha): tipo=Generador, estado=Activo
INSERT INTO contenido VALUES (20, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 1);

-- [ERR-20001] Agente 4 (ModBot-Two): estado=Suspendido
--   El trigger verifica suspendido ANTES que el tipo, asi que cae en la primera regla
INSERT INTO contenido VALUES (21, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 4);

-- [ERR-20002] Agente 3 (ModBot-One): tipo=Moderador, estado=Activo
INSERT INTO contenido VALUES (22, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 3);


-- ============================================================
-- TRG-02 | trg_publicacion_before_insert
-- ============================================================

-- [OK] Agente 1, comunidad 1 (TecnologiaIA, no archivada), rol=Miembro Activo
INSERT INTO contenido VALUES (23, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:00:00', 1);
INSERT INTO Publicacion VALUES (23, 'Titulo valido', 'Cuerpo valido', 'Activa', 0, 1);

-- [ERR-20003] Comunidad 3 (ArteDigital): archivado='S'
INSERT INTO contenido VALUES (24, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:30:00', 1);
INSERT INTO Publicacion VALUES (24, 'Arte en comunidad archivada', 'Cuerpo', 'Activa', 0, 3);

-- [ERR-20004] Agente 2 (GenBot-Beta): Generador activo, pero NO participa en comunidad 2
INSERT INTO contenido VALUES (25, TO_DATE('2026-06-02','YYYY-MM-DD'), '12:00:00', 2);
INSERT INTO Publicacion VALUES (25, 'Sin membresia en com2', 'Cuerpo', 'Activa', 0, 2);


-- ============================================================
-- TRG-03 | trg_comentario_before_insert
-- ============================================================

-- [OK] Agente 1 comenta publicacion 1 (Activa, comunidad 1, rol=Miembro Activo)
INSERT INTO contenido VALUES (26, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:00:00', 1);
INSERT INTO comentario VALUES (26, 'Comentario valido.', 1, NULL);

-- [ERR-20005] Publicacion 3: estado='Cerrada'
INSERT INTO contenido VALUES (27, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:30:00', 1);
INSERT INTO comentario VALUES (27, 'Intento en pub cerrada.', 3, NULL);

-- [ERR-20006] Agente 2 (GenBot-Beta): Generador activo, pero NO es Miembro Activo
--   en comunidad 2 (donde vive publicacion 4). El trigger lo rechaza.
INSERT INTO contenido VALUES (28, TO_DATE('2026-06-03','YYYY-MM-DD'), '10:00:00', 2);
INSERT INTO comentario VALUES (28, 'Intento sin membresia.', 4, NULL);


-- ============================================================
-- TRG-04 | trg_vota_before_insert
-- ============================================================

-- [OK] Agente 6 (ObsBot-Y): tipo=Observador, activo; publicacion 23 Activa (creada arriba)
INSERT INTO vota VALUES (6, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '08:00:00');

-- [ERR-20007] Observador suspendido no puede votar
--   Suspendemos temporalmente al agente 6, insertamos, luego restauramos
UPDATE Agente SET estado = 'Suspendido' WHERE idAgente = 6;
INSERT INTO vota VALUES (6, 1, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:00:00');
-- ^ Este INSERT debe fallar con -20007
UPDATE Agente SET estado = 'Activo' WHERE idAgente = 6;   

-- [ERR-20008] Agente 1 (GenBot-Alpha): tipo=Generador, no puede votar
INSERT INTO vota VALUES (1, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:30:00');

-- [ERR-20009] Publicacion 5: estado='Eliminada' en la tabla base
INSERT INTO vota VALUES (5, 5, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '10:00:00');


-- ============================================================
-- TRG-05 | trg_vota_after_insert
-- ============================================================

-- [VER-ANTES] Estado actual de votosTotales segun DML original:
--   pub 1: agente5(+1) + agente6(+1) = 2
--   pub 2: agente5(+1) + agente6(-1) = 0
--   pub 4: agente5(+1) + agente6(+1) = 2
SELECT idContenido, votosTotales FROM Publicacion WHERE idContenido IN (1, 2, 4, 23);

-- [OK] El INSERT de TRG-04 OK agrego voto +1 de agente 6 sobre pub 23
SELECT votosTotales FROM Publicacion WHERE idContenido = 23;

-- [OK] Agregar voto negativo de agente 5 sobre pub 23 y verificar decremento
INSERT INTO vota VALUES (5, 23, -1, TO_DATE('2026-06-05','YYYY-MM-DD'), '08:00:00');
SELECT votosTotales FROM Publicacion WHERE idContenido = 23;


-- ============================================================
-- TRG-06 | trg_modera_before_insert
-- ============================================================

-- [OK] Agente 3 (ModBot-One): Moderador activo, pertenece a comunidad 1
INSERT INTO modera VALUES (3, 23, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '09:00:00', 'ocultar');

-- [ERR-20010] Agente 4 (ModBot-Two): tipo=Moderador pero estado=Suspendido
INSERT INTO modera VALUES (4, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '10:00:00', 'ocultar');

-- [ERR-20011] Agente 1 (GenBot-Alpha): tipo=Generador, no puede moderar
INSERT INTO modera VALUES (1, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '11:00:00', 'cerrar');

-- [ERR-20012] Agente 3 (ModBot-One): Moderador activo, pero NO pertenece a comunidad 4
INSERT INTO modera VALUES (3, 1, 4, TO_DATE('2026-06-06','YYYY-MM-DD'), '12:00:00', 'cerrar');


-- ============================================================
-- TRG-07 | trg_transferencia_before_insert
-- ============================================================

-- [OK] Agente 1 (GenBot-Alpha): emailAdmin='alice@mail.com', cedente=alice -> valido
INSERT INTO transferencia VALUES (1, 'alice@mail.com', 'bob@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));

-- [ERR-20013] Agente 5 (ObsBot-X): emailAdmin='alice@mail.com', cedente='eve@mail.com' -> invalido
INSERT INTO transferencia VALUES (5, 'eve@mail.com', 'carol@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));


-- ============================================================
-- TRG-08 | trg_transferencia_after_insert
-- ============================================================

-- [VER] Tras el INSERT OK de TRG-07, el admin de agente 1 debe ser bob@mail.com
SELECT emailAdmin FROM Agente WHERE idAgente = 1;

-- [VER] Agente 5 no fue transferido (el ERR de TRG-07 lo rechazo), sigue con alice
SELECT emailAdmin FROM Agente WHERE idAgente = 5;


-- ============================================================
-- TRG-09 | trg_comunidad_archivado
-- ============================================================

-- [OK] No archivada con fecha NULL
INSERT INTO comunidad VALUES (5, 'NuevaCom', 'Descripcion.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema', 'N', NULL);

-- [OK] Archivada sin fecha: TRG-09 le asigna SYSDATE automaticamente
INSERT INTO comunidad VALUES (6, 'ArchivedCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema2', 'S', NULL);
-- [VER] La fecha fue asignada por el trigger
SELECT fechaArchivado FROM comunidad WHERE idComunidad = 6;

-- [ERR-20014] No archivada con fechaArchivado no nula: combinacion invalida
INSERT INTO comunidad VALUES (7, 'MalaCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema3', 'N', TO_DATE('2026-01-01','YYYY-MM-DD'));


-- ============================================================
-- TRG-10 | trg_vw_publicacion_delete (INSTEAD OF DELETE)
-- ============================================================

-- [OK] Eliminar publicacion 23 a traves de la vista
DELETE FROM vw_publicacion WHERE idContenido = 23;

-- [VER] El estado en la tabla base debe ser 'Eliminada'
SELECT estado FROM Publicacion WHERE idContenido = 23;

-- [VER] La vista ya no muestra esa publicacion (filtra estado <> 'Eliminada')
SELECT COUNT(*) AS visible FROM vw_publicacion WHERE idContenido = 23;


DELETE FROM vw_publicacion WHERE idContenido = 5;



SQL> INSERT INTO contenido VALUES (20, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 1)



1 row inserted.

Elapsed: 00:00:00.020


SQL> INSERT INTO contenido VALUES (21, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 4)

ORA-20001: Un agente suspendido no puede generar contenido.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT", line 12
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20001/
Error at Line: 32 Column: 0
SQL> INSERT INTO contenido VALUES (22, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 3)

ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT", line 18
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20002/
Error at Line: 35 Column: 0
SQL> INSERT INTO contenido VALUES (23, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:00:00', 1)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO Publicacion VALUES (23, 'Titulo valido', 'Cuerpo valido', 'Activa', 0, 1)



1 row inserted.

Elapsed: 00:00:00.021


SQL> INSERT INTO contenido VALUES (24, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:30:00', 1)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Publicacion VALUES (24, 'Arte en comunidad archivada', 'Cuerpo', 'Activa', 0, 3)

ORA-20003: No se permiten nuevas publicaciones en comunidades archivadas.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT", line 20
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20003/
Error at Line: 51 Column: 0
SQL> INSERT INTO contenido VALUES (25, TO_DATE('2026-06-02','YYYY-MM-DD'), '12:00:00', 2)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO Publicacion VALUES (25, 'Sin membresia en com2', 'Cuerpo', 'Activa', 0, 2)

ORA-20004: El agente debe ser Miembro Activo de la comunidad para publicar.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT", line 33
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20004/
Error at Line: 56 Column: 0
SQL> INSERT INTO contenido VALUES (26, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:00:00', 1)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comentario VALUES (26, 'Comentario valido.', 1, NULL)



1 row inserted.

Elapsed: 00:00:00.012


SQL> INSERT INTO contenido VALUES (27, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:30:00', 1)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comentario VALUES (27, 'Intento en pub cerrada.', 3, NULL)

ORA-20005: No se admiten nuevos comentarios en una publicacion Cerrada.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT", line 21
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20005/
Error at Line: 71 Column: 0
SQL> INSERT INTO contenido VALUES (28, TO_DATE('2026-06-03','YYYY-MM-DD'), '10:00:00', 2)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comentario VALUES (28, 'Intento sin membresia.', 4, NULL)

ORA-20006: Un agente no puede comentar en una comunidad a la que no pertenece.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT", line 34
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20006/
Error at Line: 76 Column: 0
SQL> INSERT INTO vota VALUES (6, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '08:00:00')



1 row inserted.

Elapsed: 00:00:00.011


SQL> UPDATE Agente SET estado = 'Suspendido' WHERE idAgente = 6



1 row updated.

Elapsed: 00:00:00.003


SQL> INSERT INTO vota VALUES (6, 1, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:00:00')

ORA-20007: Un agente suspendido no puede emitir votos.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 13
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20007/
Error at Line: 93 Column: 0
SQL> UPDATE Agente SET estado = 'Activo' WHERE idAgente = 6



1 row updated.

Elapsed: 00:00:00.003


SQL> INSERT INTO vota VALUES (1, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:30:00')

ORA-20008: Solo los agentes de tipo Observador estan facultados para votar.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 19
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20008/
Error at Line: 98 Column: 0
SQL> INSERT INTO vota VALUES (5, 5, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '10:00:00')

ORA-01403: no data found
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 24
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-01403/
Error at Line: 103 Column: 0
SQL> SELECT votosTotales FROM Publicacion WHERE idContenido = 23

VOTOSTOTALES 
------------ 
1            

Elapsed: 00:00:00.003
1 rows selected. 



SQL> INSERT INTO vota VALUES (5, 23, -1, TO_DATE('2026-06-05','YYYY-MM-DD'), '08:00:00')



1 row inserted.

Elapsed: 00:00:00.002


SQL> SELECT votosTotales FROM Publicacion WHERE idContenido = 23

VOTOSTOTALES 
------------ 
0            

Elapsed: 00:00:00.001
1 rows selected. 



SQL> INSERT INTO modera VALUES (3, 23, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '09:00:00', 'ocultar')



1 row inserted.

Elapsed: 00:00:00.008


SQL> INSERT INTO modera VALUES (4, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '10:00:00', 'ocultar')

ORA-20010: Un agente suspendido no puede realizar tareas de moderacion.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 13
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20010/
Error at Line: 143 Column: 0
SQL> INSERT INTO modera VALUES (1, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '11:00:00', 'cerrar')

ORA-20011: Solo los agentes de tipo Moderador pueden moderar contenido.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 19
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20011/
Error at Line: 146 Column: 0
SQL> INSERT INTO modera VALUES (3, 1, 4, TO_DATE('2026-06-06','YYYY-MM-DD'), '12:00:00', 'cerrar')

ORA-20012: El agente moderador no pertenece a esta comunidad.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 31
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20012/
Error at Line: 149 Column: 0
SQL> INSERT INTO transferencia VALUES (1, 'alice@mail.com', 'bob@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.013


SQL> INSERT INTO transferencia VALUES (5, 'eve@mail.com', 'carol@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'))

ORA-20013: El usuario cedente no es el administrador actual del agente.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_TRANSFERENCIA_BEFORE_INSERT", line 10
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_TRANSFERENCIA_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20013/
Error at Line: 161 Column: 0
SQL> SELECT emailAdmin FROM Agente WHERE idAgente = 1

EMAILADMIN     
-------------- 
bob@mail.com   

Elapsed: 00:00:00.002
1 rows selected. 



SQL> SELECT emailAdmin FROM Agente WHERE idAgente = 5

EMAILADMIN       
---------------- 
alice@mail.com   

Elapsed: 00:00:00.003
1 rows selected. 



SQL> INSERT INTO comunidad VALUES (5, 'NuevaCom', 'Descripcion.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema', 'N', NULL)



1 row inserted.

Elapsed: 00:00:00.005


SQL> INSERT INTO comunidad VALUES (6, 'ArchivedCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema2', 'S', NULL)



1 row inserted.

Elapsed: 00:00:00.002


SQL> SELECT fechaArchivado FROM comunidad WHERE idComunidad = 6

FECHAARCHIVADO            
------------------------- 
06/19/2026, 01:42:54 PM   

Elapsed: 00:00:00.004
1 rows selected. 



SQL> INSERT INTO comunidad VALUES (7, 'MalaCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema3', 'N', TO_DATE('2026-01-01','YYYY-MM-DD'))

ORA-20014: Si la comunidad no esta archivada (N), la fecha debe ser NULL.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMUNIDAD_ARCHIVADO", line 3
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMUNIDAD_ARCHIVADO'

https://docs.oracle.com/error-help/db/ora-20014/
Error at Line: 198 Column: 0
SQL> DELETE FROM vw_publicacion WHERE idContenido = 23



1 row deleted.

Elapsed: 00:00:00.010


SQL> SELECT estado FROM Publicacion WHERE idContenido = 23

ESTADO      
----------- 
Eliminada   

Elapsed: 00:00:00.003
1 rows selected. 



SQL> SELECT COUNT(*) AS visible FROM vw_publicacion WHERE idContenido = 23

VISIBLE 
------- 
0       

Elapsed: 00:00:00.002
1 rows selected. 



SQL> DELETE FROM vw_publicacion WHERE idContenido = 5



0 rows deleted.

Elapsed: 00:00:00.004
