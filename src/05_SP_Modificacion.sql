-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de Stored Procedures de Modificación --
-- Criterio general: el registro se identifica por su clave primaria. En los SP con varios
-- campos, los parámetros que se envían en NULL conservan el valor actual del registro y,
-- en los campos de texto opcionales, enviar una cadena vacía los deja en NULL.
-- Todas las validaciones se acumulan en un único mensaje por ejecución.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Procedimiento: Participantes.Modificacion_Confederacion
-- Descripción: Modifica el nombre de la confederación (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Confederacion
    @id_confederacion INT,
    @nombre_confederacion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE id_confederacion = @id_confederacion)
        SET @MensajeError = @MensajeError + '- La confederación que intenta modificar no existe. ';

    -- Texto vacío
    IF (@nombre_confederacion IS NULL OR LTRIM(RTRIM(@nombre_confederacion)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la confederación no puede estar vacío. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = LTRIM(RTRIM(@nombre_confederacion)) AND id_confederacion <> @id_confederacion)
        SET @MensajeError = @MensajeError + '- Ya existe otra confederación con ese nombre. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Confederacion
        SET nombre_confederacion = LTRIM(RTRIM(@nombre_confederacion))
        WHERE id_confederacion = @id_confederacion;

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
-- Procedimiento: Participantes.Modificacion_Posicion
-- Descripción: Modifica el nombre de la posición (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Posicion
    @id_posicion INT,
    @nombre_posicion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE id_posicion = @id_posicion)
        SET @MensajeError = @MensajeError + '- La posición que intenta modificar no existe. ';

    -- Texto vacío
    IF (@nombre_posicion IS NULL OR LTRIM(RTRIM(@nombre_posicion)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la posición no puede estar vacío. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = LTRIM(RTRIM(@nombre_posicion)) AND id_posicion <> @id_posicion)
        SET @MensajeError = @MensajeError + '- Ya existe otra posición con ese nombre. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Posicion
        SET nombre_posicion = LTRIM(RTRIM(@nombre_posicion))
        WHERE id_posicion = @id_posicion;

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
-- Procedimiento: Participantes.Modificacion_Categoria_arbitro
-- Descripción: Modifica la descripción de la categoría (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Categoria_arbitro
    @id_categoria INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE id_categoria = @id_categoria)
        SET @MensajeError = @MensajeError + '- La categoría de árbitro que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @MensajeError = @MensajeError + '- La descripción de la categoría no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_categoria <> @id_categoria)
        SET @MensajeError = @MensajeError + '- Ya existe otra categoría con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Categoria_arbitro
        SET descripcion = LTRIM(RTRIM(@descripcion))
        WHERE id_categoria = @id_categoria;

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
-- Procedimiento: Participantes.Modificacion_Rol_arbitro
-- Descripción: Modifica la descripción del rol (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Rol_arbitro
    @id_rol_arbitro INT,
    @descripcion VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE id_rol_arbitro = @id_rol_arbitro)
        SET @MensajeError = @MensajeError + '- El rol de árbitro que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del rol no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_rol_arbitro <> @id_rol_arbitro)
        SET @MensajeError = @MensajeError + '- Ya existe otro rol con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Rol_arbitro
        SET descripcion = LTRIM(RTRIM(@descripcion))
        WHERE id_rol_arbitro = @id_rol_arbitro;

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
-- Procedimiento: Participantes.Modificacion_Idioma
-- Descripción: Modifica el nombre del idioma (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Idioma
    @id_idioma INT,
    @nombre VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE id_idioma = @id_idioma)
        SET @MensajeError = @MensajeError + '- El idioma que intenta modificar no existe. ';

    -- Texto vacío
    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del idioma no puede estar vacío. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_idioma <> @id_idioma)
        SET @MensajeError = @MensajeError + '- Ya existe otro idioma con ese nombre. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Idioma
        SET nombre = LTRIM(RTRIM(@nombre))
        WHERE id_idioma = @id_idioma;

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
-- Procedimiento: Torneo.Modificacion_Fase
-- Descripción: Modifica el nombre de la fase (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Fase
    @id_fase INT,
    @nombre_fase VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase)
        SET @MensajeError = @MensajeError + '- La fase que intenta modificar no existe. ';

    -- Texto vacío
    IF (@nombre_fase IS NULL OR LTRIM(RTRIM(@nombre_fase)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la fase no puede estar vacío. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = LTRIM(RTRIM(@nombre_fase)) AND id_fase <> @id_fase)
        SET @MensajeError = @MensajeError + '- Ya existe otra fase con ese nombre. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Fase
        SET nombre_fase = LTRIM(RTRIM(@nombre_fase))
        WHERE id_fase = @id_fase;

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
-- Procedimiento: Torneo.Modificacion_Tipo_gol
-- Descripción: Modifica la descripción del tipo de gol (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Tipo_gol
    @id_tipo INT,
    @descripcion_tipo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE id_tipo = @id_tipo)
        SET @MensajeError = @MensajeError + '- El tipo de gol que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion_tipo IS NULL OR LTRIM(RTRIM(@descripcion_tipo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del tipo de gol no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = LTRIM(RTRIM(@descripcion_tipo)) AND id_tipo <> @id_tipo)
        SET @MensajeError = @MensajeError + '- Ya existe otro tipo de gol con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Tipo_gol
        SET descripcion_tipo = LTRIM(RTRIM(@descripcion_tipo))
        WHERE id_tipo = @id_tipo;

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
-- Procedimiento: Torneo.Modificacion_Periodo_partido
-- Descripción: Modifica la descripción del periodo (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Periodo_partido
    @id_periodo_partido INT,
    @descripcion_periodo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE id_periodo_partido = @id_periodo_partido)
        SET @MensajeError = @MensajeError + '- El periodo de partido que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion_periodo IS NULL OR LTRIM(RTRIM(@descripcion_periodo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del periodo no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE descripcion_periodo = LTRIM(RTRIM(@descripcion_periodo)) AND id_periodo_partido <> @id_periodo_partido)
        SET @MensajeError = @MensajeError + '- Ya existe otro periodo con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Periodo_partido
        SET descripcion_periodo = LTRIM(RTRIM(@descripcion_periodo))
        WHERE id_periodo_partido = @id_periodo_partido;

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
-- Procedimiento: Torneo.Modificacion_Tipo_tarjeta
-- Descripción: Modifica la descripción del tipo de tarjeta (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Tipo_tarjeta
    @id_tipo_tarjeta INT,
    @descripcion_tarjeta VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @id_tipo_tarjeta)
        SET @MensajeError = @MensajeError + '- El tipo de tarjeta que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion_tarjeta IS NULL OR LTRIM(RTRIM(@descripcion_tarjeta)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del tipo de tarjeta no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = LTRIM(RTRIM(@descripcion_tarjeta)) AND id_tipo_tarjeta <> @id_tipo_tarjeta)
        SET @MensajeError = @MensajeError + '- Ya existe otro tipo de tarjeta con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Tipo_tarjeta
        SET descripcion_tarjeta = LTRIM(RTRIM(@descripcion_tarjeta))
        WHERE id_tipo_tarjeta = @id_tipo_tarjeta;

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
-- Procedimiento: Torneo.Modificacion_Motivo_tarjeta
-- Descripción: Modifica la descripción del motivo (registro identificado por su id).
-- Validaciones: El registro debe existir, texto vacío y nombre duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Motivo_tarjeta
    @id_motivo INT,
    @descripcion_motivo VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE id_motivo = @id_motivo)
        SET @MensajeError = @MensajeError + '- El motivo de tarjeta que intenta modificar no existe. ';

    -- Texto vacío
    IF (@descripcion_motivo IS NULL OR LTRIM(RTRIM(@descripcion_motivo)) = '')
        SET @MensajeError = @MensajeError + '- La descripción del motivo no puede estar vacía. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = LTRIM(RTRIM(@descripcion_motivo)) AND id_motivo <> @id_motivo)
        SET @MensajeError = @MensajeError + '- Ya existe otro motivo con esa descripción. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Motivo_tarjeta
        SET descripcion_motivo = LTRIM(RTRIM(@descripcion_motivo))
        WHERE id_motivo = @id_motivo;

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
-- Procedimiento: Participantes.Modificacion_Moneda
-- Descripción: Modifica el nombre de una moneda. El código (PK) no se modifica porque lo referencian países y cotizaciones.
-- Validaciones: El registro debe existir y nombre vacío.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Moneda
    @codigo_moneda CHAR(3),
    @nombre_moneda VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = @codigo_moneda)
        SET @MensajeError = @MensajeError + '- La moneda que intenta modificar no existe. ';

    -- Nombre vacío
    IF (@nombre_moneda IS NULL OR LTRIM(RTRIM(@nombre_moneda)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la moneda no puede estar vacío. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Moneda
        SET nombre_moneda = LTRIM(RTRIM(@nombre_moneda))
        WHERE codigo_moneda = @codigo_moneda;

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
-- Procedimiento: Torneo.Modificacion_Grupo_Torneo
-- Descripción: Modifica la letra de un grupo del torneo.
-- Validaciones: El registro debe existir, nombre vacío, formato (una letra) y grupo duplicado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Grupo_Torneo
    @id_grupo INT,
    @nombre_grupo CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE id_grupo = @id_grupo)
        SET @MensajeError = @MensajeError + '- El grupo que intenta modificar no existe. ';

    -- Nombre vacío
    IF (@nombre_grupo IS NULL OR LTRIM(RTRIM(@nombre_grupo)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del grupo no puede estar vacío. ';

    -- Formato inválido
    ELSE IF (@nombre_grupo NOT LIKE '[a-zA-Z]')
        SET @MensajeError = @MensajeError + '- El grupo debe ser una letra de la A a la Z. ';

    -- Duplicado
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = UPPER(@nombre_grupo) AND id_grupo <> @id_grupo)
        SET @MensajeError = @MensajeError + '- Ya existe otro grupo con esa letra. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Grupo_torneo
        SET nombre_grupo = UPPER(LTRIM(RTRIM(@nombre_grupo)))
        WHERE id_grupo = @id_grupo;

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
-- Procedimiento: Torneo.Modificacion_Esquema_tactico
-- Descripción: Modifica la descripción de un esquema táctico (ej: 4-3-3).
-- Validaciones: El registro debe existir, descripción vacía, formato (números separados por guiones
--               que sumen 10 jugadores de campo) y descripción duplicada.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Esquema_tactico
    @id_esquema_tactico INT,
    @descripcion_esquema VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';
    DECLARE @descripcion VARCHAR(30) = LTRIM(RTRIM(@descripcion_esquema));
    DECLARE @suma_jugadores INT;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE id_esquema_tactico = @id_esquema_tactico)
        SET @MensajeError = @MensajeError + '- El esquema táctico que intenta modificar no existe. ';

    -- Descripción vacía
    IF (@descripcion IS NULL OR @descripcion = '')
        SET @MensajeError = @MensajeError + '- La descripción del esquema no puede estar vacía. ';
    ELSE
    BEGIN
        -- Formato: solo dígitos y guiones, sin guiones al inicio/fin ni dobles
        IF (@descripcion LIKE '%[^0-9-]%' OR @descripcion LIKE '-%' OR @descripcion LIKE '%-' OR @descripcion LIKE '%--%' OR CHARINDEX('-', @descripcion) = 0)
            SET @MensajeError = @MensajeError + '- El esquema debe tener el formato de números separados por guiones (ej: 4-4-2). ';
        ELSE
        BEGIN
            -- Los números deben sumar 10 (jugadores de campo, sin contar al arquero)
            SELECT @suma_jugadores = SUM(CAST(value AS INT))
            FROM STRING_SPLIT(@descripcion, '-');

            IF (@suma_jugadores <> 10)
                SET @MensajeError = @MensajeError + '- Los números del esquema deben sumar 10 jugadores de campo. ';
        END

        -- Duplicado
        IF EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = @descripcion AND id_esquema_tactico <> @id_esquema_tactico)
            SET @MensajeError = @MensajeError + '- Ya existe otro esquema táctico con esa descripción. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Esquema_tactico
        SET descripcion_esquema = @descripcion
        WHERE id_esquema_tactico = @id_esquema_tactico;

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
-- Procedimiento: Torneo.Modificacion_Log_importacion
-- Descripción: Modifica un registro del log de importación (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, textos vacíos, números negativos,
--               fecha futura y errores mayores a los registros procesados.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Log_importacion
    @id_log INT,
    @nombre_archivo_o_fuente VARCHAR(255) = NULL,
    @fecha_hora_ejecucion DATETIME = NULL,
    @registros_procesados INT = NULL,
    @registros_con_error INT = NULL,
    @estado VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @procesados_final INT;
    DECLARE @errores_final INT;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Log_importacion WHERE id_log = @id_log)
        SET @MensajeError = @MensajeError + '- El registro de importación que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@nombre_archivo_o_fuente IS NULL AND @fecha_hora_ejecucion IS NULL AND @registros_procesados IS NULL
        AND @registros_con_error IS NULL AND @estado IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Textos vacíos
    IF (@nombre_archivo_o_fuente IS NOT NULL AND LTRIM(RTRIM(@nombre_archivo_o_fuente)) = '')
        SET @MensajeError = @MensajeError + '- El archivo no puede estar vacío. ';

    IF (@estado IS NOT NULL AND LTRIM(RTRIM(@estado)) = '')
        SET @MensajeError = @MensajeError + '- El estado no puede estar vacío. ';

    -- Números negativos
    IF (@registros_procesados < 0 OR @registros_con_error < 0)
        SET @MensajeError = @MensajeError + '- Los registros no pueden ser negativos. ';

    -- Fecha futura
    IF (@fecha_hora_ejecucion > GETDATE())
        SET @MensajeError = @MensajeError + '- La fecha de ejecución no puede ser futura. ';

    -- Los registros con error no pueden superar a los procesados (con los valores finales)
    SELECT
        @procesados_final = ISNULL(@registros_procesados, registros_procesados),
        @errores_final = ISNULL(@registros_con_error, registros_con_error)
    FROM Torneo.Log_importacion
    WHERE id_log = @id_log;

    IF (@errores_final > @procesados_final)
        SET @MensajeError = @MensajeError + '- Los registros con error no pueden superar a los registros procesados. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Log_importacion
        SET nombre_archivo_o_fuente = ISNULL(LTRIM(RTRIM(@nombre_archivo_o_fuente)), nombre_archivo_o_fuente),
            fecha_hora_ejecucion = ISNULL(@fecha_hora_ejecucion, fecha_hora_ejecucion),
            registros_procesados = ISNULL(@registros_procesados, registros_procesados),
            registros_con_error = ISNULL(@registros_con_error, registros_con_error),
            estado = ISNULL(LTRIM(RTRIM(@estado)), estado)
        WHERE id_log = @id_log;

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
-- Procedimiento: Publicidad.Modificacion_Franja_horaria_tarifa
-- Descripción: Modifica una franja horaria publicitaria (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, descripción vacía o duplicada,
--               tarifa negativa y hora de inicio posterior a la de fin.

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Franja_horaria_tarifa
    @id_franja INT,
    @descripcion_franja VARCHAR(50) = NULL,
    @hora_inicio_local TIME(0) = NULL,
    @hora_fin_local TIME(0) = NULL,
    @tarifa_base_usd DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @inicio_final TIME(0);
    DECLARE @fin_final TIME(0);

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE id_franja = @id_franja)
        SET @MensajeError = @MensajeError + '- La franja horaria que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@descripcion_franja IS NULL AND @hora_inicio_local IS NULL AND @hora_fin_local IS NULL AND @tarifa_base_usd IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Descripción vacía o duplicada
    IF (@descripcion_franja IS NOT NULL AND LTRIM(RTRIM(@descripcion_franja)) = '')
        SET @MensajeError = @MensajeError + '- La descripción de la franja no puede estar vacía. ';
    ELSE IF EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa
                    WHERE descripcion_franja = LTRIM(RTRIM(@descripcion_franja)) AND id_franja <> @id_franja)
        SET @MensajeError = @MensajeError + '- Ya existe otra franja con esa descripción. ';

    -- Tarifa negativa
    IF (@tarifa_base_usd < 0)
        SET @MensajeError = @MensajeError + '- La tarifa base no puede ser negativa. ';

    -- Hora de inicio anterior a la de fin (con los valores finales)
    SELECT
        @inicio_final = ISNULL(@hora_inicio_local, hora_inicio_local),
        @fin_final = ISNULL(@hora_fin_local, hora_fin_local)
    FROM Publicidad.Franja_horaria_tarifa
    WHERE id_franja = @id_franja;

    IF (@inicio_final >= @fin_final)
        SET @MensajeError = @MensajeError + '- La hora de inicio de la franja debe ser anterior a la hora de fin. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Franja_horaria_tarifa
        SET descripcion_franja = ISNULL(LTRIM(RTRIM(@descripcion_franja)), descripcion_franja),
            hora_inicio_local = ISNULL(@hora_inicio_local, hora_inicio_local),
            hora_fin_local = ISNULL(@hora_fin_local, hora_fin_local),
            tarifa_base_usd = ISNULL(@tarifa_base_usd, tarifa_base_usd)
        WHERE id_franja = @id_franja;

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
-- Procedimiento: Participantes.Modificacion_Cotizacion_moneda
-- Descripción: Modifica la fecha o el valor de una cotización (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, valor mayor a cero, fecha futura
--               y cotización duplicada para la misma moneda y fecha.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Cotizacion_moneda
    @id_cotizacion INT,
    @fecha_cotizacion DATE = NULL,
    @valor_en_usd DECIMAL(10,4) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @codigo_moneda CHAR(3);

    SELECT @codigo_moneda = codigo_moneda
    FROM Participantes.Cotizacion_moneda
    WHERE id_cotizacion = @id_cotizacion;

    -- El registro debe existir
    IF (@codigo_moneda IS NULL)
        SET @MensajeError = @MensajeError + '- La cotización que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@fecha_cotizacion IS NULL AND @valor_en_usd IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Valor negativo o cero
    IF (@valor_en_usd <= 0)
        SET @MensajeError = @MensajeError + '- El valor en USD debe ser mayor a cero. ';

    -- Fecha futura
    IF (@fecha_cotizacion > CAST(GETDATE() AS DATE))
        SET @MensajeError = @MensajeError + '- La fecha de cotización no puede ser futura. ';

    -- Duplicado: ya hay otra cotización de la misma moneda en esa fecha
    IF (@fecha_cotizacion IS NOT NULL AND EXISTS (SELECT 1 FROM Participantes.Cotizacion_moneda
                                                  WHERE codigo_moneda = @codigo_moneda
                                                    AND fecha_cotizacion = @fecha_cotizacion
                                                    AND id_cotizacion <> @id_cotizacion))
        SET @MensajeError = @MensajeError + '- Ya existe una cotización de esa moneda para la fecha indicada. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Cotizacion_moneda
        SET fecha_cotizacion = ISNULL(@fecha_cotizacion, fecha_cotizacion),
            valor_en_usd = ISNULL(@valor_en_usd, valor_en_usd)
        WHERE id_cotizacion = @id_cotizacion;

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
-- Procedimiento: Participantes.Modificacion_Pais
-- Descripción: Modifica los datos de un país (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre vacío, ISO distinto de 3 letras
--               o duplicado, PBI negativo, moneda inexistente y formato de huso horario.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Pais
    @id_pais INT,
    @codigo_moneda CHAR(3) = NULL,
    @nombre VARCHAR(50) = NULL,
    @codigo_iso CHAR(3) = NULL,
    @pbi_per_capita DECIMAL(18,2) = NULL,
    @huso_horario VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais)
        SET @MensajeError = @MensajeError + '- El país que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@codigo_moneda IS NULL AND @nombre IS NULL AND @codigo_iso IS NULL AND @pbi_per_capita IS NULL AND @huso_horario IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del país no puede estar vacío. ';

    -- ISO distinto de 3 letras o duplicado
    IF (@codigo_iso IS NOT NULL AND LEN(LTRIM(RTRIM(@codigo_iso))) <> 3)
        SET @MensajeError = @MensajeError + '- El código ISO debe tener exactamente 3 caracteres. ';
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Pais WHERE codigo_iso = UPPER(LTRIM(RTRIM(@codigo_iso))) AND id_pais <> @id_pais)
        SET @MensajeError = @MensajeError + '- Ya existe otro país con ese código ISO. ';

    -- PBI negativo
    IF (@pbi_per_capita < 0)
        SET @MensajeError = @MensajeError + '- El PBI per cápita no puede ser negativo. ';

    -- Moneda inexistente
    IF (@codigo_moneda IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = UPPER(LTRIM(RTRIM(@codigo_moneda)))))
        SET @MensajeError = @MensajeError + '- La moneda indicada no existe. ';

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

        UPDATE Participantes.Pais
        SET codigo_moneda = ISNULL(UPPER(LTRIM(RTRIM(@codigo_moneda))), codigo_moneda),
            nombre = ISNULL(LTRIM(RTRIM(@nombre)), nombre),
            codigo_iso = ISNULL(UPPER(LTRIM(RTRIM(@codigo_iso))), codigo_iso),
            pbi_per_capita = ISNULL(@pbi_per_capita, pbi_per_capita),
            huso_horario = ISNULL(UPPER(REPLACE(LTRIM(RTRIM(@huso_horario)), ' ', '')), huso_horario)
        WHERE id_pais = @id_pais;

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
-- Procedimiento: Torneo.Modificacion_Parametros_suspension
-- Descripción: Modifica los criterios de suspensión (los parámetros en NULL no se modifican).
--              Si el registro se marca como activo, el resto de los parámetros se desactiva
--              en la misma transacción, para que haya un único criterio vigente.
-- Validaciones: El registro debe existir, al menos un dato, fechas de suspensión y cantidad de amarillas mayores a 0 y fase existente.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Parametros_suspension
    @id_parametro INT,
    @id_fase_limpieza_amarillas INT = NULL,
    @fechas_suspension_roja_directa TINYINT = NULL,
    @fechas_suspension_doble_amarilla TINYINT = NULL,
    @activo BIT = NULL,
    @cantidad_amarillas_suspension TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Parametros_suspension WHERE id_parametro = @id_parametro)
        SET @MensajeError = @MensajeError + '- El parámetro de suspensión que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_fase_limpieza_amarillas IS NULL AND @fechas_suspension_roja_directa IS NULL
        AND @fechas_suspension_doble_amarilla IS NULL AND @activo IS NULL AND @cantidad_amarillas_suspension IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Roja directa
    IF (@fechas_suspension_roja_directa = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión por roja directa tiene que ser mayor a 0. ';

    -- Doble amarilla
    IF (@fechas_suspension_doble_amarilla = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión por doble amarilla tiene que ser mayor a 0. ';

    -- Amarillas acumuladas
    IF (@cantidad_amarillas_suspension = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de amarillas acumuladas para suspender tiene que ser mayor a 0. ';

    -- Fase existente
    IF (@id_fase_limpieza_amarillas IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase_limpieza_amarillas))
        SET @MensajeError = @MensajeError + '- La fase de limpieza de amarillas indicada no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Un único juego de parámetros activo
        IF (@activo = 1)
        BEGIN
            UPDATE Torneo.Parametros_suspension
            SET activo = 0
            WHERE id_parametro <> @id_parametro AND activo = 1;
        END

        UPDATE Torneo.Parametros_suspension
        SET id_fase_limpieza_amarillas = ISNULL(@id_fase_limpieza_amarillas, id_fase_limpieza_amarillas),
            fechas_suspension_roja_directa = ISNULL(@fechas_suspension_roja_directa, fechas_suspension_roja_directa),
            fechas_suspension_doble_amarilla = ISNULL(@fechas_suspension_doble_amarilla, fechas_suspension_doble_amarilla),
            cantidad_amarillas_suspension = ISNULL(@cantidad_amarillas_suspension, cantidad_amarillas_suspension),
            activo = ISNULL(@activo, activo)
        WHERE id_parametro = @id_parametro;

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
-- Procedimiento: Participantes.Modificacion_Feriado_pais
-- Descripción: Modifica la fecha o la descripción de un feriado (NULL no modifica; '' deja la descripción en NULL).
-- Validaciones: El registro debe existir, al menos un dato y feriado duplicado para el mismo país y fecha.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Feriado_pais
    @id_feriado INT,
    @fecha DATE = NULL,
    @descripcion_feriado VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_pais INT;

    SELECT @id_pais = id_pais FROM Participantes.Feriado_pais WHERE id_feriado = @id_feriado;

    -- El registro debe existir
    IF (@id_pais IS NULL)
        SET @MensajeError = @MensajeError + '- El feriado que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@fecha IS NULL AND @descripcion_feriado IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Duplicado
    IF (@fecha IS NOT NULL AND EXISTS (SELECT 1 FROM Participantes.Feriado_pais
                                      WHERE id_pais = @id_pais AND fecha = @fecha AND id_feriado <> @id_feriado))
        SET @MensajeError = @MensajeError + '- El país ya tiene registrado un feriado en esa fecha. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Feriado_pais
        SET fecha = ISNULL(@fecha, fecha),
            descripcion_feriado = CASE WHEN @descripcion_feriado IS NULL THEN descripcion_feriado
                                       ELSE NULLIF(LTRIM(RTRIM(@descripcion_feriado)), '') END
        WHERE id_feriado = @id_feriado;

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
-- Procedimiento: Participantes.Modificacion_Ciudad
-- Descripción: Modifica el nombre o el país de una ciudad (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre vacío, país inexistente
--               y ciudad duplicada en el mismo país.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Ciudad
    @id_ciudad INT,
    @id_pais INT = NULL,
    @nombre VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_pais_final INT;
    DECLARE @nombre_final VARCHAR(50);

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Ciudad WHERE id_ciudad = @id_ciudad)
        SET @MensajeError = @MensajeError + '- La ciudad que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_pais IS NULL AND @nombre IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la ciudad no puede estar vacío. ';

    -- País inexistente
    IF (@id_pais IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    -- Duplicado (con los valores finales)
    SELECT
        @id_pais_final = ISNULL(@id_pais, id_pais),
        @nombre_final = ISNULL(LTRIM(RTRIM(@nombre)), nombre)
    FROM Participantes.Ciudad
    WHERE id_ciudad = @id_ciudad;

    IF EXISTS (SELECT 1 FROM Participantes.Ciudad WHERE id_pais = @id_pais_final AND nombre = @nombre_final AND id_ciudad <> @id_ciudad)
        SET @MensajeError = @MensajeError + '- Ya existe una ciudad con ese nombre en el país indicado. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Ciudad
        SET id_pais = @id_pais_final,
            nombre = @nombre_final
        WHERE id_ciudad = @id_ciudad;

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
-- Procedimiento: Participantes.Modificacion_Club_origen
-- Descripción: Modifica el nombre o el país de un club (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre vacío, país inexistente
--               y club duplicado en el mismo país.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Club_origen
    @id_club INT,
    @nombre VARCHAR(50) = NULL,
    @id_pais_club INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_pais_final INT;
    DECLARE @nombre_final VARCHAR(50);

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Club_origen WHERE id_club = @id_club)
        SET @MensajeError = @MensajeError + '- El club que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@nombre IS NULL AND @id_pais_club IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del club no puede estar vacío. ';

    -- País inexistente
    IF (@id_pais_club IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais_club))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    -- Duplicado (con los valores finales)
    SELECT
        @id_pais_final = ISNULL(@id_pais_club, id_pais_club),
        @nombre_final = ISNULL(LTRIM(RTRIM(@nombre)), nombre)
    FROM Participantes.Club_origen
    WHERE id_club = @id_club;

    IF EXISTS (SELECT 1 FROM Participantes.Club_origen WHERE id_pais_club = @id_pais_final AND nombre = @nombre_final AND id_club <> @id_club)
        SET @MensajeError = @MensajeError + '- Ya existe un club con ese nombre en el país indicado. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Club_origen
        SET nombre = @nombre_final,
            id_pais_club = @id_pais_final
        WHERE id_club = @id_club;

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
-- Procedimiento: Participantes.Modificacion_Arbitro
-- Descripción: Modifica los datos de un árbitro (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre y apellido vacíos, mayor de 18 años,
--               país y categoría existentes, y que el nuevo país no coincida con el de alguna selección
--               de los partidos en los que ya está designado (regla FIFA de neutralidad).

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Arbitro
    @id_arbitro INT,
    @id_pais INT = NULL,
    @id_categoria INT = NULL,
    @nombre VARCHAR(50) = NULL,
    @apellido VARCHAR(50) = NULL,
    @fecha_nacimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(700) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Arbitro WHERE id_arbitro = @id_arbitro)
        SET @MensajeError = @MensajeError + '- El árbitro que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_pais IS NULL AND @id_categoria IS NULL AND @nombre IS NULL AND @apellido IS NULL AND @fecha_nacimiento IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre y apellido vacíos
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre no puede estar vacío. ';

    IF (@apellido IS NOT NULL AND LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido no puede estar vacío. ';

    -- Mayor de 18 años (también descarta fechas futuras)
    IF (@fecha_nacimiento IS NOT NULL AND DATEDIFF(YEAR, @fecha_nacimiento, GETDATE()) < 18)
        SET @MensajeError = @MensajeError + '- El árbitro debe ser mayor de 18 años. ';

    -- País y categoría existentes
    IF (@id_pais IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    IF (@id_categoria IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE id_categoria = @id_categoria))
        SET @MensajeError = @MensajeError + '- La categoría indicada no existe. ';

    -- Neutralidad: el nuevo país no puede ser el de una selección de un partido donde ya está designado
    IF (@id_pais IS NOT NULL AND EXISTS (
            SELECT 1
            FROM Torneo.Designacion_arbitral D
            INNER JOIN Torneo.Partido P ON D.id_partido = P.id_partido
            INNER JOIN Participantes.Seleccion SL ON P.id_seleccion_local = SL.id_seleccion
            INNER JOIN Participantes.Seleccion SV ON P.id_seleccion_visitante = SV.id_seleccion
            WHERE D.id_arbitro = @id_arbitro
              AND @id_pais IN (SL.id_pais, SV.id_pais)))
        SET @MensajeError = @MensajeError + '- El árbitro está designado en un partido de una selección del país indicado; no puede cambiarse a esa nacionalidad. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Arbitro
        SET id_pais = ISNULL(@id_pais, id_pais),
            id_categoria = ISNULL(@id_categoria, id_categoria),
            nombre = ISNULL(LTRIM(RTRIM(@nombre)), nombre),
            apellido = ISNULL(LTRIM(RTRIM(@apellido)), apellido),
            fecha_nacimiento = ISNULL(@fecha_nacimiento, fecha_nacimiento)
        WHERE id_arbitro = @id_arbitro;

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
-- Procedimiento: Participantes.Modificacion_Seleccion
-- Descripción: Modifica los datos de una selección (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre vacío o duplicado, país, confederación
--               y grupo existentes, país ya asignado a otra selección y cambio de país con partidos ya cargados.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Seleccion
    @id_seleccion INT,
    @nombre_seleccion VARCHAR(50) = NULL,
    @id_pais INT = NULL,
    @id_confederacion INT = NULL,
    @id_grupo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(700) = '';
    DECLARE @id_pais_actual INT;

    SELECT @id_pais_actual = id_pais FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion;

    -- El registro debe existir
    IF (@id_pais_actual IS NULL)
        SET @MensajeError = @MensajeError + '- La selección que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@nombre_seleccion IS NULL AND @id_pais IS NULL AND @id_confederacion IS NULL AND @id_grupo IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío o duplicado
    IF (@nombre_seleccion IS NOT NULL AND LTRIM(RTRIM(@nombre_seleccion)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la selección no puede estar vacío. ';
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE nombre_seleccion = LTRIM(RTRIM(@nombre_seleccion)) AND id_seleccion <> @id_seleccion)
        SET @MensajeError = @MensajeError + '- Ya existe otra selección con ese nombre. ';

    -- Claves foráneas existentes
    IF (@id_pais IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    IF (@id_confederacion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE id_confederacion = @id_confederacion))
        SET @MensajeError = @MensajeError + '- La confederación indicada no existe. ';

    IF (@id_grupo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE id_grupo = @id_grupo))
        SET @MensajeError = @MensajeError + '- El grupo indicado no existe. ';

    -- Cambio de país
    IF (@id_pais IS NOT NULL AND @id_pais <> @id_pais_actual)
    BEGIN
        -- Un país solo puede tener una selección
        IF EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_pais = @id_pais AND id_seleccion <> @id_seleccion)
            SET @MensajeError = @MensajeError + '- El país indicado ya tiene otra selección registrada. ';

        -- Si ya jugó o tiene partidos programados, cambiar el país rompería las validaciones de árbitros y publicidad
        IF EXISTS (SELECT 1 FROM Torneo.Partido WHERE @id_seleccion IN (id_seleccion_local, id_seleccion_visitante))
            SET @MensajeError = @MensajeError + '- No se puede cambiar el país de una selección que ya tiene partidos registrados. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Seleccion
        SET nombre_seleccion = ISNULL(LTRIM(RTRIM(@nombre_seleccion)), nombre_seleccion),
            id_pais = ISNULL(@id_pais, id_pais),
            id_confederacion = ISNULL(@id_confederacion, id_confederacion),
            id_grupo = ISNULL(@id_grupo, id_grupo)
        WHERE id_seleccion = @id_seleccion;

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
-- Procedimiento: Participantes.Modificacion_Idioma_arbitro
-- Descripción: Reemplaza un idioma asociado a un árbitro por otro (la tabla solo tiene la clave compuesta).
-- Validaciones: La asociación debe existir, el nuevo idioma debe existir y no estar ya asociado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Idioma_arbitro
    @id_arbitro INT,
    @id_idioma INT,
    @id_idioma_nuevo INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- La asociación debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma_arbitro WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma)
        SET @MensajeError = @MensajeError + '- El árbitro no tiene asociado el idioma que intenta modificar. ';

    -- El nuevo idioma debe existir
    IF (@id_idioma_nuevo IS NULL OR NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE id_idioma = @id_idioma_nuevo))
        SET @MensajeError = @MensajeError + '- El nuevo idioma indicado no existe. ';

    -- No puede estar ya asociado
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Idioma_arbitro WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma_nuevo)
        SET @MensajeError = @MensajeError + '- El árbitro ya tiene asociado el nuevo idioma. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Idioma_arbitro
        SET id_idioma = @id_idioma_nuevo
        WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma;

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
-- Procedimiento: Publicidad.Modificacion_Anunciante
-- Descripción: Modifica los datos de un anunciante (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre e identificación fiscal vacíos
--               o duplicados y país existente.

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Anunciante
    @id_anunciante INT,
    @nombre_anunciante VARCHAR(50) = NULL,
    @id_pais_origen INT = NULL,
    @identificacion_fiscal VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE id_anunciante = @id_anunciante)
        SET @MensajeError = @MensajeError + '- El anunciante que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@nombre_anunciante IS NULL AND @id_pais_origen IS NULL AND @identificacion_fiscal IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío o duplicado
    IF (@nombre_anunciante IS NOT NULL AND LTRIM(RTRIM(@nombre_anunciante)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del anunciante no puede estar vacío. ';
    ELSE IF EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE nombre_anunciante = LTRIM(RTRIM(@nombre_anunciante)) AND id_anunciante <> @id_anunciante)
        SET @MensajeError = @MensajeError + '- Ya existe otro anunciante con ese nombre. ';

    -- Identificación fiscal vacía o duplicada
    IF (@identificacion_fiscal IS NOT NULL AND LTRIM(RTRIM(@identificacion_fiscal)) = '')
        SET @MensajeError = @MensajeError + '- La identificación fiscal no puede estar vacía. ';
    ELSE IF EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE identificacion_fiscal = LTRIM(RTRIM(@identificacion_fiscal)) AND id_anunciante <> @id_anunciante)
        SET @MensajeError = @MensajeError + '- Ya existe otro anunciante con esa identificación fiscal. ';

    -- País existente
    IF (@id_pais_origen IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais_origen))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Anunciante
        SET nombre_anunciante = ISNULL(LTRIM(RTRIM(@nombre_anunciante)), nombre_anunciante),
            id_pais_origen = ISNULL(@id_pais_origen, id_pais_origen),
            identificacion_fiscal = ISNULL(LTRIM(RTRIM(@identificacion_fiscal)), identificacion_fiscal)
        WHERE id_anunciante = @id_anunciante;

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
-- Procedimiento: Torneo.Modificacion_Sede
-- Descripción: Modifica los datos de una sede (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre y huso vacíos o con formato inválido,
--               capacidad mayor a cero y no menor a la asistencia ya registrada en sus partidos,
--               coordenadas válidas, ciudad existente y estadio duplicado en la ciudad.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Sede
    @id_sede INT,
    @id_ciudad INT = NULL,
    @nombre_estadio VARCHAR(30) = NULL,
    @capacidad INT = NULL,
    @latitud DECIMAL(9, 6) = NULL,
    @longitud DECIMAL(9, 6) = NULL,
    @huso_horario VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @id_ciudad_final INT;
    DECLARE @nombre_final VARCHAR(30);
    DECLARE @asistencia_maxima INT;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_sede = @id_sede)
        SET @MensajeError = @MensajeError + '- La sede que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_ciudad IS NULL AND @nombre_estadio IS NULL AND @capacidad IS NULL AND @latitud IS NULL
        AND @longitud IS NULL AND @huso_horario IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío
    IF (@nombre_estadio IS NOT NULL AND LTRIM(RTRIM(@nombre_estadio)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del estadio no puede estar vacío. ';

    -- Huso horario vacío o con formato inválido
    IF (@huso_horario IS NOT NULL AND LTRIM(RTRIM(@huso_horario)) = '')
        SET @MensajeError = @MensajeError + '- El huso horario no puede estar vacío. ';
    ELSE IF (@huso_horario IS NOT NULL AND Torneo.fn_Offset_Huso_Minutos(@huso_horario) IS NULL)
        SET @MensajeError = @MensajeError + '- El huso horario debe tener el formato UTC±H o UTC±H:MM (ej: UTC-3). ';

    -- Capacidad
    IF (@capacidad <= 0)
        SET @MensajeError = @MensajeError + '- La capacidad debe ser mayor a cero. ';
    ELSE IF (@capacidad IS NOT NULL)
    BEGIN
        SELECT @asistencia_maxima = MAX(asistencia_publico) FROM Torneo.Partido WHERE id_sede = @id_sede;

        IF (@asistencia_maxima > @capacidad)
            SET @MensajeError = @MensajeError + '- La nueva capacidad es menor a la asistencia ya registrada en un partido de la sede ('
                + CAST(@asistencia_maxima AS VARCHAR(10)) + '). ';
    END

    -- Coordenadas
    IF (@latitud < -90.0 OR @latitud > 90.0)
        SET @MensajeError = @MensajeError + '- La latitud debe estar entre -90 y 90. ';

    IF (@longitud < -180.0 OR @longitud > 180.0)
        SET @MensajeError = @MensajeError + '- La longitud debe estar entre -180 y 180. ';

    -- Ciudad existente
    IF (@id_ciudad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Ciudad WHERE id_ciudad = @id_ciudad))
        SET @MensajeError = @MensajeError + '- La ciudad indicada no existe. ';

    -- Estadio duplicado en la ciudad (con los valores finales)
    SELECT
        @id_ciudad_final = ISNULL(@id_ciudad, id_ciudad),
        @nombre_final = ISNULL(LTRIM(RTRIM(@nombre_estadio)), nombre_estadio)
    FROM Torneo.Sede
    WHERE id_sede = @id_sede;

    IF EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_ciudad = @id_ciudad_final AND nombre_estadio = @nombre_final AND id_sede <> @id_sede)
        SET @MensajeError = @MensajeError + '- Ya existe un estadio con ese nombre en la ciudad indicada. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Sede
        SET id_ciudad = @id_ciudad_final,
            nombre_estadio = @nombre_final,
            capacidad = ISNULL(@capacidad, capacidad),
            latitud = ISNULL(@latitud, latitud),
            longitud = ISNULL(@longitud, longitud),
            huso_horario = ISNULL(UPPER(REPLACE(LTRIM(RTRIM(@huso_horario)), ' ', '')), huso_horario)
        WHERE id_sede = @id_sede;

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
-- Procedimiento: Participantes.Modificacion_Jugador
-- Descripción: Modifica los datos personales de un jugador (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre y apellido vacíos, edad mínima (15 años)
--               y país, posición y club existentes.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Jugador
    @id_jugador INT,
    @nombre VARCHAR(30) = NULL,
    @apellido VARCHAR(30) = NULL,
    @fecha_nacimiento DATE = NULL,
    @id_pais_nacimiento INT = NULL,
    @id_posicion_habitual INT = NULL,
    @id_club_origen INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE id_jugador = @id_jugador)
        SET @MensajeError = @MensajeError + '- El jugador que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@nombre IS NULL AND @apellido IS NULL AND @fecha_nacimiento IS NULL AND @id_pais_nacimiento IS NULL
        AND @id_posicion_habitual IS NULL AND @id_club_origen IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre y apellido vacíos
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre del jugador no puede estar vacío. ';

    IF (@apellido IS NOT NULL AND LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido del jugador no puede estar vacío. ';

    -- Edad mínima 15 años
    IF (@fecha_nacimiento IS NOT NULL AND DATEDIFF(YEAR, @fecha_nacimiento, GETDATE()) < 15)
        SET @MensajeError = @MensajeError + '- El jugador debe tener al menos 15 años. ';

    -- Claves foráneas existentes
    IF (@id_pais_nacimiento IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais_nacimiento))
        SET @MensajeError = @MensajeError + '- El país de nacimiento indicado no existe. ';

    IF (@id_posicion_habitual IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE id_posicion = @id_posicion_habitual))
        SET @MensajeError = @MensajeError + '- La posición indicada no existe. ';

    IF (@id_club_origen IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Club_origen WHERE id_club = @id_club_origen))
        SET @MensajeError = @MensajeError + '- El club indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Jugador
        SET nombre = ISNULL(LTRIM(RTRIM(@nombre)), nombre),
            apellido = ISNULL(LTRIM(RTRIM(@apellido)), apellido),
            fecha_nacimiento = ISNULL(@fecha_nacimiento, fecha_nacimiento),
            id_pais_nacimiento = ISNULL(@id_pais_nacimiento, id_pais_nacimiento),
            id_posicion_habitual = ISNULL(@id_posicion_habitual, id_posicion_habitual),
            id_club_origen = ISNULL(@id_club_origen, id_club_origen)
        WHERE id_jugador = @id_jugador;

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
-- Procedimiento: Participantes.Modificacion_Integrante_cuerpo_tecnico
-- Descripción: Modifica los datos de un integrante del cuerpo técnico (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre, apellido y cargo vacíos,
--               selección existente e integrante duplicado.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Integrante_cuerpo_tecnico
    @id_integrante_ct INT,
    @id_seleccion INT = NULL,
    @nombre VARCHAR(30) = NULL,
    @apellido VARCHAR(30) = NULL,
    @cargo_rol VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';
    DECLARE @id_seleccion_final INT;
    DECLARE @nombre_final VARCHAR(30);
    DECLARE @apellido_final VARCHAR(30);
    DECLARE @cargo_final VARCHAR(30);

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Integrante_cuerpo_tecnico WHERE id_integrante_ct = @id_integrante_ct)
        SET @MensajeError = @MensajeError + '- El integrante del cuerpo técnico que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_seleccion IS NULL AND @nombre IS NULL AND @apellido IS NULL AND @cargo_rol IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Textos vacíos
    IF (@nombre IS NOT NULL AND LTRIM(RTRIM(@nombre)) = '')
        SET @MensajeError = @MensajeError + '- El nombre no puede estar vacío. ';

    IF (@apellido IS NOT NULL AND LTRIM(RTRIM(@apellido)) = '')
        SET @MensajeError = @MensajeError + '- El apellido no puede estar vacío. ';

    IF (@cargo_rol IS NOT NULL AND LTRIM(RTRIM(@cargo_rol)) = '')
        SET @MensajeError = @MensajeError + '- El cargo o rol no puede estar vacío. ';

    -- Selección existente
    IF (@id_seleccion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion))
        SET @MensajeError = @MensajeError + '- La selección indicada no existe. ';

    -- Duplicado (con los valores finales)
    SELECT
        @id_seleccion_final = ISNULL(@id_seleccion, id_seleccion),
        @nombre_final = ISNULL(LTRIM(RTRIM(@nombre)), nombre),
        @apellido_final = ISNULL(LTRIM(RTRIM(@apellido)), apellido),
        @cargo_final = ISNULL(LTRIM(RTRIM(@cargo_rol)), cargo_rol)
    FROM Participantes.Integrante_cuerpo_tecnico
    WHERE id_integrante_ct = @id_integrante_ct;

    IF EXISTS (SELECT 1 FROM Participantes.Integrante_cuerpo_tecnico
               WHERE id_seleccion = @id_seleccion_final AND nombre = @nombre_final AND apellido = @apellido_final
                 AND cargo_rol = @cargo_final AND id_integrante_ct <> @id_integrante_ct)
        SET @MensajeError = @MensajeError + '- Ya existe ese integrante con el mismo cargo en la selección. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Integrante_cuerpo_tecnico
        SET id_seleccion = @id_seleccion_final,
            nombre = @nombre_final,
            apellido = @apellido_final,
            cargo_rol = @cargo_final
        WHERE id_integrante_ct = @id_integrante_ct;

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
-- Procedimiento: Participantes.Modificacion_Convocatoria
-- Descripción: Modifica el estado, la fecha de alta o el dorsal de una convocatoria (NULL no modifica).
--              La selección y el jugador no se modifican: para eso se usa el reemplazo de convocatoria.
-- Validaciones: El registro debe existir, al menos un dato, estado vacío, fecha futura,
--               dorsal fuera de rango y dorsal ya usado por otro jugador de la selección.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Convocatoria
    @id_convocatoria INT,
    @estado_convocatoria VARCHAR(30) = NULL,
    @fecha_alta_convocatoria DATE = NULL,
    @dorsal TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_seleccion INT;

    SELECT @id_seleccion = id_seleccion FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria;

    -- El registro debe existir
    IF (@id_seleccion IS NULL)
        SET @MensajeError = @MensajeError + '- La convocatoria que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@estado_convocatoria IS NULL AND @fecha_alta_convocatoria IS NULL AND @dorsal IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Estado vacío
    IF (@estado_convocatoria IS NOT NULL AND LTRIM(RTRIM(@estado_convocatoria)) = '')
        SET @MensajeError = @MensajeError + '- El estado de la convocatoria no puede estar vacío. ';

    -- Fecha futura
    IF (@fecha_alta_convocatoria > CAST(GETDATE() AS DATE))
        SET @MensajeError = @MensajeError + '- La fecha de convocatoria no puede ser futura. ';

    -- Dorsal fuera de rango o repetido en la selección
    IF (@dorsal < 1 OR @dorsal > 26)
        SET @MensajeError = @MensajeError + '- El dorsal debe estar entre 1 y 26. ';
    ELSE IF EXISTS (SELECT 1 FROM Participantes.Convocatoria
                    WHERE id_seleccion = @id_seleccion AND dorsal = @dorsal AND id_convocatoria <> @id_convocatoria)
        SET @MensajeError = @MensajeError + '- El dorsal ya está asignado a otro jugador de la selección. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Convocatoria
        SET estado_convocatoria = ISNULL(LTRIM(RTRIM(@estado_convocatoria)), estado_convocatoria),
            fecha_alta_convocatoria = ISNULL(@fecha_alta_convocatoria, fecha_alta_convocatoria),
            dorsal = ISNULL(@dorsal, dorsal)
        WHERE id_convocatoria = @id_convocatoria;

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
-- Procedimiento: Participantes.Modificacion_Novedad_convocatoria
-- Descripción: Corrige el motivo, la fecha o las observaciones de una novedad de convocatoria
--              (NULL no modifica; '' deja las observaciones en NULL). Los jugadores involucrados
--              no se modifican para preservar el historial.
-- Validaciones: El registro debe existir, al menos un dato, motivo vacío, fecha futura
--               y fecha anterior a la convocatoria original del jugador dado de baja.

CREATE OR ALTER PROCEDURE Participantes.Modificacion_Novedad_convocatoria
    @id_novedad INT,
    @motivo_cambio VARCHAR(50) = NULL,
    @fecha_cambio DATE = NULL,
    @observaciones VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @fecha_convocatoria_original DATE;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Novedad_convocatoria WHERE id_novedad = @id_novedad)
        SET @MensajeError = @MensajeError + '- La novedad de convocatoria que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@motivo_cambio IS NULL AND @fecha_cambio IS NULL AND @observaciones IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Motivo vacío
    IF (@motivo_cambio IS NOT NULL AND LTRIM(RTRIM(@motivo_cambio)) = '')
        SET @MensajeError = @MensajeError + '- El motivo del cambio no puede estar vacío. ';

    -- Fecha futura
    IF (@fecha_cambio > CAST(GETDATE() AS DATE))
        SET @MensajeError = @MensajeError + '- La fecha del cambio no puede ser futura. ';

    -- Fecha anterior a la convocatoria original del jugador dado de baja
    SELECT @fecha_convocatoria_original = C.fecha_alta_convocatoria
    FROM Participantes.Novedad_convocatoria N
    INNER JOIN Participantes.Convocatoria C ON N.id_convocatoria_baja = C.id_convocatoria
    WHERE N.id_novedad = @id_novedad;

    IF (@fecha_cambio IS NOT NULL AND @fecha_cambio < @fecha_convocatoria_original)
        SET @MensajeError = @MensajeError + '- La fecha de novedad no puede ser anterior a la convocatoria original. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Novedad_convocatoria
        SET motivo_cambio = ISNULL(LTRIM(RTRIM(@motivo_cambio)), motivo_cambio),
            fecha_cambio = ISNULL(@fecha_cambio, fecha_cambio),
            observaciones = CASE WHEN @observaciones IS NULL THEN observaciones
                                 ELSE NULLIF(LTRIM(RTRIM(@observaciones)), '') END
        WHERE id_novedad = @id_novedad;

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
-- Procedimiento: Publicidad.Modificacion_Campania_publicitaria
-- Descripción: Modifica los datos de una campaña publicitaria (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre vacío, presupuesto mayor a cero,
--               fecha de fin no anterior a la de inicio, anunciante existente y que el nuevo período
--               no deje afuera exhibiciones ya registradas (historial de facturación).

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Campania_publicitaria
    @id_campania INT,
    @id_anunciante INT = NULL,
    @nombre_campania VARCHAR(100) = NULL,
    @fecha_inicio DATE = NULL,
    @fecha_fin DATE = NULL,
    @presupuesto DECIMAL(18,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(700) = '';
    DECLARE @inicio_final DATE;
    DECLARE @fin_final DATE;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Publicidad.Campania_publicitaria WHERE id_campania = @id_campania)
        SET @MensajeError = @MensajeError + '- La campaña que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_anunciante IS NULL AND @nombre_campania IS NULL AND @fecha_inicio IS NULL AND @fecha_fin IS NULL AND @presupuesto IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío
    IF (@nombre_campania IS NOT NULL AND LTRIM(RTRIM(@nombre_campania)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la campaña no puede estar vacío. ';

    -- Presupuesto
    IF (@presupuesto <= 0)
        SET @MensajeError = @MensajeError + '- El presupuesto debe ser mayor a cero. ';

    -- Anunciante existente
    IF (@id_anunciante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE id_anunciante = @id_anunciante))
        SET @MensajeError = @MensajeError + '- El anunciante indicado no existe. ';

    -- Fechas (con los valores finales)
    SELECT
        @inicio_final = ISNULL(@fecha_inicio, fecha_inicio),
        @fin_final = ISNULL(@fecha_fin, fecha_fin)
    FROM Publicidad.Campania_publicitaria
    WHERE id_campania = @id_campania;

    IF (@fin_final < @inicio_final)
        SET @MensajeError = @MensajeError + '- La fecha de fin no puede ser anterior a la fecha de inicio. ';
    ELSE IF EXISTS (SELECT 1
                    FROM Publicidad.Exhibicion_publicidad_partido E
                    INNER JOIN Publicidad.Pieza_publicitaria PZ ON E.id_pieza = PZ.id_pieza
                    WHERE PZ.id_campania = @id_campania
                      AND CAST(E.fecha_hora_exhibicion AS DATE) NOT BETWEEN @inicio_final AND @fin_final)
        SET @MensajeError = @MensajeError + '- El nuevo período deja afuera exhibiciones ya registradas de la campaña. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Campania_publicitaria
        SET id_anunciante = ISNULL(@id_anunciante, id_anunciante),
            nombre_campania = ISNULL(LTRIM(RTRIM(@nombre_campania)), nombre_campania),
            fecha_inicio = @inicio_final,
            fecha_fin = @fin_final,
            presupuesto = ISNULL(@presupuesto, presupuesto)
        WHERE id_campania = @id_campania;

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
-- Procedimiento: Publicidad.Modificacion_Mercado_interes_campania
-- Descripción: Reemplaza un país de interés de una campaña por otro (la tabla solo tiene la clave compuesta).
-- Validaciones: La asociación debe existir, el nuevo país debe existir y no estar ya asociado.

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Mercado_interes_campania
    @id_campania INT,
    @id_pais INT,
    @id_pais_nuevo INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- La asociación debe existir
    IF NOT EXISTS (SELECT 1 FROM Publicidad.Mercado_interes_campania WHERE id_campania = @id_campania AND id_pais = @id_pais)
        SET @MensajeError = @MensajeError + '- La campaña no tiene asociado el mercado que intenta modificar. ';

    -- El nuevo país debe existir
    IF (@id_pais_nuevo IS NULL OR NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais_nuevo))
        SET @MensajeError = @MensajeError + '- El nuevo país indicado no existe. ';

    -- No puede estar ya asociado
    ELSE IF EXISTS (SELECT 1 FROM Publicidad.Mercado_interes_campania WHERE id_campania = @id_campania AND id_pais = @id_pais_nuevo)
        SET @MensajeError = @MensajeError + '- La campaña ya tiene asociado el nuevo país como mercado de interés. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Mercado_interes_campania
        SET id_pais = @id_pais_nuevo
        WHERE id_campania = @id_campania AND id_pais = @id_pais;

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
-- Procedimiento: Publicidad.Modificacion_Pieza_publicitaria
-- Descripción: Modifica los datos de una pieza publicitaria (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, nombre y URL vacíos, duración mayor a cero,
--               idioma existente y nombre duplicado dentro de la campaña.

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Pieza_publicitaria
    @id_pieza INT,
    @id_idioma INT = NULL,
    @nombre_pieza VARCHAR(50) = NULL,
    @duracion_segundos SMALLINT = NULL,
    @url_contenido_media VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';
    DECLARE @id_campania INT;

    SELECT @id_campania = id_campania FROM Publicidad.Pieza_publicitaria WHERE id_pieza = @id_pieza;

    -- El registro debe existir
    IF (@id_campania IS NULL)
        SET @MensajeError = @MensajeError + '- La pieza publicitaria que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_idioma IS NULL AND @nombre_pieza IS NULL AND @duracion_segundos IS NULL AND @url_contenido_media IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Nombre vacío o duplicado en la campaña
    IF (@nombre_pieza IS NOT NULL AND LTRIM(RTRIM(@nombre_pieza)) = '')
        SET @MensajeError = @MensajeError + '- El nombre de la pieza no puede estar vacío. ';
    ELSE IF EXISTS (SELECT 1 FROM Publicidad.Pieza_publicitaria
                    WHERE id_campania = @id_campania AND nombre_pieza = LTRIM(RTRIM(@nombre_pieza)) AND id_pieza <> @id_pieza)
        SET @MensajeError = @MensajeError + '- La campaña ya tiene otra pieza con ese nombre. ';

    -- URL vacía
    IF (@url_contenido_media IS NOT NULL AND LTRIM(RTRIM(@url_contenido_media)) = '')
        SET @MensajeError = @MensajeError + '- La URL del contenido no puede estar vacía. ';

    -- Duración
    IF (@duracion_segundos <= 0)
        SET @MensajeError = @MensajeError + '- La duración debe ser mayor a cero segundos. ';

    -- Idioma existente
    IF (@id_idioma IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE id_idioma = @id_idioma))
        SET @MensajeError = @MensajeError + '- El idioma indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Pieza_publicitaria
        SET id_idioma = ISNULL(@id_idioma, id_idioma),
            nombre_pieza = ISNULL(LTRIM(RTRIM(@nombre_pieza)), nombre_pieza),
            duracion_segundos = ISNULL(@duracion_segundos, duracion_segundos),
            url_contenido_media = ISNULL(LTRIM(RTRIM(@url_contenido_media)), url_contenido_media)
        WHERE id_pieza = @id_pieza;

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
-- Procedimiento: Torneo.Modificacion_Partido
-- Descripción: Modifica los datos de un partido (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, sede, fase y selecciones existentes,
--               selecciones distintas, asistencia no negativa ni mayor a la capacidad de la sede,
--               resultado cargado de a pares y solo para partidos ya disputados, UTC coherente con el
--               huso de la sede, choque de horario en la sede, partido duplicado en la fase y cambio de
--               selecciones cuando el partido ya tiene alineaciones o eventos registrados.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Partido
    @id_partido INT,
    @id_sede INT = NULL,
    @id_fase INT = NULL,
    @id_seleccion_local INT = NULL,
    @id_seleccion_visitante INT = NULL,
    @fecha_hora_local DATETIME = NULL,
    @asistencia_publico INT = NULL,
    @goles_local TINYINT = NULL,
    @goles_visitante TINYINT = NULL,
    @UTC DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(1500) = '';

    -- Valores actuales
    DECLARE @sede_actual INT, @fase_actual INT, @local_actual INT, @visitante_actual INT;
    DECLARE @fecha_actual DATETIME, @asistencia_actual INT, @goles_local_actual TINYINT, @goles_visitante_actual TINYINT, @utc_actual DATETIME;

    -- Valores finales (lo que quedaría grabado)
    DECLARE @sede_final INT, @fase_final INT, @local_final INT, @visitante_final INT;
    DECLARE @fecha_final DATETIME, @asistencia_final INT, @goles_local_final TINYINT, @goles_visitante_final TINYINT, @utc_final DATETIME;

    DECLARE @capacidad_sede INT;
    DECLARE @offset_sede INT;

    SELECT
        @sede_actual = id_sede, @fase_actual = id_fase,
        @local_actual = id_seleccion_local, @visitante_actual = id_seleccion_visitante,
        @fecha_actual = fecha_hora_local, @asistencia_actual = asistencia_publico,
        @goles_local_actual = goles_local, @goles_visitante_actual = goles_visitante, @utc_actual = UTC
    FROM Torneo.Partido
    WHERE id_partido = @id_partido;

    -- El registro debe existir
    IF (@sede_actual IS NULL)
        SET @MensajeError = @MensajeError + '- El partido que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_sede IS NULL AND @id_fase IS NULL AND @id_seleccion_local IS NULL AND @id_seleccion_visitante IS NULL
        AND @fecha_hora_local IS NULL AND @asistencia_publico IS NULL AND @goles_local IS NULL
        AND @goles_visitante IS NULL AND @UTC IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    SET @sede_final = ISNULL(@id_sede, @sede_actual);
    SET @fase_final = ISNULL(@id_fase, @fase_actual);
    SET @local_final = ISNULL(@id_seleccion_local, @local_actual);
    SET @visitante_final = ISNULL(@id_seleccion_visitante, @visitante_actual);
    SET @fecha_final = ISNULL(@fecha_hora_local, @fecha_actual);
    SET @asistencia_final = ISNULL(@asistencia_publico, @asistencia_actual);
    SET @goles_local_final = ISNULL(@goles_local, @goles_local_actual);
    SET @goles_visitante_final = ISNULL(@goles_visitante, @goles_visitante_actual);
    SET @utc_final = ISNULL(@UTC, @utc_actual);

    -- Claves foráneas existentes
    IF (@id_sede IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_sede = @id_sede))
        SET @MensajeError = @MensajeError + '- La sede indicada no existe. ';

    IF (@id_fase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase))
        SET @MensajeError = @MensajeError + '- La fase indicada no existe. ';

    IF (@id_seleccion_local IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion_local))
        SET @MensajeError = @MensajeError + '- La selección local indicada no existe. ';

    IF (@id_seleccion_visitante IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion_visitante))
        SET @MensajeError = @MensajeError + '- La selección visitante indicada no existe. ';

    -- Selecciones distintas
    IF (@local_final = @visitante_final)
        SET @MensajeError = @MensajeError + '- La selección local y la visitante no pueden ser la misma. ';

    -- No se pueden cambiar las selecciones si el partido ya tiene datos asociados a ellas
    IF ((@id_seleccion_local IS NOT NULL AND @id_seleccion_local <> @local_actual)
        OR (@id_seleccion_visitante IS NOT NULL AND @id_seleccion_visitante <> @visitante_actual))
    BEGIN
        IF EXISTS (SELECT 1 FROM Torneo.Alineacion_partido WHERE id_partido = @id_partido)
           OR EXISTS (SELECT 1 FROM Torneo.Gol WHERE id_partido = @id_partido)
           OR EXISTS (SELECT 1 FROM Torneo.Tarjeta WHERE id_partido = @id_partido)
           OR EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @id_partido)
            SET @MensajeError = @MensajeError + '- No se pueden cambiar las selecciones de un partido que ya tiene alineaciones, goles, tarjetas o árbitros cargados. ';
    END

    -- Datos de la sede final (capacidad y huso horario)
    SELECT @capacidad_sede = capacidad, @offset_sede = Torneo.fn_Offset_Huso_Minutos(huso_horario)
    FROM Torneo.Sede
    WHERE id_sede = @sede_final;

    -- Asistencia
    IF (@asistencia_publico < 0)
        SET @MensajeError = @MensajeError + '- La asistencia de público no puede ser negativa. ';
    ELSE IF (@asistencia_final > @capacidad_sede)
        SET @MensajeError = @MensajeError + '- La asistencia supera la capacidad máxima del estadio. ';

    -- Resultado: se cargan ambos goles juntos y solo si el partido ya se jugó
    IF ((@goles_local_final IS NULL AND @goles_visitante_final IS NOT NULL)
        OR (@goles_local_final IS NOT NULL AND @goles_visitante_final IS NULL))
        SET @MensajeError = @MensajeError + '- El resultado debe tener cargados los goles de ambas selecciones. ';

    IF ((@goles_local IS NOT NULL OR @goles_visitante IS NOT NULL) AND @fecha_final > GETDATE())
        SET @MensajeError = @MensajeError + '- No se puede cargar el resultado de un partido que todavía no se jugó. ';

    -- El horario UTC debe ser coherente con el horario local y el huso de la sede
    IF ((@id_sede IS NOT NULL OR @fecha_hora_local IS NOT NULL OR @UTC IS NOT NULL)
        AND @offset_sede IS NOT NULL
        AND DATEDIFF(MINUTE, @utc_final, @fecha_final) <> @offset_sede)
        SET @MensajeError = @MensajeError + '- El horario UTC no coincide con el horario local según el huso de la sede. ';

    -- Choque de horario: otro partido en la misma sede y horario
    IF EXISTS (SELECT 1 FROM Torneo.Partido
               WHERE id_sede = @sede_final AND fecha_hora_local = @fecha_final AND id_partido <> @id_partido)
        SET @MensajeError = @MensajeError + '- La sede ya tiene otro partido programado en ese horario. ';

    -- Partido duplicado: mismas selecciones en la misma fase
    IF EXISTS (SELECT 1 FROM Torneo.Partido
               WHERE id_fase = @fase_final AND id_seleccion_local = @local_final
                 AND id_seleccion_visitante = @visitante_final AND id_partido <> @id_partido)
        SET @MensajeError = @MensajeError + '- Ya existe un partido entre esas selecciones en la fase indicada. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Partido
        SET id_sede = @sede_final,
            id_fase = @fase_final,
            id_seleccion_local = @local_final,
            id_seleccion_visitante = @visitante_final,
            fecha_hora_local = @fecha_final,
            asistencia_publico = @asistencia_final,
            goles_local = @goles_local_final,
            goles_visitante = @goles_visitante_final,
            UTC = @utc_final
        WHERE id_partido = @id_partido;

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
-- Procedimiento: Torneo.Modificacion_Alineacion_partido
-- Descripción: Modifica el esquema táctico de la alineación de una selección en un partido.
--              El partido y la selección no se modifican (se debe dar de baja y volver a dar de alta).
-- Validaciones: El registro debe existir y el esquema táctico debe existir.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Alineacion_partido
    @id_alineacion_partido INT,
    @id_esquema_tactico INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Alineacion_partido WHERE id_alineacion_partido = @id_alineacion_partido)
        SET @MensajeError = @MensajeError + '- La alineación que intenta modificar no existe. ';

    -- Esquema existente
    IF (@id_esquema_tactico IS NULL OR NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE id_esquema_tactico = @id_esquema_tactico))
        SET @MensajeError = @MensajeError + '- El esquema táctico indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Alineacion_partido
        SET id_esquema_tactico = @id_esquema_tactico
        WHERE id_alineacion_partido = @id_alineacion_partido;

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
-- Procedimiento: Torneo.Modificacion_Detalle_alineacion_jugador
-- Descripción: Modifica la posición en cancha o la condición de titular/suplente de un jugador
--              en la planilla de un partido (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, posición existente, máximo de 11 titulares,
--               un jugador suspendido para ese partido no puede ser titular, un suplente que ya ingresó
--               por un cambio no puede pasar a titular y un titular que ya salió por un cambio no puede
--               pasar a suplente.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Detalle_alineacion_jugador
    @id_alineacion_partido INT,
    @id_convocatoria INT,
    @id_posicion_partido INT = NULL,
    @es_titular BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @es_titular_actual BIT;
    DECLARE @id_partido INT;
    DECLARE @cantidad_titulares INT;

    SELECT @es_titular_actual = D.es_titular, @id_partido = A.id_partido
    FROM Torneo.Detalle_alineacion_jugador D
    INNER JOIN Torneo.Alineacion_partido A ON D.id_alineacion_partido = A.id_alineacion_partido
    WHERE D.id_alineacion_partido = @id_alineacion_partido AND D.id_convocatoria = @id_convocatoria;

    -- El registro debe existir
    IF (@es_titular_actual IS NULL)
        SET @MensajeError = @MensajeError + '- El jugador no figura en la planilla de esa alineación. ';

    -- Al menos un dato a modificar
    IF (@id_posicion_partido IS NULL AND @es_titular IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Posición existente
    IF (@id_posicion_partido IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE id_posicion = @id_posicion_partido))
        SET @MensajeError = @MensajeError + '- La posición indicada no existe. ';

    -- Pasa de suplente a titular
    IF (@es_titular = 1 AND @es_titular_actual = 0)
    BEGIN
        SELECT @cantidad_titulares = COUNT(*)
        FROM Torneo.Detalle_alineacion_jugador
        WHERE id_alineacion_partido = @id_alineacion_partido AND es_titular = 1;

        IF (@cantidad_titulares >= 11)
            SET @MensajeError = @MensajeError + '- La alineación ya cuenta con el máximo de 11 jugadores titulares permitidos. ';

        IF EXISTS (SELECT 1 FROM Torneo.Suspension_jugador
                   WHERE id_convocatoria = @id_convocatoria AND id_partido_sancion = @id_partido)
            SET @MensajeError = @MensajeError + '- El jugador está suspendido para este partido y no puede ser titular. ';

        IF EXISTS (SELECT 1 FROM Torneo.Sustitucion
                   WHERE id_alineacion_partido = @id_alineacion_partido AND id_convocatoria_entra = @id_convocatoria)
            SET @MensajeError = @MensajeError + '- El jugador ingresó desde el banco por una sustitución; no puede figurar como titular. ';
    END

    -- Pasa de titular a suplente
    IF (@es_titular = 0 AND @es_titular_actual = 1
        AND EXISTS (SELECT 1 FROM Torneo.Sustitucion
                    WHERE id_alineacion_partido = @id_alineacion_partido AND id_convocatoria_sale = @id_convocatoria))
        SET @MensajeError = @MensajeError + '- El jugador salió reemplazado en una sustitución; debe figurar como titular. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Detalle_alineacion_jugador
        SET id_posicion_partido = ISNULL(@id_posicion_partido, id_posicion_partido),
            es_titular = ISNULL(@es_titular, es_titular)
        WHERE id_alineacion_partido = @id_alineacion_partido AND id_convocatoria = @id_convocatoria;

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
-- Procedimiento: Torneo.Modificacion_Sustitucion
-- Descripción: Corrige el motivo, el minuto, la ventana o el indicador de tiempo suplementario de una
--              sustitución (NULL no modifica; '' deja el motivo en NULL). Los jugadores no se modifican:
--              para corregirlos se da de baja la sustitución y se registra nuevamente.
-- Validaciones: El registro debe existir, al menos un dato, minuto entre 1 y 130, ventana entre 1 y 3
--               (hasta 4 en tiempo suplementario) y el tiempo suplementario solo a partir del minuto 91.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Sustitucion
    @id_sustitucion INT,
    @motivo_sustitucion VARCHAR(50) = NULL,
    @minuto TINYINT = NULL,
    @numero_ventanas TINYINT = NULL,
    @es_tiempo_suplementario BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';
    DECLARE @minuto_final TINYINT;
    DECLARE @ventana_final TINYINT;
    DECLARE @suplementario_final BIT;

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Sustitucion WHERE id_sustitucion = @id_sustitucion)
        SET @MensajeError = @MensajeError + '- La sustitución que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@motivo_sustitucion IS NULL AND @minuto IS NULL AND @numero_ventanas IS NULL AND @es_tiempo_suplementario IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Valores finales
    SELECT
        @minuto_final = ISNULL(@minuto, minuto),
        @ventana_final = ISNULL(@numero_ventanas, numero_ventanas),
        @suplementario_final = ISNULL(@es_tiempo_suplementario, es_tiempo_suplementario)
    FROM Torneo.Sustitucion
    WHERE id_sustitucion = @id_sustitucion;

    -- Minuto
    IF (@minuto_final < 1 OR @minuto_final > 130)
        SET @MensajeError = @MensajeError + '- El minuto de la sustitución debe estar entre 1 y 130. ';

    -- Ventanas: 3 en tiempo reglamentario y una adicional en el suplementario
    IF (@ventana_final < 1 OR (@suplementario_final = 0 AND @ventana_final > 3) OR (@suplementario_final = 1 AND @ventana_final > 4))
        SET @MensajeError = @MensajeError + '- La ventana debe estar entre 1 y 3 (o hasta 4 si es en tiempo suplementario). ';

    -- Tiempo suplementario
    IF (@suplementario_final = 1 AND @minuto_final <= 90)
        SET @MensajeError = @MensajeError + '- Un cambio en tiempo suplementario debe realizarse después del minuto 90. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Sustitucion
        SET motivo_sustitucion = CASE WHEN @motivo_sustitucion IS NULL THEN motivo_sustitucion
                                      ELSE NULLIF(LTRIM(RTRIM(@motivo_sustitucion)), '') END,
            minuto = @minuto_final,
            numero_ventanas = @ventana_final,
            es_tiempo_suplementario = @suplementario_final
        WHERE id_sustitucion = @id_sustitucion;

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
-- Procedimiento: Torneo.Modificacion_Gol
-- Descripción: Corrige los datos de un gol (los parámetros en NULL no se modifican). Para quitar la
--              asistencia se envía @quitar_asistencia = 1. El autor no se modifica: si se cargó mal,
--              se da de baja el gol y se registra nuevamente.
-- Validaciones: El registro debe existir, al menos un dato, tipo y periodo existentes, minuto entre 1 y 130,
--               la asistencia debe ser de la misma selección que el autor y distinta del autor, y no se
--               puede indicar una asistencia y pedir quitarla a la vez.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Gol
    @id_gol INT,
    @id_convocatoria_asistencia INT = NULL,
    @quitar_asistencia BIT = 0,
    @id_tipo_gol INT = NULL,
    @id_periodo_partido INT = NULL,
    @minuto TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(700) = '';
    DECLARE @id_autor INT;
    DECLARE @id_seleccion_autor INT;
    DECLARE @id_seleccion_asistencia INT;

    SELECT @id_autor = G.id_convocatoria_autor, @id_seleccion_autor = C.id_seleccion
    FROM Torneo.Gol G
    INNER JOIN Participantes.Convocatoria C ON G.id_convocatoria_autor = C.id_convocatoria
    WHERE G.id_gol = @id_gol;

    -- El registro debe existir
    IF (@id_autor IS NULL)
        SET @MensajeError = @MensajeError + '- El gol que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_convocatoria_asistencia IS NULL AND ISNULL(@quitar_asistencia, 0) = 0 AND @id_tipo_gol IS NULL
        AND @id_periodo_partido IS NULL AND @minuto IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Asistencia
    IF (@id_convocatoria_asistencia IS NOT NULL AND @quitar_asistencia = 1)
        SET @MensajeError = @MensajeError + '- No se puede indicar una asistencia y pedir quitarla al mismo tiempo. ';
    ELSE IF (@id_convocatoria_asistencia IS NOT NULL)
    BEGIN
        SELECT @id_seleccion_asistencia = id_seleccion
        FROM Participantes.Convocatoria
        WHERE id_convocatoria = @id_convocatoria_asistencia;

        IF (@id_seleccion_asistencia IS NULL)
            SET @MensajeError = @MensajeError + '- El jugador de la asistencia no existe. ';
        ELSE IF (@id_seleccion_asistencia <> @id_seleccion_autor)
            SET @MensajeError = @MensajeError + '- El asistente debe pertenecer a la misma selección que el autor. ';

        IF (@id_convocatoria_asistencia = @id_autor)
            SET @MensajeError = @MensajeError + '- El autor del gol no puede ser también quien da la asistencia. ';
    END

    -- Tipo y periodo existentes
    IF (@id_tipo_gol IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE id_tipo = @id_tipo_gol))
        SET @MensajeError = @MensajeError + '- El tipo de gol indicado no existe. ';

    IF (@id_periodo_partido IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE id_periodo_partido = @id_periodo_partido))
        SET @MensajeError = @MensajeError + '- El periodo de partido indicado no existe. ';

    -- Minuto
    IF (@minuto < 1 OR @minuto > 130)
        SET @MensajeError = @MensajeError + '- El minuto del gol debe estar entre 1 y 130. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Gol
        SET id_convocatoria_asistencia = CASE WHEN @quitar_asistencia = 1 THEN NULL
                                              ELSE ISNULL(@id_convocatoria_asistencia, id_convocatoria_asistencia) END,
            id_tipo_gol = ISNULL(@id_tipo_gol, id_tipo_gol),
            id_periodo_partido = ISNULL(@id_periodo_partido, id_periodo_partido),
            minuto = ISNULL(@minuto, minuto)
        WHERE id_gol = @id_gol;

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
-- Procedimiento: Torneo.Modificacion_Tarjeta
-- Descripción: Corrige el tipo, el motivo, el periodo o el minuto de una tarjeta (NULL no modifica).
--              El jugador y el partido no se modifican: se da de baja la tarjeta y se registra nuevamente.
-- Validaciones: El registro debe existir, al menos un dato, tipo, motivo y periodo existentes
--               y minuto entre 0 y 130 (se admite 0 para tarjetas antes del inicio).

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Tarjeta
    @id_tarjeta INT,
    @id_tipo_tarjeta INT = NULL,
    @id_motivo_tarjeta INT = NULL,
    @id_periodo_partido INT = NULL,
    @minuto TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(600) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Tarjeta WHERE id_tarjeta = @id_tarjeta)
        SET @MensajeError = @MensajeError + '- La tarjeta que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_tipo_tarjeta IS NULL AND @id_motivo_tarjeta IS NULL AND @id_periodo_partido IS NULL AND @minuto IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Claves foráneas existentes
    IF (@id_tipo_tarjeta IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @id_tipo_tarjeta))
        SET @MensajeError = @MensajeError + '- El tipo de tarjeta indicado no existe. ';

    IF (@id_motivo_tarjeta IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE id_motivo = @id_motivo_tarjeta))
        SET @MensajeError = @MensajeError + '- El motivo de tarjeta indicado no existe. ';

    IF (@id_periodo_partido IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE id_periodo_partido = @id_periodo_partido))
        SET @MensajeError = @MensajeError + '- El periodo de partido indicado no existe. ';

    -- Minuto
    IF (@minuto > 130)
        SET @MensajeError = @MensajeError + '- El minuto de la tarjeta debe estar entre 0 y 130. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Tarjeta
        SET id_tipo_tarjeta = ISNULL(@id_tipo_tarjeta, id_tipo_tarjeta),
            id_motivo_tarjeta = ISNULL(@id_motivo_tarjeta, id_motivo_tarjeta),
            id_periodo_partido = ISNULL(@id_periodo_partido, id_periodo_partido),
            minuto = ISNULL(@minuto, minuto)
        WHERE id_tarjeta = @id_tarjeta;

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
-- Procedimiento: Torneo.Modificacion_Suspension_jugador
-- Descripción: Modifica el partido en que se cumple la sanción, la cantidad de fechas o si ya fue cumplida
--              (los parámetros en NULL no se modifican).
-- Validaciones: El registro debe existir, al menos un dato, fechas mayor a cero, partido de sanción existente,
--               posterior al de origen y disputado por la selección del jugador, y una sanción solo puede
--               marcarse como cumplida si tiene partido de sanción asignado.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Suspension_jugador
    @id_suspension INT,
    @id_partido_sancion INT = NULL,
    @cantidad_fechas TINYINT = NULL,
    @sancion_cumplida BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @id_convocatoria INT;
    DECLARE @id_seleccion_jugador INT;
    DECLARE @fecha_origen DATETIME;
    DECLARE @id_partido_sancion_final INT;
    DECLARE @cumplida_final BIT;
    DECLARE @fecha_sancion DATETIME;
    DECLARE @local_sancion INT;
    DECLARE @visitante_sancion INT;

    SELECT
        @id_convocatoria = S.id_convocatoria,
        @id_seleccion_jugador = C.id_seleccion,
        @fecha_origen = PO.fecha_hora_local,
        @id_partido_sancion_final = ISNULL(@id_partido_sancion, S.id_partido_sancion),
        @cumplida_final = ISNULL(@sancion_cumplida, S.sancion_cumplida)
    FROM Torneo.Suspension_jugador S
    INNER JOIN Participantes.Convocatoria C ON S.id_convocatoria = C.id_convocatoria
    INNER JOIN Torneo.Partido PO ON S.id_partido_origen = PO.id_partido
    WHERE S.id_suspension = @id_suspension;

    -- El registro debe existir
    IF (@id_convocatoria IS NULL)
        SET @MensajeError = @MensajeError + '- La suspensión que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_partido_sancion IS NULL AND @cantidad_fechas IS NULL AND @sancion_cumplida IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Fechas mayor a cero
    IF (@cantidad_fechas = 0)
        SET @MensajeError = @MensajeError + '- La cantidad de fechas de suspensión debe ser mayor a cero. ';

    -- Partido de sanción
    IF (@id_partido_sancion IS NOT NULL)
    BEGIN
        SELECT
            @fecha_sancion = fecha_hora_local,
            @local_sancion = id_seleccion_local,
            @visitante_sancion = id_seleccion_visitante
        FROM Torneo.Partido
        WHERE id_partido = @id_partido_sancion;

        IF (@fecha_sancion IS NULL)
            SET @MensajeError = @MensajeError + '- El partido de sanción indicado no existe. ';
        ELSE
        BEGIN
            IF (@fecha_sancion <= @fecha_origen)
                SET @MensajeError = @MensajeError + '- El partido de sanción debe jugarse después del partido de origen. ';

            IF (@id_seleccion_jugador NOT IN (@local_sancion, @visitante_sancion))
                SET @MensajeError = @MensajeError + '- La selección del jugador no disputa el partido de sanción indicado. ';
        END
    END

    -- Cumplida sin partido de sanción
    IF (@cumplida_final = 1 AND @id_partido_sancion_final IS NULL)
        SET @MensajeError = @MensajeError + '- No se puede marcar como cumplida una sanción sin partido de sanción asignado. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Suspension_jugador
        SET id_partido_sancion = @id_partido_sancion_final,
            cantidad_fechas = ISNULL(@cantidad_fechas, cantidad_fechas),
            sancion_cumplida = @cumplida_final
        WHERE id_suspension = @id_suspension;

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
-- Procedimiento: Torneo.Modificacion_Designacion_arbitral
-- Descripción: Cambia el rol de un árbitro designado en un partido y/o lo reemplaza por otro árbitro.
-- Validaciones: La designación debe existir, al menos un dato, rol y árbitro nuevo existentes, el árbitro
--               nuevo no puede estar ya designado en el partido ni tener la nacionalidad de alguna de las
--               selecciones, y no se puede reemplazar a un árbitro que ya tiene informe post-partido.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Designacion_arbitral
    @id_partido INT,
    @id_arbitro INT,
    @id_rol_arbitro INT = NULL,
    @id_arbitro_nuevo INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @id_pais_nuevo INT;

    -- La designación debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro)
        SET @MensajeError = @MensajeError + '- La designación que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_rol_arbitro IS NULL AND @id_arbitro_nuevo IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Rol existente
    IF (@id_rol_arbitro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE id_rol_arbitro = @id_rol_arbitro))
        SET @MensajeError = @MensajeError + '- El rol de árbitro indicado no existe. ';

    -- Reemplazo de árbitro
    IF (@id_arbitro_nuevo IS NOT NULL AND @id_arbitro_nuevo <> @id_arbitro)
    BEGIN
        SELECT @id_pais_nuevo = id_pais FROM Participantes.Arbitro WHERE id_arbitro = @id_arbitro_nuevo;

        IF (@id_pais_nuevo IS NULL)
            SET @MensajeError = @MensajeError + '- El árbitro nuevo indicado no existe. ';
        ELSE
        BEGIN
            -- Ya designado en el partido
            IF EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro_nuevo)
                SET @MensajeError = @MensajeError + '- El árbitro nuevo ya está designado en este partido. ';

            -- Regla FIFA de neutralidad
            IF EXISTS (SELECT 1
                       FROM Torneo.Partido P
                       INNER JOIN Participantes.Seleccion SL ON P.id_seleccion_local = SL.id_seleccion
                       INNER JOIN Participantes.Seleccion SV ON P.id_seleccion_visitante = SV.id_seleccion
                       WHERE P.id_partido = @id_partido
                         AND @id_pais_nuevo IN (SL.id_pais, SV.id_pais))
                SET @MensajeError = @MensajeError + '- El árbitro nuevo no puede tener la misma nacionalidad que alguna de las selecciones del partido. ';
        END

        -- Informe post-partido ya cargado para el árbitro reemplazado
        IF EXISTS (SELECT 1 FROM Torneo.Informe_post_partido WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro)
            SET @MensajeError = @MensajeError + '- No se puede reemplazar a un árbitro que ya tiene informe post-partido registrado. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Designacion_arbitral
        SET id_rol_arbitro = ISNULL(@id_rol_arbitro, id_rol_arbitro),
            id_arbitro = ISNULL(@id_arbitro_nuevo, id_arbitro)
        WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro;

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
-- Procedimiento: Torneo.Modificacion_Informe_post_partido
-- Descripción: Modifica la calificación, las observaciones o la sanción de un informe post-partido
--              (NULL no modifica; '' deja observaciones o sanción en NULL).
-- Validaciones: El registro debe existir, al menos un dato y calificación entre 1 y 10.

