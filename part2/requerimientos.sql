-- REQ 2.1 - Registrar nuevo agente
--
-- Crea un agente nuevo y su primer registro en el historial.
-- Parametros de entrada:
--   p_idAgente        : id del nuevo agente
--   p_nombre          : nombre del agente
--   p_fechaCreacion   : fecha de creacion
--   p_descripcion     : descripcion del agente
--   p_tipo            : Generador | Moderador | Observador
--   p_config          : Simple | Compuesta
--   p_emailAdmin      : email del usuario humano responsable
--   p_descHistorial   : descripcion del primer registro historico

CREATE OR REPLACE PROCEDURE sp_registrar_agente (
    p_idAgente       IN INT,
    p_nombre         IN VARCHAR2,
    p_fechaCreacion  IN DATE,
    p_descripcion    IN VARCHAR2,
    p_tipo           IN VARCHAR2,
    p_config         IN VARCHAR2,
    p_emailAdmin     IN VARCHAR2,
    p_descHistorial  IN VARCHAR2
) AS
BEGIN
    -- Insertar el agente nuevo
    INSERT INTO Agente (idAgente, nombre, fechaCreacion, descripcion, tipo, config, estado, emailAdmin)
    VALUES (p_idAgente, p_nombre, p_fechaCreacion, p_descripcion, p_tipo, p_config, 'Activo', p_emailAdmin);

    -- Crear el primer registro del historial (version 1)
    INSERT INTO historial (idAgente, version, fechaAplicacion, descripcion)
    VALUES (p_idAgente, 1, p_fechaCreacion, p_descHistorial);

    DBMS_OUTPUT.PUT_LINE('Agente ' || p_nombre || ' registrado correctamente con version 1 en historial.');
END sp_registrar_agente;
/


-- REQ 2.2 - Transferencia de administracion
--
-- Transfiere la administracion de un agente a otro usuario.
-- Los triggers TRG-07 y TRG-08 se encargan de validar
-- que el emailOrigen sea el admin actual y de actualizar
-- emailAdmin en Agente automaticamente.
-- Parametros de entrada:
--   p_idAgente      : id del agente a transferir
--   p_emailOrigen   : email del admin actual (quien cede)
--   p_emailDestino  : email del nuevo admin (quien recibe)
--   p_fecha         : fecha de la transferencia

CREATE OR REPLACE PROCEDURE sp_transferir_agente (
    p_idAgente      IN INT,
    p_emailOrigen   IN VARCHAR2,
    p_emailDestino  IN VARCHAR2,
    p_fecha         IN DATE
) AS
    v_adminActual   VARCHAR2(100);
    v_existeOrigen  INT;
    v_existeDestino INT;
BEGIN
    -- Verificar que el agente exista
    SELECT emailAdmin
    INTO v_adminActual
    FROM Agente
    WHERE idAgente = p_idAgente;

    -- Verificar que emailOrigen sea el admin actual
    IF v_adminActual != p_emailOrigen THEN
        DBMS_OUTPUT.PUT_LINE('Error: el emailOrigen no es el administrador actual del agente.');
        RETURN;
    END IF;

    -- Verificar que origen y destino no sean el mismo
    IF p_emailOrigen = p_emailDestino THEN
        DBMS_OUTPUT.PUT_LINE('Error: el origen y el destino no pueden ser el mismo usuario.');
        RETURN;
    END IF;

    -- Insertar la transferencia
    -- TRG-07 valida emailOrigen y TRG-08 actualiza emailAdmin en Agente
    INSERT INTO transferencia (idAgente, emailOrigen, emailDestino, fecha)
    VALUES (p_idAgente, p_emailOrigen, p_emailDestino, p_fecha);

    DBMS_OUTPUT.PUT_LINE('Transferencia registrada. Nuevo admin: ' || p_emailDestino);
END sp_transferir_agente;
/


-- REQ 2.3 - Generar publicacion  
--
-- Un agente Generador publica en una comunidad.
-- Los triggers TRG-01 y TRG-02 validan:
--   - Agente activo y tipo Generador
--   - Comunidad no archivada
--   - Agente es Miembro Activo de la comunidad
-- Parametros de entrada:
--   p_idContenido  : id unico (para contenido y publicacion)
--   p_titulo       : titulo de la publicacion
--   p_cuerpo       : texto de la publicacion
--   p_fecha        : fecha de creacion
--   p_hora         : hora de creacion
--   p_idAgente     : agente que publica
--   p_idComunidad  : comunidad donde se publica

CREATE OR REPLACE PROCEDURE sp_generar_publicacion (
    p_idContenido  IN INT,
    p_titulo       IN VARCHAR2,
    p_cuerpo       IN VARCHAR2,
    p_fecha        IN DATE,
    p_hora         IN VARCHAR2,
    p_idAgente     IN INT,
    p_idComunidad  IN INT
) AS
BEGIN
    -- TRG-01 valida que el agente este activo y sea Generador
    INSERT INTO contenido (idContenido, fechaCreacion, horaCreacion, idAgente)
    VALUES (p_idContenido, p_fecha, p_hora, p_idAgente);

    -- TRG-02 valida comunidad no archivada y que sea Miembro Activo
    INSERT INTO Publicacion (idPublicacion, titulo, cuerpo, estado, fechaCreacion, horaCreacion, votosTotales, idComunidad)
    VALUES (p_idContenido, p_titulo, p_cuerpo, 'Activa', p_fecha, p_hora, 0, p_idComunidad);

    DBMS_OUTPUT.PUT_LINE('Publicacion creada correctamente con id: ' || p_idContenido);
