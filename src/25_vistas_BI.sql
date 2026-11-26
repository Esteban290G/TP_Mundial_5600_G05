-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 9 - Vistas para la plataforma de BI (Metabase)
------------------------------------------
-- Metabase lee los datos directamente de la base, conectado con un usuario de solo lectura. Para no darle acceso
-- a las tablas, este script arma un esquema BI con vistas que ya resuelven los joins y exponen solo lo necesario
-- para los tableros:
--   - BI.Goleadores: goles por jugador (sin goles en contra), con selección y confederación.
--   - BI.Tarjetas_Seleccion: amarillas y rojas por selección.
--   - BI.Partidos: un registro por partido, con fecha, fase, sede, resultado, goles y asistencia.
--   - BI.Exhibiciones_Publicidad: cada pieza exhibida en cada partido, con sede, anunciante y tarifa cobrada.
--   - BI.Sedes_Mapa: cada sede con latitud y longitud, partidos jugados, asistencia e ingresos por publicidad.
--
-- Seguridad: se crea el rol rol_bi con SELECT solo sobre el esquema BI, y el login usr_bi (autenticación de
-- SQL Server) que usa Metabase. Las vistas pertenecen a dbo, igual que las tablas, así que el usuario lee las
-- vistas por encadenamiento de propiedad sin tener permiso sobre las tablas.
--
-- Se ejecuta después de los scripts 00 a 24.
------------------------------------------

USE COM5600_G05;
GO

IF SCHEMA_ID('BI') IS NULL
    EXEC('CREATE SCHEMA BI AUTHORIZATION dbo');
GO

------------------------------------------
-- Vista: BI.Goleadores
-- Descripción: Goles de cada jugador en el torneo. No cuenta los goles en contra, que no suman para la tabla de
--              goleadores. Incluye los goles de penal por separado.
------------------------------------------

CREATE OR ALTER VIEW BI.Goleadores
AS
SELECT
    C.id_convocatoria,
    J.apellido + ', ' + J.nombre AS jugador,
    S.nombre_seleccion AS seleccion,
    ISNULL(CF.nombre_confederacion, 'Sin confederación') AS confederacion,
    COUNT(G.id_gol) AS goles,
    SUM(CASE WHEN TG.descripcion_tipo = 'Penal' THEN 1 ELSE 0 END) AS goles_de_penal
FROM Torneo.Gol G
INNER JOIN Torneo.Tipo_gol TG ON TG.id_tipo = G.id_tipo_gol
INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = G.id_convocatoria_autor
INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
INNER JOIN Participantes.Seleccion S ON S.id_seleccion = C.id_seleccion
LEFT JOIN Participantes.Confederacion CF ON CF.id_confederacion = S.id_confederacion
WHERE TG.descripcion_tipo <> 'En contra'
GROUP BY C.id_convocatoria, J.apellido, J.nombre, S.nombre_seleccion, CF.nombre_confederacion;
GO

------------------------------------------
-- Vista: BI.Tarjetas_Seleccion
-- Descripción: Cantidad de tarjetas amarillas y rojas recibidas por cada selección en el torneo.
------------------------------------------

CREATE OR ALTER VIEW BI.Tarjetas_Seleccion
AS
SELECT
    S.nombre_seleccion AS seleccion,
    SUM(CASE WHEN TT.descripcion_tarjeta = 'Amarilla' THEN 1 ELSE 0 END) AS amarillas,
    SUM(CASE WHEN TT.descripcion_tarjeta = 'Roja' THEN 1 ELSE 0 END) AS rojas,
    COUNT(T.id_tarjeta) AS total_tarjetas
FROM Torneo.Tarjeta T
INNER JOIN Torneo.Tipo_tarjeta TT ON TT.id_tipo_tarjeta = T.id_tipo_tarjeta
INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = T.id_convocatoria
INNER JOIN Participantes.Seleccion S ON S.id_seleccion = C.id_seleccion
GROUP BY S.nombre_seleccion;
GO

------------------------------------------
-- Vista: BI.Partidos
-- Descripción: Un registro por partido con su fecha, fase, sede, selecciones, resultado y asistencia.
--              goles_totales queda en NULL si el partido todavía no se jugó.
------------------------------------------

CREATE OR ALTER VIEW BI.Partidos
AS
SELECT
    P.id_partido,
    CAST(P.fecha_hora_local AS DATE) AS fecha,
    P.fecha_hora_local,
    P.UTC AS fecha_hora_utc,
    F.nombre_fase AS fase,
    SE.nombre_estadio AS estadio,
    CI.nombre AS ciudad,
    PA.nombre AS pais_sede,
    SL.nombre_seleccion AS seleccion_local,
    SV.nombre_seleccion AS seleccion_visitante,
    SL.nombre_seleccion + ' - ' + SV.nombre_seleccion AS partido,
    P.goles_local,
    P.goles_visitante,
    P.goles_local + P.goles_visitante AS goles_totales,
    P.asistencia_publico
