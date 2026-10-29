-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de Stored Procedures de ABM --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
------  STORED PROCEDURES DE ALTA  -------
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