END sp_generar_publicacion;
/


-- REQ 2.4 - Emitir voto  
--
-- Un agente Observador vota una publicacion.
-- Los triggers TRG-04 y TRG-05 validan:
--   - Agente activo y tipo Observador
--   - Publicacion no eliminada
--   - Actualiza votosTotales automaticamente
-- Parametros de entrada:
--   p_idAgente      : agente que vota
--   p_idPublicacion : publicacion votada
--   p_valor         : 1 (positivo) o -1 (negativo)
--   p_fecha         : fecha del voto
--   p_hora          : hora del voto

CREATE OR REPLACE PROCEDURE sp_emitir_voto (
    p_idAgente      IN INT,
    p_idPublicacion IN INT,
    p_valor         IN INT,
    p_fecha         IN DATE,
    p_hora          IN VARCHAR2
) AS
BEGIN
    -- Validar que el valor sea 1 o -1
    IF p_valor != 1 AND p_valor != -1 THEN
        DBMS_OUTPUT.PUT_LINE('Error: el valor del voto debe ser 1 o -1.');
        RETURN;
    END IF;

    -- Insertar el voto
    -- TRG-04 valida tipo Observador, activo y pub no eliminada
    -- TRG-05 actualiza votosTotales en Publicacion automaticamente
    INSERT INTO vota (idAgente, idPublicacion, valor, fecha, hora)
    VALUES (p_idAgente, p_idPublicacion, p_valor, p_fecha, p_hora);

    DBMS_OUTPUT.PUT_LINE('Voto registrado correctamente.');
END sp_emitir_voto;
/


-- REQ 2.5 - Generar comentario 

-- Un agente Generador comenta en una publicacion o responde
-- a otro comentario.
-- Los triggers TRG-01 y TRG-03 validan:
--   - Agente activo y tipo Generador
--   - Publicacion no cerrada
--   - Agente pertenece a la comunidad del post
-- Parametros de entrada:
--   p_idContenido        : id unico para contenido y comentario
--   p_cuerpo             : texto del comentario
--   p_fecha              : fecha del comentario
--   p_hora               : hora del comentario
--   p_idAgente           : agente que comenta
--   p_idPublicacion      : id publicacion raiz
--   p_idComentarioPadre  : NULL si responde directo a la pub,
--                          o el id del comentario que responde

CREATE OR REPLACE PROCEDURE sp_generar_comentario (
    p_idContenido       IN INT,
    p_cuerpo            IN VARCHAR2,
    p_fecha             IN DATE,
    p_hora              IN VARCHAR2,
    p_idAgente          IN INT,
    p_idPublicacion     IN INT,
    p_idComentarioPadre IN INT
) AS
BEGIN
    -- TRG-01 valida que el agente este activo y sea Generador
    INSERT INTO contenido (idContenido, fechaCreacion, horaCreacion, idAgente)
    VALUES (p_idContenido, p_fecha, p_hora, p_idAgente);

    -- TRG-03 valida publicacion no cerrada y pertenencia a comunidad
    INSERT INTO comentario (idComentario, cuerpo, fechaComentario, horaComentario, idPublicacion, idComentarioPadre)
    VALUES (p_idContenido, p_cuerpo, p_fecha, p_hora, p_idPublicacion, p_idComentarioPadre);

    DBMS_OUTPUT.PUT_LINE('Comentario registrado correctamente con id: ' || p_idContenido);
END sp_generar_comentario;
/


-- REQ 2.6 - Ejecutar accion de moderacion
--
-- Un agente Moderador ejecuta una accion sobre contenido
-- de una comunidad.
-- El trigger TRG-06 valida:
--   - Agente activo y tipo Moderador
--   - Agente pertenece a la comunidad
-- El procedimiento ademas actualiza el estado de la
-- Publicacion si la accion es 'cerrar' o 'eliminar'.
-- Parametros de entrada:
--   p_idAgente     : agente moderador
--   p_idContenido  : contenido a moderar
--   p_idComunidad  : comunidad donde ocurre la moderacion
--   p_fecha        : fecha de la accion
--   p_hora         : hora de la accion
--   p_accion       : 'ocultar' | 'cerrar' | 'eliminar'

CREATE OR REPLACE PROCEDURE sp_moderar_contenido (
    p_idAgente    IN INT,
    p_idContenido IN INT,
    p_idComunidad IN INT,
    p_fecha       IN DATE,
    p_hora        IN VARCHAR2,
    p_accion      IN VARCHAR2
) AS
    v_esPublicacion INT;
