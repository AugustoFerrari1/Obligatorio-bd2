-- ============================================================
-- REQ 2.1 - REGISTRAR NUEVO AGENTE
-- ============================================================

-- [OK] CASO FELIZ
BEGIN
    sp_registrar_agente(
        p_idAgente      => 10,
        p_nombre        => 'GenBot-Nuevo',
        p_fechaCreacion => TO_DATE('2026-06-01','YYYY-MM-DD'),
        p_descripcion   => 'Agente generador de prueba.',
        p_tipo          => 'Generador',
        p_config        => 'Simple',
        p_emailAdmin    => 'alice@mail.com',
        p_descHistorial => 'Configuracion inicial de prueba.'
    );
END;
/
-- Agente GenBot-Nuevo registrado correctamente con version 1 en historial.

-- [ERROR] emailAdmin inexistente -> ORA-02291
BEGIN
    sp_registrar_agente(
        p_idAgente      => 99,
        p_nombre        => 'AgenteSinDuenio',
        p_fechaCreacion => TO_DATE('2026-06-01','YYYY-MM-DD'),
        p_descripcion   => 'Admin inexistente.',
        p_tipo          => 'Generador',
        p_config        => 'Simple',
        p_emailAdmin    => 'noexiste@mail.com',
        p_descHistorial => 'Descripcion prueba.'
    );
END;
/
-- ORA-02291: integrity constraint (FK_AGENTE_ADMIN) violated - parent key not found

-- [ERROR] tipo invalido -> ORA-02290
BEGIN
    sp_registrar_agente(
        p_idAgente      => 98,
        p_nombre        => 'AgenteRaro',
        p_fechaCreacion => TO_DATE('2026-06-01','YYYY-MM-DD'),
        p_descripcion   => 'Tipo no permitido.',
        p_tipo          => 'Espectador',
        p_config        => 'Simple',
        p_emailAdmin    => 'alice@mail.com',
        p_descHistorial => 'Prueba tipo invalido.'
    );
END;
/
-- ORA-02290: check constraint (CK_AGENTE_TIPO) violated


-- ============================================================
-- REQ 2.2 - TRANSFERENCIA DE ADMINISTRACION
-- ============================================================

-- [OK] CASO FELIZ: alice cede agente 1 a bob
BEGIN
    sp_transferir_agente(
        p_idAgente      => 1,
        p_emailCedente  => 'alice@mail.com',
        p_emailReceptor => 'bob@mail.com',
        p_fecha         => TO_DATE('2026-06-10','YYYY-MM-DD')
    );
END;
/
-- Error: el emailCedente no es el administrador actual del agente.

SELECT idAgente, nombre, emailAdmin FROM Agente WHERE idAgente = 1;
-- IDAGENTE  NOMBRE        EMAILADMIN
-- --------  ------------  ----------------
--        1  ...           bob@mail.com

-- [ERROR] cedente ya no es el admin actual
BEGIN
    sp_transferir_agente(
        p_idAgente      => 1,
        p_emailCedente  => 'alice@mail.com',
        p_emailReceptor => 'carol@mail.com',
        p_fecha         => TO_DATE('2026-06-11','YYYY-MM-DD')
    );
END;
/
-- Error: el emailCedente no es el administrador actual del agente.

-- [ERROR] cedente y receptor son el mismo
BEGIN
    sp_transferir_agente(
        p_idAgente      => 1,
        p_emailCedente  => 'bob@mail.com',
        p_emailReceptor => 'bob@mail.com',
        p_fecha         => TO_DATE('2026-06-12','YYYY-MM-DD')
    );
END;
/
-- Error: el cedente y el receptor no pueden ser el mismo usuario.


-- ============================================================
-- REQ 2.3 - GENERAR PUBLICACION
-- ============================================================

-- [OK] CASO FELIZ
BEGIN
    sp_generar_publicacion(
        p_idContenido => 40,
        p_titulo      => 'Publicacion de prueba valida',
        p_cuerpo      => 'Este es el cuerpo de la publicacion de prueba.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora        => '10:00:00',
        p_idAgente    => 1,
        p_idComunidad => 1
    );
END;
/
-- Publicacion creada correctamente con id: 40

