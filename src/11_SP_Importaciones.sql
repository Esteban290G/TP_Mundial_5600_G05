-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Procesos de Importación: datasets (CSV y XML por scraping) y APIs externas
-- 
-- DATASETS ELEGIDOS:
-- 1. repositorio worldcup (github.com/jfjelstul/worldcup) - Formato: CSV - archivo data-csv/stadiums.csv
-- 2. Fixture, sedes y resultados del Mundial 2026 desde Wikipedia (en inglés) - Formato: XML (obtenido por scraping)
--    https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_Group_A ... Group_L y .../2026_FIFA_World_Cup_knockout_stage
--    Técnica: script scraping/scraper_mundial_2026.py (Python, biblioteca estándar). Descarga el código fuente
--    (wikitext) de cada página y extrae los "match boxes" ({{Football box}}) con un parser de llaves balanceadas
--    y expresiones regulares; la capacidad de cada estadio sale de la ficha de su artículo. Genera un XML que
--    se importa sin modificar con Torneo.Importar_XML_Mundial.
--    Límites: sin clave; Wikipedia pide un User-Agent identificable y no saturar el sitio (el script pausa 1 s por pedido).
--
-- APIs ELEGIDAS:
-- 1. Nominatim (OpenStreetMap) - Geolocalización de estadios (latitud y longitud):
--    URL: https://nominatim.openstreetmap.org/search
--    Límites y autenticación: API pública sin API Key; rate limit de 1 petición HTTP por segundo por dirección IP.
--    Requiere un HTTP Referer o User-Agent válido que identifique la aplicación.
-- 2. Países (JSON mledoze/countries en GitHub):
--    URL: https://raw.githubusercontent.com/mledoze/countries/master/dist/countries.json
--    Es la fuente de datos sobre la que estaba construida REST Countries (v1-v4 fueron dadas de baja en 2026
--    y la v5 exige registro y clave, por lo que se consume directamente el JSON de origen).
--    Datos: nombre en castellano e inglés, código ISO alfa-3, código COI (usado como código FIFA con tabla de
--    excepciones donde difieren), moneda y coordenadas de referencia del país.
--    Límites y autenticación: sin clave ni límite de uso publicado (archivo de unos 800 KB).
-- 3. Banco Mundial - PBI per cápita en USD corrientes (proxy de poder adquisitivo para la publicidad):
--    URL: https://api.worldbank.org/v2/country/all/indicator/NY.GDP.PCAP.CD
--    Datos: últimos N valores de cada país (mrnev=N), guardados en Participantes.Historial_pbi_pais (información histórica).
--    Límites y autenticación: sin clave; máximo 32.500 registros por página.
-- 4. timeapi.io - Husos horarios a partir de coordenadas (sedes de Nominatim y capitales de países):
--    URL: https://timeapi.io/api/timezone/coordinate
--    Límites y autenticación: sin clave; límite no publicado (se realiza 1 consulta por segundo).
--
-- REQUISITOS DE CONFIGURACIÓN (una sola vez por servidor, con permisos de sysadmin):
--- Las APIs se consumen con sp_OACreate (objeto MSXML2.ServerXMLHTTP), que requiere habilitar
--- 'Ole Automation Procedures'. Se habilita al principio de este script.
--- BULK INSERT / OPENROWSET(BULK) leen el archivo desde la PC donde corre el servicio de SQL Server:
--- la carpeta (ej: C:\Importar\) debe existir allí y el usuario del servicio debe poder leerla.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Habilitar OLE Automation (necesario para consumir APIs desde T-SQL)

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
GO

------------------------------------------
-- Procedimiento: Torneo.Consultar_API
-- Descripción: Hace un GET HTTP a la URL indicada y devuelve el cuerpo de la respuesta.
--              Lo usan todos los procesos que consumen APIs (Nominatim, países mledoze/countries, Banco Mundial, timeapi.io).
--              La respuesta se lee con INSERT ... EXEC para admitir respuestas de más de 4000 caracteres.
-- Validaciones: URL vacía, error al crear el objeto HTTP (OLE Automation deshabilitado), error de conexión
--               y estado HTTP distinto de 200. Los errores se informan con THROW.

