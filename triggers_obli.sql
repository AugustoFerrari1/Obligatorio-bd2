-- ============================================================
--  MOLTBOOK - TRIGGERS DE RESTRICCIONES NO ESTRUCTURALES
--  Motor: Oracle (PL/SQL)
-- ============================================================
--
--  INDICE DE TRIGGERS
--  ─────────────────────────────────────────────────────────
--  TRG-01  trg_contenido_before_insert
--          Agente activo + tipo Generador al crear contenido
--
--  TRG-02  trg_publicacion_before_insert
--          Comunidad no archivada + agente Miembro Activo
--
--  TRG-03  trg_comentario_before_insert
--          Publicacion no cerrada + agente pertenece comunidad
--
--  TRG-04  trg_vota_before_insert
--          Agente activo + tipo Observador + pub no eliminada
--
--  TRG-05  trg_vota_after_insert
--          Actualiza votosTotales en Publicacion (NUEVO)
--
--  TRG-06  trg_modera_before_insert
--          Agente activo + tipo Moderador + pertenece comunidad
--
--  TRG-07  trg_transferencia_before_insert
--          emailOrigen debe ser el admin actual del agente (NUEVO)
--
--  TRG-08  trg_transferencia_after_insert
--          Actualiza emailAdmin en Agente tras la transferencia (NUEVO)
-- ============================================================


-- ============================================================
-- TRG-01: contenido - antes de insertar
--
-- Errores en tu version:
--   (ninguno de logica, estaba bien)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_contenido_before_insert
BEFORE INSERT ON contenido
FOR EACH ROW
DECLARE
    v_estado Agente.estado%TYPE;
    v_tipo   Agente.tipo%TYPE;
BEGIN
    SELECT estado, tipo
      INTO v_estado, v_tipo
      FROM Agente
     WHERE idAgente = :NEW.idAgente;

    -- Regla: agente suspendido no genera contenido
    IF v_estado = 'Suspendido' THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Un agente suspendido no puede generar contenido.');
    END IF;

    -- Regla: solo tipo Generador puede crear publicaciones/comentarios
    IF v_tipo != 'Generador' THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Solo agentes de tipo Generador pueden crear publicaciones o comentarios.');
    END IF;
END;
/


-- ============================================================
-- TRG-02: Publicacion - antes de insertar
--
-- Errores en tu version:
--   1. Columna 'fechaArchivada' no existe → es 'archivado' CHAR(1) 'S'/'N'
--   2. Tabla 'Miembro_Comunidad' no existe → es 'participa' con rol = 'Miembro Activo'
--   3. Para obtener el agente, en nuestra PK Publicacion.idPublicacion
--      ES el mismo valor que contenido.idContenido → usar :NEW.idPublicacion
-- ============================================================
CREATE OR REPLACE TRIGGER trg_publicacion_before_insert
BEFORE INSERT ON Publicacion
FOR EACH ROW
DECLARE
    v_archivado  comunidad.archivado%TYPE;
    v_id_agente  contenido.idAgente%TYPE;
    v_es_miembro NUMBER;
BEGIN
    -- Obtener el agente autor desde la superclase contenido
    -- (idPublicacion == idContenido por la FK ISA)
    SELECT idAgente
      INTO v_id_agente
      FROM contenido
     WHERE idContenido = :NEW.idPublicacion;

    -- Regla: comunidad archivada no acepta publicaciones
    SELECT archivado
      INTO v_archivado
      FROM comunidad
     WHERE idComunidad = :NEW.idComunidad;

    IF v_archivado = 'S' THEN
        RAISE_APPLICATION_ERROR(-20003,
            'No se permiten nuevas publicaciones en comunidades archivadas.');
    END IF;

    -- Regla: el agente debe ser Miembro Activo de la comunidad
    SELECT COUNT(*)
      INTO v_es_miembro
      FROM participa
     WHERE idAgente    = v_id_agente
       AND idComunidad = :NEW.idComunidad
       AND rol         = 'Miembro Activo';

    IF v_es_miembro = 0 THEN
        RAISE_APPLICATION_ERROR(-20004,
            'El agente debe ser Miembro Activo de la comunidad para publicar.');
    END IF;
END;
/


-- ============================================================
-- TRG-03: comentario - antes de insertar
--
-- Errores en tu version:
--   1. Columna 'idPublicacionRaiz' no existe → es 'idPublicacion'
--   2. 'Publicacion.idContenido' no existe → la PK es 'idPublicacion'
--   3. 'Miembro_Comunidad' no existe → usar 'participa'
--   4. Para el agente usar idComentario (= idContenido por ISA)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_comentario_before_insert
BEFORE INSERT ON comentario
FOR EACH ROW
DECLARE
    v_id_agente    contenido.idAgente%TYPE;
    v_id_comunidad Publicacion.idComunidad%TYPE;
    v_estado_pub   Publicacion.estado%TYPE;
    v_es_miembro   NUMBER;
BEGIN
    -- Obtener el agente autor del comentario desde contenido
    SELECT idAgente
      INTO v_id_agente
      FROM contenido
     WHERE idContenido = :NEW.idComentario;

    -- Obtener comunidad y estado de la publicacion raiz
    SELECT idComunidad, estado
      INTO v_id_comunidad, v_estado_pub
      FROM Publicacion
     WHERE idPublicacion = :NEW.idPublicacion;

    -- Regla: publicacion cerrada no admite comentarios
    IF v_estado_pub = 'Cerrada' THEN
        RAISE_APPLICATION_ERROR(-20005,
            'No se admiten nuevos comentarios en una publicacion Cerrada.');
    END IF;

    -- Regla: el agente debe pertenecer a la comunidad del post
    SELECT COUNT(*)
      INTO v_es_miembro
      FROM participa
     WHERE idAgente    = v_id_agente
       AND idComunidad = v_id_comunidad;

    IF v_es_miembro = 0 THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Un agente no puede comentar en una comunidad a la que no pertenece.');
    END IF;
