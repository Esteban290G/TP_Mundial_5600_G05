-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de Stored Procedures de Bajas --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Moneda
-- Descripción: Elimina físicamente una moneda del sistema.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Moneda
    @codigo_moneda CHAR(3)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = @codigo_moneda)
        SET @MensajeError = '- La moneda que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        
        DELETE FROM Participantes.Moneda 
        WHERE codigo_moneda = @codigo_moneda;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Confederacion
-- Descripción: Elimina físicamente una confederación del sistema.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Confederacion
    @id_confederacion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE id_confederacion = @id_confederacion)
        SET @MensajeError = '- La confederación que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Confederacion WHERE id_confederacion = @id_confederacion;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Posicion
-- Descripción: Elimina físicamente una posición de jugador.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Posicion
    @id_posicion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE id_posicion = @id_posicion)
        SET @MensajeError = '- La posición que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Posicion WHERE id_posicion = @id_posicion;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Categoria_arbitro
-- Descripción: Elimina físicamente una categoría de árbitro.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Categoria_arbitro
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE id_categoria = @id_categoria)
        SET @MensajeError = '- La categoría que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Categoria_arbitro WHERE id_categoria = @id_categoria;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Rol_arbitro
-- Descripción: Elimina físicamente un rol de árbitro.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Rol_arbitro
    @id_rol_arbitro INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    -- El registro debe existir
    IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE id_rol_arbitro = @id_rol_arbitro)
        SET @MensajeError = '- El rol que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Rol_arbitro WHERE id_rol_arbitro = @id_rol_arbitro;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Idioma
-- Descripción: Elimina físicamente un idioma.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Idioma
    @id_idioma INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE id_idioma = @id_idioma)
        SET @MensajeError = '- El idioma que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Idioma WHERE id_idioma = @id_idioma;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Grupo_Torneo
-- Descripción: Elimina físicamente un grupo del torneo.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Grupo_Torneo
    @id_grupo INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE id_grupo = @id_grupo)
        SET @MensajeError = '- El grupo que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Grupo_torneo WHERE id_grupo = @id_grupo;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Fase
-- Descripción: Elimina físicamente una fase del torneo.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Fase
    @id_fase INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase)
        SET @MensajeError = '- La fase que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Fase WHERE id_fase = @id_fase;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Log_importacion
-- Descripción: Elimina físicamente un log de importación.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Log_importacion
    @id_log INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Log_importacion WHERE id_log = @id_log)
        SET @MensajeError = '- El log que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Log_importacion WHERE id_log = @id_log;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Esquema_tactico
-- Descripción: Elimina físicamente un esquema táctico.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Esquema_tactico
    @id_esquema_tactico INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE id_esquema_tactico = @id_esquema_tactico)
        SET @MensajeError = '- El esquema que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Esquema_tactico WHERE id_esquema_tactico = @id_esquema_tactico;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Tipo_gol
-- Descripción: Elimina físicamente un tipo de gol.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Tipo_gol
    @id_tipo INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE id_tipo = @id_tipo)
        SET @MensajeError = '- El tipo de gol que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Tipo_gol WHERE id_tipo = @id_tipo;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Periodo_partido
-- Descripción: Elimina físicamente un periodo de partido.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Periodo_partido
    @id_periodo_partido INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE id_periodo_partido = @id_periodo_partido)
        SET @MensajeError = '- El periodo de partido que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Periodo_partido WHERE id_periodo_partido = @id_periodo_partido;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Tipo_tarjeta
-- Descripción: Elimina físicamente un tipo de tarjeta.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Tipo_tarjeta
    @id_tipo_tarjeta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @id_tipo_tarjeta)
        SET @MensajeError = '- El tipo de tarjeta que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @id_tipo_tarjeta;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Motivo_tarjeta
-- Descripción: Elimina físicamente un motivo de tarjeta.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Motivo_tarjeta
    @id_motivo INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE id_motivo = @id_motivo)
        SET @MensajeError = '- El motivo que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Motivo_tarjeta WHERE id_motivo = @id_motivo;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Franja_horaria_tarifa
-- Descripción: Elimina físicamente una franja horaria.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Franja_horaria_tarifa
    @id_franja INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE id_franja = @id_franja)
        SET @MensajeError = '- La franja horaria que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Franja_horaria_tarifa WHERE id_franja = @id_franja;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Cotizacion_moneda
