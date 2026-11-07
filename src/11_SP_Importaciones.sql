-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270

-- Importaciones (parte 1): dataset CSV de estadios y API de geolocalización --
-- DATASETS ELEGIDOS:
-- repositorio worldcup (github.com/jfjelstul/worldcup) - Formato: CSV - archivo data-csv/stadiums.csv
--
-- APIs ELEGIDAS:
--
-- API de NOMINATIM
--- Geolocalización de Estadios (Latitud y Longitud)
--- Es un servicio de OpenStreetMap.
--- https://nominatim.openstreetmap.org/search
--- Rate Limit: 1 petición HTTP por segundo por dirección IP.
--- Autenticación: API pública, no requiere API Key.
--- Pide un HTTP Referer o User-Agent válido que identifique la aplicación.
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
--              Lo usan todos los procesos que consumen APIs (Nominatim, REST Countries, Banco Mundial, timeapi.io).
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