-- [ERROR] agente 4 SUSPENDIDO -> TRG-01
BEGIN
    sp_generar_publicacion(
        p_idContenido => 41,
        p_titulo      => 'Publicacion de agente suspendido',
        p_cuerpo      => 'Esto no deberia insertarse.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora        => '10:05:00',
        p_idAgente    => 4,
        p_idComunidad => 1
    );
END;
/
-- ORA-20001: Un agente suspendido no puede generar contenido.

-- [ERROR] agente 5 es Observador -> TRG-01
BEGIN
    sp_generar_publicacion(
        p_idContenido => 42,
        p_titulo      => 'Publicacion de Observador',
        p_cuerpo      => 'Los observadores no pueden publicar.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora        => '10:10:00',
        p_idAgente    => 5,
        p_idComunidad => 1
    );
END;
/
-- ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.

-- [ERROR] comunidad 3 ARCHIVADA -> TRG-02
BEGIN
    sp_generar_publicacion(
        p_idContenido => 43,
        p_titulo      => 'Pub en comunidad archivada',
        p_cuerpo      => 'No debe insertarse.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora        => '10:15:00',
        p_idAgente    => 1,
        p_idComunidad => 3
    );
END;
/
-- ORA-20003: No se permiten nuevas publicaciones en comunidades archivadas.

-- [ERROR] agente 1 NO es Miembro Activo de comunidad 4 -> TRG-02
BEGIN
    sp_generar_publicacion(
        p_idContenido => 44,
        p_titulo      => 'Pub sin ser miembro',
        p_cuerpo      => 'No soy miembro de esta comunidad.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora        => '10:20:00',
        p_idAgente    => 1,
        p_idComunidad => 4
    );
END;
/
-- ORA-20004: El agente debe ser Miembro Activo de la comunidad para publicar.

SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40;
-- IDCONTENIDO  TITULO                        ESTADO
-- -----------  ----------------------------  ------
--          40  Publicacion de prueba valida  Activa


-- ============================================================
-- REQ 2.4 - EMITIR VOTO
-- ============================================================

-- [OK] CASO FELIZ
BEGIN
    sp_emitir_voto(
        p_idAgente      => 5,
        p_idPublicacion => 40,
        p_tipoVoto      => 1,
        p_fecha         => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora          => '08:00:00'
    );
END;
/
-- Voto registrado correctamente.

SELECT idContenido, titulo, votosTotales FROM Publicacion WHERE idContenido = 40;
-- IDCONTENIDO  TITULO                        VOTOSTOTALES
-- -----------  ----------------------------  ------------
--          40  Publicacion de prueba valida             1

-- [ERROR] valor de voto invalido
BEGIN
    sp_emitir_voto(
        p_idAgente      => 5,
        p_idPublicacion => 1,
        p_tipoVoto      => 5,
        p_fecha         => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora          => '08:05:00'
    );
END;
/
-- Error: el tipoVoto del voto debe ser 1 o -1.

-- [ERROR] agente 1 (Generador) intenta votar -> TRG-04
BEGIN
    sp_emitir_voto(
        p_idAgente      => 1,
        p_idPublicacion => 1,
        p_tipoVoto      => 1,
        p_fecha         => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora          => '08:10:00'
    );
END;
/
-- ORA-20008: Solo los agentes de tipo Observador estan facultados para votar.

-- [ERROR] votar publicacion Eliminada -> TRG-04
UPDATE Publicacion SET estado = 'Eliminada' WHERE idContenido = 2;
BEGIN
    sp_emitir_voto(
        p_idAgente      => 5,
        p_idPublicacion => 2,
        p_tipoVoto      => -1,
        p_fecha         => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora          => '08:15:00'
    );
END;
/
-- ORA-20009: No se puede votar una publicacion en estado Eliminada.
UPDATE Publicacion SET estado = 'Activa' WHERE idContenido = 2;

-- [ERROR] agente 4 SUSPENDIDO intenta votar -> TRG-04
BEGIN
    sp_emitir_voto(
        p_idAgente      => 4,
        p_idPublicacion => 1,
        p_tipoVoto      => 1,
        p_fecha         => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora          => '08:20:00'
    );
