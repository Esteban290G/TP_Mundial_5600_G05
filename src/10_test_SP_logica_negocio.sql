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
-- PREPARACIÓN: jugadores y árbitro que usan los tests de este script.
-- Se cargan al inicio porque el reemplazo de convocatoria, la planilla y las sustituciones ya los necesitan.
-- Los ids se buscan por clave natural: si un alta anterior falló, los identity pueden tener huecos.

DECLARE @idArg INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
DECLARE @idBra INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'BRA');
DECLARE @idUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idPos INT = (SELECT MIN(id_posicion) FROM Participantes.Posicion);
DECLARE @idClub INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'River Plate');
DECLARE @idCat INT = (SELECT MIN(id_categoria) FROM Participantes.Categoria_arbitro);

EXEC Participantes.Alta_Jugador @nombre = 'Julián', @apellido = 'Álvarez', @fecha_nacimiento = '20000131', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Neymar', @apellido = 'Jr', @fecha_nacimiento = '19920205', @id_pais_nacimiento = @idBra, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Federico', @apellido = 'Valverde', @fecha_nacimiento = '19980722', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;

-- Árbitro uruguayo, neutral para Argentina - Brasil
EXEC Participantes.Alta_Arbitro @id_pais = @idUru, @id_categoria = @idCat, @nombre = 'Leodán', @apellido = 'González', @fecha_nacimiento = '19820707';
GO

DECLARE @selArg INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección Argentina');
DECLARE @selBra INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil');
DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @jJulian INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Julián' AND apellido = 'Álvarez');
DECLARE @jNeymar INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Neymar');
DECLARE @jValverde INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Valverde');

EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jJulian, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 9;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selBra, @id_jugador = @jNeymar, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 10;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @jValverde, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 15;
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

-- Test 01: Caso de éxito (Leodán González, uruguayo; Ostojich ya quedó designado en el script 07).
DECLARE @idPartidoArgBra INT = (SELECT TOP 1 id_partido FROM Torneo.Partido);
DECLARE @idArbGonzalez INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE nombre = 'Leodán' AND apellido = 'González');
DECLARE @idRol INT = (SELECT MIN(id_rol_arbitro) FROM Participantes.Rol_arbitro);

EXEC Torneo.Asignar_Arbitro_Partido
    @id_partido = @idPartidoArgBra,
    @id_rol_arbitro = @idRol, 
    @id_arbitro = @idArbGonzalez;
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

-- (Julián, Neymar y Valverde se cargan en la PREPARACIÓN, al inicio del script)

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

------------------------------------------
------------------------------------------
-- PREPARACIÓN: datos para asignación de publicidad (se cargan con los SP de alta y modificación)
-- PBI per cápita aproximado en USD (Banco Mundial, indicador NY.GDP.PCAP.CD); en la Entrega 6
-- estos valores se actualizan consumiendo la API. Los husos son fijos durante el torneo (junio-julio).

IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = 'EUR') EXEC Participantes.Alta_Moneda @codigo_moneda = 'EUR', @nombre_moneda = 'Euro';
IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = 'GBP') EXEC Participantes.Alta_Moneda @codigo_moneda = 'GBP', @nombre_moneda = 'Libra esterlina';
IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = 'JPY') EXEC Participantes.Alta_Moneda @codigo_moneda = 'JPY', @nombre_moneda = 'Yen japonés';
IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = 'NGN') EXEC Participantes.Alta_Moneda @codigo_moneda = 'NGN', @nombre_moneda = 'Naira nigeriana';
GO

EXEC Participantes.Alta_Pais @codigo_moneda = 'EUR', @nombre = 'España', @codigo_iso = 'ESP', @pbi_per_capita = 33500, @huso_horario = 'UTC+2';
EXEC Participantes.Alta_Pais @codigo_moneda = 'EUR', @nombre = 'Alemania', @codigo_iso = 'DEU', @pbi_per_capita = 54300, @huso_horario = 'UTC+2';
EXEC Participantes.Alta_Pais @codigo_moneda = 'GBP', @nombre = 'Reino Unido', @codigo_iso = 'GBR', @pbi_per_capita = 49500, @huso_horario = 'UTC+1';
EXEC Participantes.Alta_Pais @codigo_moneda = 'EUR', @nombre = 'Portugal', @codigo_iso = 'PRT', @pbi_per_capita = 27300, @huso_horario = 'UTC+1';
EXEC Participantes.Alta_Pais @codigo_moneda = 'JPY', @nombre = 'Japón', @codigo_iso = 'JPN', @pbi_per_capita = 33800, @huso_horario = 'UTC+9';
EXEC Participantes.Alta_Pais @codigo_moneda = 'NGN', @nombre = 'Nigeria', @codigo_iso = 'NGA', @pbi_per_capita = 1600, @huso_horario = 'UTC+1';
GO

