-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Scripts de testing para SP de Modificación --
-- Requisitos: ejecutar antes 07_test_SP_Altas.sql (y opcionalmente 08_test_SP_Bajas.sql).
-- Los ids no se escriben a mano: se buscan por clave natural y se guardan en la tabla temporal #ref,
-- que vive mientras dure la sesión. Si se ejecuta un test suelto, correr antes la PREPARACIÓN.
-- Cada test indica en un comentario el resultado esperado.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PREPARACIÓN: datos auxiliares que necesitan los tests (se cargan con los SP de alta)

-- Tipo de gol (el alta del script 07 no llega a crearlo)
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Jugada')
    EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Jugada';
GO

-- Dos jugadores más de Argentina y dos de Uruguay
DECLARE @idArg INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
DECLARE @idUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero');
DECLARE @idClub INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'River Plate');

EXEC Participantes.Alta_Jugador @nombre = 'Rodrigo', @apellido = 'De Paul', @fecha_nacimiento = '19940524', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Enzo', @apellido = 'Fernández', @fecha_nacimiento = '20010117', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Ronald', @apellido = 'Araujo', @fecha_nacimiento = '19990307', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Darwin', @apellido = 'Núñez', @fecha_nacimiento = '19990624', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
GO

DECLARE @selArg INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección Argentina');
DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @jDePaul INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'De Paul');
DECLARE @jEnzo INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Fernández' AND nombre = 'Enzo');
DECLARE @jAraujo INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Araujo');
DECLARE @jNunez INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Núñez');

EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jDePaul, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 7;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jEnzo, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 24;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @jAraujo, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 4;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @jNunez, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 19;
GO

-- Tercer partido: Brasil vs Uruguay (fase de grupos)
DECLARE @selBra INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil');
DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @idSede INT = (SELECT id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Monumental');
DECLARE @idFase INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos');
DECLARE @idLog INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);

EXEC Torneo.Alta_Partido @id_sede = @idSede, @id_fase = @idFase, @id_seleccion_local = @selBra, @id_seleccion_visitante = @selUru,
    @id_importacion_origen = @idLog, @fecha_hora_local = '20260622 17:00:00', @asistencia_publico = NULL,
    @goles_local = NULL, @goles_visitante = NULL, @UTC = '20260622 20:00:00';
GO

-- Dos árbitros uruguayos (neutrales para Argentina - Brasil)
DECLARE @idUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idCat INT = (SELECT id_categoria FROM Participantes.Categoria_arbitro WHERE descripcion = 'Internacional');

EXEC Participantes.Alta_Arbitro @id_pais = @idUru, @id_categoria = @idCat, @nombre = 'Andrés', @apellido = 'Matonte', @fecha_nacimiento = '19880430';
EXEC Participantes.Alta_Arbitro @id_pais = @idUru, @id_categoria = @idCat, @nombre = 'Gustavo', @apellido = 'Tejera', @fecha_nacimiento = '19850602';
GO

-- Campaña auxiliar fuera del período del torneo (enero 2026)
DECLARE @idCoca INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Coca-Cola');

EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idCoca, @nombre_campania = 'Campaña Verano Test',
    @fecha_inicio = '20260101', @fecha_fin = '20260131', @presupuesto = 50000;
GO

-- Planilla de Argentina en el partido Argentina - Brasil: De Paul titular y Enzo suplente
DECLARE @idAliArg INT = (SELECT A.id_alineacion_partido
                         FROM Torneo.Alineacion_partido A
                         INNER JOIN Torneo.Partido P ON A.id_partido = P.id_partido
                         INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                         INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                         WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Brasil'
                           AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos')
                           AND A.id_seleccion = L.id_seleccion);
DECLARE @cDePaul INT = (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'De Paul');
DECLARE @cEnzo INT = (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Fernández' AND J.nombre = 'Enzo');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero');

EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAliArg, @id_convocatoria = @cDePaul, @id_posicion_partido = @idPos, @es_titular = 1;
EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAliArg, @id_convocatoria = @cEnzo, @id_posicion_partido = @idPos, @es_titular = 0;
GO

------------------------------------------
-- Tabla de referencias: ids buscados por clave natural

IF OBJECT_ID('tempdb..#ref') IS NOT NULL
    DROP TABLE #ref;

CREATE TABLE #ref (clave VARCHAR(50) PRIMARY KEY, id INT NULL);

