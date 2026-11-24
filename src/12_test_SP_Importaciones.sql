-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Fecha: 2026-11-05
-- Descripción: Scripts de prueba para los procesos de importación:
--              datasets (CSV de estadios y XML obtenido por scraping de Wikipedia) y APIs externas
--              (Nominatim, países mledoze/countries, Banco Mundial y timeapi.io).
-- Requisitos:
--   - Ejecutar antes los scripts 00 a 11 (y los tests 07 a 10, que cargan los países de prueba).
--   - Conexión a Internet (las APIs se consultan en el momento).
--   - Copiar en C:\Importar\ (en la PC del servidor SQL) los archivos de la carpeta datos/ del repositorio:
--       stadiums.csv                     -> de datos/ (descargado sin modificar de github.com/jfjelstul/worldcup)
--       stadiums_prueba_errores.csv      -> de datos/ (archivo CSV de prueba con errores a propósito)
--       mundial_2026_prueba_errores.xml  -> de datos/ (archivo XML de prueba con errores a propósito)
--       mundial_2026_wikipedia.xml       -> generado en el momento con el scraper:
--                                           python scraping\scraper_mundial_2026.py C:\Importar\mundial_2026_wikipedia.xml
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Torneo.Importar_CSV_Stadiums / Torneo.Procesar_CSV_Stadiums

-- Test 01: Importación del dataset real (240 estadios de todos los mundiales, nombres de países en inglés).
-- Resultado esperado: importación parcial. Se insertan las sedes de los países que ya existen en la base y cuyo
--                     nombre coincide (Argentina y Uruguay, con sus ciudades); el resto queda en 'Error' con el
--                     mensaje 'El país "..." no existe en la base'. Después de importar los países con la API
--                     de países con Participantes.Importar_API_Paises (test 11) se reimporta y esas filas pasan a insertarse.
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

------------------------------------------
-- PRUEBAS: Participantes.Importar_API_Paises (JSON de países mledoze/countries por HTTP)

-- Test 11: Primera importación de países.
-- Resultado esperado: alrededor de 250 países recibidos. Los que ya existían (Argentina, Brasil, Uruguay, España, etc.)
--                     quedan 'Actualizado' (se completan nombre en inglés, código FIFA y coordenadas de referencia,
--                     sin cambiar su nombre en castellano); el resto queda 'Insertado' con su moneda. Algunos
--                     territorios sin moneda (por ejemplo la Antártida) quedan en 'Error' con 'El país no tiene moneda en la fuente'.
--                     Alemania queda con código FIFA GER, Sudáfrica con RSA e Irán con IRN.
DECLARE @paises_antes INT = (SELECT COUNT(*) FROM Participantes.Pais);

EXEC Participantes.Importar_API_Paises;

SELECT @paises_antes AS paises_antes, (SELECT COUNT(*) FROM Participantes.Pais) AS paises_despues;
SELECT id_pais, nombre, nombre_ingles, codigo_iso, codigo_fifa, codigo_moneda, latitud_capital, longitud_capital
FROM Participantes.Pais
WHERE codigo_iso IN ('ARG', 'BRA', 'URY', 'MEX', 'ZAF', 'USA', 'DEU');
GO

-- Test 12: Segunda importación (mismo dataset).
-- Resultado esperado: todos los países válidos quedan 'Actualizado' y la cantidad de países no cambia (sin duplicados).
DECLARE @paises_antes INT = (SELECT COUNT(*) FROM Participantes.Pais);

EXEC Participantes.Importar_API_Paises;

SELECT @paises_antes AS paises_antes, (SELECT COUNT(*) FROM Participantes.Pais) AS paises_despues;
GO

------------------------------------------
-- PRUEBAS: Participantes.Importar_API_PBI (API del Banco Mundial)

-- Test 13: Primera importación del PBI per cápita (últimos 3 años de cada país).
-- Resultado esperado: el historial queda con hasta 3 años por país ('Insertado'); los agregados regionales quedan
--                     'Omitido'. Pais.pbi_per_capita queda con el valor del año más reciente.
DECLARE @historial_antes INT = (SELECT COUNT(*) FROM Participantes.Historial_pbi_pais);

EXEC Participantes.Importar_API_PBI @cantidad_anios = 3;

SELECT @historial_antes AS historial_antes, (SELECT COUNT(*) FROM Participantes.Historial_pbi_pais) AS historial_despues;

SELECT P.nombre, H.anio, H.pbi_per_capita, P.pbi_per_capita AS pbi_vigente_en_pais
FROM Participantes.Historial_pbi_pais H
INNER JOIN Participantes.Pais P ON P.id_pais = H.id_pais
WHERE P.codigo_iso IN ('ARG', 'BRA', 'MEX', 'USA')
ORDER BY P.nombre, H.anio DESC;
GO