CREATE OR ALTER PROCEDURE Torneo.Consultar_API
    @url VARCHAR(2000),
    @respuesta NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @token INT = NULL;
    DECLARE @hr INT;
    DECLARE @estado_http INT;
    DECLARE @fuente_error VARCHAR(255);
    DECLARE @descripcion_error VARCHAR(255);
    DECLARE @MensajeError VARCHAR(1000);
    DECLARE @resultado TABLE (texto NVARCHAR(MAX));

    SET @respuesta = NULL;

    IF (@url IS NULL OR LTRIM(RTRIM(@url)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la URL a consultar. ', 1;
        RETURN;
    END

    EXEC @hr = sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @token OUT;

    IF (@hr <> 0)
    BEGIN
        ;THROW 50002, '- No se pudo crear el objeto HTTP. Verificar que ''Ole Automation Procedures'' esté habilitado. ', 1;
        RETURN;
    END

    EXEC @hr = sp_OAMethod @token, 'open', NULL, 'GET', @url, 'false';

    IF (@hr = 0)
        EXEC @hr = sp_OAMethod @token, 'setRequestHeader', NULL, 'User-Agent', 'Proyecto_UNLaM_BDA_G05 (TP Mundial 2026)';

    IF (@hr = 0)
        EXEC @hr = sp_OAMethod @token, 'send';

    IF (@hr <> 0)
    BEGIN
        EXEC sp_OAGetErrorInfo @token, @fuente_error OUT, @descripcion_error OUT;
        EXEC sp_OADestroy @token;

        SET @MensajeError = '- No se pudo conectar con la API (' + LEFT(@url, 200) + '): '
                          + ISNULL(@descripcion_error, 'error desconocido') + ' ';
        ;THROW 50003, @MensajeError, 1;
        RETURN;
    END

    EXEC sp_OAGetProperty @token, 'status', @estado_http OUT;

    INSERT INTO @resultado (texto)
    EXEC sp_OAGetProperty @token, 'responseText';

    EXEC sp_OADestroy @token;

    SELECT @respuesta = texto FROM @resultado;

    IF (@estado_http <> 200)
    BEGIN
        SET @MensajeError = '- La API respondió con el estado HTTP ' + CAST(@estado_http AS VARCHAR(10))
                          + ' (' + LEFT(@url, 200) + '). ';
        ;THROW 50004, @MensajeError, 1;
        RETURN;
    END
END;
GO

------------------------------------------
-- github.com/jfjelstul/worldcup - Formato: CSV
------------------------------------------
-- Procedimiento: Torneo.Importar_CSV_Stadiums
-- Descripción: Lee el archivo stadiums.csv tal cual se descarga (sin modificarlo) y lo carga en
--              Torneo.Staging_stadiums a través de la vista Torneo.vw_Staging_stadiums. Después procesa
--              las filas con Torneo.Procesar_CSV_Stadiums (upsert en Torneo.Sede).
--              Se usa SQL dinámico porque BULK INSERT no acepta la ruta del archivo en una variable.
-- Validaciones: Nombre de archivo vacío y error de lectura del archivo (inexistente, sin permisos o con
--               un formato distinto al esperado). Los errores se informan con THROW.

CREATE OR ALTER PROCEDURE Torneo.Importar_CSV_Stadiums
    @nombre_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @sql NVARCHAR(MAX);
    DECLARE @FilasLeidas INT;
    DECLARE @MensajeError NVARCHAR(1000);

    IF (@nombre_archivo IS NULL OR LTRIM(RTRIM(@nombre_archivo)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la ruta del archivo a importar. ', 1;
        RETURN;
    END

    -- Se vacía el staging: el resultado de importaciones anteriores queda registrado en Torneo.Log_importacion
    TRUNCATE TABLE Torneo.Staging_stadiums;

    -- Las comillas simples de la ruta se duplican para evitar inyección de SQL
    SET @sql = N'BULK INSERT Torneo.vw_Staging_stadiums
                 FROM ''' + REPLACE(@nombre_archivo, '''', '''''') + N'''
                 WITH (
                     FORMAT = ''CSV'',
                     FIELDTERMINATOR = '','',
                     ROWTERMINATOR = ''0x0a'',
                     CODEPAGE = ''65001'',
                     FIRSTROW = 2
                 )';

    BEGIN TRY
        EXEC sp_executesql @sql;
    END TRY
    BEGIN CATCH
        SET @MensajeError = N'- Error al leer el archivo "' + @nombre_archivo + N'": ' + ERROR_MESSAGE();
        ;THROW 50002, @MensajeError, 1;
    END CATCH;

    SELECT @FilasLeidas = COUNT(*) FROM Torneo.Staging_stadiums;
    PRINT 'Lectura del CSV finalizada. Registros listos para procesar: ' + CAST(@FilasLeidas AS VARCHAR(10));

    -- Procesamiento (validaciones y upsert)
    EXEC Torneo.Procesar_CSV_Stadiums @nombre_archivo = @nombre_archivo;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Procesar_CSV_Stadiums
-- Descripción: Procesa los registros en estado 'Pendiente' de Torneo.Staging_stadiums y hace un upsert en Torneo.Sede
--              (clave: nombre del estadio + ciudad).
--                - El país se busca por nombre en castellano, nombre en inglés (el CSV viene en inglés) o código ISO.
--                - Si la ciudad no existe en ese país se crea.
--                - Las sedes nuevas quedan sin coordenadas ni huso horario (NULL): los completan
--                  Torneo.Actualizar_Coordenadas_Sedes (API Nominatim) y Torneo.Actualizar_Husos_Horarios.
--                - Importación parcial: las filas inválidas quedan en estado 'Error' con el detalle.
-- Validaciones: Staging sin filas pendientes, datos obligatorios faltantes, país inexistente, nombres más largos
--               que las columnas de destino, capacidad no numérica o no positiva y estadios repetidos en el archivo.

CREATE OR ALTER PROCEDURE Torneo.Procesar_CSV_Stadiums
    @nombre_archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_log INT;
    DECLARE @total INT = 0, @insertados INT = 0, @actualizados INT = 0, @con_error INT = 0, @duplicados INT = 0;
    DECLARE @estado_log VARCHAR(50);

    -- Verificar si hay filas pendientes
    IF NOT EXISTS (SELECT 1 FROM Torneo.Staging_stadiums WHERE estado_proceso = 'Pendiente')
    BEGIN
        ;THROW 50001, '- No hay filas pendientes de procesar en Torneo.Staging_stadiums. ', 1;
        RETURN;
    END

    ------------------------------------------
    -- Copia de trabajo de las filas pendientes
    CREATE TABLE #filas (
        id_fila INT NOT NULL PRIMARY KEY,
        stadium_name_txt VARCHAR(100) COLLATE DATABASE_DEFAULT,
        city_name_txt VARCHAR(100) COLLATE DATABASE_DEFAULT,
        country_name_txt VARCHAR(100) COLLATE DATABASE_DEFAULT,
        capacity_txt VARCHAR(100) COLLATE DATABASE_DEFAULT,

        id_pais INT NULL,
        id_ciudad INT NULL,
        capacidad INT NULL,
        id_sede_existente INT NULL,

        mensaje_error VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #filas (id_fila, stadium_name_txt, city_name_txt, country_name_txt, capacity_txt)
    SELECT
        id_fila,
        NULLIF(LTRIM(RTRIM(stadium_name)), ''),
        NULLIF(LTRIM(RTRIM(city_name)), ''),
        NULLIF(LTRIM(RTRIM(country_name)), ''),
        NULLIF(LTRIM(RTRIM(REPLACE(stadium_capacity, CHAR(13), ''))), '')
    FROM Torneo.Staging_stadiums
    WHERE estado_proceso = 'Pendiente';

    SELECT @total = COUNT(*) FROM #filas;

    ------------------------------------------
    -- Claves y conversión de tipos

    -- País: por nombre en castellano, en inglés o código ISO
    UPDATE F
    SET id_pais = (SELECT TOP 1 P.id_pais
                   FROM Participantes.Pais P
                   WHERE F.country_name_txt IN (P.nombre, P.nombre_ingles, P.codigo_iso)
                   ORDER BY P.id_pais)
    FROM #filas F;

    -- Ciudad existente en ese país
    UPDATE F
    SET id_ciudad = C.id_ciudad
    FROM #filas F
    INNER JOIN Participantes.Ciudad C ON C.nombre = F.city_name_txt AND C.id_pais = F.id_pais;

    -- Capacidad a número
    UPDATE #filas
    SET capacidad = TRY_CAST(capacity_txt AS INT);

    -- Sede existente (mismo estadio en la misma ciudad)
    UPDATE F
    SET id_sede_existente = S.id_sede
    FROM #filas F
    INNER JOIN Torneo.Sede S ON S.nombre_estadio = F.stadium_name_txt AND S.id_ciudad = F.id_ciudad;

    ------------------------------------------
    -- Validaciones por fila (se acumulan todos los problemas de cada fila)
    UPDATE F
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN F.stadium_name_txt IS NULL THEN '- Falta el nombre del estadio. '
             WHEN LEN(F.stadium_name_txt) > 30 THEN '- El nombre del estadio "' + F.stadium_name_txt + '" supera los 30 caracteres. ' END,
        CASE WHEN F.country_name_txt IS NULL THEN '- Falta el país. '
             WHEN F.id_pais IS NULL THEN '- El país "' + F.country_name_txt + '" no existe en la base. ' END,
        CASE WHEN F.city_name_txt IS NULL THEN '- Falta la ciudad. '
             WHEN LEN(F.city_name_txt) > 50 THEN '- El nombre de la ciudad "' + F.city_name_txt + '" supera los 50 caracteres. ' END,
        CASE WHEN F.capacity_txt IS NULL THEN '- Falta la capacidad. '
             WHEN F.capacidad IS NULL OR F.capacidad <= 0 THEN '- Capacidad inválida: "' + F.capacity_txt + '". ' END
    ), '')
    FROM #filas F;

    UPDATE #filas SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    -- Estadios repetidos dentro del archivo: se importa la última aparición
    ;WITH repetidos AS (
        SELECT estado, mensaje_error,
               ROW_NUMBER() OVER (PARTITION BY stadium_name_txt, city_name_txt, id_pais ORDER BY id_fila DESC) AS rn
        FROM #filas
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Duplicado',
        mensaje_error = '- Estadio repetido en el archivo: se importa su última aparición. '
    WHERE rn > 1;

    -- Insert o Update
    UPDATE #filas
    SET estado = CASE WHEN id_sede_existente IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

    -- Totales para el log
    SELECT
        @insertados = SUM(CASE WHEN estado = 'Insertado' THEN 1 ELSE 0 END),
        @actualizados = SUM(CASE WHEN estado = 'Actualizado' THEN 1 ELSE 0 END),
        @con_error = SUM(CASE WHEN estado = 'Error' THEN 1 ELSE 0 END),
        @duplicados = SUM(CASE WHEN estado = 'Duplicado' THEN 1 ELSE 0 END)
    FROM #filas;

    SET @estado_log = CASE WHEN @con_error + @duplicados = 0 THEN 'Completado'
                           WHEN @insertados + @actualizados = 0 THEN 'Sin registros válidos'
                           ELSE 'Completado con errores' END;

    ------------------------------------------
    -- Upsert y registro en Log_importacion (una única transacción)
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (LTRIM(RTRIM(@nombre_archivo)), GETDATE(), @total, @con_error + @duplicados, @estado_log);

        SET @id_log = SCOPE_IDENTITY();

        -- Ciudades nuevas de las sedes a insertar
        INSERT INTO Participantes.Ciudad (id_pais, nombre)
        SELECT DISTINCT F.id_pais, F.city_name_txt
        FROM #filas F
        WHERE F.estado = 'Insertado'
          AND F.id_ciudad IS NULL;

        UPDATE F
        SET id_ciudad = C.id_ciudad
        FROM #filas F
        INNER JOIN Participantes.Ciudad C ON C.nombre = F.city_name_txt AND C.id_pais = F.id_pais
        WHERE F.estado = 'Insertado' AND F.id_ciudad IS NULL;

        -- Actualizar estadios existentes
        UPDATE S
        SET capacidad = F.capacidad
        FROM Torneo.Sede S
        INNER JOIN #filas F ON S.id_sede = F.id_sede_existente
        WHERE F.estado = 'Actualizado';

        -- Sedes nuevas: coordenadas y huso quedan pendientes (NULL) hasta consultar las APIs
        INSERT INTO Torneo.Sede (id_ciudad, nombre_estadio, capacidad, latitud, longitud, huso_horario)
        SELECT id_ciudad, stadium_name_txt, capacidad, NULL, NULL, NULL
        FROM #filas
        WHERE estado = 'Insertado';

        -- Resultado de cada fila en el staging
        UPDATE STD
        SET estado_proceso = F.estado,
            mensaje_error = F.mensaje_error,
            id_log = @id_log
        FROM Torneo.Staging_stadiums STD
        INNER JOIN #filas F ON STD.id_fila = F.id_fila;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (LTRIM(RTRIM(@nombre_archivo)), GETDATE(), @total, @total, 'Fallido');

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;

    ------------------------------------------
    -- Reporte
    PRINT CONCAT('Importación "', @nombre_archivo, '": ', @total, ' filas leídas, ', @insertados, ' insertadas, ',
                 @actualizados, ' actualizadas, ', @con_error, ' con error y ', @duplicados, ' duplicadas.');

    SELECT id_fila, estado, stadium_name_txt AS estadio, city_name_txt AS ciudad, country_name_txt AS pais,
           ISNULL(mensaje_error, '') AS detalle
    FROM #filas
    ORDER BY id_fila;
END;
GO

------------------------------------------
-- API Nominatim
------------------------------------------
-- Procedimiento: Torneo.Actualizar_Coordenadas_Sedes
-- Descripción: Completa latitud y longitud de las sedes que todavía no las tienen, consultando la API Nominatim
--              (OpenStreetMap) con "estadio, ciudad, país". Respeta el límite de 1 consulta por segundo.
--              Recorre las sedes de a una (la API recibe una búsqueda por consulta) con un WHILE sobre el id,
--              sin cursores. Si una consulta falla o no encuentra el estadio, sigue con la siguiente.
--              El resultado queda registrado en Torneo.Log_importacion.
-- Parámetros: @limite: cantidad máxima de sedes a consultar (NULL = todas).

CREATE OR ALTER PROCEDURE Torneo.Actualizar_Coordenadas_Sedes
    @limite INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_actual INT = NULL;
    DECLARE @estadio VARCHAR(30);
    DECLARE @ciudad VARCHAR(50);
    DECLARE @pais VARCHAR(50);
    DECLARE @url VARCHAR(2000);
    DECLARE @response NVARCHAR(MAX);
    DECLARE @lat_extraida DECIMAL(9,6);
    DECLARE @lon_extraida DECIMAL(9,6);
    DECLARE @procesadas INT = 0;
    DECLARE @actualizadas INT = 0;
    DECLARE @con_error INT = 0;

    -- Primera sede sin coordenadas (también se toman las cargadas con 0,0 por versiones anteriores)
    SELECT TOP 1
        @id_actual = S.id_sede,
        @estadio = S.nombre_estadio,
        @ciudad = C.nombre,
        @pais = ISNULL(P.nombre_ingles, P.nombre)
    FROM Torneo.Sede S
    INNER JOIN Participantes.Ciudad C ON S.id_ciudad = C.id_ciudad
    INNER JOIN Participantes.Pais P ON C.id_pais = P.id_pais
    WHERE S.latitud IS NULL OR S.longitud IS NULL OR (S.latitud = 0.0 AND S.longitud = 0.0)
    ORDER BY S.id_sede ASC;

    -- El bucle corta cuando no hay más sedes pendientes o se alcanza el límite
    WHILE (@id_actual IS NOT NULL AND (@limite IS NULL OR @procesadas < @limite))
    BEGIN
        SET @procesadas = @procesadas + 1;
        SET @response = NULL;
        SET @lat_extraida = NULL;
        SET @lon_extraida = NULL;

        SET @url = 'https://nominatim.openstreetmap.org/search?q='
                   + Torneo.fn_Url_Encode(@estadio + ', ' + @ciudad + ', ' + @pais)
                   + '&format=json&limit=1';

        BEGIN TRY
            EXEC Torneo.Consultar_API @url = @url, @respuesta = @response OUTPUT;

            IF (ISJSON(@response) > 0)
            BEGIN
                SET @lat_extraida = TRY_CAST(JSON_VALUE(@response, '$[0].lat') AS DECIMAL(9,6));
                SET @lon_extraida = TRY_CAST(JSON_VALUE(@response, '$[0].lon') AS DECIMAL(9,6));
            END

            IF (@lat_extraida IS NOT NULL AND @lon_extraida IS NOT NULL)
            BEGIN
                UPDATE Torneo.Sede
                SET latitud = @lat_extraida,
                    longitud = @lon_extraida
                WHERE id_sede = @id_actual;

                SET @actualizadas = @actualizadas + 1;
                PRINT 'Geolocalizado: ' + @estadio + ' (' + @ciudad + ')';
            END
            ELSE
            BEGIN
                SET @con_error = @con_error + 1;
                PRINT 'Sin resultados en Nominatim: ' + @estadio + ' (' + @ciudad + ')';
            END
        END TRY
        BEGIN CATCH
            SET @con_error = @con_error + 1;
            PRINT 'Error al geolocalizar ' + @estadio + ': ' + ERROR_MESSAGE();
        END CATCH;

        WAITFOR DELAY '00:00:01'; -- Rate limit de Nominatim

        -- Siguiente sede pendiente con id mayor al actual
        DECLARE @siguiente_id INT;
        SET @siguiente_id = NULL;

        SELECT TOP 1
            @siguiente_id = S.id_sede,
            @estadio = S.nombre_estadio,
            @ciudad = C.nombre,
            @pais = ISNULL(P.nombre_ingles, P.nombre)
        FROM Torneo.Sede S
        INNER JOIN Participantes.Ciudad C ON S.id_ciudad = C.id_ciudad
        INNER JOIN Participantes.Pais P ON C.id_pais = P.id_pais
        WHERE (S.latitud IS NULL OR S.longitud IS NULL OR (S.latitud = 0.0 AND S.longitud = 0.0))
          AND S.id_sede > @id_actual
        ORDER BY S.id_sede ASC;

        SET @id_actual = @siguiente_id;
    END

    -- Registro de la ejecución
    INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
    VALUES ('API Nominatim - coordenadas de sedes', GETDATE(), @procesadas, @con_error,
            CASE WHEN @procesadas = 0 THEN 'Sin registros pendientes'
                 WHEN @con_error = 0 THEN 'Completado'
                 WHEN @actualizadas = 0 THEN 'Sin registros válidos'
                 ELSE 'Completado con errores' END);

    PRINT CONCAT('Proceso de API finalizado: ', @procesadas, ' sedes consultadas, ', @actualizadas,
                 ' geolocalizadas y ', @con_error, ' sin resultado o con error.');
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Importar_API_Paises
-- Descripción: Descarga por HTTP el JSON de países de mledoze/countries (la fuente de REST Countries, cuya API
--              v3.1 fue dada de baja) y hace un upsert de los países (clave: código ISO alfa-3).
--                - País existente: completa nombre en inglés, código FIFA y coordenadas de la capital
--                  (no cambia el nombre en castellano ni la moneda ya cargados).
--                - País nuevo: se inserta con el nombre en castellano y su moneda (si la moneda no existe, se crea).
--              Importación parcial: los países con datos inválidos se informan y no se importan.
-- Validaciones: Respuesta que no es JSON, código ISO inválido, nombre faltante o demasiado largo,
--               país nuevo sin moneda y países repetidos en la respuesta.

CREATE OR ALTER PROCEDURE Participantes.Importar_API_Paises
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url VARCHAR(2000) = 'https://raw.githubusercontent.com/mledoze/countries/master/dist/countries.json';
    DECLARE @fuente VARCHAR(255) = 'JSON países (mledoze/countries)';
    DECLARE @MensajeError NVARCHAR(1000);
    DECLARE @json NVARCHAR(MAX);
    DECLARE @id_log INT;
    DECLARE @total INT = 0, @insertados INT = 0, @actualizados INT = 0, @con_error INT = 0;

    -- Consulta a la API (si falla, Consultar_API lanza el error)
    EXEC Torneo.Consultar_API @url = @url, @respuesta = @json OUTPUT;

    IF (ISJSON(@json) = 0 OR LEFT(LTRIM(@json), 1) <> '[' OR JSON_VALUE(@json, '$[0].cca3') IS NULL)
    BEGIN
        -- Si la fuente devuelve un mensaje de error en JSON (p. ej. {"success": false, "errors": [...]}) se muestra
        SET @MensajeError = '- La respuesta no es la lista de países esperada'
            + ISNULL(': ' + LEFT(COALESCE(JSON_VALUE(@json, '$.errors[0].message'), JSON_VALUE(@json, '$[0].errors[0].message'),
                                           JSON_VALUE(@json, '$.message'), LEFT(@json, 150)), 300), '')
            + '. ';
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    CREATE TABLE #paises (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        codigo_iso NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        nombre_es NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        nombre_en NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        codigo_fifa NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        codigo_moneda NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        nombre_moneda NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        latitud_capital DECIMAL(9,6) NULL,
        longitud_capital DECIMAL(9,6) NULL,
        id_pais_existente INT NULL,
        mensaje_error VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #paises (codigo_iso, nombre_es, nombre_en, codigo_fifa, codigo_moneda, nombre_moneda, latitud_capital, longitud_capital)
    SELECT
        UPPER(LTRIM(RTRIM(P.cca3))),
        LTRIM(RTRIM(ISNULL(P.nombre_es, P.nombre_en))),
        LTRIM(RTRIM(P.nombre_en)),
        -- Código FIFA: el del COI salvo en los países donde la FIFA usa otro (o donde el COI no tiene código)
        UPPER(NULLIF(LTRIM(RTRIM(COALESCE(EX.codigo_fifa, P.cioc))), '')),
        M.codigo,
        M.nombre,
        TRY_CAST(JSON_VALUE(P.coordenadas, '$[0]') AS DECIMAL(9,6)),
        TRY_CAST(JSON_VALUE(P.coordenadas, '$[1]') AS DECIMAL(9,6))
    FROM OPENJSON(@json) WITH (
        cca3 NVARCHAR(10) '$.cca3',
        cioc NVARCHAR(10) '$.cioc',
        nombre_en NVARCHAR(200) '$.name.common',
        nombre_es NVARCHAR(200) '$.translations.spa.common',
        monedas NVARCHAR(MAX) '$.currencies' AS JSON,
        coordenadas NVARCHAR(MAX) '$.latlng' AS JSON
    ) AS P
    LEFT JOIN (VALUES
        ('IRN','IRN'), ('IDN','IDN'), ('SVN','SVN'), ('SLV','SLV'), ('UNK','KVX'), ('LBY','LBY'), ('GNB','GNB'),
        ('ATG','ATG'), ('BRB','BRB'), ('VGB','VGB'), ('VIR','VIR'), ('GNQ','EQG'), ('MWI','MWI'), ('BHR','BHR'),
        ('CUW','CUW'), ('NCL','NCL'), ('SSD','SSD'), ('PYF','TAH'), ('MAC','MAC'), ('FRO','FRO'), ('GIB','GIB'),
        ('TCA','TCA'), ('AIA','AIA'), ('MSR','MSR')
    ) AS EX (codigo_iso, codigo_fifa) ON EX.codigo_iso = P.cca3
    OUTER APPLY (
        -- Si el país tiene varias monedas se toma la primera en orden alfabético
        SELECT TOP 1 [key] AS codigo, JSON_VALUE([value], '$.name') AS nombre
        FROM OPENJSON(P.monedas)
        ORDER BY [key]
    ) AS M;

    SELECT @total = COUNT(*) FROM #paises;

    UPDATE PA
    SET id_pais_existente = P.id_pais
    FROM #paises PA
    INNER JOIN Participantes.Pais P ON P.codigo_iso = PA.codigo_iso;

    -- Validaciones por país
    UPDATE #paises
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN codigo_iso IS NULL OR LEN(codigo_iso) <> 3 THEN '- Código ISO inválido. ' END,
        CASE WHEN nombre_es IS NULL OR nombre_es = '' THEN '- Falta el nombre del país. '
             WHEN LEN(nombre_es) > 50 AND id_pais_existente IS NULL THEN '- El nombre "' + nombre_es + '" supera los 50 caracteres. ' END,
        CASE WHEN LEN(nombre_en) > 60 THEN '- El nombre en inglés supera los 60 caracteres. ' END,
        CASE WHEN id_pais_existente IS NULL AND codigo_moneda IS NULL THEN '- El país no tiene moneda en la fuente. '
             WHEN id_pais_existente IS NULL AND LEN(codigo_moneda) <> 3 THEN '- Código de moneda inválido. ' END
    ), '');

    -- Un código FIFA que no tenga 3 letras se descarta (no invalida el país)
    UPDATE #paises SET codigo_fifa = NULL WHERE LEN(codigo_fifa) <> 3;

    -- Código FIFA ya usado por otro país de la base: se descarta para no duplicarlo
    UPDATE PA
    SET codigo_fifa = NULL
    FROM #paises PA
    WHERE EXISTS (SELECT 1 FROM Participantes.Pais P
                  WHERE P.codigo_fifa = PA.codigo_fifa AND P.codigo_iso <> ISNULL(PA.codigo_iso, ''));

    UPDATE #paises SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    -- Países repetidos en la respuesta
    ;WITH repetidos AS (
        SELECT estado, mensaje_error, ROW_NUMBER() OVER (PARTITION BY codigo_iso ORDER BY nro) AS rn
        FROM #paises
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Error', mensaje_error = '- País repetido en la fuente. '
    WHERE rn > 1;

    UPDATE #paises
    SET estado = CASE WHEN id_pais_existente IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

    SELECT
        @insertados = SUM(CASE WHEN estado = 'Insertado' THEN 1 ELSE 0 END),
        @actualizados = SUM(CASE WHEN estado = 'Actualizado' THEN 1 ELSE 0 END),
        @con_error = SUM(CASE WHEN estado = 'Error' THEN 1 ELSE 0 END)
    FROM #paises;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @con_error,
                CASE WHEN @con_error = 0 THEN 'Completado'
                     WHEN @insertados + @actualizados = 0 THEN 'Sin registros válidos'
                     ELSE 'Completado con errores' END);

        SET @id_log = SCOPE_IDENTITY();

        -- Monedas que todavía no existen
        INSERT INTO Participantes.Moneda (codigo_moneda, nombre_moneda)
        SELECT M.codigo_moneda, LEFT(ISNULL(MAX(M.nombre_moneda), M.codigo_moneda), 50)
        FROM #paises M
        WHERE M.estado = 'Insertado'
          AND NOT EXISTS (SELECT 1 FROM Participantes.Moneda MO WHERE MO.codigo_moneda = M.codigo_moneda)
        GROUP BY M.codigo_moneda;

        -- Países existentes: datos de vinculación y de la capital
        UPDATE P
        SET nombre_ingles = ISNULL(PA.nombre_en, P.nombre_ingles),
            codigo_fifa = ISNULL(PA.codigo_fifa, P.codigo_fifa),
            latitud_capital = ISNULL(PA.latitud_capital, P.latitud_capital),
            longitud_capital = ISNULL(PA.longitud_capital, P.longitud_capital)
        FROM Participantes.Pais P
        INNER JOIN #paises PA ON P.id_pais = PA.id_pais_existente
        WHERE PA.estado = 'Actualizado';

        -- Países nuevos
        INSERT INTO Participantes.Pais (codigo_moneda, nombre, codigo_iso, pbi_per_capita, huso_horario,
                                        nombre_ingles, codigo_fifa, latitud_capital, longitud_capital)
        SELECT codigo_moneda, nombre_es, codigo_iso, NULL, NULL,
               nombre_en, codigo_fifa, latitud_capital, longitud_capital
        FROM #paises
        WHERE estado = 'Insertado';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @total, 'Fallido');

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;

    PRINT CONCAT('Países (mledoze/countries): ', @total, ' países recibidos, ', @insertados, ' insertados, ',
                 @actualizados, ' actualizados y ', @con_error, ' con error.');

    SELECT nro, estado, codigo_iso, nombre_es AS nombre, nombre_en AS nombre_ingles, codigo_fifa, codigo_moneda,
           ISNULL(mensaje_error, '') AS detalle
    FROM #paises
    ORDER BY CASE estado WHEN 'Error' THEN 0 ELSE 1 END, codigo_iso;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Importar_API_PBI