END;
/


-- ============================================================
-- TRG-04: vota - antes de insertar
--
-- Errores en tu version:
--   1. Nombre de tabla 'Voto' no existe → es 'vota'
--   2. Faltaba validar que la publicacion no este Eliminada
-- ============================================================
CREATE OR REPLACE TRIGGER trg_vota_before_insert
BEFORE INSERT ON vota
FOR EACH ROW
DECLARE
    v_estado     Agente.estado%TYPE;
    v_tipo       Agente.tipo%TYPE;
    v_estado_pub Publicacion.estado%TYPE;
BEGIN
    SELECT estado, tipo
      INTO v_estado, v_tipo
      FROM Agente
     WHERE idAgente = :NEW.idAgente;

    -- Regla: agente suspendido no puede votar
    IF v_estado = 'Suspendido' THEN
        RAISE_APPLICATION_ERROR(-20007,
            'Un agente suspendido no puede emitir votos.');
    END IF;

    -- Regla: solo Observadores pueden votar
    IF v_tipo != 'Observador' THEN
        RAISE_APPLICATION_ERROR(-20008,
            'Solo los agentes de tipo Observador estan facultados para votar.');
    END IF;

    -- Regla adicional: no se puede votar publicaciones eliminadas
    SELECT estado
      INTO v_estado_pub
      FROM Publicacion
     WHERE idPublicacion = :NEW.idPublicacion;

    IF v_estado_pub = 'Eliminada' THEN
        RAISE_APPLICATION_ERROR(-20009,
            'No se puede votar una publicacion en estado Eliminada.');
    END IF;
END;
/


-- ============================================================
-- TRG-05: vota - despues de insertar  [NUEVO - FALTABA]
--
-- Actualiza atomicamente el atributo derivado votosTotales
-- en Publicacion cada vez que se registra un nuevo voto.
-- (Mencionado en el analisis como requisito de diseno)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_vota_after_insert
AFTER INSERT ON vota
FOR EACH ROW
BEGIN
    UPDATE Publicacion
       SET votosTotales = votosTotales + :NEW.valor
     WHERE idPublicacion = :NEW.idPublicacion;
END;
/


-- ============================================================
-- TRG-06: modera - antes de insertar
--
-- Errores en tu version:
--   1. Nombre de tabla 'Moderacion' no existe → es 'modera'
--   2. 'Moderador_Comunidad' no existe → usar 'participa'
--      (el tipo Moderador se controla por Agente.tipo)
-- ============================================================
CREATE OR REPLACE TRIGGER trg_modera_before_insert
BEFORE INSERT ON modera
FOR EACH ROW
DECLARE
    v_estado     Agente.estado%TYPE;
    v_tipo       Agente.tipo%TYPE;
    v_pertenece  NUMBER;
BEGIN
    SELECT estado, tipo
      INTO v_estado, v_tipo
      FROM Agente
     WHERE idAgente = :NEW.idAgente;

    -- Regla: agente suspendido no puede moderar
    IF v_estado = 'Suspendido' THEN
        RAISE_APPLICATION_ERROR(-20010,
            'Un agente suspendido no puede realizar tareas de moderacion.');
    END IF;

    -- Regla: solo tipo Moderador puede moderar
    IF v_tipo != 'Moderador' THEN
        RAISE_APPLICATION_ERROR(-20011,
            'Solo los agentes de tipo Moderador pueden moderar contenido.');
    END IF;

    -- Regla: el moderador debe pertenecer a esa comunidad especifica
    SELECT COUNT(*)
      INTO v_pertenece
      FROM participa
     WHERE idAgente    = :NEW.idAgente
       AND idComunidad = :NEW.idComunidad;

    IF v_pertenece = 0 THEN
        RAISE_APPLICATION_ERROR(-20012,
            'El agente moderador no pertenece a esta comunidad.');
    END IF;
END;
/


-- ============================================================
-- TRG-07: transferencia - antes de insertar  [NUEVO - FALTABA]
--
-- Valida que emailOrigen sea efectivamente el administrador
-- actual del agente antes de registrar la transferencia.
-- Sin esto se podria registrar una transferencia fraudulenta.
-- ============================================================
CREATE OR REPLACE TRIGGER trg_transferencia_before_insert
BEFORE INSERT ON transferencia
FOR EACH ROW
DECLARE
    v_admin_actual Agente.emailAdmin%TYPE;
BEGIN
    SELECT emailAdmin
      INTO v_admin_actual
      FROM Agente
     WHERE idAgente = :NEW.idAgente;

    IF v_admin_actual != :NEW.emailOrigen THEN
        RAISE_APPLICATION_ERROR(-20013,
            'El usuario origen no es el administrador actual del agente.');
    END IF;
END;
/


-- ============================================================
-- TRG-08: transferencia - despues de insertar  [NUEVO - FALTABA]
--
-- Tras registrar la transferencia, actualiza emailAdmin en
-- Agente para reflejar el nuevo administrador vigente.
-- Garantiza consistencia entre la tabla transferencia y el
-- campo emailAdmin que siempre muestra el dueno actual.
-- ============================================================
CREATE OR REPLACE TRIGGER trg_transferencia_after_insert
AFTER INSERT ON transferencia
FOR EACH ROW
BEGIN
    UPDATE Agente
       SET emailAdmin = :NEW.emailDestino
     WHERE idAgente   = :NEW.idAgente;
END;
/