-- Test 14: Reimportación con más años (5): se mantiene el registro histórico.
-- Resultado esperado: los 3 años que ya estaban quedan 'Actualizado' (no se duplican ni se borran) y los 2 años
--                     anteriores quedan 'Insertado'. El historial crece y el valor vigente del país no cambia.
DECLARE @historial_antes INT = (SELECT COUNT(*) FROM Participantes.Historial_pbi_pais);

EXEC Participantes.Importar_API_PBI @cantidad_anios = 5;

SELECT @historial_antes AS historial_antes, (SELECT COUNT(*) FROM Participantes.Historial_pbi_pais) AS historial_despues;

SELECT P.nombre, H.anio, H.pbi_per_capita, H.fecha_actualizacion
FROM Participantes.Historial_pbi_pais H
INNER JOIN Participantes.Pais P ON P.id_pais = H.id_pais
WHERE P.codigo_iso = 'ARG'
ORDER BY H.anio DESC;

-- Ningún país tiene dos registros del mismo año (resultado esperado: 0 filas)
SELECT id_pais, anio, COUNT(*) AS repeticiones
FROM Participantes.Historial_pbi_pais
GROUP BY id_pais, anio
HAVING COUNT(*) > 1;
GO

-- Test 15: Cantidad de años inválida.
-- Resultado esperado: error '- La cantidad de años debe estar entre 1 y 20.'
EXEC Participantes.Importar_API_PBI @cantidad_anios = 0;
GO

------------------------------------------
-- PREPARACIÓN: selecciones del Reino Unido
-- Inglaterra y Escocia juegan el Mundial pero no son países para el dataset de países ni para ISO 3166:
-- se cargan a mano con el SP de alta (el código ISO es interno y coincide con el código FIFA).

IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = 'GBP')
    EXEC Participantes.Alta_Moneda @codigo_moneda = 'GBP', @nombre_moneda = 'Libra esterlina';
GO

IF NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE codigo_iso = 'ENG')
    EXEC Participantes.Alta_Pais @codigo_moneda = 'GBP', @nombre = 'Inglaterra', @codigo_iso = 'ENG', @pbi_per_capita = NULL,
        @huso_horario = 'UTC+1', @nombre_ingles = 'England', @codigo_fifa = 'ENG';
GO

IF NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE codigo_iso = 'SCO')
    EXEC Participantes.Alta_Pais @codigo_moneda = 'GBP', @nombre = 'Escocia', @codigo_iso = 'SCO', @pbi_per_capita = NULL,
        @huso_horario = 'UTC+1', @nombre_ingles = 'Scotland', @codigo_fifa = 'SCO';
GO

------------------------------------------
-- PRUEBAS: Torneo.Importar_XML_Mundial (dataset obtenido por scraping)

-- Test 16: Archivo de prueba con errores a propósito.
-- Resultado esperado (sedes y selecciones):
--   Sede Estadio Azteca: Insertado (se crea la ciudad Mexico City, huso UTC-6)
--   Sede con nombre de más de 30 caracteres: Error
--   Sede Estadio Fantasma: Error 'No existe un país con código ISO "XXX"'
--   Sede Estadio Sin Capacidad: Error 'Capacidad inválida: "mucha"'
--   Sede Estadio Huso Raro: Error 'Huso horario inválido: "GMT+99"'
--   Selecciones MEX y RSA: Insertado en el grupo A ('Selección de México', 'Selección de Sudáfrica')
--   Selección ZZZ: Error 'No existe un país con código FIFA o ISO "ZZZ"'
-- Resultado esperado (partidos, procesados por Torneo.Importar_Fixture):
--   Partido 1 (México - Sudáfrica): Insertado
--   Partido 2: Error 'La selección "ZZZ" no existe'
--   Partido 3: Error 'El estadio "Estadio Fantasma" no existe'
--   Partido 4: Error 'Fecha y hora local inválida' y 'Goles del local inválidos'
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\mundial_2026_prueba_errores.xml';
GO

SELECT TOP 3 * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO

-- Test 17: Importación del XML real generado por el scraper.
-- Resultado esperado: 16 sedes (Insertado, salvo el Estadio Azteca que queda 'Actualizado'), 48 selecciones en
--                     12 grupos y 104 partidos (72 de la fase de grupos y 32 de la eliminatoria), con sus resultados.
--                     Las fases de la eliminatoria se crean si no existían. Si alguna selección no se encuentra
--                     (país sin código FIFA), sus partidos quedan en 'Error' y el resto se importa igual.
DECLARE @partidos_antes INT = (SELECT COUNT(*) FROM Torneo.Partido);

EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\mundial_2026_wikipedia.xml';

SELECT @partidos_antes AS partidos_antes, (SELECT COUNT(*) FROM Torneo.Partido) AS partidos_despues;
GO

SELECT F.nombre_fase, COUNT(*) AS partidos
FROM Torneo.Partido P
INNER JOIN Torneo.Fase F ON P.id_fase = F.id_fase
GROUP BY F.nombre_fase;

SELECT S.nombre_seleccion, G.nombre_grupo, P.codigo_fifa
FROM Participantes.Seleccion S
INNER JOIN Torneo.Grupo_torneo G ON S.id_grupo = G.id_grupo
INNER JOIN Participantes.Pais P ON S.id_pais = P.id_pais
ORDER BY G.nombre_grupo, S.nombre_seleccion;
GO

-- Test 18: Reimportación del mismo XML.
-- Resultado esperado: sedes, selecciones y partidos quedan 'Actualizado'; la cantidad de partidos no cambia.
DECLARE @partidos_antes INT = (SELECT COUNT(*) FROM Torneo.Partido);

EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\mundial_2026_wikipedia.xml';

SELECT @partidos_antes AS partidos_antes, (SELECT COUNT(*) FROM Torneo.Partido) AS partidos_despues;
GO

-- Test 19: Archivo que no es XML (se pasa el CSV de estadios).
-- Resultado esperado: error 'Error al leer el archivo ... (inexistente o XML mal formado)'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\stadiums.csv';
GO

-- Test 20: Archivo inexistente.
-- Resultado esperado: error 'Error al leer el archivo "C:\Importar\no_existe.xml" ...'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\no_existe.xml';
GO

-- Test 21: Ruta vacía.
-- Resultado esperado: error 'Debe indicarse la ruta del archivo XML a importar'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = '';
GO

------------------------------------------
-- PRUEBA: reimportación del CSV de estadios ahora que los países tienen nombre en inglés

-- Test 22: Resultado esperado: las filas que antes daban 'El país no existe' (Brazil, Germany, France, etc.) ahora se
--          insertan; siguen con error solo los países que ya no existen (por ejemplo West Germany o Yugoslavia).
EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';

SELECT estado_proceso, COUNT(*) AS filas FROM Torneo.Staging_stadiums GROUP BY estado_proceso;
GO

------------------------------------------
-- PRUEBAS: APIs de coordenadas y husos horarios

-- Test 23: Coordenadas de las sedes (API Nominatim). Se limita a 20 consultas (1 por segundo).
-- Resultado esperado: las sedes del Mundial 2026 (cargadas por el XML) quedan con latitud y longitud.
EXEC Torneo.Actualizar_Coordenadas_Sedes @limite = 20;
GO

-- Test 24: Husos horarios (API timeapi.io) de las sedes geolocalizadas y de los países en uso
--          (mercados de campañas o países con selección). Se limita a 60 consultas.
-- Resultado esperado: las sedes y países pendientes quedan con su huso. En junio y julio se aplica el horario de
--                     verano del hemisferio norte: por ejemplo Alemania queda UTC+2, Estados Unidos (capital) UTC-4,
--                     México UTC-6 (no usa horario de verano) y Argentina UTC-3.
EXEC Torneo.Actualizar_Husos_Horarios @incluir_sedes = 1, @incluir_paises = 1, @solo_paises_en_uso = 1, @limite = 60;
GO

SELECT S.nombre_estadio, C.nombre AS ciudad, S.capacidad, S.latitud, S.longitud, S.huso_horario
FROM Torneo.Sede S
INNER JOIN Participantes.Ciudad C ON S.id_ciudad = C.id_ciudad
ORDER BY S.id_sede DESC;

SELECT nombre, codigo_iso, codigo_fifa, pbi_per_capita, huso_horario
FROM Participantes.Pais
WHERE huso_horario IS NOT NULL
ORDER BY nombre;
GO

-- Test 25: Uso de los datos importados en la lógica de negocio: simulación de prime time de la final.
-- Resultado esperado: lista de mercados con la hora local de la final y si cae en prime time (19 a 23 h).
DECLARE @idFinal INT = (SELECT TOP 1 P.id_partido
                        FROM Torneo.Partido P
                        INNER JOIN Torneo.Fase F ON P.id_fase = F.id_fase
                        WHERE F.nombre_fase = 'Final'
                        ORDER BY P.fecha_hora_local DESC);

IF (@idFinal IS NOT NULL)
    EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = @idFinal;
GO

-- Test 26: Log de todas las importaciones.
-- Resultado esperado: una fila por ejecución (archivos y APIs) con registros procesados, con error y estado.
SELECT * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO