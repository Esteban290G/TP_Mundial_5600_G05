-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270

-- Importaciones --
-- DATASETS ELEGIDOS:
-- github.com/jfjelstul/worldcup - Formato: CSV 
--
-- APIs ELEGIDAS:
-- API del Banco Mundial
-- 
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------

-- github.com/jfjelstul/worldcup - Formato: CSV 

CREATE OR ALTER PROCEDURE Torneo.Importar_CSV_Stadiums
    @nombre_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    TRUNCATE TABLE Torneo.Staging_stadiums;

    DECLARE @sql NVARCHAR(MAX);
    
    SET @sql = N'BULK INSERT Torneo.vw_Staging_stadiums
                 FROM ''' + @nombre_archivo + '''
                 WITH (
                     FORMAT = ''CSV'',            -- Interpreta comillas y formato CSV nativo (SQL 2017+)
                     FIELDTERMINATOR = '','',
                     ROWTERMINATOR = ''0x0a'',   -- Salto de línea de GitHub (Linux)
                     CODEPAGE = ''65001'',       -- Soporte para UTF-8 (acentos y ñ)
                     FIRSTROW = 2
                 )';
                 
    BEGIN TRY
        EXEC sp_executesql @sql;
        DECLARE @FilasInsertadas INT = (SELECT COUNT(*) FROM Torneo.Staging_stadiums);
        PRINT 'Lectura del CSV finalizada. Registros listos para procesar: ' + CAST(@FilasInsertadas AS VARCHAR(10));;
    END TRY
    BEGIN CATCH
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        PRINT 'Error al leer el archivo: ' + @Msg;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Procesar_CSV_Stadiums
-- Descripción: Procesa los registros en estado 'Pendiente' de la tabla Stadiums.
--              Realiza validaciones, busca el id_ciudad y ejecuta un Upsert en Torneo.Sede.
--              Asigna valores por defecto a latitud, longitud y huso_horario (no están en el CSV).
------------------------------------------
CREATE OR ALTER PROCEDURE Torneo.Procesar_CSV_Stadiums
    @nombre_archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_log INT;
    DECLARE @total INT = 0, @insertados INT = 0, @actualizados INT = 0, @con_error INT = 0, @duplicados INT = 0;
    DECLARE @estado_log VARCHAR(50);

    -- Verificar si hay filas pendientes
    IF NOT EXISTS (SELECT 1 FROM Torneo.Staging_stadiums WHERE estado_proceso = 'Pendiente')
    BEGIN
        PRINT 'No hay filas pendientes de procesar en Torneo.Staging_stadiums.';
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
        NULLIF(LTRIM(RTRIM(stadium_capacity)), '')
    FROM Torneo.Staging_stadiums
    WHERE estado_proceso = 'Pendiente';

    SELECT @total = COUNT(*) FROM #filas;

    ------------------------------------------
    -- Claves y conversión de tipos
    
    -- Buscar id_pais por nombre
    UPDATE F
    SET id_pais = P.id_pais
    FROM #filas F
    INNER JOIN Participantes.Pais P ON P.nombre = F.country_name_txt;

    -- Buscar id_ciudad por nombre y país
    UPDATE F
    SET id_ciudad = C.id_ciudad
    FROM #filas F
    INNER JOIN Participantes.Ciudad C ON C.nombre = F.city_name_txt AND C.id_pais = F.id_pais;

    -- Convertir capacidad a número
    UPDATE #filas
    SET capacidad = TRY_CAST(capacity_txt AS INT);

    -- Identificar si la sede ya existe
    UPDATE F
    SET id_sede_existente = S.id_sede
    FROM #filas F
    INNER JOIN Torneo.Sede S ON S.nombre_estadio = F.stadium_name_txt AND S.id_ciudad = F.id_ciudad;

    ------------------------------------------
    -- Validaciones por fila
    UPDATE F
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN F.stadium_name_txt IS NULL THEN '- Falta el nombre del estadio. ' END,
        CASE WHEN F.country_name_txt IS NULL THEN '- Falta el país. ' 
             WHEN F.id_pais IS NULL THEN '- El país "' + F.country_name_txt + '" no existe en la base. ' END,
        CASE WHEN F.city_name_txt IS NULL THEN '- Falta la ciudad. ' 
             WHEN F.id_pais IS NOT NULL AND F.id_ciudad IS NULL THEN '- La ciudad "' + F.city_name_txt + '" no existe para ese país. ' END,
        CASE WHEN F.capacity_txt IS NOT NULL AND (F.capacidad IS NULL OR F.capacidad <= 0) THEN '- Capacidad inválida: "' + F.capacity_txt + '". ' END
    ), '')
    FROM #filas F;

    -- Errores y duplicados
    UPDATE #filas SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    -- Manejo de duplicados dentro del archivo CSV
    ;WITH repetidos AS (
        SELECT estado, mensaje_error,
               ROW_NUMBER() OVER (PARTITION BY stadium_name_txt, id_ciudad ORDER BY id_fila DESC) AS rn
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

    -- Log
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
    -- Upsert y registro en Log_importacion
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Registrar en log
        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados, registros_con_error, estado)
        VALUES (LTRIM(RTRIM(@nombre_archivo)), GETDATE(), @total, @con_error + @duplicados, @estado_log);
        
        SET @id_log = SCOPE_IDENTITY();

        --Actualizar estadios existentes
        UPDATE S
        SET capacidad = ISNULL(F.capacidad, S.capacidad)
        FROM Torneo.Sede S
        INNER JOIN #filas F ON S.id_sede = F.id_sede_existente
        WHERE F.estado = 'Actualizado';

        -- 0.0 y 'UTC' para campos faltantes
        INSERT INTO Torneo.Sede (id_ciudad, nombre_estadio, capacidad, latitud, longitud, huso_horario)
        SELECT id_ciudad, stadium_name_txt, capacidad, 0.0, 0.0, 'UTC'
        FROM #filas
        WHERE estado = 'Insertado';

        -- Actualizar la tabla Stadiums con el resultado
        UPDATE STD
        SET estado_proceso = F.estado,
            mensaje_error = F.mensaje_error,
            id_log = @id_log
        FROM Torneo.Staging_stadiums STD
        INNER JOIN #filas F ON STD.id_fila = F.id_fila;

        COMMIT TRANSACTION;
        
        PRINT CONCAT('Importación procesada: ', @insertados, ' insertadas, ', @actualizados, ' actualizadas, ', @con_error, ' con error.');
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
END;
GO

------------------------------------------

-- API del Banco Mundial

-- codigo 

--========================================

--

-- codigo

------------------------------------------

-- 

-- codigo 
