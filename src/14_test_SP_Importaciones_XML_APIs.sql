-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Descripción: Scripts de prueba para la importación por APIs (REST Countries, Banco Mundial, timeapi.io)
--              y del XML obtenido por scraping de Wikipedia.
-- Requisitos:
--   - Ejecutar antes los scripts 00 a 13 y los tests 07 a 12.
--   - Conexión a Internet (las APIs se consultan en el momento).
--   - Copiar en C:\Importar\ (en la PC del servidor SQL):
--       mundial_2026_prueba_errores.xml  -> de la carpeta datos/ (archivo de prueba con errores a propósito)
--       mundial_2026_wikipedia.xml       -> generado en el momento con el scraper:
--                                           python scraping\scraper_mundial_2026.py C:\Importar\mundial_2026_wikipedia.xml
--       stadiums.csv                     -> de la carpeta datos/ (ya usado en el script 12)
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Participantes.Importar_API_Paises (API REST Countries)

-- Test 01: Primera importación de países.
-- Resultado esperado: alrededor de 250 países recibidos. Los que ya existían (Argentina, Brasil, Uruguay, España, etc.)
--                     quedan 'Actualizado' (se completan nombre en inglés, código FIFA y coordenadas de la capital,
--                     sin cambiar su nombre en castellano); el resto queda 'Insertado' con su moneda. Algunos
--                     territorios sin moneda (por ejemplo la Antártida) quedan en 'Error' con 'El país no tiene moneda en la API'.
DECLARE @paises_antes INT = (SELECT COUNT(*) FROM Participantes.Pais);

EXEC Participantes.Importar_API_Paises;

SELECT @paises_antes AS paises_antes, (SELECT COUNT(*) FROM Participantes.Pais) AS paises_despues;
SELECT id_pais, nombre, nombre_ingles, codigo_iso, codigo_fifa, codigo_moneda, latitud_capital, longitud_capital
FROM Participantes.Pais
WHERE codigo_iso IN ('ARG', 'BRA', 'URY', 'MEX', 'ZAF', 'USA', 'DEU');
GO

-- Test 02: Segunda importación (mismo dataset).
-- Resultado esperado: todos los países válidos quedan 'Actualizado' y la cantidad de países no cambia (sin duplicados).
DECLARE @paises_antes INT = (SELECT COUNT(*) FROM Participantes.Pais);

EXEC Participantes.Importar_API_Paises;

SELECT @paises_antes AS paises_antes, (SELECT COUNT(*) FROM Participantes.Pais) AS paises_despues;
GO

------------------------------------------
-- PRUEBAS: Participantes.Importar_API_PBI (API del Banco Mundial)

-- Test 03: Actualización del PBI per cápita.
-- Resultado esperado: se actualiza el PBI de la mayoría de los países con el último año disponible; los agregados
--                     regionales quedan 'Omitido' y los países sin dato (por ejemplo algunos territorios) quedan 'Sin dato'.
EXEC Participantes.Importar_API_PBI;

SELECT nombre, codigo_iso, pbi_per_capita
FROM Participantes.Pais
WHERE codigo_iso IN ('ARG', 'BRA', 'URY', 'MEX', 'ZAF', 'USA', 'DEU')
ORDER BY pbi_per_capita DESC;
GO

------------------------------------------
-- PREPARACIÓN: selecciones del Reino Unido
-- Inglaterra y Escocia juegan el Mundial pero no son países para REST Countries ni para ISO 3166:
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

-- Test 04: Archivo de prueba con errores a propósito.
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

-- Test 05: Importación del XML real generado por el scraper.
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

-- Test 06: Reimportación del mismo XML.
-- Resultado esperado: sedes, selecciones y partidos quedan 'Actualizado'; la cantidad de partidos no cambia.
DECLARE @partidos_antes INT = (SELECT COUNT(*) FROM Torneo.Partido);

EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\mundial_2026_wikipedia.xml';

SELECT @partidos_antes AS partidos_antes, (SELECT COUNT(*) FROM Torneo.Partido) AS partidos_despues;
GO

-- Test 07: Archivo que no es XML (se pasa el CSV de estadios).
-- Resultado esperado: error 'Error al leer el archivo ... (inexistente o XML mal formado)'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\stadiums.csv';
GO

-- Test 08: Archivo inexistente.
-- Resultado esperado: error 'Error al leer el archivo "C:\Importar\no_existe.xml" ...'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\no_existe.xml';
GO

-- Test 09: Ruta vacía.
-- Resultado esperado: error 'Debe indicarse la ruta del archivo XML a importar'.
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = '';
GO

------------------------------------------
-- PRUEBA: reimportación del CSV de estadios ahora que los países tienen nombre en inglés

-- Test 10: Resultado esperado: las filas que antes daban 'El país no existe' (Brazil, Germany, France, etc.) ahora se
--          insertan; siguen con error solo los países que ya no existen (por ejemplo West Germany o Yugoslavia).
EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums.csv';

SELECT estado_proceso, COUNT(*) AS filas FROM Torneo.Staging_stadiums GROUP BY estado_proceso;
GO

------------------------------------------
-- PRUEBAS: APIs de coordenadas y husos horarios

-- Test 11: Coordenadas de las sedes (API Nominatim). Se limita a 20 consultas (1 por segundo).
-- Resultado esperado: las sedes del Mundial 2026 (cargadas por el XML) quedan con latitud y longitud.
EXEC Torneo.Actualizar_Coordenadas_Sedes @limite = 20;
GO

-- Test 12: Husos horarios (API timeapi.io) de las sedes geolocalizadas y de los países en uso
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

-- Test 13: Uso de los datos importados en la lógica de negocio: simulación de prime time de la final.
-- Resultado esperado: lista de mercados con la hora local de la final y si cae en prime time (19 a 23 h).
DECLARE @idFinal INT = (SELECT TOP 1 P.id_partido
                        FROM Torneo.Partido P
                        INNER JOIN Torneo.Fase F ON P.id_fase = F.id_fase
                        WHERE F.nombre_fase = 'Final'
                        ORDER BY P.fecha_hora_local DESC);

IF (@idFinal IS NOT NULL)
    EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = @idFinal;
GO

-- Test 14: Log de todas las importaciones.
-- Resultado esperado: una fila por ejecución (archivos y APIs) con registros procesados, con error y estado.
SELECT * FROM Torneo.Log_importacion ORDER BY id_log DESC;
GO