-- Descripción: Consulta la API del Banco Mundial (indicador NY.GDP.PCAP.CD, PBI per cápita en USD corrientes)
--              y guarda los últimos @cantidad_anios valores publicados de cada país (se vincula por código ISO alfa-3).
--              Información histórica: hace un upsert en Participantes.Historial_pbi_pais con clave (país, año), así
--              una reimportación agrega los años nuevos y corrige los revisados sin borrar los anteriores.
--              Después deja en Participantes.Pais.pbi_per_capita el valor del año más reciente del historial, que es
--              la base del criterio de poder adquisitivo de la publicidad.
--              Los registros de agregados regionales (ej: 'AFE', 'WLD') o de países que no están en la base se
--              informan como 'Omitido'. Los registros sin valor se informan como 'Sin dato'.
-- Parámetros: @cantidad_anios: cantidad de años por país a traer (1 a 20; por defecto 5).
-- Validaciones: Cantidad de años fuera de rango, respuesta que no es JSON o sin la lista de datos (la API devuelve
--               un mensaje de error), año inválido, valor negativo y registros repetidos (mismo país y año).

CREATE OR ALTER PROCEDURE Participantes.Importar_API_PBI
    @cantidad_anios INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url VARCHAR(2000);
    DECLARE @fuente VARCHAR(255) = 'API Banco Mundial - PBI per cápita (NY.GDP.PCAP.CD)';
    DECLARE @json NVARCHAR(MAX);
    DECLARE @MensajeError NVARCHAR(1000);
    DECLARE @total INT = 0, @insertados INT = 0, @actualizados INT = 0, @omitidos INT = 0,
            @sin_dato INT = 0, @con_error INT = 0, @duplicados INT = 0;

    IF (@cantidad_anios IS NULL OR @cantidad_anios NOT BETWEEN 1 AND 20)
    BEGIN
        ;THROW 50001, '- La cantidad de años debe estar entre 1 y 20. ', 1;
        RETURN;
    END

    -- mrnev = los N valores no vacíos más recientes de cada país; per_page alcanza para ~270 códigos x 20 años
    SET @url = 'https://api.worldbank.org/v2/country/all/indicator/NY.GDP.PCAP.CD?format=json&mrnev='
             + CAST(@cantidad_anios AS VARCHAR(2)) + '&per_page=6000';

    EXEC Torneo.Consultar_API @url = @url, @respuesta = @json OUTPUT;

    IF (ISJSON(@json) = 0 OR JSON_QUERY(@json, '$[1]') IS NULL)
    BEGIN
        SET @MensajeError = N'- La respuesta del Banco Mundial no tiene datos: ' + LEFT(ISNULL(@json, N'(vacía)'), 300);
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    CREATE TABLE #pbi (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        codigo_iso NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        nombre NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        anio_txt NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        anio SMALLINT NULL,
        valor FLOAT NULL,
        id_pais INT NULL,
        id_historial_existente INT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
        mensaje_error VARCHAR(500) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #pbi (codigo_iso, nombre, anio_txt, anio, valor)
    SELECT NULLIF(LTRIM(RTRIM(iso3)), ''), nombre, anio, TRY_CAST(anio AS SMALLINT), valor
    FROM OPENJSON(@json, '$[1]') WITH (
        iso3 NVARCHAR(10) '$.countryiso3code',
        nombre NVARCHAR(200) '$.country.value',
        anio NVARCHAR(10) '$.date',
        valor FLOAT '$.value'
    );

    SELECT @total = COUNT(*) FROM #pbi;

    UPDATE B
    SET id_pais = P.id_pais
    FROM #pbi B
    INNER JOIN Participantes.Pais P ON P.codigo_iso = B.codigo_iso;

    UPDATE #pbi
    SET estado = CASE WHEN id_pais IS NULL THEN 'Omitido'
                      WHEN valor IS NULL THEN 'Sin dato'
                      WHEN anio IS NULL OR anio NOT BETWEEN 1960 AND 2100 OR valor < 0 THEN 'Error' END,
        mensaje_error = CASE WHEN id_pais IS NULL THEN '- No es un país de la base (agregado regional o país no importado). '
                             WHEN valor IS NULL THEN '- El Banco Mundial no publica el indicador para este país y año. '
                             ELSE NULLIF(CONCAT(
                                 CASE WHEN anio IS NULL OR anio NOT BETWEEN 1960 AND 2100
                                      THEN '- Año inválido: "' + ISNULL(anio_txt, '') + '". ' END,
                                 CASE WHEN valor < 0 THEN '- Valor negativo. ' END), '') END;

    -- Mismo país y año repetidos en la respuesta: se toma el primero
    ;WITH repetidos AS (
        SELECT estado, mensaje_error, ROW_NUMBER() OVER (PARTITION BY id_pais, anio ORDER BY nro) AS rn
        FROM #pbi
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Duplicado', mensaje_error = '- País y año repetidos en la respuesta. '
    WHERE rn > 1;

    UPDATE B
    SET id_historial_existente = H.id_historial_pbi
    FROM #pbi B
    INNER JOIN Participantes.Historial_pbi_pais H ON H.id_pais = B.id_pais AND H.anio = B.anio
    WHERE B.estado IS NULL;

    UPDATE #pbi
    SET estado = CASE WHEN id_historial_existente IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

    SELECT
        @insertados = SUM(CASE WHEN estado = 'Insertado' THEN 1 ELSE 0 END),
        @actualizados = SUM(CASE WHEN estado = 'Actualizado' THEN 1 ELSE 0 END),
        @omitidos = SUM(CASE WHEN estado = 'Omitido' THEN 1 ELSE 0 END),
        @sin_dato = SUM(CASE WHEN estado = 'Sin dato' THEN 1 ELSE 0 END),
        @con_error = SUM(CASE WHEN estado = 'Error' THEN 1 ELSE 0 END),
        @duplicados = SUM(CASE WHEN estado = 'Duplicado' THEN 1 ELSE 0 END)
    FROM #pbi;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @con_error + @sin_dato + @duplicados,
                CASE WHEN @insertados + @actualizados = 0 THEN 'Sin registros válidos'
                     WHEN @con_error + @sin_dato + @duplicados = 0 THEN 'Completado'
                     ELSE 'Completado con errores' END);

        -- Años ya registrados: se actualiza el valor (el Banco Mundial revisa cifras de años anteriores)
        UPDATE H
        SET pbi_per_capita = ROUND(B.valor, 2),
            fecha_actualizacion = GETDATE()
        FROM Participantes.Historial_pbi_pais H
        INNER JOIN #pbi B ON H.id_historial_pbi = B.id_historial_existente
        WHERE B.estado = 'Actualizado';

        -- Años nuevos: se agregan sin tocar los anteriores
        INSERT INTO Participantes.Historial_pbi_pais (id_pais, anio, pbi_per_capita)
        SELECT id_pais, anio, ROUND(valor, 2)
        FROM #pbi
        WHERE estado = 'Insertado';

        -- Valor vigente del país = el del año más reciente de su historial
        ;WITH ultimo AS (
            SELECT id_pais, pbi_per_capita,
                   ROW_NUMBER() OVER (PARTITION BY id_pais ORDER BY anio DESC) AS rn
            FROM Participantes.Historial_pbi_pais
            WHERE id_pais IN (SELECT id_pais FROM #pbi WHERE estado IN ('Insertado', 'Actualizado'))
        )
        UPDATE P
        SET pbi_per_capita = U.pbi_per_capita
        FROM Participantes.Pais P
        INNER JOIN ultimo U ON U.id_pais = P.id_pais AND U.rn = 1;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @total, 'Fallido');

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;

    PRINT CONCAT('Banco Mundial: ', @total, ' registros (país y año), ', @insertados, ' insertados en el historial, ',
                 @actualizados, ' actualizados, ', @sin_dato, ' sin dato, ', @omitidos, ' omitidos, ',
                 @duplicados, ' duplicados y ', @con_error, ' con error.');

    SELECT nro, estado, codigo_iso, nombre, anio_txt AS anio, valor, ISNULL(mensaje_error, '') AS detalle
    FROM #pbi
    WHERE estado <> 'Omitido'
    ORDER BY CASE WHEN estado IN ('Insertado', 'Actualizado') THEN 1 ELSE 0 END, codigo_iso, anio DESC;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Actualizar_Husos_Horarios