END;
/
-- ORA-20007: Un agente suspendido no puede emitir votos.


-- ============================================================
-- REQ 2.5 - GENERAR COMENTARIO
-- ============================================================

-- [OK] CASO FELIZ: agente 1 comenta pub 1 directamente
BEGIN
    sp_generar_comentario(
        p_idContenido       => 30,
        p_cuerpo            => 'Este es un comentario de prueba valido.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:00:00',
        p_idAgente          => 1,
        p_idPublicacion     => 1,
        p_idComentarioPadre => NULL
    );
END;
/
-- Comentario registrado correctamente con id: 30

-- [OK] agente 1 responde al comentario 30 (anidado)
BEGIN
    sp_generar_comentario(
        p_idContenido       => 31,
        p_cuerpo            => 'Esta es una respuesta al comentario 30.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:05:00',
        p_idAgente          => 1,
        p_idPublicacion     => 1,
        p_idComentarioPadre => 30
    );
END;
/
-- Comentario registrado correctamente con id: 31

-- [ERROR] comentar en publicacion CERRADA -> TRG-03
BEGIN
    sp_generar_comentario(
        p_idContenido       => 33,
        p_cuerpo            => 'Comentario en pub cerrada.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:10:00',
        p_idAgente          => 1,
        p_idPublicacion     => 3,
        p_idComentarioPadre => NULL
    );
END;
/
-- ORA-20005: No se admiten nuevos comentarios en una publicacion Cerrada.

-- [ERROR] agente 5 (Observador) intenta comentar -> TRG-01
BEGIN
    sp_generar_comentario(
        p_idContenido       => 33,
        p_cuerpo            => 'Observador intentando comentar.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:15:00',
        p_idAgente          => 5,
        p_idPublicacion     => 1,
        p_idComentarioPadre => NULL
    );
END;
/
-- ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.

-- [ERROR] agente 2 comenta pub 4 pero no es miembro de com 2 -> TRG-03
BEGIN
    sp_generar_comentario(
        p_idContenido       => 34,
        p_cuerpo            => 'Comentando en comunidad a la que no pertenezco.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:20:00',
        p_idAgente          => 2,
        p_idPublicacion     => 4,
        p_idComentarioPadre => NULL
    );
END;
/
-- ORA-20006: Un agente no puede comentar en una comunidad a la que no pertenece.


-- ============================================================
-- REQ 2.6 - EJECUTAR ACCION DE MODERACION
-- ============================================================

-- [OK] ModBot-One (agente 3) cierra pub 40 en comunidad 1
BEGIN
    sp_moderar_contenido(
        p_idAgente    => 3,
        p_idContenido => 40,
        p_idComunidad => 1,
        p_fecha       => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora        => '12:00:00',
        p_accion      => 'cerrar'
    );
END;
/
-- Publicacion 40 cerrada.
-- Accion de moderacion "cerrar" registrada correctamente.

SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40;
-- IDCONTENIDO  TITULO                        ESTADO
-- -----------  ----------------------------  ------
--          40  Publicacion de prueba valida  Cerrada

-- [OK] ModBot-One elimina comentario 30 en comunidad 1
BEGIN
    sp_moderar_contenido(
        p_idAgente    => 3,
        p_idContenido => 30,
        p_idComunidad => 1,
        p_fecha       => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora        => '12:05:00',
        p_accion      => 'eliminar'
    );
END;
/
-- Accion de moderacion "eliminar" registrada correctamente.

-- [ERROR] agente 1 (Generador) intenta moderar -> TRG-06
BEGIN
    sp_moderar_contenido(
        p_idAgente    => 1,
        p_idContenido => 2,
        p_idComunidad => 1,
        p_fecha       => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora        => '12:10:00',
        p_accion      => 'ocultar'
    );
END;
/
-- ORA-20011: Solo los agentes de tipo Moderador pueden moderar contenido.

-- [ERROR] agente 4 SUSPENDIDO -> TRG-06
BEGIN
    sp_moderar_contenido(
        p_idAgente    => 4,
        p_idContenido => 2,
        p_idComunidad => 1,
        p_fecha       => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora        => '12:15:00',
        p_accion      => 'cerrar'
    );
