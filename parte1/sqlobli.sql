-- ============================================================
--  OBLIGATORIO BD2 - Moltbook  |  DDL
-- ============================================================

-- usuarioHumano: propietario legal. PK email, alias unico.
CREATE TABLE usuarioHumano (
    email           VARCHAR2(100)   NOT NULL,
    alias           VARCHAR2(50)    NOT NULL,
    nombreCompleto  VARCHAR2(200)   NOT NULL,
    paisResidencia  VARCHAR2(100),
    estado          VARCHAR2(15)    DEFAULT 'Activo' NOT NULL,
    fechaRegistro   DATE NOT NULL,
    CONSTRAINT pk_usuarioHumano  PRIMARY KEY (email),
    CONSTRAINT uq_usuario_alias  UNIQUE (alias),
    CONSTRAINT ck_usuario_estado CHECK (estado IN ('Activo', 'Suspendido'))
);

-- telefonos: multivaluado de usuarioHumano.
CREATE TABLE telefonos (
    email       VARCHAR2(100)   NOT NULL,
    telefono    VARCHAR2(30)    NOT NULL,
    CONSTRAINT pk_telefonos   PRIMARY KEY (email, telefono),
    CONSTRAINT fk_tel_usuario FOREIGN KEY (email)
        REFERENCES usuarioHumano(email) ON DELETE CASCADE
);

-- Agente: actor principal. tipo discrimina rol operativo.
-- emailAdmin apunta al administrador vigente.
CREATE TABLE Agente (
    idAgente        INT             NOT NULL,
    nombre          VARCHAR2(100)   NOT NULL,
    fechaCreacion   DATE            NOT NULL,
    descripcion     CLOB,
    tipo            VARCHAR2(15)    NOT NULL,
    config          VARCHAR2(10)    NOT NULL,
    estado          VARCHAR2(15)    DEFAULT 'Activo' NOT NULL,
    emailAdmin      VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_Agente        PRIMARY KEY (idAgente),
    CONSTRAINT ck_agente_tipo   CHECK (tipo   IN ('Generador', 'Moderador', 'Observador')),
    CONSTRAINT ck_agente_config CHECK (config IN ('Simple', 'Compuesta')),
    CONSTRAINT ck_agente_estado CHECK (estado IN ('Activo', 'Suspendido')),
    CONSTRAINT fk_agente_admin  FOREIGN KEY (emailAdmin)
        REFERENCES usuarioHumano(email)
);

-- historial: entidad debil de Agente. Guarda versiones previas de config.
-- PK parcial: version; identificacion completa con idAgente.
CREATE TABLE historial (
    idAgente        INT     NOT NULL,
    version         INT     NOT NULL,
    fechaAplicacion DATE    NOT NULL,
    descripcion     CLOB,
    CONSTRAINT pk_historial   PRIMARY KEY (idAgente, version),
    CONSTRAINT fk_hist_agente FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente) ON DELETE CASCADE
);


-- transferencia: auditoria de cambio de administrador de un Agente especifico.
-- El cedente (admin actual) cede la administracion al receptor.
-- TRG-07 valida que emailCedente sea el admin actual del agente.
-- TRG-08 actualiza emailAdmin en Agente tras cada insercion.
CREATE TABLE transferencia (
    idAgente        INT             NOT NULL,
    emailCedente    VARCHAR2(100)   NOT NULL,
    emailReceptor   VARCHAR2(100)   NOT NULL,
    fecha           DATE            NOT NULL,
    CONSTRAINT pk_transferencia    PRIMARY KEY (idAgente, emailCedente, emailReceptor, fecha),
    CONSTRAINT fk_trans_agente     FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente),
    CONSTRAINT fk_trans_cedente    FOREIGN KEY (emailCedente)
        REFERENCES usuarioHumano(email),
    CONSTRAINT fk_trans_receptor   FOREIGN KEY (emailReceptor)
        REFERENCES usuarioHumano(email)
);

-- comunidad: espacio tematico (submolt). nombre unico.
-- archivado='S' bloquea nuevas publicaciones (ver TRG-02).
CREATE TABLE comunidad (
    idComunidad     INT             NOT NULL,
    nombre          VARCHAR2(100)   NOT NULL,
    descripcion     CLOB,
    fechaCreacion   DATE            NOT NULL,
    temaPrincipal   VARCHAR2(100),
    archivado       CHAR(1)         DEFAULT 'N' NOT NULL,
    fechaArchivado  DATE,
    CONSTRAINT pk_comunidad        PRIMARY KEY (idComunidad),
    CONSTRAINT uq_comunidad_nombre UNIQUE (nombre),
    CONSTRAINT ck_com_archivado    CHECK (archivado IN ('S', 'N'))
);

-- participa: Agente en comunidad. rol define capacidad de accion.
-- Solo 'Miembro Activo' puede publicar/comentar (ver TRG-02, TRG-03).
CREATE TABLE participa (
    idAgente    INT             NOT NULL,
    idComunidad INT             NOT NULL,
    rol         VARCHAR2(20)    NOT NULL,
    CONSTRAINT pk_participa      PRIMARY KEY (idAgente, idComunidad),
    CONSTRAINT ck_part_rol       CHECK (rol IN ('Seguidor', 'Miembro Activo')),
    CONSTRAINT fk_part_agente    FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente),
    CONSTRAINT fk_part_comunidad FOREIGN KEY (idComunidad)
        REFERENCES comunidad(idComunidad)
);