INSERT INTO #ref (clave, id) VALUES
    ('pais_arg', (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG')),
    ('pais_bra', (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'BRA')),
    ('pais_uru', (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY')),
    ('sel_arg', (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección Argentina')),
    ('sel_bra', (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil')),
    ('sel_uru', (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay')),
    ('sede_monumental', (SELECT id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Monumental')),
    ('ciudad_bsas', (SELECT id_ciudad FROM Participantes.Ciudad WHERE nombre = 'Buenos Aires')),
    ('fase_grupos', (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos')),
    ('pos_arquero', (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero')),
    ('club_river', (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'River Plate')),
    ('idioma_esp', (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Español')),
    ('tipo_gol_jugada', (SELECT id_tipo FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Jugada')),
    ('periodo_1t', (SELECT id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Primer Tiempo')),
    ('tarjeta_amarilla', (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla')),
    ('motivo_mano', (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Mano intencional')),
    ('franja_prime', (SELECT id_franja FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Prime Time Nocturno')),
    ('anunciante_coca', (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Coca-Cola')),
    ('campania_mundial', (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Campaña Mundial 2026')),
    ('campania_verano', (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Campaña Verano Test')),
    ('pieza_spot', (SELECT id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Spot TV Mundial 30s')),
    ('arb_pitana', (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Pitana')),
    ('arb_ostojich', (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Ostojich')),
    ('arb_matonte', (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Matonte')),
    ('arb_tejera', (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Tejera')),
    ('conv_messi', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi')),
    ('conv_depaul', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'De Paul')),
    ('conv_enzo', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Fernández' AND J.nombre = 'Enzo')),
    ('conv_araujo', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Araujo')),
    ('conv_nunez', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Núñez')),
    ('jug_messi', (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Messi')),
    ('partido_arg_bra', (SELECT P.id_partido FROM Torneo.Partido P
                         INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                         INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                         WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Brasil'
                           AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))),
    ('partido_arg_uru', (SELECT P.id_partido FROM Torneo.Partido P
                         INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                         INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                         WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                           AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))),
    ('partido_bra_uru', (SELECT P.id_partido FROM Torneo.Partido P
                         INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                         INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                         WHERE L.nombre_seleccion = 'Selección de Brasil' AND V.nombre_seleccion = 'Selección de Uruguay'
                           AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos')));

INSERT INTO #ref (clave, id) VALUES
    ('alineacion_arg', (SELECT id_alineacion_partido FROM Torneo.Alineacion_partido
                        WHERE id_partido = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra')
                          AND id_seleccion = (SELECT id FROM #ref WHERE clave = 'sel_arg')));

-- Todas las claves deberían tener un id (si alguna sale NULL, falta correr el script 07)
SELECT * FROM #ref;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Moneda

-- Test 01: Caso de éxito.
-- Resultado esperado: el nombre de ARS pasa a 'Peso argentino (ARS)'.
EXEC Participantes.Modificacion_Moneda
    @codigo_moneda = 'ARS',
    @nombre_moneda = 'Peso argentino (ARS)';
GO

SELECT * FROM Participantes.Moneda WHERE codigo_moneda = 'ARS';
GO

-- Test 02: Moneda inexistente y nombre vacío.
-- Resultado esperado: error 50001 con los dos mensajes acumulados.
EXEC Participantes.Modificacion_Moneda
    @codigo_moneda = 'XXX',
    @nombre_moneda = '   ';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Confederacion

EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'Confederación Europea';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Confederación Europea' pasa a llamarse 'UEFA'.
DECLARE @id INT = (SELECT id_confederacion FROM Participantes.Confederacion WHERE nombre_confederacion = 'Confederación Europea');
EXEC Participantes.Modificacion_Confederacion
    @id_confederacion = @id,
    @nombre_confederacion = 'UEFA';
GO

SELECT * FROM Participantes.Confederacion;
GO

-- Test 02: Nombre duplicado.
-- Resultado esperado: error 'Ya existe otra confederación con ese nombre'.
DECLARE @id INT = (SELECT id_confederacion FROM Participantes.Confederacion WHERE nombre_confederacion = 'UEFA');
EXEC Participantes.Modificacion_Confederacion
    @id_confederacion = @id,
    @nombre_confederacion = 'CONMEBOL';
GO

-- Test 03: Registro inexistente y nombre vacío.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Confederacion
    @id_confederacion = 9999,
    @nombre_confederacion = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Posicion

EXEC Participantes.Alta_Posicion @nombre_posicion = 'Delantero';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Delantero' pasa a 'Centrodelantero'.
DECLARE @id INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Delantero');
EXEC Participantes.Modificacion_Posicion
    @id_posicion = @id,
    @nombre_posicion = 'Centrodelantero';
GO

SELECT * FROM Participantes.Posicion;
GO

-- Test 02: Nombre duplicado.
-- Resultado esperado: error 'Ya existe otra posición con ese nombre'.
DECLARE @id INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Centrodelantero');
EXEC Participantes.Modificacion_Posicion
    @id_posicion = @id,
    @nombre_posicion = 'Arquero';
GO

-- Test 03: Registro inexistente y nombre vacío.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Posicion
    @id_posicion = 9999,
    @nombre_posicion = '   ';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Categoria_arbitro

EXEC Participantes.Alta_Categoria_arbitro @descripcion = 'Regional';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Regional' pasa a 'Confederación'.
DECLARE @id INT = (SELECT id_categoria FROM Participantes.Categoria_arbitro WHERE descripcion = 'Regional');
EXEC Participantes.Modificacion_Categoria_arbitro
    @id_categoria = @id,
    @descripcion = 'Confederación';
GO

SELECT * FROM Participantes.Categoria_arbitro;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otra categoría con esa descripción'.
DECLARE @id INT = (SELECT id_categoria FROM Participantes.Categoria_arbitro WHERE descripcion = 'Confederación');
EXEC Participantes.Modificacion_Categoria_arbitro
    @id_categoria = @id,
    @descripcion = 'Internacional';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Categoria_arbitro
    @id_categoria = 9999,
    @descripcion = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Rol_arbitro

EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Asistente';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Asistente' pasa a 'Árbitro Asistente'.
DECLARE @id INT = (SELECT id_rol_arbitro FROM Participantes.Rol_arbitro WHERE descripcion = 'Asistente');
EXEC Participantes.Modificacion_Rol_arbitro
    @id_rol_arbitro = @id,
    @descripcion = 'Árbitro Asistente';
GO

SELECT * FROM Participantes.Rol_arbitro;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otro rol con esa descripción'.
DECLARE @id INT = (SELECT id_rol_arbitro FROM Participantes.Rol_arbitro WHERE descripcion = 'Árbitro Asistente');
EXEC Participantes.Modificacion_Rol_arbitro
    @id_rol_arbitro = @id,
    @descripcion = 'Árbitro Principal';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Rol_arbitro
    @id_rol_arbitro = 9999,
    @descripcion = ' ';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Idioma

EXEC Participantes.Alta_Idioma @nombre = 'Ingles';
GO

-- Test 01: Caso de éxito (corrección de tilde).
-- Resultado esperado: 'Ingles' pasa a 'Inglés'.
DECLARE @id INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Ingles');
EXEC Participantes.Modificacion_Idioma
    @id_idioma = @id,
    @nombre = 'Inglés';
GO

SELECT * FROM Participantes.Idioma;
GO

-- Test 02: Nombre duplicado.
-- Resultado esperado: error 'Ya existe otro idioma con ese nombre'.
DECLARE @id INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Participantes.Modificacion_Idioma
    @id_idioma = @id,
    @nombre = 'Español';
GO

-- Test 03: Registro inexistente y nombre vacío.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Idioma
    @id_idioma = 9999,
    @nombre = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Grupo_Torneo

EXEC Torneo.Alta_Grupo_Torneo @nombre_grupo = 'C';
GO

-- Test 01: Caso de éxito (se envía en minúscula y se guarda en mayúscula).
-- Resultado esperado: el grupo 'C' pasa a ser 'D'.
DECLARE @id INT = (SELECT id_grupo FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'C');
EXEC Torneo.Modificacion_Grupo_Torneo
    @id_grupo = @id,
    @nombre_grupo = 'd';
GO

SELECT * FROM Torneo.Grupo_torneo;
GO

-- Test 02: Formato inválido.
-- Resultado esperado: error 'El grupo debe ser una letra de la A a la Z'.
DECLARE @id INT = (SELECT id_grupo FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'D');
EXEC Torneo.Modificacion_Grupo_Torneo
    @id_grupo = @id,
    @nombre_grupo = '5';
GO

-- Test 03: Letra duplicada.
-- Resultado esperado: error 'Ya existe otro grupo con esa letra'.
DECLARE @id INT = (SELECT id_grupo FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'D');
EXEC Torneo.Modificacion_Grupo_Torneo
    @id_grupo = @id,
    @nombre_grupo = 'A';
GO

-- Test 04: Registro inexistente y nombre vacío.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Grupo_Torneo
    @id_grupo = 9999,
    @nombre_grupo = ' ';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Fase

EXEC Torneo.Alta_Fase @nombre_fase = 'Octavos';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Octavos' pasa a 'Octavos de final'.
DECLARE @id INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Octavos');
EXEC Torneo.Modificacion_Fase
    @id_fase = @id,
    @nombre_fase = 'Octavos de final';
GO

SELECT * FROM Torneo.Fase;
GO

-- Test 02: Nombre duplicado.
-- Resultado esperado: error 'Ya existe otra fase con ese nombre'.
DECLARE @id INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Octavos de final');
EXEC Torneo.Modificacion_Fase
    @id_fase = @id,
    @nombre_fase = 'Fase de Grupos';
GO

-- Test 03: Registro inexistente y nombre vacío.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Fase
    @id_fase = 9999,
    @nombre_fase = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Log_importacion

-- Test 01: Caso de éxito (solo se envían algunos campos).
-- Resultado esperado: cambian registros con error y estado; el resto de los campos queda igual.
DECLARE @id INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);
SELECT * FROM Torneo.Log_importacion WHERE id_log = @id;

EXEC Torneo.Modificacion_Log_importacion
    @id_log = @id,
    @registros_con_error = 3,
    @estado = 'Finalizado con errores';

SELECT * FROM Torneo.Log_importacion WHERE id_log = @id;
GO

-- Test 02: Errores mayores a los registros procesados (comparando con el valor ya guardado).
-- Resultado esperado: error 'Los registros con error no pueden superar a los registros procesados'.
DECLARE @id INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);
EXEC Torneo.Modificacion_Log_importacion
    @id_log = @id,
    @registros_procesados = 1,
    @registros_con_error = 5;
GO

-- Test 03: Texto vacío, números negativos y fecha futura.
-- Resultado esperado: error con cuatro mensajes acumulados (archivo vacío, negativos, fecha futura y,
--                     como -1 procesados queda por debajo de los 3 errores ya guardados, errores > procesados).
DECLARE @id INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);
EXEC Torneo.Modificacion_Log_importacion
    @id_log = @id,
    @nombre_archivo_o_fuente = '  ',
    @registros_procesados = -1,
    @fecha_hora_ejecucion = '20500101 10:00:00';
GO

-- Test 04: Registro inexistente sin datos para modificar.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Log_importacion
    @id_log = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Esquema_tactico

EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '4-3-3';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: '4-3-3' pasa a '4-2-3-1'.
DECLARE @id INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-3-3');
EXEC Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico = @id,
    @descripcion_esquema = '4-2-3-1';
GO

SELECT * FROM Torneo.Esquema_tactico;
GO

-- Test 02: Esquema que no suma 10 jugadores de campo.
-- Resultado esperado: error 'Los números del esquema deben sumar 10 jugadores de campo'.
DECLARE @id INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-2-3-1');
EXEC Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico = @id,
    @descripcion_esquema = '4-4-3';
GO

-- Test 03: Formato inválido.
-- Resultado esperado: error de formato (números separados por guiones).
DECLARE @id INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-2-3-1');
EXEC Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico = @id,
    @descripcion_esquema = 'Ofensivo';
GO

-- Test 04: Esquema duplicado.
-- Resultado esperado: error 'Ya existe otro esquema táctico con esa descripción'.
DECLARE @id INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-2-3-1');
EXEC Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico = @id,
    @descripcion_esquema = '4-4-2';
GO

-- Test 05: Registro inexistente.
-- Resultado esperado: error 'El esquema táctico que intenta modificar no existe'.
EXEC Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico = 9999,
    @descripcion_esquema = '3-5-2';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Tipo_gol

EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Cabeza';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Cabeza' pasa a 'Cabezazo'.
DECLARE @id INT = (SELECT id_tipo FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Cabeza');
EXEC Torneo.Modificacion_Tipo_gol
    @id_tipo = @id,
    @descripcion_tipo = 'Cabezazo';
GO

SELECT * FROM Torneo.Tipo_gol;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otro tipo de gol con esa descripción'.
DECLARE @id INT = (SELECT id_tipo FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Cabezazo');
EXEC Torneo.Modificacion_Tipo_gol
    @id_tipo = @id,
    @descripcion_tipo = 'Jugada';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Tipo_gol
    @id_tipo = 9999,
    @descripcion_tipo = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Periodo_partido

EXEC Torneo.Alta_Periodo_partido @descripcion_periodo = 'Segundo';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Segundo' pasa a 'Segundo Tiempo'.
DECLARE @id INT = (SELECT id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Segundo');
EXEC Torneo.Modificacion_Periodo_partido
    @id_periodo_partido = @id,
    @descripcion_periodo = 'Segundo Tiempo';
GO

SELECT * FROM Torneo.Periodo_partido;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otro periodo con esa descripción'.
DECLARE @id INT = (SELECT id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Segundo Tiempo');
EXEC Torneo.Modificacion_Periodo_partido
    @id_periodo_partido = @id,
    @descripcion_periodo = 'Primer Tiempo';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Periodo_partido
    @id_periodo_partido = 9999,
    @descripcion_periodo = ' ';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Tipo_tarjeta

EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Rojo';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Rojo' pasa a 'Roja'.
DECLARE @id INT = (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Rojo');
EXEC Torneo.Modificacion_Tipo_tarjeta
    @id_tipo_tarjeta = @id,
    @descripcion_tarjeta = 'Roja';
GO

SELECT * FROM Torneo.Tipo_tarjeta;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otro tipo de tarjeta con esa descripción'.
DECLARE @id INT = (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja');
EXEC Torneo.Modificacion_Tipo_tarjeta
    @id_tipo_tarjeta = @id,
    @descripcion_tarjeta = 'Amarilla';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Tipo_tarjeta
    @id_tipo_tarjeta = 9999,
    @descripcion_tarjeta = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Motivo_tarjeta

EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Juego brusco';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Juego brusco' pasa a 'Juego brusco grave'.
DECLARE @id INT = (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego brusco');
EXEC Torneo.Modificacion_Motivo_tarjeta
    @id_motivo = @id,
    @descripcion_motivo = 'Juego brusco grave';
GO

SELECT * FROM Torneo.Motivo_tarjeta;
GO

-- Test 02: Descripción duplicada.
-- Resultado esperado: error 'Ya existe otro motivo con esa descripción'.
DECLARE @id INT = (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego brusco grave');
EXEC Torneo.Modificacion_Motivo_tarjeta
    @id_motivo = @id,
    @descripcion_motivo = 'Mano intencional';
GO

-- Test 03: Registro inexistente y descripción vacía.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Motivo_tarjeta
    @id_motivo = 9999,
    @descripcion_motivo = '   ';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Franja_horaria_tarifa

EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Mañana', @hora_inicio_local = '08:00:00',
    @hora_fin_local = '11:59:59', @tarifa_base_usd = 50000.00;
GO

-- Test 01: Caso de éxito (descripción y tarifa; los horarios quedan igual).
-- Resultado esperado: la franja pasa a 'Franja Matutina' con tarifa 60000.
DECLARE @id INT = (SELECT id_franja FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Mañana');
EXEC Publicidad.Modificacion_Franja_horaria_tarifa
    @id_franja = @id,
    @descripcion_franja = 'Franja Matutina',
    @tarifa_base_usd = 60000.00;
GO

SELECT * FROM Publicidad.Franja_horaria_tarifa;
GO

-- Test 02: Hora de inicio posterior a la hora de fin ya guardada (11:59:59).
-- Resultado esperado: error 'La hora de inicio de la franja debe ser anterior a la hora de fin'.
DECLARE @id INT = (SELECT id_franja FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Franja Matutina');
EXEC Publicidad.Modificacion_Franja_horaria_tarifa
    @id_franja = @id,
    @hora_inicio_local = '13:00:00';
GO

-- Test 03: Descripción duplicada y tarifa negativa.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_franja FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Franja Matutina');
EXEC Publicidad.Modificacion_Franja_horaria_tarifa
    @id_franja = @id,
    @descripcion_franja = 'Prime Time Nocturno',
    @tarifa_base_usd = -10.00;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Publicidad.Modificacion_Franja_horaria_tarifa
    @id_franja = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Cotizacion_moneda

EXEC Participantes.Alta_Cotizacion_moneda @codigo_moneda = 'ARS', @fecha_cotizacion = '20231021', @valor_en_usd = 0.0011;
GO

-- Test 01: Caso de éxito (solo el valor).
-- Resultado esperado: la cotización de ARS del 20/10/2023 pasa a 0.0012.
DECLARE @id INT = (SELECT id_cotizacion FROM Participantes.Cotizacion_moneda WHERE codigo_moneda = 'ARS' AND fecha_cotizacion = '20231020');
EXEC Participantes.Modificacion_Cotizacion_moneda
    @id_cotizacion = @id,
    @valor_en_usd = 0.0012;
GO

SELECT * FROM Participantes.Cotizacion_moneda;
GO

-- Test 02: Fecha duplicada para la misma moneda.
-- Resultado esperado: error 'Ya existe una cotización de esa moneda para la fecha indicada'.
DECLARE @id INT = (SELECT id_cotizacion FROM Participantes.Cotizacion_moneda WHERE codigo_moneda = 'ARS' AND fecha_cotizacion = '20231021');
EXEC Participantes.Modificacion_Cotizacion_moneda
    @id_cotizacion = @id,
    @fecha_cotizacion = '20231020';
GO

-- Test 03: Valor cero y fecha futura.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_cotizacion FROM Participantes.Cotizacion_moneda WHERE codigo_moneda = 'ARS' AND fecha_cotizacion = '20231021');
EXEC Participantes.Modificacion_Cotizacion_moneda
    @id_cotizacion = @id,
    @fecha_cotizacion = '20501231',
    @valor_en_usd = 0;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Cotizacion_moneda
    @id_cotizacion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Pais

-- Test 01: Caso de éxito (huso horario y PBI de Argentina).
-- Resultado esperado: Argentina queda con huso 'UTC-3' y PBI 13700; moneda, nombre e ISO no cambian.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Modificacion_Pais
    @id_pais = @id,
    @pbi_per_capita = 13700.00,
    @huso_horario = 'utc-3';
GO

-- Test 02: Caso de éxito (huso de Brasil y Uruguay, usados luego por el cálculo de prime time).
-- Resultado esperado: ambos países quedan con huso 'UTC-3'.
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'pais_bra');
DECLARE @idUru INT = (SELECT id FROM #ref WHERE clave = 'pais_uru');
EXEC Participantes.Modificacion_Pais @id_pais = @idBra, @huso_horario = 'UTC-3';
EXEC Participantes.Modificacion_Pais @id_pais = @idUru, @huso_horario = 'UTC-03:00';
GO

SELECT * FROM Participantes.Pais;
GO

-- Test 03: Nombre vacío, ISO de 2 letras, PBI negativo y huso con formato inválido.
-- Resultado esperado: error con los cuatro mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Modificacion_Pais
    @id_pais = @id,
    @nombre = ' ',
    @codigo_iso = 'AR',
    @pbi_per_capita = -1,
    @huso_horario = 'GMT+25';
GO

-- Test 04: Código ISO de otro país y moneda inexistente.
-- Resultado esperado: error 'Ya existe otro país con ese código ISO' y 'La moneda indicada no existe'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Modificacion_Pais
    @id_pais = @id,
    @codigo_iso = 'BRA',
    @codigo_moneda = 'ZZZ';
GO

-- Test 05: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Pais
    @id_pais = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Parametros_suspension

DECLARE @idFase INT = (SELECT id FROM #ref WHERE clave = 'fase_grupos');
EXEC Torneo.Alta_Parametros_suspension @id_fase_limpieza_amarillas = @idFase, @fechas_suspension_roja_directa = 2,
    @fechas_suspension_doble_amarilla = 1, @activo = 0;
GO

-- Test 01: Caso de éxito (se activa el nuevo juego de parámetros).
-- Resultado esperado: el registro nuevo queda activo con 3 fechas por roja directa y el anterior pasa a activo = 0.
DECLARE @id INT = (SELECT MAX(id_parametro) FROM Torneo.Parametros_suspension);
SELECT * FROM Torneo.Parametros_suspension;

EXEC Torneo.Modificacion_Parametros_suspension
    @id_parametro = @id,
    @fechas_suspension_roja_directa = 3,
    @activo = 1;

SELECT * FROM Torneo.Parametros_suspension;
GO

-- Test 02: Fechas en cero y fase inexistente.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT MAX(id_parametro) FROM Torneo.Parametros_suspension);
EXEC Torneo.Modificacion_Parametros_suspension
    @id_parametro = @id,
    @id_fase_limpieza_amarillas = 9999,
    @fechas_suspension_roja_directa = 0,
    @fechas_suspension_doble_amarilla = 0;
GO

-- Test 03: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Parametros_suspension
    @id_parametro = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Feriado_pais

-- Test 01: Caso de éxito (se completa la descripción que estaba en NULL).
-- Resultado esperado: el feriado del 09/07/2026 queda con descripción 'Día de la Independencia'.
DECLARE @id INT = (SELECT id_feriado FROM Participantes.Feriado_pais
                   WHERE id_pais = (SELECT id FROM #ref WHERE clave = 'pais_arg') AND fecha = '20260709');
EXEC Participantes.Modificacion_Feriado_pais
    @id_feriado = @id,
    @descripcion_feriado = 'Día de la Independencia';
GO

SELECT * FROM Participantes.Feriado_pais;
GO

-- Test 02: Fecha que ya tiene otro feriado del mismo país.
-- Resultado esperado: error 'El país ya tiene registrado un feriado en esa fecha'.
DECLARE @id INT = (SELECT id_feriado FROM Participantes.Feriado_pais
                   WHERE id_pais = (SELECT id FROM #ref WHERE clave = 'pais_arg') AND fecha = '20260709');
EXEC Participantes.Modificacion_Feriado_pais
    @id_feriado = @id,
    @fecha = '20260525';
GO

-- Test 03: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Feriado_pais
    @id_feriado = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Ciudad

DECLARE @idArg INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Alta_Ciudad @id_pais = @idArg, @nombre = 'Cordoba';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Cordoba' pasa a 'Córdoba Capital'.
DECLARE @id INT = (SELECT id_ciudad FROM Participantes.Ciudad WHERE nombre = 'Cordoba');
EXEC Participantes.Modificacion_Ciudad
    @id_ciudad = @id,
    @nombre = 'Córdoba Capital';
GO

SELECT * FROM Participantes.Ciudad;
GO

-- Test 02: Ciudad duplicada en el mismo país.
-- Resultado esperado: error 'Ya existe una ciudad con ese nombre en el país indicado'.
DECLARE @id INT = (SELECT id_ciudad FROM Participantes.Ciudad WHERE nombre = 'Córdoba Capital');
EXEC Participantes.Modificacion_Ciudad
    @id_ciudad = @id,
    @nombre = 'Buenos Aires';
GO

-- Test 03: Nombre vacío y país inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_ciudad FROM Participantes.Ciudad WHERE nombre = 'Córdoba Capital');
EXEC Participantes.Modificacion_Ciudad
    @id_ciudad = @id,
    @id_pais = 9999,
    @nombre = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Club_origen

DECLARE @idArg INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Alta_Club_origen @nombre = 'Boca', @id_pais_club = @idArg;
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Boca' pasa a 'Boca Juniors'.
DECLARE @id INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'Boca');
EXEC Participantes.Modificacion_Club_origen
    @id_club = @id,
    @nombre = 'Boca Juniors';
GO

SELECT * FROM Participantes.Club_origen;
GO

-- Test 02: Club duplicado en el mismo país.
-- Resultado esperado: error 'Ya existe un club con ese nombre en el país indicado'.
DECLARE @id INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'Boca Juniors');
EXEC Participantes.Modificacion_Club_origen
    @id_club = @id,
    @nombre = 'River Plate';
GO

-- Test 03: Nombre vacío y país inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'Boca Juniors');
EXEC Participantes.Modificacion_Club_origen
    @id_club = @id,
    @nombre = ' ',
    @id_pais_club = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Arbitro

-- Test 01: Caso de éxito (nombre completo y categoría).
-- Resultado esperado: Pitana queda como 'Néstor Fabián' con categoría 'Confederación'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'arb_pitana');
DECLARE @idCat INT = (SELECT id_categoria FROM Participantes.Categoria_arbitro WHERE descripcion = 'Confederación');
EXEC Participantes.Modificacion_Arbitro
    @id_arbitro = @id,
    @nombre = 'Néstor Fabián',
    @id_categoria = @idCat;
GO

SELECT * FROM Participantes.Arbitro;
GO

-- Test 02: Cambio a la nacionalidad de una selección de un partido donde ya está designado.
-- Resultado esperado: error de neutralidad (Ostojich está designado en Argentina - Brasil).
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'arb_ostojich');
DECLARE @idArg INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Participantes.Modificacion_Arbitro
    @id_arbitro = @id,
    @id_pais = @idArg;
GO

-- Test 03: Nombre vacío, menor de 18 años y categoría inexistente.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'arb_matonte');
EXEC Participantes.Modificacion_Arbitro
    @id_arbitro = @id,
    @nombre = '',
    @fecha_nacimiento = '20150101',
    @id_categoria = 9999;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Arbitro
    @id_arbitro = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Seleccion

-- Test 01: Caso de éxito (cambio de grupo).
-- Resultado esperado: Uruguay pasa al grupo B.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sel_uru');
DECLARE @idGrupoB INT = (SELECT id_grupo FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'B');
EXEC Participantes.Modificacion_Seleccion
    @id_seleccion = @id,
    @id_grupo = @idGrupoB;
GO

SELECT * FROM Participantes.Seleccion;
GO

-- Test 02: Cambio a un país que ya tiene selección, con partidos ya registrados.
-- Resultado esperado: error 'El país indicado ya tiene otra selección registrada' y
--                     'No se puede cambiar el país de una selección que ya tiene partidos registrados'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sel_arg');
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'pais_bra');
EXEC Participantes.Modificacion_Seleccion
    @id_seleccion = @id,
    @id_pais = @idBra;
GO

-- Test 03: Nombre duplicado, confederación y grupo inexistentes.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sel_uru');
EXEC Participantes.Modificacion_Seleccion
    @id_seleccion = @id,
    @nombre_seleccion = 'Selección de Brasil',
    @id_confederacion = 9999,
    @id_grupo = 9999;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Seleccion
    @id_seleccion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Idioma_arbitro

-- Test 01: Caso de éxito (Pitana cambia Español por Inglés).
-- Resultado esperado: la asociación de Pitana pasa a ser con Inglés.
DECLARE @idArb INT = (SELECT id FROM #ref WHERE clave = 'arb_pitana');
DECLARE @idEsp INT = (SELECT id FROM #ref WHERE clave = 'idioma_esp');
DECLARE @idIng INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Participantes.Modificacion_Idioma_arbitro
    @id_arbitro = @idArb,
    @id_idioma = @idEsp,
    @id_idioma_nuevo = @idIng;
GO

SELECT * FROM Participantes.Idioma_arbitro;
GO

-- Test 02: El nuevo idioma ya está asociado al árbitro.
-- Resultado esperado: error 'El árbitro ya tiene asociado el nuevo idioma'.
DECLARE @idArb INT = (SELECT id FROM #ref WHERE clave = 'arb_pitana');
DECLARE @idEsp INT = (SELECT id FROM #ref WHERE clave = 'idioma_esp');
DECLARE @idIng INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Participantes.Alta_Idioma_arbitro @id_arbitro = @idArb, @id_idioma = @idEsp;
EXEC Participantes.Modificacion_Idioma_arbitro
    @id_arbitro = @idArb,
    @id_idioma = @idEsp,
    @id_idioma_nuevo = @idIng;
GO

-- Test 03: Asociación inexistente e idioma nuevo inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Participantes.Modificacion_Idioma_arbitro
    @id_arbitro = 9999,
    @id_idioma = 9999,
    @id_idioma_nuevo = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Anunciante

DECLARE @idArg INT = (SELECT id FROM #ref WHERE clave = 'pais_arg');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Pepsi', @id_pais_origen = @idArg, @identificacion_fiscal = '30-55555555-5';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: 'Pepsi' pasa a 'PepsiCo'.
DECLARE @id INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Pepsi');
EXEC Publicidad.Modificacion_Anunciante
    @id_anunciante = @id,
    @nombre_anunciante = 'PepsiCo';
GO

SELECT * FROM Publicidad.Anunciante;
GO

-- Test 02: Nombre e identificación fiscal de otro anunciante.
-- Resultado esperado: error con ambos mensajes de duplicado.
DECLARE @id INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'PepsiCo');
EXEC Publicidad.Modificacion_Anunciante
    @id_anunciante = @id,
    @nombre_anunciante = 'Coca-Cola',
    @identificacion_fiscal = '30-12345678-9';
GO

-- Test 03: Identificación fiscal vacía y país inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'PepsiCo');
EXEC Publicidad.Modificacion_Anunciante
    @id_anunciante = @id,
    @identificacion_fiscal = '  ',
    @id_pais_origen = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Sede

-- Test 01: Caso de éxito (capacidad real del estadio).
-- Resultado esperado: el Monumental queda con capacidad 83214.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sede_monumental');
EXEC Torneo.Modificacion_Sede
    @id_sede = @id,
    @capacidad = 83214;
GO

SELECT * FROM Torneo.Sede;
GO

-- Test 02: Capacidad menor a la asistencia ya registrada (80000 en Argentina - Brasil).
-- Resultado esperado: error 'La nueva capacidad es menor a la asistencia ya registrada...'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sede_monumental');
EXEC Torneo.Modificacion_Sede
    @id_sede = @id,
    @capacidad = 50000;
GO

-- Test 03: Huso horario con formato inválido, coordenadas fuera de rango y ciudad inexistente.
-- Resultado esperado: error con los cuatro mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'sede_monumental');
EXEC Torneo.Modificacion_Sede
    @id_sede = @id,
    @huso_horario = 'Hora ARG',
    @latitud = 120,
    @longitud = -200,
    @id_ciudad = 9999;
GO

-- Test 04: Nombre de estadio duplicado en la misma ciudad.
-- Resultado esperado: error 'Ya existe un estadio con ese nombre en la ciudad indicada'.
DECLARE @idCiudad INT = (SELECT id FROM #ref WHERE clave = 'ciudad_bsas');
EXEC Torneo.Alta_Sede @id_ciudad = @idCiudad, @nombre_estadio = 'La Bombonera', @capacidad = 54000,
    @latitud = -34.635556, @longitud = -58.364722, @huso_horario = 'UTC-3';

DECLARE @id INT = (SELECT id_sede FROM Torneo.Sede WHERE nombre_estadio = 'La Bombonera');
EXEC Torneo.Modificacion_Sede
    @id_sede = @id,
    @nombre_estadio = 'Monumental';
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Jugador

-- Test 01: Caso de éxito (posición habitual).
-- Resultado esperado: Messi queda con posición 'Centrodelantero'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'jug_messi');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Centrodelantero');
EXEC Participantes.Modificacion_Jugador
    @id_jugador = @id,
    @id_posicion_habitual = @idPos;
GO

SELECT * FROM Participantes.Jugador;
GO

-- Test 02: Apellido vacío y menor de 15 años.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'jug_messi');
EXEC Participantes.Modificacion_Jugador
    @id_jugador = @id,
    @apellido = '',
    @fecha_nacimiento = '20200101';
GO

-- Test 03: País, posición y club inexistentes.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'jug_messi');
EXEC Participantes.Modificacion_Jugador
    @id_jugador = @id,
    @id_pais_nacimiento = 9999,
    @id_posicion_habitual = 9999,
    @id_club_origen = 9999;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Jugador
    @id_jugador = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Integrante_cuerpo_tecnico

DECLARE @idSel INT = (SELECT id FROM #ref WHERE clave = 'sel_arg');
EXEC Participantes.Alta_Integrante_cuerpo_tecnico @id_seleccion = @idSel, @nombre = 'Pablo', @apellido = 'Aimar', @cargo_rol = 'Ayudante';
GO

-- Test 01: Caso de éxito.
-- Resultado esperado: Aimar queda con cargo 'Ayudante de campo'.
DECLARE @id INT = (SELECT id_integrante_ct FROM Participantes.Integrante_cuerpo_tecnico WHERE apellido = 'Aimar');
EXEC Participantes.Modificacion_Integrante_cuerpo_tecnico
    @id_integrante_ct = @id,
    @cargo_rol = 'Ayudante de campo';
GO

SELECT * FROM Participantes.Integrante_cuerpo_tecnico;
GO

-- Test 02: Integrante duplicado (mismos datos que Scaloni).
-- Resultado esperado: error 'Ya existe ese integrante con el mismo cargo en la selección'.
DECLARE @id INT = (SELECT id_integrante_ct FROM Participantes.Integrante_cuerpo_tecnico WHERE apellido = 'Aimar');
EXEC Participantes.Modificacion_Integrante_cuerpo_tecnico
    @id_integrante_ct = @id,
    @nombre = 'Lionel',
    @apellido = 'Scaloni',
    @cargo_rol = 'Director Técnico';
GO

-- Test 03: Cargo vacío y selección inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id_integrante_ct FROM Participantes.Integrante_cuerpo_tecnico WHERE apellido = 'Aimar');
EXEC Participantes.Modificacion_Integrante_cuerpo_tecnico
    @id_integrante_ct = @id,
    @cargo_rol = ' ',
    @id_seleccion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Convocatoria

-- Test 01: Caso de éxito (cambio de dorsal).
-- Resultado esperado: De Paul pasa del dorsal 7 al 8.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Participantes.Modificacion_Convocatoria
    @id_convocatoria = @id,
    @dorsal = 8;
GO

SELECT * FROM Participantes.Convocatoria;
GO

-- Test 02: Dorsal usado por otro jugador de la selección (10 de Messi).
-- Resultado esperado: error 'El dorsal ya está asignado a otro jugador de la selección'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Participantes.Modificacion_Convocatoria
    @id_convocatoria = @id,
    @dorsal = 10;
GO

-- Test 03: Estado vacío, fecha futura y dorsal fuera de rango.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Participantes.Modificacion_Convocatoria
    @id_convocatoria = @id,
    @estado_convocatoria = '',
    @fecha_alta_convocatoria = '20500101',
    @dorsal = 30;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Convocatoria
    @id_convocatoria = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Modificacion_Novedad_convocatoria

-- Se registra un reemplazo en Uruguay: sale Araujo y entra Núñez.
DECLARE @cBaja INT = (SELECT id FROM #ref WHERE clave = 'conv_araujo');
DECLARE @cAlta INT = (SELECT id FROM #ref WHERE clave = 'conv_nunez');
EXEC Participantes.Registrar_Reemplazo_Convocatoria @id_convocatoria_baja = @cBaja, @id_convocatoria_alta = @cAlta,
    @motivo_cambio = 'Lesion', @fecha_cambio = '20260601', @observaciones = NULL;
GO

-- Test 01: Caso de éxito (motivo y observaciones).
-- Resultado esperado: la novedad queda con motivo 'Lesión muscular' y la observación cargada.
DECLARE @id INT = (SELECT MAX(id_novedad) FROM Participantes.Novedad_convocatoria
                   WHERE id_convocatoria_baja = (SELECT id FROM #ref WHERE clave = 'conv_araujo'));
EXEC Participantes.Modificacion_Novedad_convocatoria
    @id_novedad = @id,
    @motivo_cambio = 'Lesión muscular',
    @observaciones = 'Parte médico recibido';
GO

SELECT * FROM Participantes.Novedad_convocatoria;
GO

-- Test 02: Motivo vacío y fecha anterior a la convocatoria original (15/05/2026).
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT MAX(id_novedad) FROM Participantes.Novedad_convocatoria
                   WHERE id_convocatoria_baja = (SELECT id FROM #ref WHERE clave = 'conv_araujo'));
EXEC Participantes.Modificacion_Novedad_convocatoria
    @id_novedad = @id,
    @motivo_cambio = '  ',
    @fecha_cambio = '20260101';
GO

-- Test 03: Fecha futura.
-- Resultado esperado: error 'La fecha del cambio no puede ser futura'.
DECLARE @id INT = (SELECT MAX(id_novedad) FROM Participantes.Novedad_convocatoria
                   WHERE id_convocatoria_baja = (SELECT id FROM #ref WHERE clave = 'conv_araujo'));
EXEC Participantes.Modificacion_Novedad_convocatoria
    @id_novedad = @id,
    @fecha_cambio = '20500101';
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Participantes.Modificacion_Novedad_convocatoria
    @id_novedad = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Campania_publicitaria

-- Test 01: Caso de éxito (presupuesto).
-- Resultado esperado: la 'Campaña Mundial 2026' queda con presupuesto 2.000.000.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'campania_mundial');
EXEC Publicidad.Modificacion_Campania_publicitaria
    @id_campania = @id,
    @presupuesto = 2000000.00;
GO

SELECT * FROM Publicidad.Campania_publicitaria;
GO

-- Test 02: Acortar la campaña dejando afuera una exhibición ya registrada (15/06/2026).
-- Resultado esperado: error 'El nuevo período deja afuera exhibiciones ya registradas de la campaña'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'campania_mundial');
EXEC Publicidad.Modificacion_Campania_publicitaria
    @id_campania = @id,
    @fecha_fin = '20260601';
GO

-- Test 03: Fecha de fin anterior a la fecha de inicio guardada (01/05/2026).
-- Resultado esperado: error 'La fecha de fin no puede ser anterior a la fecha de inicio'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'campania_mundial');
EXEC Publicidad.Modificacion_Campania_publicitaria
    @id_campania = @id,
    @fecha_fin = '20260401';
GO

-- Test 04: Nombre vacío, presupuesto cero y anunciante inexistente.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'campania_mundial');
EXEC Publicidad.Modificacion_Campania_publicitaria
    @id_campania = @id,
    @nombre_campania = '',
    @presupuesto = 0,
    @id_anunciante = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Mercado_interes_campania

DECLARE @idCamp INT = (SELECT id FROM #ref WHERE clave = 'campania_verano');
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'pais_bra');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idBra;
GO

-- Test 01: Caso de éxito (Brasil se reemplaza por Uruguay).
-- Resultado esperado: la campaña de verano queda con Uruguay como mercado de interés.
DECLARE @idCamp INT = (SELECT id FROM #ref WHERE clave = 'campania_verano');
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'pais_bra');
DECLARE @idUru INT = (SELECT id FROM #ref WHERE clave = 'pais_uru');
EXEC Publicidad.Modificacion_Mercado_interes_campania
    @id_campania = @idCamp,
    @id_pais = @idBra,
    @id_pais_nuevo = @idUru;
GO

SELECT * FROM Publicidad.Mercado_interes_campania;
GO

-- Test 02: El nuevo país ya es mercado de la campaña.
-- Resultado esperado: error 'La campaña ya tiene asociado el nuevo país como mercado de interés'.
DECLARE @idCamp INT = (SELECT id FROM #ref WHERE clave = 'campania_verano');
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'pais_bra');
DECLARE @idUru INT = (SELECT id FROM #ref WHERE clave = 'pais_uru');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idBra;
EXEC Publicidad.Modificacion_Mercado_interes_campania
    @id_campania = @idCamp,
    @id_pais = @idBra,
    @id_pais_nuevo = @idUru;
GO

-- Test 03: Asociación inexistente y país nuevo inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Publicidad.Modificacion_Mercado_interes_campania
    @id_campania = 9999,
    @id_pais = 9999,
    @id_pais_nuevo = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Pieza_publicitaria

DECLARE @idCamp INT = (SELECT id FROM #ref WHERE clave = 'campania_verano');
DECLARE @idEsp INT = (SELECT id FROM #ref WHERE clave = 'idioma_esp');
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idEsp, @nombre_pieza = 'Banner Enero',
    @duracion_segundos = 15, @url_contenido_media = 'https://videofifa.com/campanias/banner_enero.mp4';
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idEsp, @nombre_pieza = 'Banner Febrero',
    @duracion_segundos = 15, @url_contenido_media = 'https://videofifa.com/campanias/banner_febrero.mp4';
GO

-- Test 01: Caso de éxito (duración e idioma).
-- Resultado esperado: 'Banner Enero' queda con 20 segundos y en Inglés.
DECLARE @id INT = (SELECT id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Banner Enero');
DECLARE @idIng INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Publicidad.Modificacion_Pieza_publicitaria
    @id_pieza = @id,
    @duracion_segundos = 20,
    @id_idioma = @idIng;
GO

SELECT * FROM Publicidad.Pieza_publicitaria;
GO

-- Test 02: Nombre repetido dentro de la misma campaña.
-- Resultado esperado: error 'La campaña ya tiene otra pieza con ese nombre'.
DECLARE @id INT = (SELECT id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Banner Febrero');
EXEC Publicidad.Modificacion_Pieza_publicitaria
    @id_pieza = @id,
    @nombre_pieza = 'Banner Enero';
GO

-- Test 03: URL vacía, duración cero e idioma inexistente.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Banner Febrero');
EXEC Publicidad.Modificacion_Pieza_publicitaria
    @id_pieza = @id,
    @url_contenido_media = ' ',
    @duracion_segundos = 0,
    @id_idioma = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Partido

-- Test 01: Caso de éxito (asistencia).
-- Resultado esperado: Argentina - Brasil queda con asistencia 81000 y el resto igual.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @asistencia_publico = 81000;
GO

SELECT * FROM Torneo.Partido;
GO

-- Test 02: Local igual al visitante, en un partido que ya tiene alineación y árbitros.
-- Resultado esperado: error 'no pueden ser la misma' y 'No se pueden cambiar las selecciones...'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idBra INT = (SELECT id FROM #ref WHERE clave = 'sel_bra');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @id_seleccion_local = @idBra;
GO

-- Test 03: Asistencia mayor a la capacidad (83214) y UTC que no coincide con el huso de la sede (UTC-3).
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @asistencia_publico = 90000,
    @UTC = '20260615 18:00:00';
GO

-- Test 04: Mover Argentina - Uruguay al mismo horario y sede que Argentina - Brasil (UTC coherente).
-- Resultado esperado: error 'La sede ya tiene otro partido programado en ese horario'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_uru');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @fecha_hora_local = '20260615 17:00:00',
    @UTC = '20260615 20:00:00';
GO

-- Test 05: Resultado para un partido reprogramado a una fecha futura.
-- Resultado esperado: error 'No se puede cargar el resultado de un partido que todavía no se jugó'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_bra_uru');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @fecha_hora_local = '20300101 10:00:00',
    @UTC = '20300101 13:00:00',
    @goles_local = 1,
    @goles_visitante = 1;
GO

-- Test 06: Resultado cargado de una sola selección.
-- Resultado esperado: error 'El resultado debe tener cargados los goles de ambas selecciones'.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'partido_bra_uru');
EXEC Torneo.Modificacion_Partido
    @id_partido = @id,
    @goles_local = 2;
GO

-- Test 07: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Partido
    @id_partido = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Alineacion_partido

-- Test 01: Caso de éxito (cambio de esquema).
-- Resultado esperado: la alineación de Argentina queda con el esquema 4-2-3-1.
DECLARE @id INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idEsq INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-2-3-1');
EXEC Torneo.Modificacion_Alineacion_partido
    @id_alineacion_partido = @id,
    @id_esquema_tactico = @idEsq;
GO

SELECT * FROM Torneo.Alineacion_partido;
GO

-- Test 02: Alineación y esquema inexistentes.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Alineacion_partido
    @id_alineacion_partido = 9999,
    @id_esquema_tactico = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Detalle_alineacion_jugador

-- Test 01: Caso de éxito (posición en cancha).
-- Resultado esperado: De Paul figura como 'Centrodelantero' en la planilla.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Centrodelantero');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @id_posicion_partido = @idPos;
GO

SELECT * FROM Torneo.Detalle_alineacion_jugador;
GO

-- Test 02: Caso de éxito (Enzo pasa de suplente a titular).
-- Resultado esperado: Enzo queda con es_titular = 1.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_enzo');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @es_titular = 1;
GO

-- Test 03: Caso de éxito (Enzo vuelve al banco).
-- Resultado esperado: Enzo queda con es_titular = 0.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_enzo');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @es_titular = 0;
GO

SELECT * FROM Torneo.Detalle_alineacion_jugador;
GO

-- Se registra el cambio: sale De Paul, entra Enzo (minuto 60).
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @cSale INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
DECLARE @cEntra INT = (SELECT id FROM #ref WHERE clave = 'conv_enzo');
EXEC Torneo.Registrar_Sustitucion_Partido @id_alineacion_partido = @idAli, @id_convocatoria_sale = @cSale,
    @id_convocatoria_entra = @cEntra, @motivo_sustitucion = 'Tactico', @minuto = 60, @numero_ventanas = 1,
    @es_tiempo_suplementario = 0;
GO

-- Test 04: El suplente que ingresó por el cambio no puede pasar a titular.
-- Resultado esperado: error 'El jugador ingresó desde el banco por una sustitución...'.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_enzo');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @es_titular = 1;
GO

-- Test 05: El titular que salió por el cambio no puede pasar a suplente.
-- Resultado esperado: error 'El jugador salió reemplazado en una sustitución; debe figurar como titular'.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @es_titular = 0;
GO

-- Test 06: Jugador que no está en la planilla y posición inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @idAli INT = (SELECT id FROM #ref WHERE clave = 'alineacion_arg');
DECLARE @idConv INT = (SELECT id FROM #ref WHERE clave = 'conv_nunez');
EXEC Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido = @idAli,
    @id_convocatoria = @idConv,
    @id_posicion_partido = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Sustitucion

-- Test 01: Caso de éxito (minuto y motivo).
-- Resultado esperado: el cambio De Paul - Enzo queda en el minuto 65 con motivo 'Táctico'.
DECLARE @id INT = (SELECT MAX(id_sustitucion) FROM Torneo.Sustitucion
                   WHERE id_convocatoria_sale = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
EXEC Torneo.Modificacion_Sustitucion
    @id_sustitucion = @id,
    @minuto = 65,
    @motivo_sustitucion = 'Táctico';
GO

SELECT * FROM Torneo.Sustitucion;
GO

-- Test 02: Tiempo suplementario en el minuto 65.
-- Resultado esperado: error 'Un cambio en tiempo suplementario debe realizarse después del minuto 90'.
DECLARE @id INT = (SELECT MAX(id_sustitucion) FROM Torneo.Sustitucion
                   WHERE id_convocatoria_sale = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
EXEC Torneo.Modificacion_Sustitucion
    @id_sustitucion = @id,
    @es_tiempo_suplementario = 1;
GO

-- Test 03: Minuto cero y ventana 4 en tiempo reglamentario.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @id INT = (SELECT MAX(id_sustitucion) FROM Torneo.Sustitucion
                   WHERE id_convocatoria_sale = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
EXEC Torneo.Modificacion_Sustitucion
    @id_sustitucion = @id,
    @minuto = 0,
    @numero_ventanas = 4;
GO

-- Test 04: Caso de éxito (cambio en el alargue con la ventana adicional).
-- Resultado esperado: el cambio queda en el minuto 105, ventana 4, tiempo suplementario.
DECLARE @id INT = (SELECT MAX(id_sustitucion) FROM Torneo.Sustitucion
                   WHERE id_convocatoria_sale = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
EXEC Torneo.Modificacion_Sustitucion
    @id_sustitucion = @id,
    @minuto = 105,
    @numero_ventanas = 4,
    @es_tiempo_suplementario = 1;
GO

SELECT * FROM Torneo.Sustitucion;
GO

-- Test 05: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Sustitucion
    @id_sustitucion = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Gol

-- Se registra un gol de Messi sin asistencia (minuto 10).
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @cMessi INT = (SELECT id FROM #ref WHERE clave = 'conv_messi');
DECLARE @idTipo INT = (SELECT id FROM #ref WHERE clave = 'tipo_gol_jugada');
DECLARE @idPer INT = (SELECT id FROM #ref WHERE clave = 'periodo_1t');
EXEC Torneo.Registrar_Gol_Partido @id_convocatoria_autor = @cMessi, @id_convocatoria_asistencia = NULL,
    @id_tipo_gol = @idTipo, @id_periodo_partido = @idPer, @id_partido = @idPartido, @minuto = 10;
GO

-- Test 01: Caso de éxito (se agrega la asistencia de De Paul y se corrige el minuto).
-- Resultado esperado: el gol queda con asistencia de De Paul en el minuto 12.
DECLARE @id INT = (SELECT MAX(id_gol) FROM Torneo.Gol WHERE id_convocatoria_autor = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @cDePaul INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Torneo.Modificacion_Gol
    @id_gol = @id,
    @id_convocatoria_asistencia = @cDePaul,
    @minuto = 12;
GO

SELECT * FROM Torneo.Gol;
GO

-- Test 02: Caso de éxito (se quita la asistencia).
-- Resultado esperado: el gol queda con id_convocatoria_asistencia en NULL.
DECLARE @id INT = (SELECT MAX(id_gol) FROM Torneo.Gol WHERE id_convocatoria_autor = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
EXEC Torneo.Modificacion_Gol
    @id_gol = @id,
    @quitar_asistencia = 1;
GO

SELECT * FROM Torneo.Gol;
GO

-- Test 03: Asistencia de un jugador de otra selección (Núñez, Uruguay).
-- Resultado esperado: error 'El asistente debe pertenecer a la misma selección que el autor'.
DECLARE @id INT = (SELECT MAX(id_gol) FROM Torneo.Gol WHERE id_convocatoria_autor = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @cNunez INT = (SELECT id FROM #ref WHERE clave = 'conv_nunez');
EXEC Torneo.Modificacion_Gol
    @id_gol = @id,
    @id_convocatoria_asistencia = @cNunez;
GO

-- Test 04: Asistencia del propio autor, tipo inexistente y minuto cero.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @id INT = (SELECT MAX(id_gol) FROM Torneo.Gol WHERE id_convocatoria_autor = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @cMessi INT = (SELECT id FROM #ref WHERE clave = 'conv_messi');
EXEC Torneo.Modificacion_Gol
    @id_gol = @id,
    @id_convocatoria_asistencia = @cMessi,
    @id_tipo_gol = 9999,
    @minuto = 0;
GO

-- Test 05: Indicar una asistencia y pedir quitarla al mismo tiempo.
-- Resultado esperado: error 'No se puede indicar una asistencia y pedir quitarla al mismo tiempo'.
DECLARE @id INT = (SELECT MAX(id_gol) FROM Torneo.Gol WHERE id_convocatoria_autor = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @cDePaul INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
EXEC Torneo.Modificacion_Gol
    @id_gol = @id,
    @id_convocatoria_asistencia = @cDePaul,
    @quitar_asistencia = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Tarjeta

-- Se registra una amarilla a De Paul (minuto 30).
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @cDePaul INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
DECLARE @idTipo INT = (SELECT id FROM #ref WHERE clave = 'tarjeta_amarilla');
DECLARE @idMot INT = (SELECT id FROM #ref WHERE clave = 'motivo_mano');
DECLARE @idPer INT = (SELECT id FROM #ref WHERE clave = 'periodo_1t');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @idPartido, @id_convocatoria = @cDePaul, @id_tipo_tarjeta = @idTipo,
    @id_motivo_tarjeta = @idMot, @id_periodo_partido = @idPer, @minuto = 30;
GO

-- Test 01: Caso de éxito (la amarilla se corrige a roja por juego brusco grave, minuto 31).
-- Resultado esperado: la tarjeta queda como 'Roja', motivo 'Juego brusco grave', minuto 31.
DECLARE @id INT = (SELECT MAX(id_tarjeta) FROM Torneo.Tarjeta WHERE id_convocatoria = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
DECLARE @idRoja INT = (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja');
DECLARE @idMot INT = (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego brusco grave');
EXEC Torneo.Modificacion_Tarjeta
    @id_tarjeta = @id,
    @id_tipo_tarjeta = @idRoja,
    @id_motivo_tarjeta = @idMot,
    @minuto = 31;
GO

SELECT * FROM Torneo.Tarjeta;
GO

-- Test 02: Tipo, motivo y periodo inexistentes y minuto fuera de rango.
-- Resultado esperado: error con los cuatro mensajes acumulados.
DECLARE @id INT = (SELECT MAX(id_tarjeta) FROM Torneo.Tarjeta WHERE id_convocatoria = (SELECT id FROM #ref WHERE clave = 'conv_depaul'));
EXEC Torneo.Modificacion_Tarjeta
    @id_tarjeta = @id,
    @id_tipo_tarjeta = 9999,
    @id_motivo_tarjeta = 9999,
    @id_periodo_partido = 9999,
    @minuto = 200;
GO

-- Test 03: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Tarjeta
    @id_tarjeta = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Suspension_jugador

-- Test 01: Caso de éxito (la suspensión de Messi se cumple en Argentina - Uruguay).
-- Resultado esperado: la suspensión queda con partido de sanción Argentina - Uruguay y cumplida = 1.
DECLARE @id INT = (SELECT MIN(id_suspension) FROM Torneo.Suspension_jugador
                   WHERE id_convocatoria = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_uru');
EXEC Torneo.Modificacion_Suspension_jugador
    @id_suspension = @id,
    @id_partido_sancion = @idPartido,
    @sancion_cumplida = 1;
GO

SELECT * FROM Torneo.Suspension_jugador;
GO

-- Test 02: Partido de sanción igual al de origen.
-- Resultado esperado: error 'El partido de sanción debe jugarse después del partido de origen'.
DECLARE @id INT = (SELECT MIN(id_suspension) FROM Torneo.Suspension_jugador
                   WHERE id_convocatoria = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Torneo.Modificacion_Suspension_jugador
    @id_suspension = @id,
    @id_partido_sancion = @idPartido;
GO

-- Test 03: Partido de sanción que no disputa la selección del jugador (Brasil - Uruguay).
-- Resultado esperado: error 'La selección del jugador no disputa el partido de sanción indicado'.
DECLARE @id INT = (SELECT MIN(id_suspension) FROM Torneo.Suspension_jugador
                   WHERE id_convocatoria = (SELECT id FROM #ref WHERE clave = 'conv_messi'));
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_bra_uru');
EXEC Torneo.Modificacion_Suspension_jugador
    @id_suspension = @id,
    @id_partido_sancion = @idPartido;
GO

-- Test 04: Marcar como cumplida una sanción sin partido asignado y con cero fechas.
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @cDePaul INT = (SELECT id FROM #ref WHERE clave = 'conv_depaul');
DECLARE @idOrigen INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Torneo.Alta_Suspension_jugador @id_convocatoria = @cDePaul, @id_partido_origen = @idOrigen,
    @id_partido_sancion = NULL, @cantidad_fechas = 1, @sancion_cumplida = 0;

DECLARE @id INT = (SELECT MAX(id_suspension) FROM Torneo.Suspension_jugador WHERE id_convocatoria = @cDePaul);
EXEC Torneo.Modificacion_Suspension_jugador
    @id_suspension = @id,
    @cantidad_fechas = 0,
    @sancion_cumplida = 1;
GO

-- Test 05: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Suspension_jugador
    @id_suspension = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Designacion_arbitral

-- Se designa a Tejera como asistente en Argentina - Brasil.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idTejera INT = (SELECT id FROM #ref WHERE clave = 'arb_tejera');
DECLARE @idRol INT = (SELECT id_rol_arbitro FROM Participantes.Rol_arbitro WHERE descripcion = 'Árbitro Asistente');
EXEC Torneo.Asignar_Arbitro_Partido @id_partido = @idPartido, @id_rol_arbitro = @idRol, @id_arbitro = @idTejera;
GO

-- Test 01: Caso de éxito (Tejera se reemplaza por Matonte, mismo rol).
-- Resultado esperado: la designación de Tejera pasa a Matonte.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idTejera INT = (SELECT id FROM #ref WHERE clave = 'arb_tejera');
DECLARE @idMatonte INT = (SELECT id FROM #ref WHERE clave = 'arb_matonte');
EXEC Torneo.Modificacion_Designacion_arbitral
    @id_partido = @idPartido,
    @id_arbitro = @idTejera,
    @id_arbitro_nuevo = @idMatonte;
GO

SELECT * FROM Torneo.Designacion_arbitral;
GO

-- Test 02: Reemplazo por un árbitro argentino (Pitana) de un árbitro que ya tiene informe (Ostojich).
-- Resultado esperado: error de neutralidad y 'No se puede reemplazar a un árbitro que ya tiene informe post-partido'.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idOstojich INT = (SELECT id FROM #ref WHERE clave = 'arb_ostojich');
DECLARE @idPitana INT = (SELECT id FROM #ref WHERE clave = 'arb_pitana');
EXEC Torneo.Modificacion_Designacion_arbitral
    @id_partido = @idPartido,
    @id_arbitro = @idOstojich,
    @id_arbitro_nuevo = @idPitana;
GO

-- Test 03: El árbitro nuevo ya está designado en el partido (Tejera vuelve a designarse como asistente).
-- Resultado esperado: error 'El árbitro nuevo ya está designado en este partido'.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idMatonte INT = (SELECT id FROM #ref WHERE clave = 'arb_matonte');
DECLARE @idTejera INT = (SELECT id FROM #ref WHERE clave = 'arb_tejera');
DECLARE @idRol INT = (SELECT id_rol_arbitro FROM Participantes.Rol_arbitro WHERE descripcion = 'Árbitro Asistente');
EXEC Torneo.Asignar_Arbitro_Partido @id_partido = @idPartido, @id_rol_arbitro = @idRol, @id_arbitro = @idTejera;

EXEC Torneo.Modificacion_Designacion_arbitral
    @id_partido = @idPartido,
    @id_arbitro = @idMatonte,
    @id_arbitro_nuevo = @idTejera;
GO

-- Test 04: Designación inexistente y rol inexistente.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Modificacion_Designacion_arbitral
    @id_partido = 9999,
    @id_arbitro = 9999,
    @id_rol_arbitro = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Modificacion_Informe_post_partido

-- Test 01: Caso de éxito (calificación y observaciones en blanco).
-- Resultado esperado: el informe de Ostojich queda con calificación 9 y observaciones en NULL.
DECLARE @id INT = (SELECT id_informe FROM Torneo.Informe_post_partido
                   WHERE id_partido = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra')
                     AND id_arbitro = (SELECT id FROM #ref WHERE clave = 'arb_ostojich'));
EXEC Torneo.Modificacion_Informe_post_partido
    @id_informe = @id,
    @calificacion_desempenio = 9,
    @observaciones = '';
GO

SELECT * FROM Torneo.Informe_post_partido;
GO

-- Test 02: Calificación fuera de rango.
-- Resultado esperado: error 'La calificación de desempeño debe estar entre 1 y 10'.
DECLARE @id INT = (SELECT id_informe FROM Torneo.Informe_post_partido
                   WHERE id_partido = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra')
                     AND id_arbitro = (SELECT id FROM #ref WHERE clave = 'arb_ostojich'));
EXEC Torneo.Modificacion_Informe_post_partido
    @id_informe = @id,
    @calificacion_desempenio = 11;
GO

-- Test 03: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Torneo.Modificacion_Informe_post_partido
    @id_informe = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Modificacion_Exhibicion_publicidad_partido

-- Test 01: Caso de éxito (tarifa y horario dentro de la franja prime time 20:00 - 23:59).
-- Resultado esperado: el espacio 1 de Argentina - Brasil queda con tarifa 175000 a las 22:00.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Publicidad.Modificacion_Exhibicion_publicidad_partido
    @id_partido = @idPartido,
    @numero_espacio = 1,
    @tarifa_aplicada_usd = 175000.00,
    @fecha_hora_exhibicion = '20260615 22:00:00';
GO

SELECT * FROM Publicidad.Exhibicion_publicidad_partido;
GO

-- Test 02: Horario fuera de la franja y tarifa menor a la base (150000).
-- Resultado esperado: error con ambos mensajes acumulados.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
EXEC Publicidad.Modificacion_Exhibicion_publicidad_partido
    @id_partido = @idPartido,
    @numero_espacio = 1,
    @tarifa_aplicada_usd = 100.00,
    @fecha_hora_exhibicion = '20260615 15:00:00';
GO

-- Test 03: Pieza de una campaña no vigente en la fecha del partido y franja inexistente.
-- Resultado esperado: error 'La campaña de la pieza no está vigente...' y 'La franja horaria indicada no existe'.
DECLARE @idPartido INT = (SELECT id FROM #ref WHERE clave = 'partido_arg_bra');
DECLARE @idPieza INT = (SELECT id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Banner Enero');
EXEC Publicidad.Modificacion_Exhibicion_publicidad_partido
    @id_partido = @idPartido,
    @numero_espacio = 1,
    @id_pieza = @idPieza,
    @id_franja = 9999;
GO

-- Test 04: Registro inexistente sin datos.
-- Resultado esperado: error 'no existe' y 'No se indicó ningún dato para modificar'.
EXEC Publicidad.Modificacion_Exhibicion_publicidad_partido
    @id_partido = 9999,
    @numero_espacio = 4;
GO