CREATE OR ALTER PROCEDURE Torneo.Modificacion_Informe_post_partido
    @id_informe INT,
    @calificacion_desempenio TINYINT = NULL,
    @observaciones VARCHAR(255) = NULL,
    @sancion_aplicada VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Torneo.Informe_post_partido WHERE id_informe = @id_informe)
        SET @MensajeError = @MensajeError + '- El informe que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@calificacion_desempenio IS NULL AND @observaciones IS NULL AND @sancion_aplicada IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Calificación fuera de rango
    IF (@calificacion_desempenio < 1 OR @calificacion_desempenio > 10)
        SET @MensajeError = @MensajeError + '- La calificación de desempeño debe estar entre 1 y 10. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Torneo.Informe_post_partido
        SET calificacion_desempenio = ISNULL(@calificacion_desempenio, calificacion_desempenio),
            observaciones = CASE WHEN @observaciones IS NULL THEN observaciones
                                 ELSE NULLIF(LTRIM(RTRIM(@observaciones)), '') END,
            sancion_aplicada = CASE WHEN @sancion_aplicada IS NULL THEN sancion_aplicada
                                    ELSE NULLIF(LTRIM(RTRIM(@sancion_aplicada)), '') END
        WHERE id_informe = @id_informe;

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
-- Procedimiento: Publicidad.Modificacion_Exhibicion_publicidad_partido
-- Descripción: Modifica la pieza, la tarifa, la franja o el horario de una exhibición (NULL no modifica).
-- Validaciones: El registro debe existir, al menos un dato, tarifa negativa, pieza y franja existentes,
--               hora de exhibición dentro de la franja, tarifa no menor a la base de la franja
--               y campaña de la pieza vigente en la fecha del partido.

