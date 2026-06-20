-- ============================================================
-- TRG-01 | trg_contenido_before_insert
-- ============================================================

-- [OK] Agente 1 (GenBot-Alpha): tipo=Generador, estado=Activo
INSERT INTO contenido VALUES (20, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 1);
1 row inserted.

-- [ERR-20001] Agente 4 (ModBot-Two): estado=Suspendido
INSERT INTO contenido VALUES (21, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 4);
ORA-20001: Un agente suspendido no puede generar contenido.

-- [ERR-20002] Agente 3 (ModBot-One): tipo=Moderador, estado=Activo
INSERT INTO contenido VALUES (22, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 3);
ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.


-- ============================================================
-- TRG-02 | trg_publicacion_before_insert
-- ============================================================

-- [OK] Agente 1, comunidad 1 (TecnologiaIA, no archivada), rol=Miembro Activo
INSERT INTO contenido VALUES (23, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:00:00', 1);
INSERT INTO Publicacion VALUES (23, 'Titulo valido', 'Cuerpo valido', 'Activa', 0, 1);
1 row inserted.

-- [ERR-20003] Comunidad 3 (ArteDigital): archivado='S'
INSERT INTO contenido VALUES (24, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:30:00', 1);
INSERT INTO Publicacion VALUES (24, 'Arte en comunidad archivada', 'Cuerpo', 'Activa', 0, 3);
ORA-20003: No se permiten nuevas publicaciones en comunidades archivadas.

-- [ERR-20004] Agente 2 (GenBot-Beta): Generador activo, pero NO participa en comunidad 2
INSERT INTO contenido VALUES (25, TO_DATE('2026-06-02','YYYY-MM-DD'), '12:00:00', 2);
INSERT INTO Publicacion VALUES (25, 'Sin membresia en com2', 'Cuerpo', 'Activa', 0, 2);
ORA-20004: El agente no es miembro activo de la comunidad.


-- ============================================================
-- TRG-03 | trg_comentario_before_insert
-- ============================================================

-- [OK] Agente 1 comenta publicacion 1 (Activa, comunidad 1, rol=Miembro Activo)
INSERT INTO contenido VALUES (26, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:00:00', 1);
INSERT INTO comentario VALUES (26, 'Comentario valido.', 1, NULL);
1 row inserted.

-- [ERR-20005] Publicacion 3: estado='Cerrada'
INSERT INTO contenido VALUES (27, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:30:00', 1);
INSERT INTO comentario VALUES (27, 'Intento en pub cerrada.', 3, NULL);
ORA-20005: No se pueden agregar comentarios a una publicacion cerrada.

-- [ERR-20006] Agente 2 (GenBot-Beta): NO es Miembro Activo en comunidad 2
INSERT INTO contenido VALUES (28, TO_DATE('2026-06-03','YYYY-MM-DD'), '10:00:00', 2);
INSERT INTO comentario VALUES (28, 'Intento sin membresia.', 4, NULL);
ORA-20006: El agente no es miembro activo de la comunidad de la publicacion.


-- ============================================================
-- TRG-04 | trg_vota_before_insert
-- ============================================================

-- [OK] Agente 6 (ObsBot-Y): tipo=Observador, activo
INSERT INTO vota VALUES (6, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '08:00:00');
1 row inserted.

-- [ERR-20007] Observador suspendido no puede votar
UPDATE Agente SET estado = 'Suspendido' WHERE idAgente = 6;
INSERT INTO vota VALUES (6, 1, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:00:00');
ORA-20007: Un agente suspendido no puede emitir votos.
UPDATE Agente SET estado = 'Activo' WHERE idAgente = 6;

-- [ERR-20008] Agente 1 (GenBot-Alpha): tipo=Generador, no puede votar
INSERT INTO vota VALUES (1, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:30:00');
ORA-20008: Solo los agentes de tipo Observador estan facultados para votar.

-- [ERR-20009] Publicacion 5: estado='Eliminada'
INSERT INTO vota VALUES (5, 5, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '10:00:00');
ORA-01403: no data found


-- ============================================================
-- TRG-05 | trg_vota_after_insert
-- ============================================================

-- [VER] votosTotales antes
SELECT idContenido, votosTotales FROM Publicacion WHERE idContenido IN (1, 2, 4, 23);
IDCONTENIDO  VOTOSTOTALES
-----------  ------------
1            2
2            0
4            2
23           1

-- [OK] Voto negativo de agente 5 sobre pub 23, votosTotales debe decrementar
INSERT INTO vota VALUES (5, 23, -1, TO_DATE('2026-06-05','YYYY-MM-DD'), '08:00:00');
SELECT votosTotales FROM Publicacion WHERE idContenido = 23;
VOTOSTOTALES
------------
0


-- ============================================================
-- TRG-06 | trg_modera_before_insert
-- ============================================================

-- [OK] Agente 3 (ModBot-One): Moderador activo, pertenece a comunidad 1
INSERT INTO modera VALUES (3, 23, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '09:00:00', 'ocultar');
1 row inserted.

-- [ERR-20010] Agente 4 (ModBot-Two): Moderador pero estado=Suspendido
INSERT INTO modera VALUES (4, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '10:00:00', 'ocultar');
ORA-20010: Un agente suspendido no puede realizar tareas de moderacion.

-- [ERR-20011] Agente 1 (GenBot-Alpha): tipo=Generador, no puede moderar
INSERT INTO modera VALUES (1, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '11:00:00', 'cerrar');
ORA-20011: Solo los agentes de tipo Moderador pueden moderar contenido.

-- [ERR-20012] Agente 3 (ModBot-One): NO pertenece a comunidad 4
INSERT INTO modera VALUES (3, 1, 4, TO_DATE('2026-06-06','YYYY-MM-DD'), '12:00:00', 'cerrar');
ORA-20012: El agente moderador no pertenece a esta comunidad.


-- ============================================================
-- TRG-07 | trg_transferencia_before_insert
-- ============================================================

-- [OK] Agente 1: cedente=alice es el admin actual
INSERT INTO transferencia VALUES (1, 'alice@mail.com', 'bob@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));
1 row inserted.

-- [ERR-20013] Agente 5: cedente='eve@mail.com' no es el admin actual
INSERT INTO transferencia VALUES (5, 'eve@mail.com', 'carol@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));
ORA-20013: El usuario cedente no es el administrador actual del agente.


-- ============================================================
-- TRG-08 | trg_transferencia_after_insert
-- ============================================================

-- [VER] Admin de agente 1 debe ser bob@mail.com tras la transferencia
SELECT emailAdmin FROM Agente WHERE idAgente = 1;
EMAILADMIN
--------------
bob@mail.com

-- [VER] Agente 5 no fue transferido, sigue con alice
SELECT emailAdmin FROM Agente WHERE idAgente = 5;
EMAILADMIN
----------------
alice@mail.com


-- ============================================================
-- TRG-09 | trg_comunidad_archivado
-- ============================================================

-- [OK] No archivada con fecha NULL
INSERT INTO comunidad VALUES (5, 'NuevaCom', 'Descripcion.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema', 'N', NULL);
1 row inserted.

-- [OK] Archivada sin fecha: el trigger asigna SYSDATE automaticamente
INSERT INTO comunidad VALUES (6, 'ArchivedCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema2', 'S', NULL);
SELECT fechaArchivado FROM comunidad WHERE idComunidad = 6;
FECHAARCHIVADO
-------------------------
06/19/2026, 01:42:54 PM

-- [ERR-20014] No archivada con fechaArchivado no nula: combinacion invalida
INSERT INTO comunidad VALUES (7, 'MalaCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema3', 'N', TO_DATE('2026-01-01','YYYY-MM-DD'));
ORA-20014: Si la comunidad no esta archivada (N), la fecha debe ser NULL.


-- ============================================================
-- TRG-10 | trg_vw_publicacion_delete (INSTEAD OF DELETE)
-- ============================================================

-- [OK] Eliminar publicacion 23 a traves de la vista
DELETE FROM vw_publicacion WHERE idContenido = 23;
1 row deleted.

-- [VER] El estado en la tabla base debe ser 'Eliminada'
SELECT estado FROM Publicacion WHERE idContenido = 23;
ESTADO
-----------
Eliminada

-- [VER] La vista ya no muestra esa publicacion
SELECT COUNT(*) AS visible FROM vw_publicacion WHERE idContenido = 23;
VISIBLE
-------
0