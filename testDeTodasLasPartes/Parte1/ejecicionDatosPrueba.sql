SQL> INSERT INTO usuarioHumano VALUES ('alice@mail.com', 'alice', 'Alice Romero',  'Uruguay',   'Activo',     TO_DATE('2024-01-10','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.728


SQL> INSERT INTO usuarioHumano VALUES ('bob@mail.com',   'bob',   'Bob Pereira',   'Argentina', 'Activo',     TO_DATE('2024-02-05','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO usuarioHumano VALUES ('carol@mail.com', 'carol', 'Carol Suarez',  'Uruguay',   'Activo',     TO_DATE('2024-03-01','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO usuarioHumano VALUES ('dave@mail.com',  'dave',  'Dave Gonzalez', 'Brasil',    'Suspendido', TO_DATE('2024-04-15','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO usuarioHumano VALUES ('eve@mail.com',   'eve',   'Eve Martinez',  'Uruguay',   'Activo',     TO_DATE('2024-05-20','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO telefonos VALUES ('alice@mail.com', '099111111')



1 row inserted.

Elapsed: 00:00:00.364


SQL> INSERT INTO telefonos VALUES ('alice@mail.com', '092222222')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO telefonos VALUES ('bob@mail.com',   '099333333')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO telefonos VALUES ('carol@mail.com', '098444444')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO Agente VALUES (1, 'GenBot-Alpha', TO_DATE('2024-06-01','YYYY-MM-DD'), 'Genera contenido cientifico.',    'Generador',  'Compuesta', 'Activo',     'alice@mail.com')



1 row inserted.

Elapsed: 00:00:00.254


SQL> INSERT INTO Agente VALUES (2, 'GenBot-Beta',  TO_DATE('2024-06-15','YYYY-MM-DD'), 'Genera contenido de tecnologia.', 'Generador',  'Simple',    'Activo',     'bob@mail.com')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Agente VALUES (3, 'ModBot-One',   TO_DATE('2024-07-01','YYYY-MM-DD'), 'Modera contenido inapropiado.',   'Moderador',  'Compuesta', 'Activo',     'carol@mail.com')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Agente VALUES (4, 'ModBot-Two',   TO_DATE('2024-07-10','YYYY-MM-DD'), 'Moderador con restricciones.',    'Moderador',  'Simple',    'Suspendido', 'carol@mail.com')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Agente VALUES (5, 'ObsBot-X',     TO_DATE('2024-08-01','YYYY-MM-DD'), 'Solo vota y observa.',            'Observador', 'Simple',    'Activo',     'alice@mail.com')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Agente VALUES (6, 'ObsBot-Y',     TO_DATE('2024-08-15','YYYY-MM-DD'), 'Observador de tendencias.',       'Observador', 'Simple',    'Activo',     'eve@mail.com')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO historial VALUES (1, 1, TO_DATE('2024-06-01','YYYY-MM-DD'), 'Configuracion inicial: Compuesta.')



1 row inserted.

Elapsed: 00:00:00.018


SQL> INSERT INTO historial VALUES (1, 2, TO_DATE('2024-09-01','YYYY-MM-DD'), 'Upgrade a Compuesta para mayor capacidad.')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO historial VALUES (2, 1, TO_DATE('2024-06-15','YYYY-MM-DD'), 'Configuracion inicial: Simple.')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO historial VALUES (3, 1, TO_DATE('2024-07-01','YYYY-MM-DD'), 'Configuracion inicial: Compuesta.')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO historial VALUES (5, 1, TO_DATE('2024-08-01','YYYY-MM-DD'), 'Configuracion inicial: Simple.')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO historial VALUES (6, 1, TO_DATE('2024-08-15','YYYY-MM-DD'), 'Configuracion inicial: Simple.')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO transferencia VALUES (2, 'bob@mail.com', 'carol@mail.com', TO_DATE('2025-01-10','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.168


SQL> INSERT INTO comunidad VALUES (1, 'TecnologiaIA',   'Debate sobre avances en IA.',      TO_DATE('2024-05-01','YYYY-MM-DD'), 'Inteligencia Artificial', 'N', NULL)



1 row inserted.

Elapsed: 00:00:00.512


SQL> INSERT INTO comunidad VALUES (2, 'CienciaAbierta', 'Divulgacion cientifica libre.',     TO_DATE('2024-05-15','YYYY-MM-DD'), 'Ciencia',                 'N', NULL)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comunidad VALUES (3, 'ArteDigital',    'Creaciones artisticas con IA.',     TO_DATE('2024-06-01','YYYY-MM-DD'), 'Arte',                    'S', TO_DATE('2025-02-01','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comunidad VALUES (4, 'FuturoAgentes',  'Vision a largo plazo de los bots.', TO_DATE('2024-07-01','YYYY-MM-DD'), 'Futuro',                  'N', NULL)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO participa VALUES (1, 1, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.396


SQL> INSERT INTO participa VALUES (1, 2, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO participa VALUES (2, 1, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO participa VALUES (3, 1, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO participa VALUES (3, 2, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO participa VALUES (4, 1, 'Miembro Activo')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO participa VALUES (5, 1, 'Seguidor')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO participa VALUES (5, 2, 'Seguidor')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO participa VALUES (6, 1, 'Seguidor')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO participa VALUES (6, 4, 'Seguidor')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO contenido VALUES (1,  TO_DATE('2026-05-20','YYYY-MM-DD'), '09:00:00', 1)



1 row inserted.

Elapsed: 00:00:00.025


SQL> INSERT INTO contenido VALUES (2,  TO_DATE('2026-05-22','YYYY-MM-DD'), '11:30:00', 1)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO contenido VALUES (3,  TO_DATE('2026-05-25','YYYY-MM-DD'), '14:00:00', 2)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO contenido VALUES (4,  TO_DATE('2026-05-28','YYYY-MM-DD'), '16:15:00', 1)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO contenido VALUES (5,  TO_DATE('2026-05-30','YYYY-MM-DD'), '08:45:00', 2)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO contenido VALUES (11, TO_DATE('2026-05-21','YYYY-MM-DD'), '10:00:00', 2)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO contenido VALUES (12, TO_DATE('2026-05-21','YYYY-MM-DD'), '10:30:00', 1)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO contenido VALUES (13, TO_DATE('2026-05-23','YYYY-MM-DD'), '12:00:00', 2)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO contenido VALUES (14, TO_DATE('2026-05-29','YYYY-MM-DD'), '17:00:00', 1)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO contenido VALUES (15, TO_DATE('2026-05-31','YYYY-MM-DD'), '09:20:00', 2)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Publicacion VALUES (1, 'Avances en LLMs 2025',          'Los modelos de lenguaje superan benchmarks clave.',     'Activa',    0, 1)



1 row inserted.

Elapsed: 00:00:00.176


SQL> INSERT INTO Publicacion VALUES (2, 'Redes neuronales y creatividad', 'Analisis de modelos generativos aplicados al arte.',    'Activa',    0, 1)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Publicacion VALUES (3, 'Debate: IA reemplaza empleos',   'Argumentos a favor y en contra del reemplazo laboral.', 'Cerrada',   0, 1)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Publicacion VALUES (4, 'Open Science y agentes de IA',   'Como los agentes pueden democratizar la investigacion.','Activa',    0, 2)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO Publicacion VALUES (5, 'Contenido eliminado',            'Este contenido fue eliminado por violacion de normas.', 'Eliminada', 0, 2)

ORA-20004: El agente debe ser Miembro Activo de la comunidad para publicar.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT", line 33
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_PUBLICACION_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20004/
Error at Line: 82 Column: 0
SQL> INSERT INTO cita VALUES (2, 1, TO_DATE('2026-05-22','YYYY-MM-DD'))



1 row inserted.

Elapsed: 00:00:00.313


SQL> INSERT INTO comentario VALUES (11, 'Totalmente de acuerdo, los LLMs estan avanzando rapidamente.',            1, NULL)



1 row inserted.

Elapsed: 00:00:00.257


SQL> INSERT INTO comentario VALUES (12, 'Comparto, aunque falta mejorar razonamiento causal.',                     1, 11)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO comentario VALUES (13, 'Los agentes ya estan siendo usados en revision de papers.',               4, NULL)

ORA-20006: Un agente no puede comentar en una comunidad a la que no pertenece.
ORA-06512: at "AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT", line 34
ORA-04088: error during execution of trigger 'AGUFERRARI100_SCHEMA_BFXQM.TRG_COMENTARIO_BEFORE_INSERT'

https://docs.oracle.com/error-help/db/ora-20006/
Error at Line: 94 Column: 0
SQL> INSERT INTO comentario VALUES (14, 'La creatividad de las redes neuronales sigue siendo limitada.',           2, NULL)



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO comentario VALUES (15, 'En musica ya superan a humanos en ciertos aspectos.',                     2, 14)



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO vota VALUES (5, 1,  1, TO_DATE('2026-05-21','YYYY-MM-DD'), '08:00:00')



1 row inserted.

Elapsed: 00:00:00.024


SQL> INSERT INTO vota VALUES (6, 1,  1, TO_DATE('2026-05-22','YYYY-MM-DD'), '09:00:00')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO vota VALUES (5, 2,  1, TO_DATE('2026-05-23','YYYY-MM-DD'), '10:00:00')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO vota VALUES (6, 2, -1, TO_DATE('2026-05-24','YYYY-MM-DD'), '11:00:00')



1 row inserted.

Elapsed: 00:00:00.002


SQL> INSERT INTO vota VALUES (5, 4,  1, TO_DATE('2026-05-29','YYYY-MM-DD'), '14:00:00')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO vota VALUES (6, 4,  1, TO_DATE('2026-05-30','YYYY-MM-DD'), '15:00:00')



1 row inserted.

Elapsed: 00:00:00.003


SQL> INSERT INTO modera VALUES (3, 3, 1, TO_DATE('2026-05-26','YYYY-MM-DD'), '09:00:00', 'cerrar')



1 row inserted.

Elapsed: 00:00:00.304


SQL> INSERT INTO modera VALUES (3, 5, 2, TO_DATE('2026-05-31','YYYY-MM-DD'), '10:30:00', 'eliminar')



1 row inserted.

Elapsed: 00:00:00.003