-- Descripción: Completa el huso horario de las sedes (con sus coordenadas, de Nominatim) y de los países
--              (con las coordenadas de referencia del país, de mledoze/countries) consultando la API timeapi.io.
--              Como el torneo se juega en junio y julio, a los lugares del hemisferio norte que usan horario de
--              verano se les suma 1 hora al huso estándar (en el hemisferio sur es invierno y no se aplica).
--              Recorre los pendientes con un WHILE sobre una tabla numerada (sin cursores), 1 consulta por segundo.
--              Si una consulta falla, se informa y se sigue con el siguiente.
-- Parámetros: @incluir_sedes / @incluir_paises: qué completar.
--             @solo_paises_en_uso: 1 = solo los países que son mercado de una campaña o tienen selección.
--             @limite: cantidad máxima de consultas (NULL = todas).

CREATE OR ALTER PROCEDURE Torneo.Actualizar_Husos_Horarios
    @incluir_sedes BIT = 1,
    @incluir_paises BIT = 1,
    @solo_paises_en_uso BIT = 1,
    @limite INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @total INT;
    DECLARE @tipo VARCHAR(10);
    DECLARE @id INT;
    DECLARE @nombre VARCHAR(60);
    DECLARE @latitud DECIMAL(9,6);
    DECLARE @longitud DECIMAL(9,6);
    DECLARE @url VARCHAR(2000);
    DECLARE @respuesta NVARCHAR(MAX);
    DECLARE @segundos INT;
    DECLARE @usa_horario_verano NVARCHAR(10);
    DECLARE @huso VARCHAR(10);
    DECLARE @actualizados INT = 0;
    DECLARE @con_error INT = 0;

    CREATE TABLE #pendientes (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        tipo VARCHAR(10),
        id INT,
        nombre VARCHAR(60) COLLATE DATABASE_DEFAULT,
        latitud DECIMAL(9,6),
        longitud DECIMAL(9,6)
    );

    IF (@incluir_sedes = 1)
        INSERT INTO #pendientes (tipo, id, nombre, latitud, longitud)
        SELECT 'Sede', id_sede, nombre_estadio, latitud, longitud
        FROM Torneo.Sede
        WHERE huso_horario IS NULL AND latitud IS NOT NULL AND longitud IS NOT NULL
          AND NOT (latitud = 0 AND longitud = 0)
        ORDER BY id_sede;

    IF (@incluir_paises = 1)
        INSERT INTO #pendientes (tipo, id, nombre, latitud, longitud)
        SELECT 'País', P.id_pais, P.nombre, P.latitud_capital, P.longitud_capital
        FROM Participantes.Pais P
        WHERE P.huso_horario IS NULL AND P.latitud_capital IS NOT NULL AND P.longitud_capital IS NOT NULL
          AND (@solo_paises_en_uso = 0
               OR EXISTS (SELECT 1 FROM Publicidad.Mercado_interes_campania M WHERE M.id_pais = P.id_pais)
               OR EXISTS (SELECT 1 FROM Participantes.Seleccion S WHERE S.id_pais = P.id_pais))
        ORDER BY P.id_pais;

    SELECT @total = COUNT(*) FROM #pendientes;

    IF (@limite IS NOT NULL AND @limite < @total)
        SET @total = @limite;

    WHILE (@i <= @total)
    BEGIN
        SELECT @tipo = tipo, @id = id, @nombre = nombre, @latitud = latitud, @longitud = longitud
        FROM #pendientes
        WHERE nro = @i;

        SET @respuesta = NULL;
        SET @segundos = NULL;
        SET @huso = NULL;

        SET @url = 'https://timeapi.io/api/timezone/coordinate?latitude=' + CONVERT(VARCHAR(20), @latitud)
                 + '&longitude=' + CONVERT(VARCHAR(20), @longitud);

        BEGIN TRY
            EXEC Torneo.Consultar_API @url = @url, @respuesta = @respuesta OUTPUT;

            IF (ISJSON(@respuesta) > 0)
            BEGIN
                SET @segundos = TRY_CAST(JSON_VALUE(@respuesta, '$.standardUtcOffset.seconds') AS INT);
                IF (@segundos IS NULL)
                    SET @segundos = TRY_CAST(JSON_VALUE(@respuesta, '$.currentUtcOffset.seconds') AS INT);

                SET @usa_horario_verano = JSON_VALUE(@respuesta, '$.hasDayLightSaving');

                -- Horario de verano boreal durante el torneo (junio - julio)
                IF (@segundos IS NOT NULL AND @usa_horario_verano = 'true' AND @latitud > 0)
                    SET @segundos = @segundos + 3600;

                SET @huso = Torneo.fn_Huso_Desde_Segundos(@segundos);
            END

            IF (@huso IS NOT NULL)
            BEGIN
                IF (@tipo = 'Sede')
                    UPDATE Torneo.Sede SET huso_horario = @huso WHERE id_sede = @id;
                ELSE
                    UPDATE Participantes.Pais SET huso_horario = @huso WHERE id_pais = @id;

                SET @actualizados = @actualizados + 1;
                PRINT @tipo + ' ' + @nombre + ': ' + @huso;
            END
            ELSE
            BEGIN
                SET @con_error = @con_error + 1;
                PRINT @tipo + ' ' + @nombre + ': la API no devolvió un huso horario válido.';
            END
        END TRY
        BEGIN CATCH
            SET @con_error = @con_error + 1;
            PRINT @tipo + ' ' + @nombre + ': ' + ERROR_MESSAGE();
        END CATCH;

        WAITFOR DELAY '00:00:01';
        SET @i = @i + 1;
    END

    INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
    VALUES ('API timeapi.io - husos horarios', GETDATE(), @total, @con_error,
            CASE WHEN @total = 0 THEN 'Sin registros pendientes'
                 WHEN @con_error = 0 THEN 'Completado'
                 WHEN @actualizados = 0 THEN 'Sin registros válidos'
                 ELSE 'Completado con errores' END);

    PRINT CONCAT('timeapi.io: ', @total, ' consultas, ', @actualizados, ' husos actualizados y ', @con_error, ' con error.');
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Importar_XML_Mundial
-- Descripción: Importa el XML generado por el scraping de Wikipedia (scraping/scraper_mundial_2026.py), sin modificarlo.
--              1. Lee el archivo (OPENROWSET BULK; SQL dinámico porque la ruta no puede ir en una variable).
--              2. Upsert de fases y grupos que no existan.
--              3. Upsert de sedes (clave: estadio + ciudad) y sus ciudades. La capacidad que se guarda es la mayor
--                 entre la de la ficha del estadio y la asistencia máxima registrada (en el Mundial algunos estadios
--                 se reconfiguran). El huso horario es el de sus partidos; las coordenadas las completa Nominatim.
--              4. Upsert de selecciones (clave: país, buscado por código FIFA o ISO) con su grupo. Las nuevas quedan
--                 sin confederación (se carga después con Participantes.Modificacion_Seleccion).
--              5. Carga los partidos en Torneo.Staging_fixture y llama a Torneo.Importar_Fixture (Entrega 5), que
--                 valida cada partido, hace el upsert en Torneo.Partido y registra el resultado.
--              Importación parcial: sedes, selecciones o partidos inválidos se informan y no frenan al resto.
-- Validaciones: Ruta vacía, archivo inexistente o XML mal formado, estructura distinta a la esperada y, por registro,
--               datos faltantes, nombres demasiado largos, país inexistente, capacidad o huso inválidos y letra de grupo inválida.

