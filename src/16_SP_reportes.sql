-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Stored Procedures de reportes
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Reporte 1: Goleadores por selección, fase y torneo.

CREATE OR ALTER PROCEDURE Torneo.Reporte_Goleadores
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        S.nombre_seleccion AS Seleccion,
        F.nombre_fase AS Fase,
        J.apellido + ', ' + J.nombre AS Jugador,
        COUNT(G.id_gol) AS Goles_Convertidos
    FROM Torneo.Gol G
    INNER JOIN Torneo.Partido P ON G.id_partido = P.id_partido
    INNER JOIN Torneo.Fase F ON P.id_fase = F.id_fase
    INNER JOIN Participantes.Convocatoria C ON G.id_convocatoria_autor = C.id_convocatoria
    INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador
    INNER JOIN Participantes.Seleccion S ON C.id_seleccion = S.id_seleccion
    GROUP BY 
        S.nombre_seleccion, 
        F.nombre_fase, 
        J.apellido, 
        J.nombre
    ORDER BY 
        S.nombre_seleccion ASC,
        F.nombre_fase ASC,
        Goles_Convertidos DESC;
END;
GO

------------------------------------------
-- Reporte 2: Tarjetas (amarillas y rojas) por selección y jugador, con detalle de suspensiones activas por acumulación.

CREATE OR ALTER PROCEDURE Torneo.Reporte_Tarjetas_Suspensiones
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        S.nombre_seleccion AS Seleccion,
        J.apellido + ', ' + J.nombre AS Jugador,
        SUM(CASE WHEN TT.descripcion_tarjeta = 'Amarilla' THEN 1 ELSE 0 END) AS Tarjetas_Amarillas,
        SUM(CASE WHEN TT.descripcion_tarjeta = 'Roja' THEN 1 ELSE 0 END) AS Tarjetas_Rojas,
        ISNULL(Susp.Fechas_Pendientes, 0) AS Fechas_Suspension_Pendientes,
        ISNULL(Susp.Detalle, 'Sin suspensiones activas') AS Detalle_Suspension
    FROM Torneo.Tarjeta T
    INNER JOIN Torneo.Tipo_tarjeta TT ON T.id_tipo_tarjeta = TT.id_tipo_tarjeta
    INNER JOIN Participantes.Convocatoria C ON T.id_convocatoria = C.id_convocatoria
    INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador
    INNER JOIN Participantes.Seleccion S ON C.id_seleccion = S.id_seleccion
    -- Agrupar las suspensiones activas de cada jugador
    LEFT JOIN (
        SELECT 
            id_convocatoria, 
            SUM(cantidad_fechas) AS Fechas_Pendientes,
            STRING_AGG(tipo_suspension, ' / ') AS Detalle
        FROM Torneo.Suspension_jugador
        WHERE sancion_cumplida = 0
        GROUP BY id_convocatoria
    ) AS Susp ON C.id_convocatoria = Susp.id_convocatoria
    GROUP BY 
        S.nombre_seleccion, 
        J.apellido, 
        J.nombre,
        Susp.Fechas_Pendientes,
        Susp.Detalle
    ORDER BY 
        Seleccion ASC, 
        Tarjetas_Rojas DESC, 
        Tarjetas_Amarillas DESC, 
        Jugador ASC;
END;
GO

EXEC Torneo.Reporte_Tarjetas_Suspensiones;

------------------------------------------
-- Reporte 3:

------------------------------------------