BEGIN
    -- Registrar la accion de moderacion
    -- TRG-06 valida que sea Moderador activo y pertenezca a la comunidad
    INSERT INTO modera (idAgente, idContenido, idComunidad, fecha, hora, accion)
    VALUES (p_idAgente, p_idContenido, p_idComunidad, p_fecha, p_hora, p_accion);

    -- Si la accion es 'cerrar' o 'eliminar', actualizar el estado de la publicacion
    -- (solo aplica si el contenido es una publicacion)
    IF p_accion = 'cerrar' OR p_accion = 'eliminar' THEN

        -- Verificar si el contenido es una publicacion
        SELECT COUNT(*) INTO v_esPublicacion
        FROM Publicacion
        WHERE idPublicacion = p_idContenido;

        IF v_esPublicacion > 0 THEN
            IF p_accion = 'cerrar' THEN
                UPDATE Publicacion
                SET estado = 'Cerrada'
                WHERE idPublicacion = p_idContenido;
                DBMS_OUTPUT.PUT_LINE('Publicacion ' || p_idContenido || ' cerrada.');
            ELSIF p_accion = 'eliminar' THEN
                UPDATE Publicacion
                SET estado = 'Eliminada'
                WHERE idPublicacion = p_idContenido;
                DBMS_OUTPUT.PUT_LINE('Publicacion ' || p_idContenido || ' marcada como eliminada.');
            END IF;
        END IF;

    END IF;

    DBMS_OUTPUT.PUT_LINE('Accion de moderacion "' || p_accion || '" registrada correctamente.');
END sp_moderar_contenido;
/


-- REQ 2.7 - Actualizar configuracion del agente  

-- Agrega una nueva version al historial y actualiza
-- la configuracion activa del agente.
-- Parametros de entrada:
--   p_idAgente    : agente a actualizar
--   p_nuevaConfig : nueva configuracion 
--   p_descripcion : descripcion del cambio
--   p_fecha       : fecha de aplicacion

CREATE OR REPLACE PROCEDURE sp_actualizar_config (
    p_idAgente    IN INT,
    p_nuevaConfig IN VARCHAR2,
    p_descripcion IN VARCHAR2,
    p_fecha       IN DATE
) AS
    v_ultimaVersion INT;
    v_nuevaVersion  INT;
BEGIN

    SELECT NVL(MAX(version), 0) INTO v_ultimaVersion 
    FROM historial 
    WHERE idAgente = p_idAgente;

    -- Calcular la nueva version
    v_nuevaVersion := v_ultimaVersion + 1;

    -- Insertar el nuevo registro en el historial
    INSERT INTO historial (idAgente, version, fechaAplicacion, descripcion)
    VALUES (p_idAgente, v_nuevaVersion, p_fecha, p_descripcion);

    -- Actualizar la configuracion activa del agente
    UPDATE Agente
    SET config = p_nuevaConfig
    WHERE idAgente = p_idAgente;

    DBMS_OUTPUT.PUT_LINE('Agente ' || p_idAgente || ' actualizado a version ' || v_nuevaVersion || ' con config: ' || p_nuevaConfig);
END sp_actualizar_config;
/

-- REQ 2.8 - Ranking de publicaciones
--
-- Retorna las 10 publicaciones activas con mayor puntaje
-- en una comunidad, en los ultimos 30 dias.
-- Tiene un filtro opcional por emailAdmin del agente autor.
-- Parametros de entrada:
--   p_idComunidad : comunidad a consultar
--   p_emailAdmin  : filtro opcional (NULL = sin filtro)
-- Salida: se muestra en pantalla con DBMS_OUTPUT

CREATE OR REPLACE PROCEDURE sp_ranking_publicaciones (
    p_idComunidad IN INT,
    p_emailAdmin  IN VARCHAR2
) AS
    v_contador  INT := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RANKING - Comunidad: ' || p_idComunidad || ' ===');
    DBMS_OUTPUT.PUT_LINE('Puesto | Votos | Titulo                | Fecha      | Agente          | Admin');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------------------------');

    -- Iterar usando un cursor implicito con FOR
    FOR v_fila IN (
        SELECT p.votosTotales,
               p.titulo,
               p.fechaCreacion,
               a.nombre      AS nombreAgente,
               a.emailAdmin
        FROM Publicacion p
        JOIN contenido   c ON c.idContenido = p.idPublicacion
        JOIN Agente      a ON a.idAgente    = c.idAgente
        WHERE p.idComunidad   = p_idComunidad
          AND p.estado        = 'Activa'
          AND p.fechaCreacion >= SYSDATE - 30
          AND (p_emailAdmin IS NULL OR a.emailAdmin = p_emailAdmin)
        ORDER BY p.votosTotales DESC
        FETCH FIRST 10 ROWS ONLY
    ) LOOP
        v_contador := v_contador + 1;

        DBMS_OUTPUT.PUT_LINE(
            v_contador          || '      | ' ||
            v_fila.votosTotales || '     | ' ||
            v_fila.titulo       || ' | ' ||
            v_fila.fechaCreacion|| ' | ' ||
            v_fila.nombreAgente || ' | ' ||
            v_fila.emailAdmin
        );
    END LOOP;

    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron publicaciones activas en los ultimos 30 dias.');
    END IF;
END sp_ranking_publicaciones;
/