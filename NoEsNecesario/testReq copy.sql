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

SELECT idAgente, nombre, emailAdmin FROM Agente WHERE idAgente = 1;

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

SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40;


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

SELECT idContenido, titulo, votosTotales FROM Publicacion WHERE idContenido = 40;

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

-- [ERROR] comentar en publicacion CERRADA -> TRG-03
BEGIN
    sp_generar_comentario(
        p_idContenido       => 32,
        p_cuerpo            => 'Comentario en pub cerrada.',
        p_fecha             => TO_DATE('2026-06-15','YYYY-MM-DD'),
        p_hora              => '11:10:00',
        p_idAgente          => 1,
        p_idPublicacion     => 3,
        p_idComentarioPadre => NULL
    );
END;
/

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

SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40;

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

SELECT version, fechaAplicacion, descripcion FROM historial WHERE idAgente = 2 ORDER BY version;
SELECT idAgente, nombre, config FROM Agente WHERE idAgente = 2;

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

-- [OK] Ranking comunidad 1 filtrado por emailAdmin
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 1,
        p_emailAdmin  => 'alice@mail.com'
    );
END;
/

-- [OK] comunidad 4 sin publicaciones activas
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 4,
        p_emailAdmin  => NULL
    );
END;
/

-- [OK] filtro por emailAdmin sin resultados
BEGIN
    sp_ranking_publicaciones(
        p_idComunidad => 1,
        p_emailAdmin  => 'eve@mail.com'
    );
END;
/





