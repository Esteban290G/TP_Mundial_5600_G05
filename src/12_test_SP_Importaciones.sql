-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Fecha: 2026-11-05
-- Descripción: Scripts de prueba para la importación del CSV de estadios y la API Nominatim.
-- Requisitos:
--   - Ejecutar antes los scripts 00 a 11 (y los tests 07 a 10, que cargan los países de prueba).
--   - Copiar en C:\Importar\ (en la PC del servidor SQL) los archivos de la carpeta datos/ del repositorio:
--       stadiums.csv                  -> descargado sin modificar de github.com/jfjelstul/worldcup (data-csv/stadiums.csv)
--       stadiums_prueba_errores.csv   -> archivo de prueba armado por el grupo con errores a propósito
--   - Las pruebas de API necesitan conexión a Internet.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Torneo.Importar_CSV_Stadiums / Torneo.Procesar_CSV_Stadiums

-- Test 01: Importación del dataset real (240 estadios de todos los mundiales, nombres de países en inglés).
-- Resultado esperado: importación parcial. Se insertan las sedes de los países que ya existen en la base y cuyo
--                     nombre coincide (Argentina y Uruguay, con sus ciudades); el resto queda en 'Error' con el
--                     mensaje 'El país "..." no existe en la base'. Después de importar los países con la API
--                     REST Countries (script 14) se reimporta y esas filas pasan a insertarse.
--                     El log queda 'Completado con errores'.
DECLARE @sedes_antes INT = (SELECT COUNT(*) FROM Torneo.Sede);

EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';

SELECT @sedes_antes AS sedes_antes, (SELECT COUNT(*) FROM Torneo.Sede) AS sedes_despues;
SELECT estado_proceso, COUNT(*) AS filas FROM Torneo.Staging_stadiums GROUP BY estado_proceso;
GO

SELECT
    S.id_sede,
    S.nombre_estadio,
    S.capacidad,
    C.nombre AS Ciudad,
    S.latitud,
    S.longitud,
    S.huso_horario
FROM Torneo.Sede S
INNER JOIN Participantes.Ciudad C ON S.id_ciudad = C.id_ciudad;

SELECT TOP 5 * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO

-- Test 02: Reimportación del mismo archivo.
-- Resultado esperado: las filas que antes se insertaron ahora quedan 'Actualizado' y la cantidad de sedes no cambia
--                     (no se generan duplicados).
DECLARE @sedes_antes INT = (SELECT COUNT(*) FROM Torneo.Sede);

EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';

SELECT @sedes_antes AS sedes_antes, (SELECT COUNT(*) FROM Torneo.Sede) AS sedes_despues;
SELECT estado_proceso, COUNT(*) AS filas FROM Torneo.Staging_stadiums GROUP BY estado_proceso;
GO

-- Test 03: Archivo de prueba con errores a propósito (7 filas).
-- Resultado esperado:
--   Fila 1: Insertado (Estadio Ciudad de La Plata; se crea la ciudad La Plata)
--   Fila 2: Error 'Falta el nombre del estadio'
--   Fila 3: Error 'Capacidad inválida: "abc"'
--   Fila 4: Error 'El país "Atlantis" no existe en la base'
--   Fila 5: Error 'El nombre del estadio ... supera los 30 caracteres'
--   Fila 6: Duplicado (el mismo estadio aparece en la fila 7)
--   Fila 7: Insertado (Estadio Mario Alberto Kempes, capacidad 57500; se crea la ciudad Córdoba)
--   El log queda 'Completado con errores' con 7 procesados y 5 con error.
EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums_prueba_errores.csv';
GO

SELECT * FROM Torneo.Staging_stadiums ORDER BY id_fila;
SELECT TOP 1 * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO

-- Test 04: Procesar sin filas pendientes (todas las del Test 03 ya fueron procesadas).
-- Resultado esperado: error 'No hay filas pendientes de procesar en Torneo.Staging_stadiums'.
EXEC Torneo.Procesar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums_prueba_errores.csv';
GO

-- Test 05: Archivo inexistente.
-- Resultado esperado: error 'Error al leer el archivo "C:\Importar\no_existe.csv": ...' (el archivo no existe).
EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\no_existe.csv';
GO

-- Test 06: Nombre de archivo vacío.
-- Resultado esperado: error 'Debe indicarse la ruta del archivo a importar'.
EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = '  ';
GO

------------------------------------------
-- PRUEBAS: Torneo.Consultar_API

-- Test 07: Consulta exitosa a Nominatim.
-- Resultado esperado: devuelve un JSON con las coordenadas del Estadio Centenario (latitud -34.89, longitud -56.15 aprox.).
DECLARE @respuesta NVARCHAR(MAX);
EXEC Torneo.Consultar_API
    @url = 'https://nominatim.openstreetmap.org/search?q=Estadio%20Centenario%2C%20Montevideo&format=json&limit=1',
    @respuesta = @respuesta OUTPUT;

SELECT @respuesta AS respuesta,
       JSON_VALUE(@respuesta, '$[0].lat') AS latitud,
       JSON_VALUE(@respuesta, '$[0].lon') AS longitud;
GO

-- Test 08: Dominio inexistente.
-- Resultado esperado: error 'No se pudo conectar con la API (...)'.
DECLARE @respuesta NVARCHAR(MAX);
EXEC Torneo.Consultar_API
    @url = 'https://dominio-inexistente.invalid/api',
    @respuesta = @respuesta OUTPUT;
GO

-- Test 09: URL vacía.
-- Resultado esperado: error 'Debe indicarse la URL a consultar'.
DECLARE @respuesta NVARCHAR(MAX);
EXEC Torneo.Consultar_API
    @url = '',
    @respuesta = @respuesta OUTPUT;
GO

------------------------------------------
-- PRUEBAS: Torneo.Actualizar_Coordenadas_Sedes (API Nominatim)

-- Test 10: Geolocalización de las sedes pendientes (se limita a 5 para no demorar la prueba: 1 consulta por segundo).
-- Resultado esperado: hasta 5 sedes sin coordenadas quedan con latitud y longitud; las que Nominatim no encuentra
--                     se informan con 'Sin resultados en Nominatim' y siguen pendientes. Se registra una fila
--                     'API Nominatim - coordenadas de sedes' en el log.
SELECT id_sede, nombre_estadio, latitud, longitud
FROM Torneo.Sede;

EXEC Torneo.Actualizar_Coordenadas_Sedes @limite = 5;

SELECT id_sede, nombre_estadio, latitud, longitud
FROM Torneo.Sede;

SELECT TOP 1 * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO
