SQL> CREATE OR REPLACE TRIGGER trg_contenido_before_insert
     BEFORE INSERT ON contenido
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_CONTENIDO_BEFORE_INSERT compiled

Elapsed: 00:00:00.176


SQL> CREATE OR REPLACE TRIGGER trg_publicacion_before_insert
     BEFORE INSERT ON Publicacion
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_PUBLICACION_BEFORE_INSERT compiled

Elapsed: 00:00:00.160


SQL> CREATE OR REPLACE TRIGGER trg_comentario_before_insert
     BEFORE INSERT ON comentario
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_COMENTARIO_BEFORE_INSERT compiled

Elapsed: 00:00:00.153


SQL> CREATE OR REPLACE TRIGGER trg_vota_before_insert
     BEFORE INSERT ON vota
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_VOTA_BEFORE_INSERT compiled

Elapsed: 00:00:00.148


SQL> CREATE OR REPLACE TRIGGER trg_vota_after_insert
     AFTER INSERT ON vota
     FOR EACH ROW
     BEGIN...
Show more...



Trigger TRG_VOTA_AFTER_INSERT compiled

Elapsed: 00:00:00.144


SQL> CREATE OR REPLACE TRIGGER trg_modera_before_insert
     BEFORE INSERT ON modera
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_MODERA_BEFORE_INSERT compiled

Elapsed: 00:00:00.149


SQL> CREATE OR REPLACE TRIGGER trg_transferencia_before_insert
     BEFORE INSERT ON transferencia
     FOR EACH ROW
     DECLARE...
Show more...



Trigger TRG_TRANSFERENCIA_BEFORE_INSERT compiled

Elapsed: 00:00:00.146


SQL> CREATE OR REPLACE TRIGGER trg_transferencia_after_insert
     AFTER INSERT ON transferencia
     FOR EACH ROW
     BEGIN...
Show more...



Trigger TRG_TRANSFERENCIA_AFTER_INSERT compiled

Elapsed: 00:00:00.143


SQL> CREATE OR REPLACE TRIGGER trg_comunidad_archivado
     BEFORE INSERT OR UPDATE ON comunidad
     FOR EACH ROW
     BEGIN...
Show more...



Trigger TRG_COMUNIDAD_ARCHIVADO compiled

Elapsed: 00:00:00.144


SQL> CREATE OR REPLACE TRIGGER trg_vw_publicacion_delete
     INSTEAD OF DELETE ON vw_publicacion
     FOR EACH ROW
     BEGIN...
Show more...



Trigger TRG_VW_PUBLICACION_DELETE compiled

Elapsed: 00:00:00.151