SQL> BEGIN
         sp_registrar_agente(
             p_idAgente      => 10,
             p_nombre        => 'GenBot-Nuevo',...
Show more...


Agente GenBot-Nuevo registrado correctamente con version 1 en historial.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.021


SQL> BEGIN
         sp_registrar_agente(
             p_idAgente      => 99,
             p_nombre        => 'AgenteSinDuenio',...
Show more...

ORA-02291: integrity constraint (AGUFERRARI100_SCHEMA_BFXQM.FK_AGENTE_ADMIN) violated - parent key not found
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_REGISTRAR_AGENTE", line 13
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-02291/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_registrar_agente(
             p_idAgente      => 98,
             p_nombre        => 'AgenteRaro',...
Show more...

ORA-02290: check constraint (AGUFERRARI100_SCHEMA_BFXQM.CK_AGENTE_TIPO) violated
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_REGISTRAR_AGENTE", line 13
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-02290/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_transferir_agente(
             p_idAgente      => 1,
             p_emailCedente  => 'alice@mail.com',...
Show more...


Transferencia registrada. Nuevo admin del agente 1: bob@mail.com


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.015


SQL> BEGIN
         sp_transferir_agente(
             p_idAgente      => 1,
             p_emailCedente  => 'alice@mail.com',...
Show more...


Error: el emailCedente no es el administrador actual del agente.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_transferir_agente(
             p_idAgente      => 1,
             p_emailCedente  => 'bob@mail.com',...
Show more...


Error: el cedente y el receptor no pueden ser el mismo usuario.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_generar_publicacion(
             p_idContenido => 40,
             p_titulo      => 'Publicacion de prueba valida',...
Show more...


Publicacion creada correctamente con id: 40


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.016


SQL> BEGIN
         sp_generar_publicacion(
             p_idContenido => 41,
             p_titulo      => 'Publicacion de agente suspendido',...
Show more...

ORA-20001: Un agente suspendido no puede generar contenido.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT", line 12
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_PUBLICACION", line 12
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20001/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_publicacion(
             p_idContenido => 42,
             p_titulo      => 'Publicacion de Observador',...
Show more...

ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT", line 18
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_PUBLICACION", line 12
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20002/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_publicacion(
             p_idContenido => 43,
             p_titulo      => 'Pub en comunidad archivada',...
Show more...

ORA-20003: No se permiten nuevas publicaciones en comunidades archivadas.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT", line 20
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_PUBLICACION", line 16
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20003/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_publicacion(
             p_idContenido => 44,
             p_titulo      => 'Pub sin ser miembro',...
Show more...

ORA-20004: El agente debe ser Miembro Activo de la comunidad para publicar.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT", line 33
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_PUBLICACION", line 16
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20004/
Error at Line: 1 Column: 1
SQL> SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40

IDCONTENIDO TITULO                         ESTADO   
----------- ------------------------------ -------- 
40          Publicacion de prueba valida   Activa   

Elapsed: 00:00:00.001
1 rows selected. 



SQL> BEGIN
         sp_emitir_voto(
             p_idAgente      => 5,
             p_idPublicacion => 40,...
Show more...


Voto registrado correctamente.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.010


SQL> SELECT idContenido, titulo, votosTotales FROM Publicacion WHERE idContenido = 40

IDCONTENIDO TITULO                         VOTOSTOTALES 
----------- ------------------------------ ------------ 
40          Publicacion de prueba valida   1            

Elapsed: 00:00:00.001
1 rows selected. 



SQL> BEGIN
         sp_emitir_voto(
             p_idAgente      => 5,
             p_idPublicacion => 1,...
Show more...


Error: el tipoVoto del voto debe ser 1 o -1.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_emitir_voto(
             p_idAgente      => 1,
             p_idPublicacion => 1,...
Show more...

ORA-20008: Solo los agentes de tipo Observador estan facultados para votar.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 19
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_EMITIR_VOTO", line 18
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20008/
Error at Line: 1 Column: 1
SQL> UPDATE Publicacion SET estado = 'Eliminada' WHERE idContenido = 2



1 row updated.

Elapsed: 00:00:00.001


SQL> BEGIN
         sp_emitir_voto(
             p_idAgente      => 5,
             p_idPublicacion => 2,...
Show more...

ORA-20009: No se puede votar una publicacion en estado Eliminada.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 30
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_EMITIR_VOTO", line 18
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20009/
Error at Line: 1 Column: 1
SQL> UPDATE Publicacion SET estado = 'Activa' WHERE idContenido = 2



1 row updated.

Elapsed: 00:00:00.002


SQL> BEGIN
         sp_emitir_voto(
             p_idAgente      => 4,
             p_idPublicacion => 1,...
Show more...

ORA-20007: Un agente suspendido no puede emitir votos.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT", line 13
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_VOTA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_EMITIR_VOTO", line 18
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20007/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_comentario(
             p_idContenido       => 30,
             p_cuerpo            => 'Este es un comentario de prueba valido.',...
Show more...


Comentario registrado correctamente con id: 30


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.010


SQL> BEGIN
         sp_generar_comentario(
             p_idContenido       => 31,
             p_cuerpo            => 'Esta es una respuesta al comentario 30.',...
Show more...


Comentario registrado correctamente con id: 31


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.007


SQL> BEGIN
         sp_generar_comentario(
             p_idContenido       => 32,
             p_cuerpo            => 'Comentario en pub cerrada.',...
Show more...

ORA-20005: No se admiten nuevos comentarios en una publicacion Cerrada.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT", line 21
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_COMENTARIO", line 16
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20005/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_comentario(
             p_idContenido       => 33,
             p_cuerpo            => 'Observador intentando comentar.',...
Show more...

ORA-20002: Solo agentes de tipo Generador pueden crear publicaciones o comentarios.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT", line 18
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_CONTENIDO_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_COMENTARIO", line 12
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20002/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_generar_comentario(
             p_idContenido       => 34,
             p_cuerpo            => 'Comentando en comunidad a la que no pertenezco.',...
Show more...

ORA-20006: Un agente no puede comentar en una comunidad a la que no pertenece.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT", line 34
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_GENERAR_COMENTARIO", line 16
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20006/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_moderar_contenido(
             p_idAgente    => 3,
             p_idContenido => 40,...
Show more...


Publicacion 40 cerrada.
Accion de moderacion "cerrar" registrada correctamente.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.010


SQL> SELECT idContenido, titulo, estado FROM Publicacion WHERE idContenido = 40

IDCONTENIDO TITULO                         ESTADO    
----------- ------------------------------ --------- 
40          Publicacion de prueba valida   Cerrada   

Elapsed: 00:00:00.001
1 rows selected. 



SQL> BEGIN
         sp_moderar_contenido(
             p_idAgente    => 3,
             p_idContenido => 30,...
Show more...


Accion de moderacion "eliminar" registrada correctamente.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_moderar_contenido(
             p_idAgente    => 1,
             p_idContenido => 2,...
Show more...

ORA-20011: Solo los agentes de tipo Moderador pueden moderar contenido.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 19
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_MODERAR_CONTENIDO", line 13
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20011/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_moderar_contenido(
             p_idAgente    => 4,
             p_idContenido => 2,...
Show more...

ORA-20010: Un agente suspendido no puede realizar tareas de moderacion.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 13
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_MODERAR_CONTENIDO", line 13
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20010/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_moderar_contenido(
             p_idAgente    => 3,
             p_idContenido => 2,...
Show more...

ORA-20012: El agente moderador no pertenece a esta comunidad.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT", line 31
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_MODERA_BEFORE_INSERT'
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_MODERAR_CONTENIDO", line 13
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-20012/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_actualizar_config(
             p_idAgente    => 2,
             p_nuevaConfig => 'Compuesta',...
Show more...


Agente 2 actualizado a version 2 con config: Compuesta


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.007


SQL> SELECT version, fechaAplicacion, descripcion FROM historial WHERE idAgente = 2 ORDER BY version

VERSION FECHAAPLICACION           DESCRIPCION                                        
------- ------------------------- -------------------------------------------------- 
1       06/14/2024, 09:00:00 PM   Configuracion inicial: Simple.                     
2       06/14/2026, 09:00:00 PM   Upgrade de Simple a Compuesta por mayor demanda.   

Elapsed: 00:00:00.002
2 rows selected. 



SQL> SELECT idAgente, nombre, config FROM Agente WHERE idAgente = 2

IDAGENTE NOMBRE        CONFIG      
-------- ------------- ----------- 
2        GenBot-Beta   Compuesta   

Elapsed: 00:00:00.001
1 rows selected. 



SQL> BEGIN
         sp_actualizar_config(
             p_idAgente    => 2,
             p_nuevaConfig => 'Simple',...
Show more...


Agente 2 actualizado a version 3 con config: Simple


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.005


SQL> BEGIN
         sp_actualizar_config(
             p_idAgente    => 999,
             p_nuevaConfig => 'Simple',...
Show more...

ORA-02291: integrity constraint (AGUFERRARI100_SCHEMA_BFXQM.FK_HIST_AGENTE) violated - parent key not found
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_ACTUALIZAR_CONFIG", line 19
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-02291/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_actualizar_config(
             p_idAgente    => 1,
             p_nuevaConfig => 'Avanzada',...
Show more...

ORA-02290: check constraint (AGUFERRARI100_SCHEMA_BFXQM.CK_AGENTE_CONFIG) violated
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.SP_ACTUALIZAR_CONFIG", line 23
ORA-06512: at line 2

https://docs.oracle.com/error-help/db/ora-02290/
Error at Line: 1 Column: 1
SQL> BEGIN
         sp_ranking_publicaciones(
             p_idComunidad => 1,
             p_emailAdmin  => NULL...
Show more...


=== RANKING - Comunidad: 1 ===
Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-----------------------------------------------------------------------
1      | 0     | Redes neuronales y creatividad | 22-MAY-26 | GenBot-Alpha | bob@mail.com


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_ranking_publicaciones(
             p_idComunidad => 1,
             p_emailAdmin  => 'alice@mail.com'...
Show more...


=== RANKING - Comunidad: 1 ===
Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-----------------------------------------------------------------------
No se encontraron publicaciones activas en los ultimos 30 dias.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.006


SQL> BEGIN
         sp_ranking_publicaciones(
             p_idComunidad => 4,
             p_emailAdmin  => NULL...
Show more...


=== RANKING - Comunidad: 4 ===
Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-----------------------------------------------------------------------
No se encontraron publicaciones activas en los ultimos 30 dias.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.005


SQL> BEGIN
         sp_ranking_publicaciones(
             p_idComunidad => 1,
             p_emailAdmin  => 'eve@mail.com'...
Show more...


=== RANKING - Comunidad: 1 ===
Puesto | Votos | Titulo                | Fecha      | Agente          | Admin
-----------------------------------------------------------------------
No se encontraron publicaciones activas en los ultimos 30 dias.


PL/SQL procedure successfully completed.

Elapsed: 00:00:00.005