-- Husos de los países sudamericanos (por si no se ejecutó el script 09)
DECLARE @idArg INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
DECLARE @idBra INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'BRA');
DECLARE @idUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
EXEC Participantes.Modificacion_Pais @id_pais = @idArg, @huso_horario = 'UTC-3';
EXEC Participantes.Modificacion_Pais @id_pais = @idBra, @huso_horario = 'UTC-3';
EXEC Participantes.Modificacion_Pais @id_pais = @idUru, @huso_horario = 'UTC-3';
GO

-- Anunciantes de 7 países (más Coca-Cola, ya cargado)
DECLARE @p INT;
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'YPF', @id_pais_origen = @p, @identificacion_fiscal = 'AR-30-54668997-9';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'DEU');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Adidas', @id_pais_origen = @p, @identificacion_fiscal = 'DE-132496211';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ESP');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Banco Santander', @id_pais_origen = @p, @identificacion_fiscal = 'ES-A39000013';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'GBR');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Unilever', @id_pais_origen = @p, @identificacion_fiscal = 'GB-257151041';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'PRT');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Galp', @id_pais_origen = @p, @identificacion_fiscal = 'PT-504499777';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'JPN');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Toyota', @id_pais_origen = @p, @identificacion_fiscal = 'JP-1180301018771';
SET @p = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'NGA');
EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Dangote', @id_pais_origen = @p, @identificacion_fiscal = 'NG-RC-71242';
GO

-- Campañas vigentes durante el torneo: una pieza y un mercado de interés por anunciante
-- Inglés por si no se ejecutó el script 09
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Inglés')
    EXEC Participantes.Alta_Idioma @nombre = 'Inglés';
GO
DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'YPF');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'YPF Pasión Celeste',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 400000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'YPF Pasión Celeste');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Español');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Spot YPF Uruguay',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/ury_ypf.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Adidas');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Adidas Mundial Europa',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 900000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Adidas Mundial Europa');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'DEU');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Español');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Adidas Alemania',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/deu_adidas.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Banco Santander');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Santander Fútbol',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 600000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Santander Fútbol');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ESP');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Español');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Santander España',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/esp_banco.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Unilever');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Unilever Matchday',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 700000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Unilever Matchday');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'GBR');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Unilever Reino Unido',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/gbr_unilever.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Galp');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Galp Seleção',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 300000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Galp Seleção');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'PRT');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Español');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Galp Portugal',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/prt_galp.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Toyota');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Toyota World Cup',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 800000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Toyota World Cup');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'JPN');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Toyota Japón',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/jpn_toyota.mp4';
GO

DECLARE @idAnun INT = (SELECT id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Dangote');
EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnun, @nombre_campania = 'Dangote Africa Goals',
    @fecha_inicio = '20260601', @fecha_fin = '20260719', @presupuesto = 200000;

DECLARE @idCamp INT = (SELECT id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Dangote Africa Goals');
DECLARE @idPais INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'NGA');
DECLARE @idIdioma INT = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = 'Inglés');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @idCamp, @id_pais = @idPais;
EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCamp, @id_idioma = @idIdioma, @nombre_pieza = 'Panel Dangote Nigeria',
    @duracion_segundos = 30, @url_contenido_media = 'https://videofifa.com/campanias/nga_dangote.mp4';
GO

-- Franja tarifaria de la tarde (los partidos de prueba son a las 17:00 hora local)
EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Tarde', @hora_inicio_local = '12:00:00',
    @hora_fin_local = '19:59:59', @tarifa_base_usd = 90000.00;
GO

-- Partido de prueba sin franja ni campañas vigentes: Uruguay - Brasil, 20/08/2026 a la 01:00 hora local
DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @selBra INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil');
DECLARE @idSede INT = (SELECT id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Monumental');
DECLARE @idFase INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos');
DECLARE @idLog INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);
EXEC Torneo.Alta_Partido @id_sede = @idSede, @id_fase = @idFase, @id_seleccion_local = @selUru, @id_seleccion_visitante = @selBra,
    @id_importacion_origen = @idLog, @fecha_hora_local = '20260820 01:00:00', @asistencia_publico = NULL,
    @goles_local = NULL, @goles_visitante = NULL, @UTC = '20260820 04:00:00';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Simular_Prime_Time_Partido

