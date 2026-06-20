SQL> CREATE TABLE usuarioHumano (
         email           VARCHAR2(100)   NOT NULL,
         alias           VARCHAR2(50)    NOT NULL,
         nombreCompleto  VARCHAR2(200)   NOT NULL,...
Show more...



Table USUARIOHUMANO created.

Elapsed: 00:00:00.035


SQL> CREATE TABLE telefonos (
         email       VARCHAR2(100)   NOT NULL,
         telefono    VARCHAR2(30)    NOT NULL,
         CONSTRAINT pk_telefonos   PRIMARY KEY (email, telefono),...
Show more...



Table TELEFONOS created.

Elapsed: 00:00:00.024


SQL> CREATE TABLE Agente (
         idAgente        INT             NOT NULL,
         nombre          VARCHAR2(100)   NOT NULL,
         fechaCreacion   DATE            NOT NULL,...
Show more...



Table AGENTE created.

Elapsed: 00:00:00.030


SQL> CREATE TABLE historial (
         idAgente        INT     NOT NULL,
         version         INT     NOT NULL,
         fechaAplicacion DATE    NOT NULL,...
Show more...



Table HISTORIAL created.

Elapsed: 00:00:00.025


SQL> CREATE TABLE transferencia (
         idAgente        INT             NOT NULL,
         emailCedente    VARCHAR2(100)   NOT NULL,
         emailReceptor   VARCHAR2(100)   NOT NULL,...
Show more...



Table TRANSFERENCIA created.

Elapsed: 00:00:00.027


SQL> CREATE TABLE comunidad (
         idComunidad     INT             NOT NULL,
         nombre          VARCHAR2(100)   NOT NULL,
         descripcion     VARCHAR2(200),...
Show more...



Table COMUNIDAD created.

Elapsed: 00:00:00.029


SQL> CREATE TABLE participa (
         idAgente    INT             NOT NULL,
         idComunidad INT             NOT NULL,
         rol         VARCHAR2(20)    NOT NULL,...
Show more...



Table PARTICIPA created.

Elapsed: 00:00:00.026


SQL> CREATE TABLE contenido (
         idContenido     INT             NOT NULL,
         fechaCreacion   DATE            NOT NULL,
         horaCreacion    VARCHAR2(8)     NOT NULL,...
Show more...



Table CONTENIDO created.

Elapsed: 00:00:00.025


SQL> CREATE TABLE Publicacion (
         idContenido     INT             NOT NULL,
         titulo          VARCHAR2(255)   NOT NULL,
         cuerpo          VARCHAR2(200)            NOT NULL,...
Show more...



Table PUBLICACION created.

Elapsed: 00:00:00.033


SQL> CREATE TABLE cita (
         idPublicacionOrigen INT   NOT NULL,
         idPublicacionCitada INT   NOT NULL,
         fechaCita           DATE  NOT NULL,...
Show more...



Table CITA created.

Elapsed: 00:00:00.024


SQL> CREATE TABLE comentario (
         idContenido         INT         NOT NULL,
         cuerpo              VARCHAR2(200)        NOT NULL,
         idPublicacion       INT         NOT NULL,...
Show more...



Table COMENTARIO created.

Elapsed: 00:00:00.025


SQL> CREATE TABLE vota (
         idAgente        INT         NOT NULL,
         idPublicacion   INT         NOT NULL,
         tipoVoto        INT         NOT NULL,...
Show more...



Table VOTA created.

Elapsed: 00:00:00.027


SQL> CREATE TABLE modera (
         idAgente    INT         NOT NULL,
         idContenido INT         NOT NULL,
         idComunidad INT         NOT NULL,...
Show more...



Table MODERA created.

Elapsed: 00:00:00.032


SQL> CREATE OR REPLACE VIEW vw_publicacion AS
     SELECT * FROM Publicacion WHERE estado <> 'Eliminada'



View VW_PUBLICACION created.

Elapsed: 00:00:00.023