-- contenido: superclase ISA. Atributos comunes a publicacion y comentario.
-- idAgente registra quien genera el contenido (relacion genera).
CREATE TABLE contenido (
    idContenido     INT             NOT NULL,
    fechaCreacion   DATE            NOT NULL,
    horaCreacion    VARCHAR2(8)     NOT NULL,
    idAgente        INT             NOT NULL,
    CONSTRAINT pk_contenido    PRIMARY KEY (idContenido),
    CONSTRAINT fk_cont_agente  FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente)
);

-- Publicacion: subclase de contenido. idContenido = PK heredada de contenido (ISA).
-- fechaCreacion y horaCreacion se heredan de contenido, no se repiten aqui.
-- estado: borrado logico ('Eliminada' oculta pero no borra fisicamente).
-- votosTotales: derivado, mantenido atomicamente por TRG-05.
-- idComunidad: relacion publicadoEn, siempre obligatoria.
CREATE TABLE Publicacion (
    idContenido     INT             NOT NULL,
    titulo          VARCHAR2(255)   NOT NULL,
    cuerpo          CLOB            NOT NULL,
    estado          VARCHAR2(10)    DEFAULT 'Activa' NOT NULL,
    votosTotales    INT             DEFAULT 0 NOT NULL,
    idComunidad     INT             NOT NULL,
    CONSTRAINT pk_publicacion    PRIMARY KEY (idContenido),
    CONSTRAINT ck_pub_estado     CHECK (estado IN ('Activa', 'Cerrada', 'Eliminada')),
    CONSTRAINT fk_pub_contenido  FOREIGN KEY (idContenido)
        REFERENCES contenido(idContenido) ON DELETE CASCADE,
    CONSTRAINT fk_pub_comunidad  FOREIGN KEY (idComunidad)
        REFERENCES comunidad(idComunidad)
);

-- cita: relacion N:M entre publicaciones. Registra fecha de la mencion.
CREATE TABLE cita (
    idPublicacionOrigen INT   NOT NULL,
    idPublicacionCitada INT   NOT NULL,
    fechaCita           DATE  NOT NULL,
    CONSTRAINT pk_cita        PRIMARY KEY (idPublicacionOrigen, idPublicacionCitada),
    CONSTRAINT fk_cita_origen FOREIGN KEY (idPublicacionOrigen)
        REFERENCES Publicacion(idContenido),
    CONSTRAINT fk_cita_citada FOREIGN KEY (idPublicacionCitada)
        REFERENCES Publicacion(idContenido)
    
);

-- comentario: subclase de contenido. idContenido = PK heredada de contenido (ISA).
-- fechaCreacion y horaCreacion se heredan de contenido, no se repiten aqui.
-- idPublicacion: publicacion raiz del hilo (relacion comenta).
-- idComentarioPadre: autorreferencial para hilos anidados (RespondeA).
--   NULL = responde directamente a la publicacion.
CREATE TABLE comentario (
    idContenido         INT         NOT NULL,
    cuerpo              CLOB        NOT NULL,
    idPublicacion       INT         NOT NULL,
    idComentarioPadre   INT,
    CONSTRAINT pk_comentario       PRIMARY KEY (idContenido),
    CONSTRAINT fk_com_contenido    FOREIGN KEY (idContenido)
        REFERENCES contenido(idContenido) ON DELETE CASCADE,
    CONSTRAINT fk_com_publicacion  FOREIGN KEY (idPublicacion)
        REFERENCES Publicacion(idContenido),
    CONSTRAINT fk_com_responde     FOREIGN KEY (idComentarioPadre)
        REFERENCES comentario(idContenido)
);

-- vota: Agente Observador vota una Publicacion. PK garantiza un voto por agente.
-- valor: 1 positivo | -1 negativo. votosTotales se actualiza via TRG-05.
CREATE TABLE vota (
    idAgente        INT         NOT NULL,
    idPublicacion   INT         NOT NULL,
    valor           INT         NOT NULL,
    fecha           DATE        NOT NULL,
    hora            VARCHAR2(8) NOT NULL,
    CONSTRAINT pk_vota           PRIMARY KEY (idAgente, idPublicacion),
    CONSTRAINT ck_vota_valor     CHECK (valor IN (1, -1)),
    CONSTRAINT fk_vota_agente    FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente),
    CONSTRAINT fk_vota_pub       FOREIGN KEY (idPublicacion)
        REFERENCES Publicacion(idContenido)
);

-- modera: relacion ternaria Agente-contenido-comunidad.
-- Registra acciones de moderacion; el agente debe pertenecer
-- a la comunidad y ser de tipo Moderador (ver TRG-06).
CREATE TABLE modera (
    idAgente    INT         NOT NULL,
    idContenido INT         NOT NULL,
    idComunidad INT         NOT NULL,
    fecha       DATE        NOT NULL,
    hora        VARCHAR2(8) NOT NULL,
    accion      VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_modera        PRIMARY KEY (idAgente, idContenido, idComunidad, fecha, hora),
    CONSTRAINT ck_mod_accion    CHECK (accion IN ('ocultar', 'cerrar', 'eliminar')),
    CONSTRAINT fk_mod_agente    FOREIGN KEY (idAgente)
        REFERENCES Agente(idAgente),
    CONSTRAINT fk_mod_contenido FOREIGN KEY (idContenido)
        REFERENCES contenido(idContenido),
    CONSTRAINT fk_mod_comunidad FOREIGN KEY (idComunidad)
        REFERENCES comunidad(idComunidad)
);
