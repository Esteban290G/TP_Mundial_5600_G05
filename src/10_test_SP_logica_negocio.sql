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
-- PRUEBAS: Participantes.Registrar_Reemplazo_Convocatoria

-- Test 01: Caso de éxito con observacion.
EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = 1,
    @id_convocatoria_alta = 2,
    @motivo_cambio = 'Lesión de rodilla',
    @fecha_cambio = '2026-06-01', 
    @observaciones = 'Se adjunta parte médico oficial';
GO

SELECT * FROM Participantes.Novedad_convocatoria;
GO

-- Test 02: Caso de éxito con observacion vacía.
EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = 2,
    @id_convocatoria_alta = 1,
    @motivo_cambio = 'Recuperación milagrosa',
    @fecha_cambio = '2026-06-02',
    @observaciones = '     ';
GO

SELECT * FROM Participantes.Novedad_convocatoria;
GO

-- Test 03: Fechas cruzadas.
EXEC Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja = 1,
    @id_convocatoria_alta = 2,
    @motivo_cambio = 'Desgarro',
    @fecha_cambio = '2026-01-01',
    @observaciones = NULL;
GO

------------------------------------------
-- PRUEBAS: Torneo.Asignar_Arbitro_Partido

-- Test 01: Caso de éxito.
EXEC Torneo.Asignar_Arbitro_Partido
    @id_partido = 1,
    @id_rol_arbitro = 2, 
    @id_arbitro = 2;
GO

SELECT * FROM Torneo.Designacion_arbitral;
GO

-- Test 02: el arbitro es de la misma nacionalidad que una de las selecciones.
EXEC Torneo.Asignar_Arbitro_Partido
    @id_partido = 1,
    @id_rol_arbitro = 1,
    @id_arbitro = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Confirmar_Planilla_Jugador

-- Test 01: Caso de éxito titular.
EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = 1,
    @id_convocatoria = 1,
    @id_posicion_partido = 1,
    @es_titular = 1;
GO

SELECT * FROM Torneo.Detalle_alineacion_jugador;
GO

-- Test 02: Caso de éxito suplente.
EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = 1,
    @id_convocatoria = 2,
    @id_posicion_partido = 1,
    @es_titular = 0;
GO

SELECT * FROM Torneo.Detalle_alineacion_jugador;
GO

-- Test 03: Jugador de otra selección.
EXEC Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido = 1,
    @id_convocatoria = 3, 
    @id_posicion_partido = 1,
    @es_titular = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Sustitucion_Partido

-- Test 01: Caso de éxito.
EXEC Torneo.Registrar_Sustitucion_Partido
    @id_alineacion_partido = 1,
    @id_convocatoria_sale = 1,
    @id_convocatoria_entra = 2,
    @motivo_sustitucion = 'Cambio táctico',
    @minuto = 75,
    @numero_ventanas = 1,
    @es_tiempo_suplementario = 0;
GO

SELECT * FROM Torneo.Sustitucion;
GO

-- Test 02: El que entra es titular.
EXEC Torneo.Registrar_Sustitucion_Partido
    @id_alineacion_partido = 1,
    @id_convocatoria_sale = 2,
    @id_convocatoria_entra = 1,
    @motivo_sustitucion = 'Lesión',
    @minuto = 80,
    @numero_ventanas = 2,
    @es_tiempo_suplementario = 0;
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Gol_Partido

-- Test 01: Caso de éxito.
EXEC Torneo.Registrar_Gol_Partido
	@descripcion_tipo = 'Penal';
GO

SELECT * FROM Torneo.Tipo_gol;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Registrar_Gol_Partido
	@descripcion_tipo = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Registrar_Tarjeta_Partido

-- Test 01: Caso de éxito (Messi 1).
EXEC Torneo.Registrar_Tarjeta_Partido
    @id_partido = 1,
    @id_convocatoria = 1,
    @id_tipo_tarjeta = 1,
    @id_motivo_tarjeta = 1,
    @id_periodo_partido = 1,
    @minuto = 42;
GO

SELECT * FROM Torneo.Tarjeta;
GO

-- Test 02: Jugador de una seleccion aparte (Valverde en Arg vs Bra).
EXEC Torneo.Registrar_Tarjeta_Partido
    @id_partido = 1,
    @id_convocatoria = 4,
    @id_tipo_tarjeta = 1,
    @id_motivo_tarjeta = 1,
    @id_periodo_partido = 1,
    @minuto = 70;
GO