-- Test 01: Simulación para Argentina - Uruguay (18/06/2026 17:00 local = 20:00 UTC).
-- Resultado esperado: prime time (19 a 23 h) en Alemania y España (22:00), Reino Unido, Portugal y Nigeria (21:00);
--                     fuera de prime time Argentina, Brasil y Uruguay (17:00) y Japón (05:00 del día siguiente).
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = @idPartido;
GO

-- Test 02: Simulación con otro rango de prime time (20 a 22 h).
-- Resultado esperado: quedan en prime time solo Reino Unido, Portugal y Nigeria (21:00).
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = @idPartido, @hora_inicio_prime = '20:00', @hora_fin_prime = '22:00';
GO

-- Test 03: Partido inexistente y rango de prime time inválido.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = 9999, @hora_inicio_prime = '20:00', @hora_fin_prime = '20:00';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Asignar_Publicidad_Partido

-- Test 01: Caso de éxito en Argentina - Uruguay. Hay 8 piezas candidatas y 5 mercados en prime time
--          (más de cuatro), por lo que se aplica el criterio de prioridad para elegir solo cuatro.
-- Resultado esperado (franja 'Tarde', tarifa 90000):
--   Espacio 1: YPF (Uruguay juega el partido, PBI 17000)
--   Espacio 2: Coca-Cola (Argentina juega el partido, PBI menor al de Uruguay)
--   Espacio 3: Adidas (Alemania en prime time, PBI 54300)
--   Espacio 4: Unilever (Reino Unido en prime time, PBI 49500)
--   Quedan afuera: Santander, Galp y Dangote (prime time pero menor PBI) y Toyota (Japón fuera de prime time).
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @idPartido;

SELECT E.*, PZ.nombre_pieza
FROM Publicidad.Exhibicion_publicidad_partido E
INNER JOIN Publicidad.Pieza_publicitaria PZ ON E.id_pieza = PZ.id_pieza
WHERE E.id_partido = @idPartido
ORDER BY E.numero_espacio;
GO

-- Test 02: Volver a asignar el mismo partido.
-- Resultado esperado: error 'El partido ya tiene publicidad asignada...'.
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @idPartido;
GO

-- Test 03: Argentina - Brasil (ya tiene una exhibición cargada) con rango de prime time inválido.
-- Resultado esperado: error 'ya tiene publicidad asignada' y 'El rango de prime time debe tener...'.
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Brasil'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @idPartido, @hora_inicio_prime = NULL;
GO

