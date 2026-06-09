 
-- TRG-01: contenido
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


-- TRG-02: Publicacion
CREATE OR REPLACE TRIGGER trg_publicacion_before_insert
BEFORE INSERT ON Publicacion
FOR EACH ROW
DECLARE
    v_archivado  comunidad.archivado%TYPE;
    v_id_agente  contenido.idAgente%TYPE;
    v_es_miembro NUMBER;
BEGIN
    -- Obtener el agente autor desde la superclase contenido
    -- (idContenido de Publicacion == idContenido de contenido por la FK ISA)
    SELECT idAgente
    INTO v_id_agente
    FROM contenido
    WHERE idContenido = :NEW.idContenido;

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


-- TRG-03: comentario
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
    WHERE idContenido = :NEW.idContenido;

    -- Obtener comunidad y estado de la publicacion raiz
    SELECT idComunidad, estado
    INTO v_id_comunidad, v_estado_pub
    FROM Publicacion
    WHERE idContenido = :NEW.idPublicacion;

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
        AND idComunidad = v_id_comunidad
        AND rol         = 'Miembro Activo';

    IF v_es_miembro = 0 THEN
        RAISE_APPLICATION_ERROR(-20006,
            'Un agente no puede comentar en una comunidad a la que no pertenece.');
    END IF;
END;
/


-- TRG-04: vota
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
    WHERE idContenido = :NEW.idPublicacion;

    IF v_estado_pub = 'Eliminada' THEN
        RAISE_APPLICATION_ERROR(-20009,
            'No se puede votar una publicacion en estado Eliminada.');
    END IF;
END;
/


-- TRG-05: vota
CREATE OR REPLACE TRIGGER trg_vota_after_insert
AFTER INSERT ON vota
FOR EACH ROW
BEGIN
    UPDATE Publicacion
       SET votosTotales = votosTotales + :NEW.tipoVoto
     WHERE idContenido = :NEW.idPublicacion;
END;
/



-- TRG-06: modera
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

-- TRG-07: Valida que el cedente sea el administrador actual del agente especifico.
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

    IF v_admin_actual != :NEW.emailCedente THEN
        RAISE_APPLICATION_ERROR(-20013,
            'El usuario cedente no es el administrador actual del agente.');
    END IF;
END;
/


-- TRG-08: Actualiza emailAdmin en el Agente especifico.
CREATE OR REPLACE TRIGGER trg_transferencia_after_insert
AFTER INSERT ON transferencia
FOR EACH ROW
BEGIN
    UPDATE Agente
    SET    emailAdmin = :NEW.emailReceptor
    WHERE  idAgente   = :NEW.idAgente;
END;
/

-- TRG-09: Consistencia de fechaArchivado en comunidad
CREATE OR REPLACE TRIGGER trg_comunidad_archivado
BEFORE INSERT OR UPDATE ON comunidad
FOR EACH ROW
BEGIN
    IF :NEW.archivado = 'N' AND :NEW.fechaArchivado IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20014, 'Si la comunidad no esta archivada (N), la fecha debe ser NULL.');
    ELSIF :NEW.archivado = 'S' AND :NEW.fechaArchivado IS NULL THEN
        :NEW.fechaArchivado := SYSDATE;
    END IF;
END;
/

-- TRG-10: Borrado logico en la vista vw_publicacion
CREATE OR REPLACE TRIGGER trg_vw_publicacion_delete
INSTEAD OF DELETE ON vw_publicacion
FOR EACH ROW
BEGIN
    UPDATE Publicacion
    SET estado = 'Eliminada'
    WHERE idContenido = :OLD.idContenido;
END;
/
