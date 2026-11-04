-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de Stored Procedures de Altas --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Moneda
-- Descripción: Da de alta una nueva moneda en el sistema.
-- Validaciones: Código distinto de 3 caracteres y Nombre vacío.

CREATE OR ALTER PROCEDURE Participantes.Alta_Moneda
    @codigo_moneda VARCHAR(10),
    @nombre_moneda VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(150) = ''; -- Acumula los errores encontrados

    -- Código distinto de 3 caracteres
    IF (@codigo_moneda IS NULL OR LEN(LTRIM(RTRIM(@codigo_moneda))) <> 3)
        SET @MensajeError = @MensajeError + '- El código de moneda debe tener exactamente 3 caracteres. ';
    
    -- Nombre vacío
    IF (@nombre_moneda IS NULL OR LTRIM(RTRIM(@nombre_moneda)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la moneda no puede estar vacío. ';

    -- Si MensajeError tiene texto es porque alguna validación falló
    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Moneda (codigo_moneda, nombre_moneda)
        VALUES (@codigo_moneda, @nombre_moneda);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Confederacion
-- Descripción: Da de alta una nueva conferderación en el sistema.
-- Validaciones: Nombre vacío.

CREATE OR ALTER PROCEDURE Participantes.Alta_Confederacion
    @nombre_confederacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Nombre vacío
    IF (@nombre_confederacion IS NULL OR LTRIM(RTRIM(@nombre_confederacion)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la confederación no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Confederacion (nombre_confederacion)
        VALUES (LTRIM(RTRIM(@nombre_confederacion)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Posicion
-- Descripción: Da de alta una nueva Posición de jugador en el sistema.
-- Validaciones: Nombre vacío

CREATE OR ALTER PROCEDURE Participantes.Alta_Posicion
    @nombre_posicion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre_posicion IS NULL OR LTRIM(RTRIM(@nombre_posicion)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la posición no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Posicion (nombre_posicion)
        VALUES (LTRIM(RTRIM(@nombre_posicion)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Categoria_arbitro
-- Descripción: Da de alta a una categoría de arbitro en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Participantes.Alta_Categoria_arbitro
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Descripción vacía
    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @MensajeError = @MensajeError + '- La descripción de la categoría no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Categoria_Arbitro (descripcion)
        VALUES (LTRIM(RTRIM(@descripcion)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Rol_arbitro
-- Descripción: Da de alta a un Rol de arbitro en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Participantes.Alta_Rol_arbitro
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Descripción vacía
    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del rol no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Rol_arbitro (descripcion)
        VALUES (LTRIM(RTRIM(@descripcion)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Idioma
-- Descripción: Da de alta un nuevo idioma en el sistema.
-- Validaciones: Nombre vacío

CREATE OR ALTER PROCEDURE Participantes.Alta_Idioma
    @nombre VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del idioma no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Idioma (nombre)
        VALUES (LTRIM(RTRIM(@nombre)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Grupo_Torneo
-- Descripción: Da de alta un nuevo grupo del torneo en el sistema.
-- Validaciones: Nombre vacío, Formato inválido.

CREATE OR ALTER PROCEDURE Torneo.Alta_Grupo_Torneo
    @nombre_grupo CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(100) = '';

    -- Nombre vacío
    IF (@nombre_grupo IS NULL OR LTRIM(RTRIM(@nombre_grupo)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del grupo no puede estar vacío. ';

    -- Formato inválido
    IF (@nombre_grupo NOT LIKE '[a-zA-Z]')
        SET @MensajeError = @MensajeError + '- El grupo debe ser una letra de la A a la Z. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Grupo_torneo(nombre_grupo)
        VALUES (UPPER(LTRIM(RTRIM(@nombre_grupo))));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Fase
-- Descripción: Da de alta una nueva fase del torneo en el sistema.
-- Validaciones: Nombre vacío.

CREATE OR ALTER PROCEDURE Torneo.Alta_Fase
    @nombre_fase VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre_fase IS NULL OR LTRIM(RTRIM(@nombre_fase)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la fase no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Fase (nombre_fase)
        VALUES (LTRIM(RTRIM(@nombre_fase)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Log_importacion
-- Descripción: Da de alta un registro de log de importación.
-- Validaciones: Textos vacíos, números negativos y fechas futuras.

CREATE OR ALTER PROCEDURE Torneo.Alta_Log_importacion
    @nombre_archivo_o_fuente VARCHAR(255),
    @fecha_hora_ejecucion DATETIME,
    @registros_procesados INT,
    @registros_con_error INT,
    @estado VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(200) = '';

    -- Textos vacíos
    IF (@nombre_archivo_o_fuente IS NULL OR LTRIM(RTRIM(@nombre_archivo_o_fuente)) = '')
        SET @MensajeError = @MensajeError + '- El archivo no puede estar vacío. ';

    IF (@estado IS NULL OR LTRIM(RTRIM(@estado)) = '')
        SET @MensajeError = @MensajeError + '- El estado no puede estar vacío. ';

    -- números negativos
    IF (@registros_procesados < 0 OR @registros_con_error < 0)
        SET @MensajeError = @MensajeError + '- Los registros no pueden ser negativos. ';

    -- fechas futuras
    IF (@fecha_hora_ejecucion > GETDATE())
        SET @MensajeError = @MensajeError + '- La fecha de ejecución no puede ser futura. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (
            nombre_archivo_o_fuente, 
            fecha_hora_ejecucion, 
            registros_procesados, 
            registros_con_error, 
            estado
        )
        VALUES (
            LTRIM(RTRIM(@nombre_archivo_o_fuente)), 
            @fecha_hora_ejecucion, 
            @registros_procesados, 
            @registros_con_error, 
            LTRIM(RTRIM(@estado))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Esquema_tactico
-- Descripción: Da de alta a un Esquema táctico en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Torneo.Alta_Esquema_tactico
    @descripcion_esquema VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Descripción vacía
    IF (@descripcion_esquema IS NULL OR LTRIM(RTRIM(@descripcion_esquema)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del esquema no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Esquema_tactico (descripcion_esquema)
        VALUES (LTRIM(RTRIM(@descripcion_esquema)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Tipo_gol
-- Descripción: Da de alta a un tipo de gol en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Torneo.Alta_Tipo_gol
    @descripcion_tipo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Descripción vacía
    IF (@descripcion_tipo IS NULL OR LTRIM(RTRIM(@descripcion_tipo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del tipo de gol no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Tipo_gol (descripcion_tipo)
        VALUES (LTRIM(RTRIM(@descripcion_tipo)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Periodo_partido
-- Descripción: Da de alta a un periodo del partido en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Torneo.Alta_Periodo_partido
    @descripcion_periodo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(70) = '';

    -- Descripción vacía
    IF (@descripcion_periodo IS NULL OR LTRIM(RTRIM(@descripcion_periodo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del periodo del partido no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Periodo_partido (descripcion_periodo)
        VALUES (LTRIM(RTRIM(@descripcion_periodo)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Tipo_tarjeta
-- Descripción: Da de alta a un tipo de tarjeta en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Torneo.Alta_Tipo_tarjeta
    @descripcion_tarjeta VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Descripción vacía
    IF (@descripcion_tarjeta IS NULL OR LTRIM(RTRIM(@descripcion_tarjeta)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del tipo de tarjeta no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Tipo_tarjeta (descripcion_tarjeta)
        VALUES (LTRIM(RTRIM(@descripcion_tarjeta)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Motivo_tarjeta
-- Descripción: Da de alta al motivo de una tarjeta en el sistema.
-- Validaciones: Descripción vacía

CREATE OR ALTER PROCEDURE Torneo.Alta_Motivo_tarjeta
    @descripcion_motivo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(70) = '';

    -- Descripción vacía
    IF (@descripcion_motivo IS NULL OR LTRIM(RTRIM(@descripcion_motivo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del motivo de tarjeta no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Motivo_tarjeta (descripcion_motivo)
        VALUES (LTRIM(RTRIM(@descripcion_motivo)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Franja_horaria_tarifa
-- Descripción: Da de alta una franja horaria publicitaria.
-- Validaciones: Descripción vacía y tarifa negativa.

CREATE OR ALTER PROCEDURE Publicidad.Alta_Franja_horaria_tarifa
    @descripcion_franja VARCHAR(50),
    @hora_inicio_local TIME(0),
    @hora_fin_local TIME(0),
    @tarifa_base_usd DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(100) = '';

    -- Descripción vacía
    IF (@descripcion_franja IS NULL OR LTRIM(RTRIM(@descripcion_franja)) = '')
        SET @MensajeError = @MensajeError + '- La descripción de la franja no puede estar vacía. ';

    -- Tarifa negativa
    IF (@tarifa_base_usd < 0)
        SET @MensajeError = @MensajeError + '- La tarifa base no puede ser negativa. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Franja_horaria_tarifa (
            descripcion_franja, 
            hora_inicio_local, 
            hora_fin_local, 
            tarifa_base_usd
        )
        VALUES (
            LTRIM(RTRIM(@descripcion_franja)), 
            @hora_inicio_local, 
            @hora_fin_local, 
            @tarifa_base_usd
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Cotizacion_moneda
-- Descripción: Da de alta la cotización histórica de una moneda.
-- Validaciones: Código vacío, valor negativo/cero, fecha futura.

CREATE OR ALTER PROCEDURE Participantes.Alta_Cotizacion_moneda
    @codigo_moneda CHAR(3),
    @fecha_cotizacion DATE,
    @valor_en_usd DECIMAL(10,4)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(150) = '';

    -- Código vacío
    IF (@codigo_moneda IS NULL OR LTRIM(RTRIM(@codigo_moneda)) = '')
        SET @MensajeError = @MensajeError + '- El código de moneda no puede estar vacío. ';

    -- Valor negativo/cero
    IF (@valor_en_usd <= 0)
        SET @MensajeError = @MensajeError + '- El valor en USD debe ser mayor a cero. ';

    -- Fecha futura
    IF (@fecha_cotizacion > CAST(GETDATE() AS DATE))
        SET @MensajeError = @MensajeError + '- La fecha de cotización no puede ser futura. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Cotizacion_moneda (
            codigo_moneda, 
            fecha_cotizacion, 
            valor_en_usd
        )
        VALUES (
            UPPER(LTRIM(RTRIM(@codigo_moneda))), 
            @fecha_cotizacion, 
            @valor_en_usd
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Pais
-- Descripción: Da de alta un nuevo país en el sistema.
-- Validaciones: Nombre vacío, ISO distinto de 3 letras, PBI negativo y formato de huso horario.

CREATE OR ALTER PROCEDURE Participantes.Alta_Pais
    @codigo_moneda CHAR(3),
    @nombre VARCHAR(50),
    @codigo_iso CHAR(3),
    @pbi_per_capita DECIMAL(18,2),
    @huso_horario VARCHAR(10) = NULL -- Opcional (ej: 'UTC-3'). Se usa para calcular el prime time del mercado.
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del país no puede estar vacío. ';
    
    -- ISO distinto de 3 letras
    IF (@codigo_iso IS NULL OR LEN(LTRIM(RTRIM(@codigo_iso))) <> 3)
        SET @MensajeError = @MensajeError + '- El código ISO debe tener exactamente 3 caracteres. ';
    
    -- PBI negativo
    IF (@pbi_per_capita < 0)
        SET @MensajeError = @MensajeError + '- El PBI per cápita no puede ser negativo. ';

    -- Formato de huso horario
    IF (@huso_horario IS NOT NULL AND Torneo.fn_Offset_Huso_Minutos(@huso_horario) IS NULL)
        SET @MensajeError = @MensajeError + '- El huso horario debe tener el formato UTC±H o UTC±H:MM (ej: UTC-3). ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Pais (codigo_moneda, nombre, codigo_iso, pbi_per_capita, huso_horario)
        VALUES (
            UPPER(LTRIM(RTRIM(@codigo_moneda))), 
            LTRIM(RTRIM(@nombre)), 
            UPPER(LTRIM(RTRIM(@codigo_iso))), 
            @pbi_per_capita,
            UPPER(REPLACE(LTRIM(RTRIM(@huso_horario)), ' ', ''))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Parametros_suspension
-- Descripción: Da de alta un parámetro de suspensión en el sistema.
-- Validaciones: Fechas suspension roja y fechas suspension doble amarilla igual a 0.

CREATE OR ALTER PROCEDURE Torneo.Alta_Parametros_suspension
    @id_fase_limpieza_amarillas INT,
    @fechas_suspension_roja_directa TINYINT,
    @fechas_suspension_doble_amarilla TINYINT,
    @activo bit,
    @cantidad_amarillas_suspension TINYINT = 2 -- Opcional: amarillas acumuladas que generan suspensión
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- Roja directa
    IF (@fechas_suspension_roja_directa = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión por roja directa tiene que ser mayor a 0. ';
    
    -- Doble amarilla
    IF (@fechas_suspension_doble_amarilla = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión por doble amarilla tiene que ser mayor a 0. ';

    -- Amarillas acumuladas
    IF (@cantidad_amarillas_suspension IS NULL OR @cantidad_amarillas_suspension = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de amarillas acumuladas para suspender tiene que ser mayor a 0. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Parametros_suspension (id_fase_limpieza_amarillas, fechas_suspension_roja_directa, fechas_suspension_doble_amarilla, cantidad_amarillas_suspension, activo)
        VALUES (
            @id_fase_limpieza_amarillas,
            @fechas_suspension_roja_directa,
            @fechas_suspension_doble_amarilla,
            @cantidad_amarillas_suspension,
            @activo
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Feriado_pais
-- Descripción: Da de alta una fecha feriado de un país en el sistema.
-- Validaciones: Transformación a NULL de cadenas vacías.

CREATE OR ALTER PROCEDURE Participantes.Alta_Feriado_pais
    @id_pais INT,
    @fecha DATE,
    @descripcion_feriado VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Feriado_pais (id_pais, fecha, descripcion_feriado)
        VALUES (
            @id_pais,
            @fecha,
            NULLIF(LTRIM(RTRIM(@descripcion_feriado)), '')
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Ciudad
-- Descripción: Da de alta una nueva ciudad en el sistema.
-- Validaciones: Nombre vacío. 
CREATE OR ALTER PROCEDURE Participantes.Alta_Ciudad
    @id_pais INT,
    @nombre VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = '- El nombre de la ciudad no puede estar vacío.';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Ciudad (id_pais, nombre)
        VALUES (
            @id_pais,
            LTRIM(RTRIM(@nombre))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Club_origen
-- Descripción: Da de alta un club en el sistema.
-- Validaciones: Nombre vacío. 
CREATE OR ALTER PROCEDURE Participantes.Alta_Club_origen
    @nombre VARCHAR(50),
    @id_pais_club INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = '- El nombre del club no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Club_origen (nombre, id_pais_club)
        VALUES (
            LTRIM(RTRIM(@nombre)),
            @id_pais_club
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Arbitro
-- Descripción: Da de alta un árbitro en el sistema.
-- Validaciones: Nombre y Apellido vacíos y que sea mayor de 18 años.

CREATE OR ALTER PROCEDURE Participantes.Alta_Arbitro
    @id_pais INT,
    @id_categoria INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @fecha_nacimiento DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(120) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre no puede estar vacío. ';

    -- Apellido vacío
    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido no puede estar vacío. ';

    -- Fecha futura y mayor de edad
    IF (DATEDIFF(YEAR, @fecha_nacimiento, GETDATE()) < 18)
        SET @MensajeError = @MensajeError + '- El árbitro debe ser mayor de 18 años. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Arbitro (id_pais, id_categoria, nombre, apellido, fecha_nacimiento)
        VALUES (
            @id_pais,
            @id_categoria,
            LTRIM(RTRIM(@nombre)),
            LTRIM(RTRIM(@apellido)),
            @fecha_nacimiento
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Seleccion
-- Descripción: Da de alta una selección en el sistema.
-- Validaciones: Nombre vacío.

CREATE OR ALTER PROCEDURE Participantes.Alta_Seleccion
    @nombre_seleccion VARCHAR(50),
    @id_pais INT,
    @id_confederacion INT,
    @id_grupo INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';

    -- Nombre vacío
    IF (@nombre_seleccion IS NULL OR LTRIM(RTRIM(@nombre_seleccion)) = '')
        SET @MensajeError = '- El nombre de la selección no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Seleccion (nombre_seleccion, id_pais, id_confederacion, id_grupo)
        VALUES (
            LTRIM(RTRIM(@nombre_seleccion)),
            @id_pais,
            @id_confederacion,
            @id_grupo
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Idioma_arbitro
-- Descripción: Asocia un idioma a un árbitro.
-- Validaciones: Ninguna.

CREATE OR ALTER PROCEDURE Participantes.Alta_Idioma_arbitro
    @id_arbitro INT,
    @id_idioma INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Idioma_arbitro (id_arbitro, id_idioma)
        VALUES (@id_arbitro, @id_idioma);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Anunciante
-- Descripción: Da de alta un anunciante en el sistema.
-- Validaciones: Nombre vacío, identificación fiscal vacía. 

CREATE OR ALTER PROCEDURE Publicidad.Alta_Anunciante
    @nombre_anunciante VARCHAR(50),
    @id_pais_origen INT,
    @identificacion_fiscal VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(100) = '';

    -- Nombre vacío
    IF (@nombre_anunciante IS NULL OR LTRIM(RTRIM(@nombre_anunciante)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del anunciante no puede estar vacío. ';

    -- Identificación fiscal vacía
    IF (@identificacion_fiscal IS NULL OR LTRIM(RTRIM(@identificacion_fiscal)) = '')
        SET @MensajeError = @MensajeError + '- La identificación fiscal no puede estar vacía. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Anunciante (nombre_anunciante, id_pais_origen, identificacion_fiscal)
        VALUES (
            LTRIM(RTRIM(@nombre_anunciante)),
            @id_pais_origen,
            LTRIM(RTRIM(@identificacion_fiscal))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Sede
-- Descripción: Da de alta un estadio/sede en el sistema.
-- Validaciones: Nombre vacío, huso horario vacío, capacidad inválida y coordenadas válidas.

CREATE OR ALTER PROCEDURE Torneo.Alta_Sede
    @id_ciudad INT,
    @nombre_estadio VARCHAR(30),
    @capacidad INT,
    @latitud DECIMAL(9, 6),
    @longitud DECIMAL(9, 6),
    @huso_horario VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(210) = '';

    -- Nombre vacío
    IF (@nombre_estadio IS NULL OR LTRIM(RTRIM(@nombre_estadio)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del estadio no puede estar vacío. ';

    -- Huso horario vacío.
    IF (@huso_horario IS NULL OR LTRIM(RTRIM(@huso_horario)) = '')
        SET @MensajeError = @MensajeError + '- El huso horario no puede estar vacío. ';

    -- Capacidad mayor a cero
    IF (@capacidad <= 0)
        SET @MensajeError = @MensajeError + '- La capacidad debe ser mayor a cero. ';

    -- Validación de coordenadas
    IF (@latitud < -90.0 OR @latitud > 90.0)
        SET @MensajeError = @MensajeError + '- La latitud debe estar entre -90 y 90. ';

    IF (@longitud < -180.0 OR @longitud > 180.0)
        SET @MensajeError = @MensajeError + '- La longitud debe estar entre -180 y 180. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Sede (id_ciudad, nombre_estadio, capacidad, latitud, longitud, huso_horario)
        VALUES (
            @id_ciudad,
            LTRIM(RTRIM(@nombre_estadio)),
            @capacidad,
            @latitud,
            @longitud,
            LTRIM(RTRIM(@huso_horario))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Jugador
-- Descripción: Da de alta un jugador en el sistema.
-- Validaciones: Nombre vacío, apellido vacío y edad mínima (15 años).

CREATE OR ALTER PROCEDURE Participantes.Alta_Jugador
    @nombre VARCHAR(30),
    @apellido VARCHAR(30),
    @fecha_nacimiento DATE,
    @id_pais_nacimiento INT,
    @id_posicion_habitual INT,
    @id_club_origen INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(140) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del jugador no puede estar vacío. ';

    -- Apellido vacío
    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido del jugador no puede estar vacío. ';

    -- Edad mínimo 15 años
    IF (DATEDIFF(YEAR, @fecha_nacimiento, GETDATE()) < 15)
        SET @MensajeError = @MensajeError + '- El jugador debe tener al menos 15 años. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Jugador (
            nombre, 
            apellido, 
            fecha_nacimiento, 
            id_pais_nacimiento, 
            id_posicion_habitual, 
            id_club_origen
        )
        VALUES (
            LTRIM(RTRIM(@nombre)),
            LTRIM(RTRIM(@apellido)),
            @fecha_nacimiento,
            @id_pais_nacimiento,
            @id_posicion_habitual,
            @id_club_origen
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Integrante_cuerpo_tecnico
-- Descripción: Da de alta un integrante del cuerpo técnico de una selección.
-- Validaciones: Nombre, apellido y cargo vacíos.

CREATE OR ALTER PROCEDURE Participantes.Alta_Integrante_cuerpo_tecnico
    @id_seleccion INT,
    @nombre VARCHAR(30),
    @apellido VARCHAR(30),
    @cargo_rol VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(110) = '';

    -- Nombre vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre no puede estar vacío. ';

    -- Apellido vacío
    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido no puede estar vacío. ';

    -- Cargo vacío
    IF (@cargo_rol IS NULL OR LTRIM(RTRIM(@cargo_rol)) = '')
        SET @MensajeError = @MensajeError + '- El cargo o rol no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Integrante_cuerpo_tecnico (id_seleccion, nombre, apellido, cargo_rol)
        VALUES (
            @id_seleccion,
            LTRIM(RTRIM(@nombre)),
            LTRIM(RTRIM(@apellido)),
            LTRIM(RTRIM(@cargo_rol))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Alta_Convocatoria
-- Descripción: Registra la convocatoria de un jugador a una selección.
-- Validaciones: Estado vacío, fecha futura y dorsal fuera de rango.

CREATE OR ALTER PROCEDURE Participantes.Alta_Convocatoria
    @id_seleccion INT,
    @id_jugador INT,
    @estado_convocatoria VARCHAR(30),
    @fecha_alta_convocatoria DATE,
    @dorsal TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(140) = '';

    -- Estado vacío
    IF (@estado_convocatoria IS NULL OR LTRIM(RTRIM(@estado_convocatoria)) = '')
        SET @MensajeError = @MensajeError + '- El estado de la convocatoria no puede estar vacío. ';

    -- Fecha futura
    IF (@fecha_alta_convocatoria > GETDATE())
        SET @MensajeError = @MensajeError + '- La fecha de convocatoria no puede ser futura. ';

    -- Dorsal fuera de rango
    IF (@dorsal < 1 OR @dorsal > 26)
        SET @MensajeError = @MensajeError + '- El dorsal debe estar entre 1 y 26. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Convocatoria (
            id_seleccion, 
            id_jugador, 
            estado_convocatoria, 
            fecha_alta_convocatoria, 
            dorsal
        )
        VALUES (
            @id_seleccion,
            @id_jugador,
            LTRIM(RTRIM(@estado_convocatoria)),
            @fecha_alta_convocatoria,
            @dorsal
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Campania_publicitaria
-- Descripción: Da de alta una campaña publicitaria.
-- Validaciones: Nombre vacío.

CREATE OR ALTER PROCEDURE Publicidad.Alta_Campania_publicitaria
    @id_anunciante INT,
    @nombre_campania VARCHAR(100),
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @presupuesto DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(50) = '';

    -- Nombre vacío
    IF (@nombre_campania IS NULL OR LTRIM(RTRIM(@nombre_campania)) = '')
        SET @MensajeError = '- El nombre de la campaña no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Campania_publicitaria (
            id_anunciante, 
            nombre_campania, 
            fecha_inicio, 
            fecha_fin, 
            presupuesto
        )
        VALUES (
            @id_anunciante,
            LTRIM(RTRIM(@nombre_campania)),
            @fecha_inicio,
            @fecha_fin,
            @presupuesto
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Partido
-- Descripción: Da de alta un partido en el sistema.
-- Validaciones: Asistencia no negativa y no mayor a la capacidad de la sede.

CREATE OR ALTER PROCEDURE Torneo.Alta_Partido
    @id_sede INT,
    @id_fase INT,
    @id_seleccion_local INT,
    @id_seleccion_visitante INT,
    @id_importacion_origen INT,
    @fecha_hora_local DATETIME,
    @asistencia_publico INT,
    @goles_local TINYINT,
    @goles_visitante TINYINT,
    @UTC DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(110) = '';
    DECLARE @capacidad_sede INT;

    -- Aistencia no negativa
    IF (@asistencia_publico IS NOT NULL AND @asistencia_publico < 0)
        SET @MensajeError = @MensajeError + '- La asistencia de público no puede ser negativa. ';

    -- Asistencia no mayor a la capacidad de la sede
    IF (@asistencia_publico IS NOT NULL AND @asistencia_publico > 0)
    BEGIN
        SELECT @capacidad_sede = capacidad 
        FROM Torneo.Sede 
        WHERE id_sede = @id_sede;

        IF (@capacidad_sede IS NOT NULL AND @asistencia_publico > @capacidad_sede)
            SET @MensajeError = @MensajeError + '- La asistencia supera la capacidad máxima del estadio. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Partido (
            id_sede, 
            id_fase, 
            id_seleccion_local, 
            id_seleccion_visitante, 
            id_importacion_origen, 
            fecha_hora_local, 
            asistencia_publico, 
            goles_local, 
            goles_visitante, 
            UTC
        )
        VALUES (
            @id_sede,
            @id_fase,
            @id_seleccion_local,
            @id_seleccion_visitante,
            @id_importacion_origen,
            @fecha_hora_local,
            @asistencia_publico,
            @goles_local,
            @goles_visitante,
            @UTC
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Mercado_interes_campania
-- Descripción: Asocia un mercado de interés a una campaña publicitaria.
-- Validaciones: Ninguna.

CREATE OR ALTER PROCEDURE Publicidad.Alta_Mercado_interes_campania
    @id_campania INT,
    @id_pais INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Mercado_interes_campania (id_campania, id_pais)
        VALUES (@id_campania, @id_pais);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Pieza_publicitaria
-- Descripción: Da de alta una pieza publicitaria para una campaña.
-- Validaciones: Nombre vacío, URL vacía y duración válida.

CREATE OR ALTER PROCEDURE Publicidad.Alta_Pieza_publicitaria
    @id_campania INT,
    @id_idioma INT,
    @nombre_pieza VARCHAR(50),
    @duracion_segundos SMALLINT,
    @url_contenido_media VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(140) = '';

    -- Nombre vacío
    IF (@nombre_pieza IS NULL OR LTRIM(RTRIM(@nombre_pieza)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la pieza no puede estar vacío. ';

    -- URL vacía
    IF (@url_contenido_media IS NULL OR LTRIM(RTRIM(@url_contenido_media)) = '')
        SET @MensajeError = @MensajeError + '- La URL del contenido no puede estar vacía. ';

    -- Duración válida.
    IF (@duracion_segundos <= 0)
        SET @MensajeError = @MensajeError + '- La duración debe ser mayor a cero segundos. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Pieza_publicitaria (
            id_campania, 
            id_idioma, 
            nombre_pieza, 
            duracion_segundos, 
            url_contenido_media
        )
        VALUES (
            @id_campania,
            @id_idioma,
            LTRIM(RTRIM(@nombre_pieza)),
            @duracion_segundos,
            LTRIM(RTRIM(@url_contenido_media))
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Alineacion_partido
-- Descripción: Da de alta la alineación de un equipo para un partido.
-- Validaciones: La selección debe participar en el partido.

CREATE OR ALTER PROCEDURE Torneo.Alta_Alineacion_partido
    @id_partido INT,
    @id_seleccion INT,
    @id_esquema_tactico INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(60) = '';
    DECLARE @es_participante INT = 0;

    -- Ver si la selección es local o visitante en ese partido
    SELECT @es_participante = 1
    FROM Torneo.Partido
    WHERE id_partido = @id_partido 
      AND (id_seleccion_local = @id_seleccion OR id_seleccion_visitante = @id_seleccion);

    -- La seleccion no es participante.
    IF (@es_participante = 0)
        SET @MensajeError = '- La selección indicada no participa en este partido. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Alineacion_partido (id_partido, id_seleccion, id_esquema_tactico)
        VALUES (@id_partido, @id_seleccion, @id_esquema_tactico);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Suspension_jugador
-- Descripción: Registra la suspensión de un jugador.
-- Validaciones: Fechas de sanción mayor a 0, participación en el partido de origen, y partido sanción posterior al de origen.
CREATE OR ALTER PROCEDURE Torneo.Alta_Suspension_jugador
    @id_convocatoria INT,
    @id_partido_origen INT,
    @id_partido_sancion INT, -- Puede ser NULL
    @cantidad_fechas TINYINT,
    @sancion_cumplida BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(210) = '';
    
    DECLARE @id_seleccion_jugador INT;
    DECLARE @id_local_origen INT, @id_visitante_origen INT;
    DECLARE @fecha_origen DATETIME, @fecha_sancion DATETIME;

    -- fechas mayor a 0
    IF (@cantidad_fechas = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión debe ser mayor a cero. ';

    SELECT @id_seleccion_jugador = id_seleccion 
    FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria;

    SELECT 
        @id_local_origen = id_seleccion_local, 
        @id_visitante_origen = id_seleccion_visitante,
        @fecha_origen = fecha_hora_local
    FROM Torneo.Partido WHERE id_partido = @id_partido_origen;

    -- El jugador tiene que ser del partido de origen
    IF (@id_seleccion_jugador IS NOT NULL AND @id_local_origen IS NOT NULL 
        AND @id_seleccion_jugador NOT IN (@id_local_origen, @id_visitante_origen))
    BEGIN
        SET @MensajeError = @MensajeError + '- El jugador suspendido no pertenece a los equipos del partido de origen. ';
    END

    -- Cronología
    IF (@id_partido_sancion IS NOT NULL)
    BEGIN
        SELECT @fecha_sancion = fecha_hora_local 
        FROM Torneo.Partido WHERE id_partido = @id_partido_sancion;

        IF (@fecha_sancion IS NOT NULL AND @fecha_origen IS NOT NULL AND @fecha_sancion <= @fecha_origen)
        BEGIN
            SET @MensajeError = @MensajeError + '- El partido de sanción debe jugarse después del partido de origen. ';
        END
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Suspension_jugador (
            id_convocatoria, 
            id_partido_origen, 
            id_partido_sancion, 
            cantidad_fechas, 
            sancion_cumplida
        )
        VALUES (
            @id_convocatoria,
            @id_partido_origen,
            @id_partido_sancion,
            @cantidad_fechas,
            @sancion_cumplida
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Alta_Exhibicion_publicidad_partido
-- Descripción: Registra la exhibición de una pieza publicitaria durante un partido.
-- Validaciones: Numero espacio dentro de rango, tarifa negativa, hora del anuncio debe coincidir con la franja horaria, tarifa abajo de la base.

CREATE OR ALTER PROCEDURE Publicidad.Alta_Exhibicion_publicidad_partido
    @id_partido INT,
    @numero_espacio TINYINT,
    @id_pieza INT,
    @tarifa_aplicada_usd DECIMAL(18,2),
    @id_franja INT,
    @fecha_hora_exhibicion DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(250) = '';
    
    DECLARE @hora_inicio TIME;
    DECLARE @hora_fin TIME;
    DECLARE @tarifa_base DECIMAL(18,2);
    DECLARE @hora_exhibicion TIME = CAST(@fecha_hora_exhibicion AS TIME);

    -- numero dentro de rango
    IF (@numero_espacio < 1 OR @numero_espacio > 4)
        SET @MensajeError = @MensajeError + '- El número de espacio debe estar entre 1 y 4. ';

    -- tarifa negativa
    IF (@tarifa_aplicada_usd < 0)
        SET @MensajeError = @MensajeError + '- La tarifa aplicada no puede ser negativa. ';

    -- Datos de franja horaria
    SELECT 
        @hora_inicio = hora_inicio_local,
        @hora_fin = hora_fin_local,
        @tarifa_base = tarifa_base_usd
    FROM Publicidad.Franja_horaria_tarifa
    WHERE id_franja = @id_franja;

    -- hora del anuncio debe coincidir con la franja horaria
    IF (@hora_inicio IS NOT NULL AND @hora_fin IS NOT NULL)
    BEGIN
        IF (@hora_exhibicion < @hora_inicio OR @hora_exhibicion > @hora_fin)
            SET @MensajeError = @MensajeError + '- La hora de exhibición no corresponde a los horarios de la franja indicada. ';
    END

    -- tarifa abajo de la base
    IF (@tarifa_base IS NOT NULL AND @tarifa_aplicada_usd < @tarifa_base)
    BEGIN
        SET @MensajeError = @MensajeError + '- La tarifa aplicada no puede ser menor a la tarifa base de la franja horaria. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Publicidad.Exhibicion_publicidad_partido (
            id_partido, 
            numero_espacio, 
            id_pieza, 
            tarifa_aplicada_usd, 
            id_franja, 
            fecha_hora_exhibicion
        )
        VALUES (
            @id_partido,
            @numero_espacio,
            @id_pieza,
            @tarifa_aplicada_usd,
            @id_franja,
            @fecha_hora_exhibicion
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Alta_Informe_post_partido
-- Descripción: Registra el informe de desempeño de un árbitro tras un partido.
-- Validaciones: Calificación fuera de rango y el partido ya debe haberse jugado.

CREATE OR ALTER PROCEDURE Torneo.Alta_Informe_post_partido
    @id_partido INT,
    @id_arbitro INT,
    @calificacion_desempenio TINYINT,
    @observaciones VARCHAR(255),
    @sancion_aplicada VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(140) = '';
    DECLARE @fecha_partido DATETIME;

    -- Calificación fuera de rango
    IF (@calificacion_desempenio < 1 OR @calificacion_desempenio > 10)
        SET @MensajeError = @MensajeError + '- La calificación de desempeño debe estar entre 1 y 10. ';

    -- El partido ya debe haberse jugado
    SELECT @fecha_partido = fecha_hora_local 
    FROM Torneo.Partido 
    WHERE id_partido = @id_partido;

    IF (@fecha_partido IS NOT NULL AND @fecha_partido > GETDATE())
        SET @MensajeError = @MensajeError + '- No se puede registrar un informe para un partido que aún no se ha jugado. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Informe_post_partido (
            id_partido, 
            id_arbitro, 
            calificacion_desempenio, 
            observaciones, 
            sancion_aplicada
        )
        VALUES (
            @id_partido,
            @id_arbitro,
            @calificacion_desempenio,
            NULLIF(LTRIM(RTRIM(@observaciones)), ''),
            NULLIF(LTRIM(RTRIM(@sancion_aplicada)), '')
        );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO