-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 9 - Pruebas de las vistas para BI y del usuario usr_bi
------------------------------------------
-- Parte 1: el contenido de cada vista coincide con las tablas de origen (los totales se calculan sobre las tablas
--          y se comparan con los de la vista).
-- Parte 2: el usuario usr_bi (el que usa Metabase) puede leer las vistas del esquema BI y nada más.
--          Cada prueba se ejecuta con su identidad (EXECUTE AS USER) y se clasifica como en los scripts 19 a 22:
--          Denegado si SQL Server rechaza la operación por permisos (229, 230, 262, 297, 300, 15151, 15247).
-- Al final se muestra el cuadro de resultados: la columna "coincide" debe ser 'Sí' en todas.
-- Requiere los datos de prueba del script 14.
------------------------------------------

USE COM5600_G05;
GO

SET NOCOUNT ON;

DECLARE @r TABLE (
    nro INT IDENTITY(1,1),
    prueba VARCHAR(120),
    esperado VARCHAR(40),
    obtenido VARCHAR(40),
    detalle NVARCHAR(400)
);

------------------------------------------
-- Parte 1: contenido de las vistas
------------------------------------------

-- Prueba 01: La vista de goleadores suma todos los goles que no son en contra
DECLARE @goles_base INT = (SELECT COUNT(*) FROM Torneo.Gol G
                           INNER JOIN Torneo.Tipo_gol TG ON TG.id_tipo = G.id_tipo_gol
                           WHERE TG.descripcion_tipo <> 'En contra');
DECLARE @goles_vista INT = (SELECT ISNULL(SUM(goles), 0) FROM BI.Goleadores);
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Goleadores: total de goles', CAST(@goles_base AS VARCHAR(40)), CAST(@goles_vista AS VARCHAR(40)),
        'Suma de BI.Goleadores contra Torneo.Gol');

-- Prueba 02: La vista de tarjetas suma todas las tarjetas registradas
DECLARE @tarjetas_base INT = (SELECT COUNT(*) FROM Torneo.Tarjeta);
DECLARE @tarjetas_vista INT = (SELECT ISNULL(SUM(total_tarjetas), 0) FROM BI.Tarjetas_Seleccion);
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Tarjetas por selección: total de tarjetas', CAST(@tarjetas_base AS VARCHAR(40)), CAST(@tarjetas_vista AS VARCHAR(40)),
        'Suma de BI.Tarjetas_Seleccion contra Torneo.Tarjeta');

-- Prueba 03: Un registro por partido
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Partidos: un registro por partido',
        CAST((SELECT COUNT(*) FROM Torneo.Partido) AS VARCHAR(40)),
        CAST((SELECT COUNT(*) FROM BI.Partidos) AS VARCHAR(40)),
        'Filas de BI.Partidos contra Torneo.Partido');

-- Prueba 04: Una fila por exhibición y el mismo total facturado
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Exhibiciones: filas y total facturado',
        CONCAT((SELECT COUNT(*) FROM Publicidad.Exhibicion_publicidad_partido), ' / ',
               (SELECT ISNULL(SUM(tarifa_aplicada_usd), 0) FROM Publicidad.Exhibicion_publicidad_partido)),
        CONCAT((SELECT COUNT(*) FROM BI.Exhibiciones_Publicidad), ' / ',
               (SELECT ISNULL(SUM(tarifa_aplicada_usd), 0) FROM BI.Exhibiciones_Publicidad)),
        'Cantidad / USD de BI.Exhibiciones_Publicidad contra la tabla de exhibiciones');

-- Prueba 05: Los ingresos por sede suman lo mismo que las exhibiciones
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Sedes: ingresos por publicidad',
        CAST((SELECT ISNULL(SUM(tarifa_aplicada_usd), 0) FROM Publicidad.Exhibicion_publicidad_partido) AS VARCHAR(40)),
        CAST((SELECT SUM(ingresos_publicidad_usd) FROM BI.Sedes_Mapa) AS VARCHAR(40)),
        'Suma de BI.Sedes_Mapa contra la tabla de exhibiciones');

-- Prueba 06: Hay al menos 8 sedes con coordenadas para el mapa (las del script 14)
DECLARE @sedes_geo INT = (SELECT COUNT(*) FROM BI.Sedes_Mapa WHERE latitud IS NOT NULL AND longitud IS NOT NULL);
INSERT INTO @r (prueba, esperado, obtenido, detalle)
VALUES ('Sedes: al menos 8 con latitud y longitud', 'Sí', CASE WHEN @sedes_geo >= 8 THEN 'Sí' ELSE 'No' END,
        CONCAT(@sedes_geo, ' sedes geolocalizadas de ', (SELECT COUNT(*) FROM BI.Sedes_Mapa)));

------------------------------------------
-- Parte 2: permisos del usuario usr_bi
------------------------------------------
EXECUTE AS USER = 'usr_bi';

-- Prueba 07: Lectura de una vista del esquema BI
BEGIN TRY
    SELECT TOP (1) jugador FROM BI.Goleadores;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: leer BI.Goleadores', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: leer BI.Goleadores', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 08: Lectura de la vista del mapa de sedes
BEGIN TRY
    SELECT TOP (1) estadio, latitud, longitud FROM BI.Sedes_Mapa;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: leer BI.Sedes_Mapa', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: leer BI.Sedes_Mapa', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 09: Lectura directa de una tabla con datos personales
BEGIN TRY
    SELECT TOP (1) id_jugador FROM Participantes.Jugador;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: leer Participantes.Jugador', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: leer Participantes.Jugador', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 10: Lectura directa de una tabla del torneo
BEGIN TRY
    SELECT TOP (1) id_partido FROM Torneo.Partido;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: leer Torneo.Partido', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: leer Torneo.Partido', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 11: Ejecución de un reporte de la Entrega 7
-- usr_bi no tiene ningún permiso sobre el SP, así que SQL Server ni siquiera le muestra que existe y responde
-- con el error 2812 (procedimiento no encontrado) en lugar de 229. Para este usuario también cuenta como Denegado.
BEGIN TRY
    EXEC Torneo.Reporte_Goleadores;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: ejecutar Reporte_Goleadores', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: ejecutar Reporte_Goleadores', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 2812, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 12: Modificación directa de una tabla
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE Torneo.Sede SET capacidad = capacidad WHERE id_sede = (SELECT MIN(id_sede) FROM BI.Sedes_Mapa);
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('usr_bi: modificar Torneo.Sede', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('usr_bi: modificar Torneo.Sede', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Error' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

------------------------------------------
-- Fin: se vuelve a la identidad original y se muestra el cuadro de resultados
------------------------------------------
REVERT;

SELECT nro, prueba, esperado, obtenido,
       CASE WHEN esperado = obtenido THEN 'Sí' ELSE 'NO' END AS coincide,
       detalle
FROM @r
ORDER BY nro;

-- Vista previa de lo que va a mostrar Metabase
SELECT TOP (10) jugador, seleccion, goles, goles_de_penal FROM BI.Goleadores ORDER BY goles DESC, jugador;
SELECT seleccion, amarillas, rojas, total_tarjetas FROM BI.Tarjetas_Seleccion ORDER BY total_tarjetas DESC, seleccion;
SELECT estadio, ciudad, pais, latitud, longitud, partidos, asistencia_total, ingresos_publicidad_usd
FROM BI.Sedes_Mapa ORDER BY ingresos_publicidad_usd DESC, estadio;
GO