-- Test 04: Partido a la 01:00 (sin franja tarifaria) y fuera del período de todas las campañas.
-- Resultado esperado: error 'No hay una franja tarifaria que cubra el horario local del partido (01:00)'
--                     y 'Solo hay 0 pieza(s) candidata(s)...'.
DECLARE @idPartido INT = (SELECT P.id_partido FROM Torneo.Partido P
                          INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                          INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                          WHERE L.nombre_seleccion = 'Selección de Uruguay' AND V.nombre_seleccion = 'Selección de Brasil'
                            AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'));
EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @idPartido;
GO

-- Test 05: Partido inexistente.
-- Resultado esperado: error 'El partido indicado no existe'.
EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = 9999;
GO

------------------------------------------
------------------------------------------
-- PRUEBAS: Torneo.Importar_Fixture
-- La carga del staging simula lo que hará el proceso de lectura del archivo / scraping (Entrega 6):
-- se insertan los datos tal cual vienen, como texto.

IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Octavos de final')
    EXEC Torneo.Alta_Fase @nombre_fase = 'Octavos de final';
GO

-- Primera importación: 11 filas, con filas válidas, inválidas y una repetida.
INSERT INTO Torneo.Staging_fixture (fase, estadio, seleccion_local, seleccion_visitante, fecha_hora_local, fecha_hora_utc, goles_local, goles_visitante, asistencia)
VALUES
    -- 1. Partido nuevo por nombre de país, sin hora UTC (se calcula)    -> Duplicado (se repite en la fila 6)
    ('Octavos de final', 'Monumental', 'Argentina', 'Brasil', '2026-07-04 16:00:00', NULL, '3', '1', '83000'),
    -- 2. Partido existente (Argentina - Uruguay): se carga el resultado -> Actualizado
    ('Fase de Grupos', 'Monumental', 'Selección Argentina', 'Selección de Uruguay', '2026-06-18 17:00:00', '2026-06-18 20:00:00', '1', '0', '80500'),
    -- 3. Estadio y selección inexistentes, fecha y goles inválidos      -> Error (5 problemas)
    ('Fase de Grupos', 'Estadio Inventado', 'Atlántida', 'Uruguay', 'fecha mala', NULL, '-1', 'x', NULL),
    -- 4. Local y visitante son la misma selección (por nombre y por ISO) -> Error
    ('Octavos de final', 'Monumental', 'Uruguay', 'URY', '2026-07-05 16:00:00', NULL, NULL, NULL, NULL),
    -- 5. Asistencia mayor a la capacidad del estadio                     -> Error
    ('Octavos de final', 'Monumental', 'Brasil', 'Uruguay', '2026-07-06 16:00:00', NULL, '0', '0', '999999'),
    -- 6. Repetición de la fila 1 con el resultado corregido              -> Insertado (3 a 2)
    ('Octavos de final', 'Monumental', 'Argentina', 'Brasil', '2026-07-04 16:00:00', NULL, '3', '2', '83000'),
    -- 7. Falta la fase                                                   -> Error
    ('', 'Monumental', 'Brasil', 'Argentina', '2026-07-07 16:00:00', NULL, NULL, NULL, NULL),
    -- 8. Mismo horario y sede que Argentina - Brasil (15/06 17:00)       -> Error
    ('Octavos de final', 'Monumental', 'Uruguay', 'Brasil', '2026-06-15 17:00:00', '2026-06-15 20:00:00', NULL, NULL, NULL),
    -- 9. Hora UTC incoherente con el huso de la sede (UTC-3)             -> Error
    ('Octavos de final', 'Monumental', 'Brasil', 'Argentina', '2026-07-10 16:00:00', '2026-07-10 22:00:00', NULL, NULL, NULL),
    -- 10. Resultado de un partido que todavía no se jugó                 -> Error
    ('Octavos de final', 'Monumental', 'Argentina', 'Uruguay', '2027-01-10 16:00:00', NULL, '2', '0', NULL),
    -- 11. Partido futuro sin resultado (fixture)                          -> Insertado
    ('Octavos de final', 'Monumental', 'Brasil', 'Uruguay', '2027-01-15 16:00:00', NULL, NULL, NULL, NULL);
GO

-- Test 01: Importación con errores parciales.
-- Resultado esperado: 11 filas leídas, 2 insertadas (filas 6 y 11), 1 actualizada (fila 2), 7 con error
--                     (3, 4, 5, 7, 8, 9 y 10) y 1 duplicada (fila 1). El log queda 'Completado con errores'.
DECLARE @partidos_antes INT = (SELECT COUNT(*) FROM Torneo.Partido);

EXEC Torneo.Importar_Fixture @nombre_archivo = 'fixture_mundial_2026_wikipedia.csv';

SELECT @partidos_antes AS partidos_antes, (SELECT COUNT(*) FROM Torneo.Partido) AS partidos_despues;
SELECT * FROM Torneo.Log_importacion ORDER BY id_log DESC;
SELECT * FROM Torneo.Partido ORDER BY id_partido;
GO

-- Segunda importación del mismo archivo (solo las filas válidas, con la asistencia corregida).
INSERT INTO Torneo.Staging_fixture (fase, estadio, seleccion_local, seleccion_visitante, fecha_hora_local, fecha_hora_utc, goles_local, goles_visitante, asistencia)
VALUES
    ('Octavos de final', 'Monumental', 'Argentina', 'Brasil', '2026-07-04 16:00:00', NULL, '3', '2', '83100'),
    ('Fase de Grupos', 'Monumental', 'Selección Argentina', 'Selección de Uruguay', '2026-06-18 17:00:00', '2026-06-18 20:00:00', '1', '0', '80600'),
    ('Octavos de final', 'Monumental', 'Brasil', 'Uruguay', '2027-01-15 16:00:00', NULL, NULL, NULL, NULL);
GO

-- Test 02: Reimportación del mismo dataset (no debe generar duplicados).
-- Resultado esperado: las 3 filas quedan 'Actualizado', la cantidad de partidos no cambia
--                     y la asistencia de los dos primeros partidos se actualiza.
DECLARE @partidos_antes INT = (SELECT COUNT(*) FROM Torneo.Partido);

EXEC Torneo.Importar_Fixture @nombre_archivo = 'fixture_mundial_2026_wikipedia.csv';

SELECT @partidos_antes AS partidos_antes, (SELECT COUNT(*) FROM Torneo.Partido) AS partidos_despues;
SELECT * FROM Torneo.Staging_fixture ORDER BY id_fila;
GO

-- Test 03: Nombre de archivo vacío y staging sin filas pendientes.
-- Resultado esperado: error con ambos mensajes acumulados.
EXEC Torneo.Importar_Fixture @nombre_archivo = '   ';
GO

------------------------------------------
------------------------------------------
-- PRUEBAS: Torneo.Registrar_Tarjeta_Partido (suspensiones automáticas)
-- Partidos de Uruguay en orden: Argentina - Uruguay (18/06), Brasil - Uruguay (22/06) y Uruguay - Brasil (20/08).

-- PREPARACIÓN
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja')
    EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Roja';
GO

-- Brasil - Uruguay del 22/06 (lo crea el script 09; se crea acá si no se ejecutó)
IF NOT EXISTS (SELECT 1 FROM Torneo.Partido P
               INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
               INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
               WHERE L.nombre_seleccion = 'Selección de Brasil' AND V.nombre_seleccion = 'Selección de Uruguay'
                 AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))