END;
/
-- ORA-20010: Un agente suspendido no puede realizar tareas de moderacion.

-- [ERROR] agente 3 modera en comunidad 4 donde no pertenece -> TRG-06
BEGIN
    sp_moderar_contenido(
        p_idAgente    => 3,
        p_idContenido => 2,
        p_idComunidad => 4,
        p_fecha       => TO_DATE('2026-06-16','YYYY-MM-DD'),
        p_hora        => '12:20:00',
        p_accion      => 'ocultar'
    );
END;
/
-- ORA-20012: El agente moderador no pertenece a esta comunidad.


-- ============================================================
-- REQ 2.7 - ACTUALIZAR CONFIGURACION DEL AGENTE
-- ============================================================

-- [OK] actualizar config agente 2 (version 1 -> 2)
BEGIN
    sp_actualizar_config(
        p_idAgente    => 2,
        p_nuevaConfig => 'Compuesta',
        p_descripcion => 'Upgrade de Simple a Compuesta por mayor demanda.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD')
    );
END;
/
-- Agente 2 actualizado a version 2 con config: Compuesta

SELECT version, fechaAplicacion, descripcion FROM historial WHERE idAgente = 2 ORDER BY version;
-- VERSION  FECHAAPLICACION  DESCRIPCION
-- -------  ---------------  ------------------------------------------------
--       1  01/06/26         Configuracion inicial.
--       2  15/06/26         Upgrade de Simple a Compuesta por mayor demanda.

SELECT idAgente, nombre, config FROM Agente WHERE idAgente = 2;
-- IDAGENTE  NOMBRE  CONFIG
-- --------  ------  --------
--        2  ...     Compuesta

-- [OK] Segunda actualizacion (version 2 -> 3)
BEGIN
    sp_actualizar_config(
        p_idAgente    => 2,
        p_nuevaConfig => 'Simple',
        p_descripcion => 'Rollback a Simple por mantenimiento.',
        p_fecha       => TO_DATE('2026-06-17','YYYY-MM-DD')
    );
END;
/
-- Agente 2 actualizado a version 3 con config: Simple

-- [ERROR] agente inexistente -> ORA-02291
BEGIN
    sp_actualizar_config(
        p_idAgente    => 999,
        p_nuevaConfig => 'Simple',
        p_descripcion => 'No deberia ejecutarse.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD')
    );
END;
/
-- ORA-02291: integrity constraint (FK_HIST_AGENTE) violated - parent key not found

-- [ERROR] config invalida -> ORA-02290
BEGIN
    sp_actualizar_config(
        p_idAgente    => 1,
        p_nuevaConfig => 'Avanzada',
        p_descripcion => 'Config no permitida.',
        p_fecha       => TO_DATE('2026-06-15','YYYY-MM-DD')
    );
END;
/
-- ORA-02290: check constraint (CK_AGENTE_CONFIG) violated


-- ============================================================
-- REQ 2.8 - RANKING DE PUBLICACIONES
-- ============================================================

-- [OK] Ranking comunidad 1 sin filtro
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 1,
        p_emailAdmin  => NULL
    );
END;
/
-- === RANKING - Comunidad: 1 ===
-- Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-- -----------------------------------------------------------------------
-- No se encontraron publicaciones activas en los ultimos 30 dias.

-- [OK] Ranking comunidad 1 filtrado por emailAdmin
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 1,
        p_emailAdmin  => 'alice@mail.com'
    );
END;
/
-- === RANKING - Comunidad: 1 ===
-- Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-- -----------------------------------------------------------------------
-- No se encontraron publicaciones activas en los ultimos 30 dias.

-- [OK] comunidad 4 sin publicaciones activas
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 4,
        p_emailAdmin  => NULL
    );
END;
/
-- === RANKING - Comunidad: 4 ===
-- Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-- -----------------------------------------------------------------------
-- No se encontraron publicaciones activas en los ultimos 30 dias.

-- [OK] filtro por emailAdmin sin resultados
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 1,
        p_emailAdmin  => 'eve@mail.com'
    );
END;
/
-- === RANKING - Comunidad: 1 ===
-- Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-- -----------------------------------------------------------------------
-- No se encontraron publicaciones activas en los ultimos 30 dias.
