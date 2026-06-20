-- ============================================================
-- TRG-01 | trg_contenido_before_insert
-- ============================================================
INSERT INTO contenido VALUES (20, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 1);
INSERT INTO contenido VALUES (21, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 4);
INSERT INTO contenido VALUES (22, TO_DATE('2026-06-01','YYYY-MM-DD'), '10:00:00', 3);


-- ============================================================
-- TRG-02 | trg_publicacion_before_insert
-- ============================================================
INSERT INTO contenido VALUES (23, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:00:00', 1);
INSERT INTO Publicacion VALUES (23, 'Titulo valido', 'Cuerpo valido', 'Activa', 0, 1);
INSERT INTO contenido VALUES (24, TO_DATE('2026-06-02','YYYY-MM-DD'), '11:30:00', 1);
INSERT INTO Publicacion VALUES (24, 'Arte en comunidad archivada', 'Cuerpo', 'Activa', 0, 3);
INSERT INTO contenido VALUES (25, TO_DATE('2026-06-02','YYYY-MM-DD'), '12:00:00', 2);
INSERT INTO Publicacion VALUES (25, 'Sin membresia en com2', 'Cuerpo', 'Activa', 0, 2);


-- ============================================================
-- TRG-03 | trg_comentario_before_insert
-- ============================================================
INSERT INTO contenido VALUES (26, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:00:00', 1);
INSERT INTO comentario VALUES (26, 'Comentario valido.', 1, NULL);
INSERT INTO contenido VALUES (27, TO_DATE('2026-06-03','YYYY-MM-DD'), '09:30:00', 1);
INSERT INTO comentario VALUES (27, 'Intento en pub cerrada.', 3, NULL);
INSERT INTO contenido VALUES (28, TO_DATE('2026-06-03','YYYY-MM-DD'), '10:00:00', 2);
INSERT INTO comentario VALUES (28, 'Intento sin membresia.', 4, NULL);


-- ============================================================
-- TRG-04 | trg_vota_before_insert
-- ============================================================
INSERT INTO vota VALUES (6, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '08:00:00');
UPDATE Agente SET estado = 'Suspendido' WHERE idAgente = 6;
INSERT INTO vota VALUES (6, 1, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:00:00');
UPDATE Agente SET estado = 'Activo' WHERE idAgente = 6;
INSERT INTO vota VALUES (1, 23, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '09:30:00');
INSERT INTO vota VALUES (5, 5, 1, TO_DATE('2026-06-04','YYYY-MM-DD'), '10:00:00');


-- ============================================================
-- TRG-05 | trg_vota_after_insert
-- ============================================================
INSERT INTO vota VALUES (5, 23, -1, TO_DATE('2026-06-05','YYYY-MM-DD'), '08:00:00');


-- ============================================================
-- TRG-06 | trg_modera_before_insert
-- ============================================================
INSERT INTO modera VALUES (3, 23, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '09:00:00', 'ocultar');
INSERT INTO modera VALUES (4, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '10:00:00', 'ocultar');
INSERT INTO modera VALUES (1, 1, 1, TO_DATE('2026-06-06','YYYY-MM-DD'), '11:00:00', 'cerrar');
INSERT INTO modera VALUES (3, 1, 4, TO_DATE('2026-06-06','YYYY-MM-DD'), '12:00:00', 'cerrar');


-- ============================================================
-- TRG-07 | trg_transferencia_before_insert
-- ============================================================
INSERT INTO transferencia VALUES (1, 'alice@mail.com', 'bob@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));
INSERT INTO transferencia VALUES (5, 'eve@mail.com', 'carol@mail.com', TO_DATE('2026-06-07','YYYY-MM-DD'));


-- ============================================================
-- TRG-09 | trg_comunidad_archivado
-- ============================================================
INSERT INTO comunidad VALUES (5, 'NuevaCom', 'Descripcion.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema', 'N', NULL);
INSERT INTO comunidad VALUES (6, 'ArchivedCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema2', 'S', NULL);
INSERT INTO comunidad VALUES (7, 'MalaCom', 'Desc.', TO_DATE('2026-06-01','YYYY-MM-DD'), 'Tema3', 'N', TO_DATE('2026-01-01','YYYY-MM-DD'));


-- ============================================================
-- TRG-10 | trg_vw_publicacion_delete (INSTEAD OF DELETE)
-- ============================================================
DELETE FROM vw_publicacion WHERE idContenido = 23;