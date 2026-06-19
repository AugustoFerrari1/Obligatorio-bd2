SQL> CREATE OR REPLACE PROCEDURE sp_registrar_agente (
         p_idAgente       IN INT,
         p_nombre         IN VARCHAR2,
         p_fechaCreacion  IN DATE,...
Show more...



Procedure SP_REGISTRAR_AGENTE compiled

Elapsed: 00:00:00.163


SQL> CREATE OR REPLACE PROCEDURE sp_transferir_agente (
         p_idAgente      IN INT,
         p_emailCedente  IN VARCHAR2,
         p_emailReceptor IN VARCHAR2,...
Show more...



Procedure SP_TRANSFERIR_AGENTE compiled

Elapsed: 00:00:00.156


SQL> CREATE OR REPLACE PROCEDURE sp_generar_publicacion (
         p_idContenido  IN INT,
         p_titulo       IN VARCHAR2,
         p_cuerpo       IN VARCHAR2,...
Show more...



Procedure SP_GENERAR_PUBLICACION compiled

Elapsed: 00:00:00.154


SQL> CREATE OR REPLACE PROCEDURE sp_emitir_voto (
         p_idAgente      IN INT,
         p_idPublicacion IN INT,
         p_tipoVoto       IN INT,...
Show more...



Procedure SP_EMITIR_VOTO compiled

Elapsed: 00:00:00.153


SQL> CREATE OR REPLACE PROCEDURE sp_generar_comentario (
         p_idContenido       IN INT,
         p_cuerpo            IN VARCHAR2,
         p_fecha             IN DATE,...
Show more...



Procedure SP_GENERAR_COMENTARIO compiled

Elapsed: 00:00:00.152


SQL> CREATE OR REPLACE PROCEDURE sp_moderar_contenido (
         p_idAgente    IN INT,
         p_idContenido IN INT,
         p_idComunidad IN INT,...
Show more...



Procedure SP_MODERAR_CONTENIDO compiled

Elapsed: 00:00:00.158


SQL> CREATE OR REPLACE PROCEDURE sp_actualizar_config (
         p_idAgente    IN INT,
         p_nuevaConfig IN VARCHAR2,
         p_descripcion IN VARCHAR2,...
Show more...



Procedure SP_ACTUALIZAR_CONFIG compiled

Elapsed: 00:00:00.155


SQL> CREATE OR REPLACE PROCEDURE sp_ranking_publicaciones (
         p_idComunidad IN INT,
         p_emailAdmin  IN VARCHAR2
     ) AS...
Show more...



Procedure SP_RANKING_PUBLICACIONES compiled

Elapsed: 00:00:00.145