-- Descripción: Elimina físicamente una cotización de moneda.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Cotizacion_moneda
    @id_cotizacion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Cotizacion_moneda WHERE id_cotizacion = @id_cotizacion)
        SET @MensajeError = '- La cotización que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Cotizacion_moneda WHERE id_cotizacion = @id_cotizacion;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Pais
-- Descripción: Elimina físicamente un país del sistema.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Pais
    @id_pais INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais)
        SET @MensajeError = '- El país que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Pais WHERE id_pais = @id_pais;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Parametros_suspension
-- Descripción: Elimina físicamente los parámetros de suspensión.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Parametros_suspension
    @id_parametro INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Parametros_suspension WHERE id_parametro = @id_parametro)
        SET @MensajeError = '- El parámetro que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Parametros_suspension WHERE id_parametro = @id_parametro;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Feriado_pais
-- Descripción: Elimina físicamente un feriado del sistema.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Feriado_pais
    @id_feriado INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Feriado_pais WHERE id_feriado = @id_feriado)
        SET @MensajeError = '- El feriado que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Feriado_pais WHERE id_feriado = @id_feriado;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Ciudad
-- Descripción: Elimina físicamente una ciudad.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Ciudad
    @id_ciudad INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Ciudad WHERE id_ciudad = @id_ciudad)
        SET @MensajeError = '- La ciudad que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Ciudad WHERE id_ciudad = @id_ciudad;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Club_origen
-- Descripción: Elimina físicamente un club.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Club_origen
    @id_club INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Club_origen WHERE id_club = @id_club)
        SET @MensajeError = '- El club que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Club_origen WHERE id_club = @id_club;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Arbitro
-- Descripción: Elimina físicamente un árbitro.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Arbitro
    @id_arbitro INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Arbitro WHERE id_arbitro = @id_arbitro)
        SET @MensajeError = '- El árbitro que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Arbitro WHERE id_arbitro = @id_arbitro;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Seleccion
-- Descripción: Elimina físicamente una selección.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Seleccion
    @id_seleccion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion)
        SET @MensajeError = '- La selección que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Idioma_arbitro
-- Descripción: Elimina un idioma asociado a un árbitro.
-- Validaciones: El registro compuesto debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Idioma_arbitro
    @id_arbitro INT,
    @id_idioma INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma_arbitro WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma)
        SET @MensajeError = '- La asociación entre el árbitro y el idioma no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Idioma_arbitro 
        WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Anunciante
-- Descripción: Elimina físicamente un anunciante.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Anunciante
    @id_anunciante INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE id_anunciante = @id_anunciante)
        SET @MensajeError = '- El anunciante que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Anunciante WHERE id_anunciante = @id_anunciante;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Sede
-- Descripción: Elimina físicamente una sede.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Sede
    @id_sede INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_sede = @id_sede)
        SET @MensajeError = '- La sede que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Sede WHERE id_sede = @id_sede;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Jugador
-- Descripción: Elimina físicamente un jugador.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Jugador
    @id_jugador INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE id_jugador = @id_jugador)
        SET @MensajeError = '- El jugador que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Jugador WHERE id_jugador = @id_jugador;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Integrante_cuerpo_tecnico
-- Descripción: Elimina físicamente un integrante del cuerpo técnico.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Integrante_cuerpo_tecnico
    @id_integrante_ct INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Integrante_cuerpo_tecnico WHERE id_integrante_ct = @id_integrante_ct)
        SET @MensajeError = '- El integrante que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Integrante_cuerpo_tecnico WHERE id_integrante_ct = @id_integrante_ct;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Convocatoria
-- Descripción: Elimina físicamente una convocatoria.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Convocatoria
    @id_convocatoria INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(60) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria)
        SET @MensajeError = '- La convocatoria que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Baja_Novedad_convocatoria
-- Descripción: Elimina físicamente una novedad de convocatoria.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Participantes.Baja_Novedad_convocatoria
    @id_novedad INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Participantes.Novedad_convocatoria WHERE id_novedad = @id_novedad)
        SET @MensajeError = '- La novedad que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Participantes.Novedad_convocatoria WHERE id_novedad = @id_novedad;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Campania_publicitaria
-- Descripción: Elimina físicamente una campaña publicitaria.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Campania_publicitaria
    @id_campania INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Campania_publicitaria WHERE id_campania = @id_campania)
        SET @MensajeError = '- La campaña que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Campania_publicitaria WHERE id_campania = @id_campania;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Pieza_publicitaria
