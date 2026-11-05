-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Fecha: 2026-11-05
-- Descripción: Scripts de prueba para la importación de archivos.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------

EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';
GO

EXEC Torneo.Procesar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';
GO

SELECT 
    id_fila, 
    stadium_name AS Estadio, 
    city_name AS Ciudad, 
    country_name AS Pais, 
    estado_proceso, 
    mensaje_error 
FROM Torneo.Staging_stadiums;

SELECT 
    S.id_sede, 
    S.nombre_estadio, 
    S.capacidad, 
    C.nombre AS Ciudad
FROM Torneo.Sede S
INNER JOIN Participantes.Ciudad C ON S.id_ciudad = C.id_ciudad;


SELECT 
    id_log, 
    nombre_archivo_o_fuente, 
    fecha_hora_ejecucion, 
    registros_procesados, 
    registros_con_error, 
    estado 
FROM Torneo.Log_importacion 
ORDER BY id_log DESC;
GO