CREATE OR ALTER PROCEDURE Torneo.Importar_XML_Mundial
    @nombre_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML;
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @MensajeError NVARCHAR(1000);
    DECLARE @fuente VARCHAR(255);
    DECLARE @total INT = 0, @con_error INT = 0;

    IF (@nombre_archivo IS NULL OR LTRIM(RTRIM(@nombre_archivo)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la ruta del archivo XML a importar. ', 1;
        RETURN;
    END

    SET @fuente = LEFT(LTRIM(RTRIM(@nombre_archivo)) + ' (sedes y selecciones)', 255);

    ------------------------------------------
    -- 1) Lectura del archivo
    SET @sql = N'SELECT @contenido = CAST(BulkColumn AS XML)
                 FROM OPENROWSET(BULK ''' + REPLACE(@nombre_archivo, '''', '''''') + N''', SINGLE_BLOB) AS archivo;';

    BEGIN TRY
        EXEC sp_executesql @sql, N'@contenido XML OUTPUT', @contenido = @xml OUTPUT;
    END TRY
    BEGIN CATCH
        SET @MensajeError = N'- Error al leer el archivo "' + @nombre_archivo + N'" (inexistente o XML mal formado): ' + ERROR_MESSAGE();
        ;THROW 50002, @MensajeError, 1;
    END CATCH;

    IF (@xml IS NULL OR @xml.exist('/mundial/partidos/partido') = 0)
    BEGIN
        ;THROW 50003, '- El archivo no tiene la estructura esperada (/mundial/partidos/partido). ', 1;
        RETURN;
    END

    ------------------------------------------
    -- Partidos del archivo en una tabla de trabajo (los métodos XML no se pueden usar en GROUP BY)
    CREATE TABLE #partidos_xml (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        fase NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        estadio NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        seleccion_local NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        seleccion_visitante NVARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        fecha_hora_local NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        fecha_hora_utc NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        goles_local NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        goles_visitante NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        asistencia NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #partidos_xml (fase, estadio, seleccion_local, seleccion_visitante, fecha_hora_local,
                               fecha_hora_utc, goles_local, goles_visitante, asistencia)
    SELECT
        LEFT(LTRIM(RTRIM(P.n.value('@fase', 'NVARCHAR(200)'))), 100),
        LEFT(LTRIM(RTRIM(P.n.value('(estadio/text())[1]', 'NVARCHAR(200)'))), 100),
        LEFT(ISNULL(P.n.value('(local/@codigo_fifa)[1]', 'NVARCHAR(100)'), P.n.value('(local/text())[1]', 'NVARCHAR(100)')), 100),
        LEFT(ISNULL(P.n.value('(visitante/@codigo_fifa)[1]', 'NVARCHAR(100)'), P.n.value('(visitante/text())[1]', 'NVARCHAR(100)')), 100),
        LEFT(P.n.value('(fecha_hora_local/text())[1]', 'NVARCHAR(100)'), 50),
        LEFT(P.n.value('(fecha_hora_utc/text())[1]', 'NVARCHAR(100)'), 50),
        LEFT(P.n.value('(goles_local/text())[1]', 'NVARCHAR(50)'), 10),
        LEFT(P.n.value('(goles_visitante/text())[1]', 'NVARCHAR(50)'), 10),
        LEFT(P.n.value('(asistencia/text())[1]', 'NVARCHAR(50)'), 20)
    FROM @xml.nodes('/mundial/partidos/partido') AS P(n);

    ------------------------------------------
    -- 2) Sedes del archivo
    CREATE TABLE #sedes (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        estadio NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        ciudad NVARCHAR(200) COLLATE DATABASE_DEFAULT NULL,
        pais_iso NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        capacidad_txt NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        huso NVARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
        capacidad INT NULL,
        asistencia_maxima INT NULL,
        id_pais INT NULL,
        id_ciudad INT NULL,
        id_sede INT NULL,
        mensaje_error VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #sedes (estadio, ciudad, pais_iso, capacidad_txt, huso)
    SELECT
        NULLIF(LTRIM(RTRIM(S.n.value('@estadio', 'NVARCHAR(200)'))), ''),
        NULLIF(LTRIM(RTRIM(S.n.value('@ciudad', 'NVARCHAR(200)'))), ''),
        NULLIF(LTRIM(RTRIM(S.n.value('@pais_iso', 'NVARCHAR(10)'))), ''),
        NULLIF(LTRIM(RTRIM(S.n.value('@capacidad', 'NVARCHAR(50)'))), ''),
        NULLIF(LTRIM(RTRIM(S.n.value('@huso_horario', 'NVARCHAR(20)'))), '')
    FROM @xml.nodes('/mundial/sedes/sede') AS S(n);

    -- Asistencia máxima de cada estadio según los partidos del archivo
    UPDATE S
    SET asistencia_maxima = A.maxima
    FROM #sedes S
    INNER JOIN (
        SELECT estadio, MAX(TRY_CAST(asistencia AS INT)) AS maxima
        FROM #partidos_xml
        GROUP BY estadio
    ) AS A ON A.estadio = S.estadio;

    UPDATE #sedes
    SET capacidad = (SELECT MAX(v) FROM (VALUES (TRY_CAST(capacidad_txt AS INT)), (asistencia_maxima)) AS valores(v));

    UPDATE S
    SET id_pais = P.id_pais
    FROM #sedes S
    INNER JOIN Participantes.Pais P ON P.codigo_iso = S.pais_iso;

    UPDATE S
    SET id_ciudad = C.id_ciudad
    FROM #sedes S
    INNER JOIN Participantes.Ciudad C ON C.id_pais = S.id_pais AND C.nombre = S.ciudad;

    UPDATE S
    SET id_sede = SE.id_sede
    FROM #sedes S
    INNER JOIN Torneo.Sede SE ON SE.id_ciudad = S.id_ciudad AND SE.nombre_estadio = S.estadio;

    UPDATE #sedes
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN estadio IS NULL THEN '- Falta el nombre del estadio. '
             WHEN LEN(estadio) > 30 THEN '- El nombre del estadio "' + estadio + '" supera los 30 caracteres. ' END,
        CASE WHEN ciudad IS NULL THEN '- Falta la ciudad. '
             WHEN LEN(ciudad) > 50 THEN '- El nombre de la ciudad supera los 50 caracteres. ' END,
        CASE WHEN pais_iso IS NULL THEN '- Falta el país. '
             WHEN id_pais IS NULL THEN '- No existe un país con código ISO "' + pais_iso + '". ' END,
        CASE WHEN capacidad_txt IS NOT NULL AND TRY_CAST(capacidad_txt AS INT) IS NULL THEN '- Capacidad inválida: "' + capacidad_txt + '". '
             WHEN id_sede IS NULL AND (capacidad IS NULL OR capacidad <= 0) THEN '- Sede nueva sin capacidad válida. ' END,
        CASE WHEN huso IS NOT NULL AND (LEN(huso) > 10 OR Torneo.fn_Offset_Huso_Minutos(huso) IS NULL)
             THEN '- Huso horario inválido: "' + huso + '". ' END
    ), '');

    UPDATE #sedes SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    ;WITH repetidos AS (
        SELECT estado, mensaje_error, ROW_NUMBER() OVER (PARTITION BY estadio, ciudad, id_pais ORDER BY nro DESC) AS rn
        FROM #sedes
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Duplicado', mensaje_error = '- Sede repetida en el archivo: se importa su última aparición. '
    WHERE rn > 1;

    UPDATE #sedes
    SET estado = CASE WHEN id_sede IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

    ------------------------------------------
    -- 3) Selecciones y grupos del archivo
    CREATE TABLE #selecciones (
        nro INT IDENTITY(1,1) PRIMARY KEY,
        letra NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        codigo NVARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        id_pais INT NULL,
        nombre_pais VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        id_seleccion INT NULL,
        mensaje_error VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #selecciones (letra, codigo)
    SELECT
        UPPER(NULLIF(LTRIM(RTRIM(G.n.value('@letra', 'NVARCHAR(10)'))), '')),
        UPPER(NULLIF(LTRIM(RTRIM(S.n.value('@codigo_fifa', 'NVARCHAR(10)'))), ''))
    FROM @xml.nodes('/mundial/grupos/grupo') AS G(n)
    CROSS APPLY G.n.nodes('seleccion') AS S(n);

    UPDATE SL
    SET id_pais = P.id_pais, nombre_pais = P.nombre
    FROM #selecciones SL
    CROSS APPLY (SELECT TOP 1 PA.id_pais, PA.nombre
                 FROM Participantes.Pais PA
                 WHERE SL.codigo IN (PA.codigo_fifa, PA.codigo_iso)
                 ORDER BY CASE WHEN PA.codigo_fifa = SL.codigo THEN 0 ELSE 1 END) AS P;

    UPDATE SL
    SET id_seleccion = SE.id_seleccion
    FROM #selecciones SL
    INNER JOIN Participantes.Seleccion SE ON SE.id_pais = SL.id_pais;

    UPDATE #selecciones
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN letra IS NULL OR letra NOT LIKE '[A-Z]' THEN '- Letra de grupo inválida. ' END,
        CASE WHEN codigo IS NULL THEN '- Falta el código de la selección. '
             WHEN id_pais IS NULL THEN '- No existe un país con código FIFA o ISO "' + codigo + '" (importar países con Participantes.Importar_API_Paises o cargarlo a mano). '
             WHEN id_seleccion IS NULL AND EXISTS (SELECT 1 FROM Participantes.Seleccion SE
                                                   WHERE SE.nombre_seleccion = LEFT('Selección de ' + nombre_pais, 50))
                  THEN '- Ya existe otra selección llamada "Selección de ' + nombre_pais + '". ' END
    ), '');

    UPDATE #selecciones SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    ;WITH repetidos AS (
        SELECT estado, mensaje_error, ROW_NUMBER() OVER (PARTITION BY id_pais ORDER BY nro DESC) AS rn
        FROM #selecciones
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Duplicado', mensaje_error = '- Selección repetida en el archivo: se toma su última aparición. '
    WHERE rn > 1;

    UPDATE #selecciones
    SET estado = CASE WHEN id_seleccion IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

    SELECT @total = (SELECT COUNT(*) FROM #sedes) + (SELECT COUNT(*) FROM #selecciones),
           @con_error = (SELECT COUNT(*) FROM #sedes WHERE estado IN ('Error', 'Duplicado'))
                      + (SELECT COUNT(*) FROM #selecciones WHERE estado IN ('Error', 'Duplicado'));

    ------------------------------------------
    -- 4) Upsert de fases, grupos, ciudades, sedes y selecciones (una transacción)
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @con_error,
                CASE WHEN @con_error = 0 THEN 'Completado'
                     WHEN @con_error = @total THEN 'Sin registros válidos'
                     ELSE 'Completado con errores' END);

        -- Fases
        INSERT INTO Torneo.Fase (nombre_fase)
        SELECT DISTINCT X.fase
        FROM #partidos_xml X
        WHERE X.fase IS NOT NULL AND X.fase <> '' AND LEN(X.fase) <= 30
          AND NOT EXISTS (SELECT 1 FROM Torneo.Fase FA WHERE FA.nombre_fase = X.fase);

        -- Grupos
        INSERT INTO Torneo.Grupo_torneo (nombre_grupo)
        SELECT DISTINCT letra
        FROM #selecciones
        WHERE estado IN ('Insertado', 'Actualizado')
          AND NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo G WHERE G.nombre_grupo = letra);

        -- Ciudades nuevas
        INSERT INTO Participantes.Ciudad (id_pais, nombre)
        SELECT DISTINCT id_pais, ciudad
        FROM #sedes
        WHERE estado = 'Insertado' AND id_ciudad IS NULL;

        UPDATE S
        SET id_ciudad = C.id_ciudad
        FROM #sedes S
        INNER JOIN Participantes.Ciudad C ON C.id_pais = S.id_pais AND C.nombre = S.ciudad
        WHERE S.estado = 'Insertado' AND S.id_ciudad IS NULL;

        -- Sedes existentes: capacidad (si la nueva es mayor) y huso horario
        UPDATE SE
        SET capacidad = CASE WHEN S.capacidad > SE.capacidad THEN S.capacidad ELSE SE.capacidad END,
            huso_horario = ISNULL(UPPER(S.huso), SE.huso_horario)
        FROM Torneo.Sede SE
        INNER JOIN #sedes S ON SE.id_sede = S.id_sede
        WHERE S.estado = 'Actualizado';

        -- Sedes nuevas (coordenadas pendientes para Nominatim)
        INSERT INTO Torneo.Sede (id_ciudad, nombre_estadio, capacidad, latitud, longitud, huso_horario)
        SELECT id_ciudad, estadio, capacidad, NULL, NULL, UPPER(huso)
        FROM #sedes
        WHERE estado = 'Insertado';

        -- Selecciones existentes: grupo
        UPDATE SE
        SET id_grupo = G.id_grupo
        FROM Participantes.Seleccion SE
        INNER JOIN #selecciones SL ON SE.id_seleccion = SL.id_seleccion
        INNER JOIN Torneo.Grupo_torneo G ON G.nombre_grupo = SL.letra
        WHERE SL.estado = 'Actualizado';

        -- Selecciones nuevas (sin confederación)
        INSERT INTO Participantes.Seleccion (nombre_seleccion, id_pais, id_confederacion, id_grupo)
        SELECT LEFT('Selección de ' + SL.nombre_pais, 50), SL.id_pais, NULL, G.id_grupo
        FROM #selecciones SL
        INNER JOIN Torneo.Grupo_torneo G ON G.nombre_grupo = SL.letra
        WHERE SL.estado = 'Insertado'
          AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion SE WHERE SE.nombre_seleccion = LEFT('Selección de ' + SL.nombre_pais, 50));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (@fuente, GETDATE(), @total, @total, 'Fallido');

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;

    -- Reporte de sedes y selecciones
    SELECT 'Sede' AS tipo, nro, estado, estadio AS dato, ciudad AS detalle_1, pais_iso AS detalle_2, ISNULL(mensaje_error, '') AS detalle
    FROM #sedes
    UNION ALL
    SELECT 'Selección', nro, estado, codigo, letra, nombre_pais, ISNULL(mensaje_error, '')
    FROM #selecciones
    ORDER BY tipo, nro;

    ------------------------------------------
    -- 5) Partidos: staging + SP de la Entrega 5
    INSERT INTO Torneo.Staging_fixture (fase, estadio, seleccion_local, seleccion_visitante, fecha_hora_local,
                                        fecha_hora_utc, goles_local, goles_visitante, asistencia)
    SELECT fase, estadio, seleccion_local, seleccion_visitante, fecha_hora_local,
           fecha_hora_utc, goles_local, goles_visitante, asistencia
    FROM #partidos_xml
    ORDER BY nro;

    EXEC Torneo.Importar_Fixture @nombre_archivo = @nombre_archivo;
END;
GO