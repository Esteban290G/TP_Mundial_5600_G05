-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Scripts de prueba para los SP de consultas del torneo:
--   - Torneo.Consultar_Fixture
--   - Torneo.Consultar_Historial_Titularidad
--   - Torneo.Consultar_Equipo_En_Cancha
--   - Torneo.Consultar_Historial_Arbitro
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Torneo.Consultar_Fixture
------------------------------------------

-- Test 01: Fixture completo sin filtros.
-- Resultado esperado: todos los partidos cargados ordenados cronológicamente por horario UTC.
EXEC Torneo.Consultar_Fixture;
GO

-- Test 02: Filtrado por selección (Argentina).
-- Resultado esperado: todos los partidos en los que participó Argentina, tanto de local como de visitante.
DECLARE @id_arg INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                       INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'ARG');
EXEC Torneo.Consultar_Fixture @id_seleccion = @id_arg;
GO

-- Test 03: Filtrado combinado por sede y fase (Mercedes-Benz Stadium, Fase de Grupos).
-- Resultado esperado: solo los partidos de fase de grupos disputados en esa sede.
DECLARE @id_sede INT = (SELECT TOP 1 id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Mercedes-Benz Stadium');
DECLARE @id_fase INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos');
EXEC Torneo.Consultar_Fixture @id_sede = @id_sede, @id_fase = @id_fase;
GO

-- Test 04: Filtrado por una fecha puntual (17/06/2026).
-- Resultado esperado: solo los partidos con fecha local 2026-06-17 (Portugal-RD Congo, Inglaterra-Croacia,
--                     Ghana-Panamá y Uzbekistán-Colombia, ordenados por UTC).
EXEC Torneo.Consultar_Fixture @fecha_desde = '20260617', @fecha_hasta = '20260617';
GO

-- Test 05: Validaciones acumuladas (sede, fase y selección inexistentes + fechas invertidas).
-- Resultado esperado: error 50001 con los cuatro mensajes acumulados.
EXEC Torneo.Consultar_Fixture
    @id_sede = -1,
    @id_fase = -1,
    @id_seleccion = -1,
    @fecha_desde = '20260720',
    @fecha_hasta = '20260601';
GO

------------------------------------------
-- PRUEBAS: Torneo.Consultar_Historial_Titularidad
------------------------------------------

-- Test 06: Historial de titularidad de toda una selección (Argentina).
-- Resultado esperado: primer resultado con el plantel de Argentina (titularidades, suplencias y porcentaje);
--                     segundo resultado con la participación partido por partido en orden cronológico.
DECLARE @id_arg INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                       INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'ARG');
EXEC Torneo.Consultar_Historial_Titularidad @id_seleccion = @id_arg;
GO

-- Test 07: Historial de un jugador puntual (el jugador reemplazado por lesión antes del minuto 20).
-- Resultado esperado: resumen de ese único jugador y sus partidos en planilla, mostrando minuto_salida <= 20
--                     en el partido donde salió lesionado (Argentina vs Argelia).
DECLARE @id_jug INT = (
    SELECT TOP 1 C.id_jugador
    FROM Torneo.Sustitucion SU
    INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = SU.id_convocatoria_sale
    WHERE SU.motivo_sustitucion = 'Lesión' AND SU.minuto <= 20
);
EXEC Torneo.Consultar_Historial_Titularidad @id_jugador = @id_jug;
GO

-- Test 08: Historial general de todos los convocados sin filtros.
-- Resultado esperado: resumen de titularidad de todas las selecciones cargadas y detalle completo de planillas.
EXEC Torneo.Consultar_Historial_Titularidad;
GO

-- Test 09: Validaciones acumuladas (jugador y selección inexistentes).
-- Resultado esperado: error 50001 con ambos mensajes acumulados.
EXEC Torneo.Consultar_Historial_Titularidad @id_jugador = -1, @id_seleccion = -1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Consultar_Equipo_En_Cancha
------------------------------------------

-- Test 10: Cambio por lesión antes del minuto 20 (Argentina vs Argelia: sustitución en el minuto 15).
-- Resultado esperado: en el minuto 10 figuran los 11 titulares de Argentina; en el minuto 20 siguen siendo 11,
--                     pero sale el defensor lesionado y aparece su reemplazante con origen 'Ingresó por cambio' (min 15).
DECLARE @id_arg INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                       INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'ARG');
DECLARE @id_partido_arg_alg INT = (
    SELECT TOP 1 P.id_partido
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Pais PL ON PL.id_pais = SL.id_pais
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Participantes.Pais PV ON PV.id_pais = SV.id_pais
    WHERE PL.codigo_iso = 'ARG' AND PV.codigo_iso = 'DZA'
);

EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_arg_alg, @minuto = 10, @id_seleccion = @id_arg;
EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_arg_alg, @minuto = 20, @id_seleccion = @id_arg;
GO

-- Test 11: Expulsión por doble amarilla (Uruguay vs Cabo Verde: expulsado en el minuto 71).
-- Resultado esperado: en el minuto 70 Cabo Verde tiene 11 jugadores en cancha; en el minuto 75 pasa a tener 10.
DECLARE @id_cpv INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                       INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'CPV');
DECLARE @id_partido_uru_cpv INT = (
    SELECT TOP 1 P.id_partido
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Pais PL ON PL.id_pais = SL.id_pais
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Participantes.Pais PV ON PV.id_pais = SV.id_pais
    WHERE PL.codigo_iso = 'URY' AND PV.codigo_iso = 'CPV'
);

EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_uru_cpv, @minuto = 70, @id_seleccion = @id_cpv;
EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_uru_cpv, @minuto = 75, @id_seleccion = @id_cpv;
GO

-- Test 12: Ambos equipos a la vez con roja directa (Jordania vs Argelia: roja a Jordania en el minuto 55).
-- Resultado esperado: 21 filas en total en el minuto 60 (10 jugadores de Jordania y 11 de Argelia).
DECLARE @id_partido_jor_alg INT = (
    SELECT TOP 1 P.id_partido
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Pais PL ON PL.id_pais = SL.id_pais
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Participantes.Pais PV ON PV.id_pais = SV.id_pais
    WHERE PL.codigo_iso = 'JOR' AND PV.codigo_iso = 'DZA'
);

EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_jor_alg, @minuto = 60;
GO

-- Test 13: Validaciones acumuladas (partido inexistente, minuto fuera de rango y selección inexistente).
-- Resultado esperado: error 50001 con los tres mensajes acumulados.
EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = -1, @minuto = 150, @id_seleccion = -1;
GO

-- Test 14: Selección válida que no participa del partido indicado (España en Argentina vs Argelia).
-- Resultado esperado: error 50001 '- La selección indicada no participa en ese partido.'
DECLARE @id_esp INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                       INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'ESP');
DECLARE @id_partido_arg_alg INT = (
    SELECT TOP 1 P.id_partido
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Pais PL ON PL.id_pais = SL.id_pais
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Participantes.Pais PV ON PV.id_pais = SV.id_pais
    WHERE PL.codigo_iso = 'ARG' AND PV.codigo_iso = 'DZA'
);

EXEC Torneo.Consultar_Equipo_En_Cancha @id_partido = @id_partido_arg_alg, @minuto = 45, @id_seleccion = @id_esp;
GO

------------------------------------------
-- PRUEBAS: Torneo.Consultar_Historial_Arbitro
------------------------------------------

-- Test 15: Historial completo de todos los árbitros sin filtros.
-- Resultado esperado: primer resultado con el resumen de los árbitros (idiomas, roles, informes y promedio);
--                     segundo resultado con todos los partidos arbitrados y sus informes post-partido.
EXEC Torneo.Consultar_Historial_Arbitro;
GO

-- Test 16: Historial de un árbitro puntual (Marco Bellini, Italia).
-- Resultado esperado: resumen de Marco Bellini y el detalle cronológico de todos sus partidos (como principal,
--                     asistente, cuarto árbitro o VAR) con sus calificaciones y observaciones cuando dirigió.
DECLARE @id_bellini INT = (SELECT TOP 1 id_arbitro FROM Participantes.Arbitro
                           WHERE nombre = 'Marco' AND apellido = 'Bellini');
EXEC Torneo.Consultar_Historial_Arbitro @id_arbitro = @id_bellini;
GO

-- Test 17: Solo actuaciones con informe post-partido cargado.
-- Resultado esperado: únicamente árbitros y partidos donde existe registro en Torneo.Informe_post_partido
EXEC Torneo.Consultar_Historial_Arbitro @solo_con_informe = 1;
GO

-- Test 18: Validaciones acumuladas (árbitro y país inexistentes).
-- Resultado esperado: error 50001 con ambos mensajes acumulados.
EXEC Torneo.Consultar_Historial_Arbitro @id_arbitro = -1, @id_pais = -1;
GO