FROM Torneo.Partido P
INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
INNER JOIN Participantes.Pais PA ON PA.id_pais = CI.id_pais
INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante;
GO

------------------------------------------
-- Vista: BI.Exhibiciones_Publicidad
-- Descripción: Cada pieza publicitaria exhibida en cada partido (uno de los cuatro espacios), con la sede, el
--              anunciante, la campaña, la franja y la tarifa cobrada en dólares. Es la base de los gráficos de
--              ocupación e ingresos por publicidad.
------------------------------------------

CREATE OR ALTER VIEW BI.Exhibiciones_Publicidad
AS
SELECT
    E.id_partido,
    CAST(P.fecha_hora_local AS DATE) AS fecha,
    F.nombre_fase AS fase,
    SE.nombre_estadio AS estadio,
    CI.nombre AS ciudad,
    PS.nombre AS pais_sede,
    SL.nombre_seleccion + ' - ' + SV.nombre_seleccion AS partido,
    E.numero_espacio,
    A.nombre_anunciante AS anunciante,
    PA.nombre AS pais_anunciante,
    CA.nombre_campania AS campania,
    PZ.nombre_pieza AS pieza,
    FR.descripcion_franja AS franja,
    E.tarifa_aplicada_usd
FROM Publicidad.Exhibicion_publicidad_partido E
INNER JOIN Torneo.Partido P ON P.id_partido = E.id_partido
INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
INNER JOIN Participantes.Pais PS ON PS.id_pais = CI.id_pais
INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
INNER JOIN Publicidad.Pieza_publicitaria PZ ON PZ.id_pieza = E.id_pieza
INNER JOIN Publicidad.Campania_publicitaria CA ON CA.id_campania = PZ.id_campania
INNER JOIN Publicidad.Anunciante A ON A.id_anunciante = CA.id_anunciante
INNER JOIN Participantes.Pais PA ON PA.id_pais = A.id_pais_origen
INNER JOIN Publicidad.Franja_horaria_tarifa FR ON FR.id_franja = E.id_franja;
GO

------------------------------------------
-- Vista: BI.Sedes_Mapa
-- Descripción: Cada sede con su ubicación (latitud y longitud) para el mapa, la cantidad de partidos, la
--              asistencia total y lo facturado por publicidad en sus partidos. Las sedes que todavía no se
--              geolocalizaron tienen latitud y longitud en NULL y no aparecen en el mapa.
------------------------------------------

CREATE OR ALTER VIEW BI.Sedes_Mapa
AS
SELECT
    SE.id_sede,
    SE.nombre_estadio AS estadio,
    CI.nombre AS ciudad,
    PA.nombre AS pais,
    SE.capacidad,
    SE.huso_horario,
    SE.latitud,
    SE.longitud,
    ISNULL(PT.partidos, 0) AS partidos,
    ISNULL(PT.asistencia_total, 0) AS asistencia_total,
    ISNULL(PU.ingresos_publicidad_usd, 0) AS ingresos_publicidad_usd
FROM Torneo.Sede SE
INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
INNER JOIN Participantes.Pais PA ON PA.id_pais = CI.id_pais
LEFT JOIN (
    SELECT id_sede, COUNT(*) AS partidos, SUM(asistencia_publico) AS asistencia_total
    FROM Torneo.Partido
    GROUP BY id_sede
) AS PT ON PT.id_sede = SE.id_sede
LEFT JOIN (
    SELECT P.id_sede, SUM(E.tarifa_aplicada_usd) AS ingresos_publicidad_usd
    FROM Publicidad.Exhibicion_publicidad_partido E
    INNER JOIN Torneo.Partido P ON P.id_partido = E.id_partido
    GROUP BY P.id_sede
) AS PU ON PU.id_sede = SE.id_sede;
GO

------------------------------------------
-- Rol y usuario de solo lectura para Metabase
-- Metabase se conecta con autenticación de SQL Server: el servidor tiene que estar en modo mixto
-- (autenticación de SQL Server y de Windows). Ver el documento de la Entrega 9.
------------------------------------------

IF DATABASE_PRINCIPAL_ID('rol_bi') IS NULL
    CREATE ROLE rol_bi;

GRANT SELECT ON SCHEMA::BI TO rol_bi;

IF SUSER_ID('usr_bi') IS NULL
    CREATE LOGIN usr_bi WITH PASSWORD = 'G05#BI2026', DEFAULT_DATABASE = COM5600_G05, CHECK_POLICY = ON;

IF DATABASE_PRINCIPAL_ID('usr_bi') IS NULL
    CREATE USER usr_bi FOR LOGIN usr_bi;

IF IS_ROLEMEMBER('rol_bi', 'usr_bi') = 0
    ALTER ROLE rol_bi ADD MEMBER usr_bi;

PRINT 'Vistas del esquema BI creadas. Usuario de solo lectura para Metabase: usr_bi (rol_bi).';
GO