CREATE OR ALTER PROCEDURE Publicidad.Modificacion_Exhibicion_publicidad_partido
    @id_partido INT,
    @numero_espacio TINYINT,
    @id_pieza INT = NULL,
    @tarifa_aplicada_usd DECIMAL(18,2) = NULL,
    @id_franja INT = NULL,
    @fecha_hora_exhibicion DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @existe BIT = 0;
    DECLARE @id_pieza_final INT;
    DECLARE @tarifa_final DECIMAL(18,2);
    DECLARE @id_franja_final INT;
    DECLARE @fecha_final DATETIME;
    DECLARE @hora_inicio TIME(0);
    DECLARE @hora_fin TIME(0);
    DECLARE @tarifa_base DECIMAL(18,2);
    DECLARE @fecha_partido DATE;

    SELECT
        @existe = 1,
        @id_pieza_final = ISNULL(@id_pieza, E.id_pieza),
        @tarifa_final = ISNULL(@tarifa_aplicada_usd, E.tarifa_aplicada_usd),
        @id_franja_final = ISNULL(@id_franja, E.id_franja),
        @fecha_final = ISNULL(@fecha_hora_exhibicion, E.fecha_hora_exhibicion),
        @fecha_partido = CAST(P.fecha_hora_local AS DATE)
    FROM Publicidad.Exhibicion_publicidad_partido E
    INNER JOIN Torneo.Partido P ON E.id_partido = P.id_partido
    WHERE E.id_partido = @id_partido AND E.numero_espacio = @numero_espacio;

    -- El registro debe existir
    IF (@existe = 0)
        SET @MensajeError = @MensajeError + '- La exhibición que intenta modificar no existe. ';

    -- Al menos un dato a modificar
    IF (@id_pieza IS NULL AND @tarifa_aplicada_usd IS NULL AND @id_franja IS NULL AND @fecha_hora_exhibicion IS NULL)
        SET @MensajeError = @MensajeError + '- No se indicó ningún dato para modificar. ';

    -- Tarifa negativa
    IF (@tarifa_aplicada_usd < 0)
        SET @MensajeError = @MensajeError + '- La tarifa aplicada no puede ser negativa. ';

    -- Pieza existente y campaña vigente en la fecha del partido
    IF (@id_pieza IS NOT NULL)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Publicidad.Pieza_publicitaria WHERE id_pieza = @id_pieza)
            SET @MensajeError = @MensajeError + '- La pieza publicitaria indicada no existe. ';
        ELSE IF NOT EXISTS (SELECT 1
                            FROM Publicidad.Pieza_publicitaria PZ
                            INNER JOIN Publicidad.Campania_publicitaria C ON PZ.id_campania = C.id_campania
                            WHERE PZ.id_pieza = @id_pieza AND @fecha_partido BETWEEN C.fecha_inicio AND C.fecha_fin)
            SET @MensajeError = @MensajeError + '- La campaña de la pieza no está vigente en la fecha del partido. ';
    END

    -- Franja existente
    IF (@id_franja IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE id_franja = @id_franja))
        SET @MensajeError = @MensajeError + '- La franja horaria indicada no existe. ';

    -- Horario dentro de la franja y tarifa no menor a la base (con los valores finales)
    SELECT
        @hora_inicio = hora_inicio_local,
        @hora_fin = hora_fin_local,
        @tarifa_base = tarifa_base_usd
    FROM Publicidad.Franja_horaria_tarifa
    WHERE id_franja = @id_franja_final;

    IF (@hora_inicio IS NOT NULL AND (CAST(@fecha_final AS TIME(0)) < @hora_inicio OR CAST(@fecha_final AS TIME(0)) > @hora_fin))
        SET @MensajeError = @MensajeError + '- La hora de exhibición no corresponde a los horarios de la franja indicada. ';

    IF (@tarifa_base IS NOT NULL AND @tarifa_final < @tarifa_base)
        SET @MensajeError = @MensajeError + '- La tarifa aplicada no puede ser menor a la tarifa base de la franja horaria. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Publicidad.Exhibicion_publicidad_partido
        SET id_pieza = @id_pieza_final,
            tarifa_aplicada_usd = @tarifa_final,
            id_franja = @id_franja_final,
            fecha_hora_exhibicion = @fecha_final
        WHERE id_partido = @id_partido AND numero_espacio = @numero_espacio;

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