BEGIN
    DECLARE @selBra INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil');
    DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
    DECLARE @idSede INT = (SELECT id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Monumental');
    DECLARE @idFase INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos');
    DECLARE @idLog INT = (SELECT MIN(id_log) FROM Torneo.Log_importacion);
    EXEC Torneo.Alta_Partido @id_sede = @idSede, @id_fase = @idFase, @id_seleccion_local = @selBra, @id_seleccion_visitante = @selUru,
        @id_importacion_origen = @idLog, @fecha_hora_local = '20260622 17:00:00', @asistencia_publico = NULL,
        @goles_local = NULL, @goles_visitante = NULL, @UTC = '20260622 20:00:00';
END
GO

-- Tres jugadores de Uruguay
DECLARE @idUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero');
DECLARE @idClub INT = (SELECT id_club FROM Participantes.Club_origen WHERE nombre = 'River Plate');
EXEC Participantes.Alta_Jugador @nombre = 'Rodrigo', @apellido = 'Bentancur', @fecha_nacimiento = '19970625', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'Manuel', @apellido = 'Ugarte', @fecha_nacimiento = '20010411', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
EXEC Participantes.Alta_Jugador @nombre = 'José María', @apellido = 'Giménez', @fecha_nacimiento = '19950120', @id_pais_nacimiento = @idUru, @id_posicion_habitual = @idPos, @id_club_origen = @idClub;
GO

DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @j1 INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Bentancur');
DECLARE @j2 INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Ugarte');
DECLARE @j3 INT = (SELECT id_jugador FROM Participantes.Jugador WHERE apellido = 'Giménez');
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @j1, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 6;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @j2, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 5;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @selUru, @id_jugador = @j3, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 2;
GO

-- Referencias para los tests de esta sección
IF OBJECT_ID('tempdb..#tar') IS NOT NULL
    DROP TABLE #tar;

CREATE TABLE #tar (clave VARCHAR(30) PRIMARY KEY, id INT NULL);

INSERT INTO #tar (clave, id) VALUES
    ('p_arg_uru', (SELECT P.id_partido FROM Torneo.Partido P
                   INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                   INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                   WHERE L.nombre_seleccion = 'Selección Argentina' AND V.nombre_seleccion = 'Selección de Uruguay'
                     AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))),
    ('p_bra_uru', (SELECT P.id_partido FROM Torneo.Partido P
                   INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                   INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                   WHERE L.nombre_seleccion = 'Selección de Brasil' AND V.nombre_seleccion = 'Selección de Uruguay'
                     AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))),
    ('p_uru_bra', (SELECT P.id_partido FROM Torneo.Partido P
                   INNER JOIN Participantes.Seleccion L ON P.id_seleccion_local = L.id_seleccion
                   INNER JOIN Participantes.Seleccion V ON P.id_seleccion_visitante = V.id_seleccion
                   WHERE L.nombre_seleccion = 'Selección de Uruguay' AND V.nombre_seleccion = 'Selección de Brasil'
                     AND P.id_fase = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos'))),
    ('c_bentancur', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Bentancur')),
    ('c_ugarte', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Ugarte')),
    ('c_gimenez', (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Giménez')),
    ('amarilla', (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla')),
    ('roja', (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja')),
    ('motivo', (SELECT MIN(id_motivo) FROM Torneo.Motivo_tarjeta)),
    ('periodo', (SELECT MIN(id_periodo_partido) FROM Torneo.Periodo_partido));

SELECT * FROM #tar;
SELECT * FROM Torneo.Parametros_suspension WHERE activo = 1;
GO

-- Test 01: Primera amarilla de Bentancur (Argentina - Uruguay).
-- Resultado esperado: se registra la tarjeta y no se genera suspensión (lleva 1 amarilla acumulada).
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_arg_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_bentancur');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'amarilla'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 35;

SELECT * FROM Torneo.Suspension_jugador WHERE id_convocatoria = @c;
GO

-- Test 02: Segunda amarilla de Bentancur en otro partido (Brasil - Uruguay): suspensión por acumulación.
-- Resultado esperado: suspensión de 1 fecha, tipo 'Acumulación de amarillas', a cumplir en Uruguay - Brasil (20/08).
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_bra_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_bentancur');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'amarilla'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 12;

SELECT * FROM Torneo.Suspension_jugador WHERE id_convocatoria = @c;
GO

-- Test 03: Bentancur suspendido no puede integrar la planilla del partido siguiente (Uruguay - Brasil).
-- Resultado esperado: error 'El jugador está suspendido para este partido y no puede integrar la planilla'.
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_uru_bra'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_bentancur');
DECLARE @selUru INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Uruguay');
DECLARE @idEsq INT = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-4-2');
DECLARE @idPos INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero');
EXEC Torneo.Alta_Alineacion_partido @id_partido = @p, @id_seleccion = @selUru, @id_esquema_tactico = @idEsq;

DECLARE @idAli INT = (SELECT id_alineacion_partido FROM Torneo.Alineacion_partido WHERE id_partido = @p AND id_seleccion = @selUru);
EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAli, @id_convocatoria = @c,
    @id_posicion_partido = @idPos, @es_titular = 1;
GO

-- Test 04: Primera amarilla de Ugarte (Argentina - Uruguay, minuto 20).
-- Resultado esperado: se registra la tarjeta sin suspensión.
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_arg_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_ugarte');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'amarilla'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 20;
GO

-- Test 05: Segunda amarilla de Ugarte en el mismo partido (minuto 70): expulsión por doble amarilla.
-- Resultado esperado: suspensión tipo 'Doble amarilla' por las fechas del parámetro activo,
--                     a cumplir en Brasil - Uruguay (22/06).
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_arg_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_ugarte');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'amarilla'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 70;

SELECT * FROM Torneo.Tarjeta WHERE id_convocatoria = @c;
SELECT * FROM Torneo.Suspension_jugador WHERE id_convocatoria = @c;
GO

-- Test 06: Otra tarjeta a Ugarte después de haber sido expulsado.
-- Resultado esperado: error 'El jugador ya fue expulsado en este partido; no puede recibir otra tarjeta'.
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_arg_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_ugarte');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'roja'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 80;
GO

-- Test 07: Roja directa a Giménez (Brasil - Uruguay).
-- Resultado esperado: suspensión tipo 'Roja directa' por las fechas del parámetro activo,
--                     a cumplir en Uruguay - Brasil (20/08).
DECLARE @p INT = (SELECT id FROM #tar WHERE clave = 'p_bra_uru'), @c INT = (SELECT id FROM #tar WHERE clave = 'c_gimenez');
DECLARE @t INT = (SELECT id FROM #tar WHERE clave = 'roja'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @c, @id_tipo_tarjeta = @t,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 55;

SELECT * FROM Torneo.Suspension_jugador WHERE id_convocatoria = @c;
GO

-- Test 08: Partido inexistente, tipo de tarjeta inexistente y minuto fuera de rango.
-- Resultado esperado: error con los tres mensajes acumulados.
DECLARE @c INT = (SELECT id FROM #tar WHERE clave = 'c_gimenez'), @m INT = (SELECT id FROM #tar WHERE clave = 'motivo'), @per INT = (SELECT id FROM #tar WHERE clave = 'periodo');
EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = 9999, @id_convocatoria = @c, @id_tipo_tarjeta = 9999,
    @id_motivo_tarjeta = @m, @id_periodo_partido = @per, @minuto = 200;
GO
