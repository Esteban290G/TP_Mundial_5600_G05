-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Scripts de testing para SP de lógica de negocio --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Variables para evitar errores de identity
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');
DECLARE @idConvNeymar INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Neymar');
DECLARE @idConvValverde INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Valverde');

DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);

DECLARE @idArbPitana INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Pitana');
DECLARE @idArbOstojich INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Ostojich');
GO

------------------------------------------
-- PRUEBAS: Participantes.Registrar_Reemplazo_Convocatoria

-- Test 01: Caso de éxito con observacion.
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = @idConvMessi,
    @id_convocatoria_alta = @idConvJulian,
    @motivo_cambio = 'Lesión de rodilla',
    @fecha_cambio = '2026-06-01', 
    @observaciones = 'Se adjunta parte médico oficial';
GO

SELECT * FROM Participantes.Novedad_convocatoria;
GO

-- Test 02: Caso de éxito con observacion vacía.
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = @idConvJulian,
    @id_convocatoria_alta = @idConvMessi,
    @motivo_cambio = 'Recuperación milagrosa',
    @fecha_cambio = '2026-06-02',
    @observaciones = '     ';
GO

-- Test 03: Fechas cruzadas.
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = @idConvMessi,
    @id_convocatoria_alta = @idConvJulian,
    @motivo_cambio = 'Desgarro',
    @fecha_cambio = '2026-01-01',
    @observaciones = NULL;
GO

------------------------------------------
-- PRUEBAS: Torneo.Asignar_Arbitro_Partido

-- Test 01: Caso de éxito.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idArbOstojich INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Ostojich');

EXEC Torneo.Asignar_Arbitro_Partido
    @id_partido = @idPartidoArgBra,
    @id_rol_arbitro = 2, 
    @id_arbitro = @idArbOstojich;
GO

SELECT * FROM Torneo.Designacion_arbitral;
GO

-- Test 02: el arbitro es de la misma nacionalidad que una de las selecciones.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idArbPitana INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Pitana');

EXEC Torneo.Asignar_Arbitro_Partido
    @id_partido = @idPartidoArgBra,
    @id_rol_arbitro = 1,
    @id_arbitro = @idArbPitana;
GO

------------------------------------------
-- PRUEBAS: Torneo.Confirmar_Planilla_Jugador

-- Test 01: Caso de éxito titular.
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');

EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = @idAliArg,
    @id_convocatoria = @idConvMessi,
    @id_posicion_partido = 1,
    @es_titular = 1;
GO

SELECT * FROM Torneo.Detalle_alineacion_jugador;
GO

-- Test 02: Caso de éxito suplente.
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = @idAliArg,
    @id_convocatoria = @idConvJulian,
    @id_posicion_partido = 1,
    @es_titular = 0;
GO

-- Test 03: Jugador de otra selección.
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);
DECLARE @idConvNeymar INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Neymar');

EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = @idAliArg,
    @id_convocatoria = @idConvNeymar, 
    @id_posicion_partido = 1,
    @es_titular = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Sustitucion_Partido

-- Test 01: Caso de éxito.
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Torneo.Registrar_Sustitucion_Partido
    @id_alineacion_partido = @idAliArg,
    @id_convocatoria_sale = @idConvMessi,
    @id_convocatoria_entra = @idConvJulian,
    @motivo_sustitucion = 'Cambio táctico',
    @minuto = 75,
    @numero_ventanas = 1,
    @es_tiempo_suplementario = 0;
GO

SELECT * FROM Torneo.Sustitucion;
GO

-- Test 02: El que entra es titular.
DECLARE @idAliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Torneo.Registrar_Sustitucion_Partido
    @id_alineacion_partido = @idAliArg,
    @id_convocatoria_sale = @idConvJulian,
    @id_convocatoria_entra = @idConvMessi,
    @motivo_sustitucion = 'Lesión',
    @minuto = 80,
    @numero_ventanas = 2,
    @es_tiempo_suplementario = 0;
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Gol_Partido

EXEC Participantes.Alta_Jugador @nombre = 'Julián', @apellido = 'Álvarez', @fecha_nacimiento = '20000131', @id_pais_nacimiento = 1, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 1, @id_jugador = 2, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 9;

EXEC Participantes.Alta_Jugador @nombre = 'Neymar', @apellido = 'Jr', @fecha_nacimiento = '19920205', @id_pais_nacimiento = 2, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 2, @id_jugador = 3, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 10;

EXEC Participantes.Alta_Jugador @nombre = 'Federico', @apellido = 'Valverde', @fecha_nacimiento = '19980722', @id_pais_nacimiento = 3, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 3, @id_jugador = 4, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 15;
GO

-- Test 01: Caso de éxito sin asistencia.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');

EXEC Torneo.Registrar_Gol_Partido
    @id_convocatoria_autor = @idConvMessi,
    @id_convocatoria_asistencia = NULL,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = @idPartidoArgBra,
    @minuto = 15;
GO

SELECT * FROM Torneo.Gol;
GO

-- Test 02: Caso de éxito con asistencia.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvJulian INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Julián');

EXEC Torneo.Registrar_Gol_Partido
    @id_convocatoria_autor = @idConvMessi,
    @id_convocatoria_asistencia = @idConvJulian,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = @idPartidoArgBra,
    @minuto = 30;
GO

-- Test 03: Asistencia del equipo rival.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
DECLARE @idConvNeymar INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.nombre = 'Neymar');

EXEC Torneo.Registrar_Gol_Partido
    @id_convocatoria_autor = @idConvMessi,
    @id_convocatoria_asistencia = @idConvNeymar,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = @idPartidoArgBra,
    @minuto = 45;
GO

-- Test 04: Gol de un jugador de otra seleccion.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvValverde INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Valverde');

EXEC Torneo.Registrar_Gol_Partido
    @id_convocatoria_autor = @idConvValverde,
    @id_convocatoria_asistencia = NULL,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = @idPartidoArgBra,
    @minuto = 60;
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Tarjeta_Partido

-- Test 01: Caso de éxito.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvMessi INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');

EXEC Torneo.Registrar_Tarjeta_Partido
    @id_partido = @idPartidoArgBra,
    @id_convocatoria = @idConvMessi,
    @id_tipo_tarjeta = 1,
    @id_motivo_tarjeta = 1,
    @id_periodo_partido = 1,
    @minuto = 42;
GO

SELECT * FROM Torneo.Tarjeta;
GO

-- Test 02: Jugador de una seleccion aparte.
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idConvValverde INT = (SELECT id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Valverde');

EXEC Torneo.Registrar_Tarjeta_Partido
    @id_partido = @idPartidoArgBra,
    @id_convocatoria = @idConvValverde,
    @id_tipo_tarjeta = 1,
    @id_motivo_tarjeta = 1,
    @id_periodo_partido = 1,
    @minuto = 70;
GO