-- Descripción: Elimina físicamente una pieza publicitaria.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Pieza_publicitaria
    @id_pieza INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(50) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Pieza_publicitaria WHERE id_pieza = @id_pieza)
        SET @MensajeError = '- La pieza que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Pieza_publicitaria WHERE id_pieza = @id_pieza;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Sustitucion
-- Descripción: Elimina físicamente una sustitución.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Sustitucion
    @id_sustitucion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Sustitucion WHERE id_sustitucion = @id_sustitucion)
        SET @MensajeError = '- La sustitución que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Sustitucion WHERE id_sustitucion = @id_sustitucion;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Informe_post_partido
-- Descripción: Elimina físicamente un informe de árbitro.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Informe_post_partido
    @id_informe INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Informe_post_partido WHERE id_informe = @id_informe)
        SET @MensajeError = '- El informe que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Informe_post_partido WHERE id_informe = @id_informe;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Detalle_alineacion_jugador
-- Descripción: Elimina a un jugador de la planilla de alineación.
-- Validaciones: El registro compuesto debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Detalle_alineacion_jugador
    @id_alineacion_partido INT,
    @id_convocatoria INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador WHERE id_alineacion_partido = @id_alineacion_partido AND id_convocatoria = @id_convocatoria)
        SET @MensajeError = '- El detalle de alineación que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Detalle_alineacion_jugador 
        WHERE id_alineacion_partido = @id_alineacion_partido AND id_convocatoria = @id_convocatoria;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Exhibicion_publicidad_partido
-- Descripción: Elimina una exhibición publicitaria.
-- Validaciones: El registro compuesto debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Exhibicion_publicidad_partido
    @id_partido INT,
    @numero_espacio TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Exhibicion_publicidad_partido WHERE id_partido = @id_partido AND numero_espacio = @numero_espacio)
        SET @MensajeError = '- La exhibición que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Exhibicion_publicidad_partido 
        WHERE id_partido = @id_partido AND numero_espacio = @numero_espacio;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Suspension_jugador
-- Descripción: Elimina físicamente una suspensión.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Suspension_jugador
    @id_suspension INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Suspension_jugador WHERE id_suspension = @id_suspension)
        SET @MensajeError = '- La suspensión que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Suspension_jugador WHERE id_suspension = @id_suspension;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Tarjeta
-- Descripción: Elimina físicamente una tarjeta.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Tarjeta
    @id_tarjeta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Tarjeta WHERE id_tarjeta = @id_tarjeta)
        SET @MensajeError = '- La tarjeta que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Tarjeta WHERE id_tarjeta = @id_tarjeta;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Gol
-- Descripción: Elimina físicamente un gol.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Gol
    @id_gol INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Gol WHERE id_gol = @id_gol)
        SET @MensajeError = '- El gol que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Gol WHERE id_gol = @id_gol;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Alineacion_partido
-- Descripción: Elimina físicamente una alineación.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Alineacion_partido
    @id_alineacion_partido INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Alineacion_partido WHERE id_alineacion_partido = @id_alineacion_partido)
        SET @MensajeError = '- La alineación que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Alineacion_partido WHERE id_alineacion_partido = @id_alineacion_partido;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Designacion_arbitral
-- Descripción: Elimina una designación arbitral.
-- Validaciones: El registro compuesto debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Designacion_arbitral
    @id_partido INT,
    @id_arbitro INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro)
        SET @MensajeError = '- La designación que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Designacion_arbitral 
        WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Baja_Mercado_interes_campania
-- Descripción: Elimina un mercado de interés.
-- Validaciones: El registro compuesto debe existir.

CREATE OR ALTER PROCEDURE Publicidad.Baja_Mercado_interes_campania
    @id_campania INT,
    @id_pais INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Publicidad.Mercado_interes_campania WHERE id_campania = @id_campania AND id_pais = @id_pais)
        SET @MensajeError = '- El mercado de interés que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Publicidad.Mercado_interes_campania 
        WHERE id_campania = @id_campania AND id_pais = @id_pais;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Baja_Partido
-- Descripción: Elimina físicamente un partido.
-- Validaciones: El registro debe existir.

CREATE OR ALTER PROCEDURE Torneo.Baja_Partido
    @id_partido INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MensajeError VARCHAR(100) = '';

    IF NOT EXISTS (SELECT 1 FROM Torneo.Partido WHERE id_partido = @id_partido)
        SET @MensajeError = '- El partido que intenta eliminar no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM Torneo.Partido WHERE id_partido = @id_partido;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO