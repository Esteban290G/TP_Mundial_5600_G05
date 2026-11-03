-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de Stored Procedures de lógica de negocio --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Procedimiento: Participantes.Registrar_Reemplazo_Convocatoria
-- Descripción: Registra un cambio o reemplazo en la lista de convocados.
-- Validaciones: Motivo vacío y validacion entre fecha de convocacion y fecha de baja.

CREATE OR ALTER PROCEDURE Participantes.Registrar_Reemplazo_Convocatoria
    @id_convocatoria_baja INT,
    @id_convocatoria_alta INT,
    @motivo_cambio VARCHAR(50),
    @fecha_cambio DATE,
    @observaciones VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(170) = '';
    DECLARE @fecha_convocatoria_original DATE;

    -- Motivo vacío
    IF (@motivo_cambio IS NULL OR LTRIM(RTRIM(@motivo_cambio)) = '')
        SET @MensajeError = @MensajeError + '- El motivo del cambio no puede estar vacío. ';

    -- Fecha futura
    IF (@fecha_cambio > GETDATE())
        SET @MensajeError = @MensajeError + '- La fecha del cambio no puede ser futura. ';

    -- Relacion entre cuándo fue convocado el jugador que se da de baja
    SELECT @fecha_convocatoria_original = fecha_alta_convocatoria 
    FROM Participantes.Convocatoria 
    WHERE id_convocatoria = @id_convocatoria_baja;

    -- Si el id existe y la fecha de novedad es más vieja que la convocatoria original se produce el error.
    IF (@fecha_convocatoria_original IS NOT NULL AND @fecha_cambio < @fecha_convocatoria_original)
        SET @MensajeError = @MensajeError + '- La fecha de novedad no puede ser anterior a la convocatoria original. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Participantes.Novedad_convocatoria (
            id_convocatoria_baja, 
            id_convocatoria_alta, 
            motivo_cambio, 
            fecha_cambio, 
            observaciones
        )
        VALUES (
            @id_convocatoria_baja,
            @id_convocatoria_alta,
            LTRIM(RTRIM(@motivo_cambio)),
            @fecha_cambio,
            NULLIF(LTRIM(RTRIM(@observaciones)), '')
        );

        -- Actualizar el estado del jugador dado de baja
        UPDATE Participantes.Convocatoria
        SET estado_convocatoria = 'Desafectado'
        WHERE id_convocatoria = @id_convocatoria_baja;

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
-- Procedimiento: Torneo.Asignar_Arbitro_Partido
-- Descripción: Asigna un árbitro a un partido.
-- Validaciones: El árbitro no puede ser de la misma nacionalidad que los equipos.

CREATE OR ALTER PROCEDURE Torneo.Asignar_Arbitro_Partido
    @id_partido INT,
    @id_rol_arbitro INT,
    @id_arbitro INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(100) = '';
    DECLARE @id_pais_arbitro INT;
    DECLARE @id_pais_local INT;
    DECLARE @id_pais_visitante INT;

    -- pais del arbitro
    SELECT @id_pais_arbitro = id_pais 
    FROM Participantes.Arbitro 
    WHERE id_arbitro = @id_arbitro;

    -- paises de las selecciones local y visitante
    SELECT 
        @id_pais_local = S_Local.id_pais,
        @id_pais_visitante = S_Visitante.id_pais
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion S_Local ON P.id_seleccion_local = S_Local.id_seleccion
    INNER JOIN Participantes.Seleccion S_Visitante ON P.id_seleccion_visitante = S_Visitante.id_seleccion
    WHERE P.id_partido = @id_partido;

    -- regla fifa
    IF (@id_pais_arbitro IS NOT NULL AND (@id_pais_arbitro = @id_pais_local OR @id_pais_arbitro = @id_pais_visitante))
    BEGIN
        SET @MensajeError = '- El árbitro no puede tener la misma nacionalidad que ninguna de las selecciones del partido. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Designacion_arbitral (id_partido, id_rol_arbitro, id_arbitro)
        VALUES (@id_partido, @id_rol_arbitro, @id_arbitro);

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
-- Procedimiento: Torneo.Registrar_Sustitucion_Partido
-- Descripción: Registra un cambio de jugadores durante un partido.
-- Validaciones: El jugador que entra debe ser suplente.

CREATE OR ALTER PROCEDURE Torneo.Registrar_Sustitucion_Partido
    @id_alineacion_partido INT,
    @id_convocatoria_sale INT,
    @id_convocatoria_entra INT,
    @motivo_sustitucion VARCHAR(50),
    @minuto TINYINT,
    @numero_ventanas TINYINT,
    @es_tiempo_suplementario BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(70) = '';
    DECLARE @entra_es_titular BIT;

    -- El jugador que entra debe ser suplente
    SELECT @entra_es_titular = es_titular
    FROM Torneo.Detalle_alineacion_jugador
    WHERE id_alineacion_partido = @id_alineacion_partido 
      AND id_convocatoria = @id_convocatoria_entra;

    IF (@entra_es_titular = 1)
        SET @MensajeError = '- El jugador que entra a la cancha no puede ser un titular. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Sustitucion (
            id_alineacion_partido, 
            id_convocatoria_sale, 
            id_convocatoria_entra, 
            motivo_sustitucion, 
            minuto, 
            numero_ventanas, 
            es_tiempo_suplementario
        )
        VALUES (
            @id_alineacion_partido,
            @id_convocatoria_sale,
            @id_convocatoria_entra,
            NULLIF(LTRIM(RTRIM(@motivo_sustitucion)), ''),
            @minuto,
            @numero_ventanas,
            @es_tiempo_suplementario
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
-- Procedimiento: Torneo.Confirmar_Planilla_Jugador
-- Descripción: Agrega un jugador(titular o suplente) a la alineación de un partido.
-- Validaciones: Jugador pertenece a selección y límite máximo de 11 titulares.

CREATE OR ALTER PROCEDURE Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido INT,
    @id_convocatoria INT,
    @id_posicion_partido INT,
    @es_titular BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(150) = '';
    DECLARE @id_seleccion_alineacion INT;
    DECLARE @id_seleccion_jugador INT;
    DECLARE @cantidad_titulares INT = 0;

    -- selección perteneciente a la alineación
    SELECT @id_seleccion_alineacion = id_seleccion 
    FROM Torneo.Alineacion_partido 
    WHERE id_alineacion_partido = @id_alineacion_partido;

    -- selección que pertenece el jugador convocado
    SELECT @id_seleccion_jugador = id_seleccion 
    FROM Participantes.Convocatoria 
    WHERE id_convocatoria = @id_convocatoria;

    -- El jugador debe ser de la misma selección que la alineación
    IF (@id_seleccion_alineacion IS NOT NULL AND @id_seleccion_jugador IS NOT NULL 
        AND @id_seleccion_alineacion <> @id_seleccion_jugador)
    BEGIN
        SET @MensajeError = @MensajeError + '- El jugador no pertenece a la selección de esta alineación. ';
    END

    -- Máximo 11 titulares
    IF (@es_titular = 1)
    BEGIN
        SELECT @cantidad_titulares = COUNT(*) 
        FROM Torneo.Detalle_alineacion_jugador 
        WHERE id_alineacion_partido = @id_alineacion_partido AND es_titular = 1;

        IF (@cantidad_titulares >= 11)
            SET @MensajeError = @MensajeError + '- La alineación ya cuenta con el máximo de 11 jugadores titulares permitidos. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Detalle_alineacion_jugador (
            id_alineacion_partido, 
            id_convocatoria, 
            id_posicion_partido, 
            es_titular
        )
        VALUES (
            @id_alineacion_partido,
            @id_convocatoria,
            @id_posicion_partido,
            @es_titular
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
-- Procedimiento: Torneo.Registrar_Gol_Partido
-- Descripción: Registra un gol en un partido.
-- Validaciones: El autor debe jugar el partido y el asistente debe ser de su mismo equipo.

CREATE OR ALTER PROCEDURE Torneo.Registrar_Gol_Partido
    @id_convocatoria_autor INT,
    @id_convocatoria_asistencia INT,
    @id_tipo_gol INT,
    @id_periodo_partido INT,
    @id_partido INT,
    @minuto TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(140) = '';
    DECLARE @id_seleccion_autor INT;
    DECLARE @id_seleccion_asistencia INT;
    DECLARE @id_local INT;
    DECLARE @id_visitante INT;

    -- Selecciones que participan en el torneo
    SELECT @id_local = id_seleccion_local, @id_visitante = id_seleccion_visitante
    FROM Torneo.Partido WHERE id_partido = @id_partido;

    -- jugador autor del gol que pertenece a la seleccion
    SELECT @id_seleccion_autor = id_seleccion 
    FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria_autor;

    -- si hubo asistencia, jugador asistente del gol que pertenece a la seleccion
    IF (@id_convocatoria_asistencia IS NOT NULL)
    BEGIN
        SELECT @id_seleccion_asistencia = id_seleccion 
        FROM Participantes.Convocatoria WHERE id_convocatoria = @id_convocatoria_asistencia;
    END

    -- autor del gol debe pertenecer a una de las selecciones del partido.
    IF (@id_seleccion_autor IS NOT NULL AND @id_local IS NOT NULL AND @id_seleccion_autor NOT IN (@id_local, @id_visitante))
        SET @MensajeError = @MensajeError + '- El autor del gol no pertenece a los equipos que disputan el partido. ';

    -- asistente del gol debe pertenecer a una de las selecciones del partido.
    IF (@id_seleccion_asistencia IS NOT NULL AND @id_seleccion_asistencia <> @id_seleccion_autor)
        SET @MensajeError = @MensajeError + '- El asistente debe pertenecer a la misma selección que el autor. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Gol (
            id_convocatoria_autor, 
            id_convocatoria_asistencia, 
            id_tipo_gol, 
            id_periodo_partido, 
            id_partido, 
            minuto
        )
        VALUES (
            @id_convocatoria_autor,
            @id_convocatoria_asistencia,
            @id_tipo_gol,
            @id_periodo_partido,
            @id_partido,
            @minuto
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
-- Procedimiento: Torneo.Registrar_Tarjeta_Partido
-- Descripción: Registra una tarjeta en un partido.
-- Validaciones: El jugador que recibe la tarjeta debe jugar el partido.

CREATE OR ALTER PROCEDURE Torneo.Registrar_Tarjeta_Partido
    @id_partido INT,
    @id_convocatoria INT,
    @id_tipo_tarjeta INT,
    @id_motivo_tarjeta INT,
    @id_periodo_partido INT,
    @minuto TINYINT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(80) = '';
    DECLARE @id_seleccion_jugador INT;
    DECLARE @id_local INT;
    DECLARE @id_visitante INT;

    -- selecciones que juegan el partido
    SELECT @id_local = id_seleccion_local, @id_visitante = id_seleccion_visitante
    FROM Torneo.Partido 
    WHERE id_partido = @id_partido;

    -- selección pertenece el jugador convocado
    SELECT @id_seleccion_jugador = id_seleccion 
    FROM Participantes.Convocatoria 
    WHERE id_convocatoria = @id_convocatoria;

    -- el jugador debe ser local o visitante
    IF (@id_seleccion_jugador IS NOT NULL AND @id_local IS NOT NULL AND @id_seleccion_jugador NOT IN (@id_local, @id_visitante))
    BEGIN
        SET @MensajeError = '- El jugador sancionado no pertenece a los equipos que disputan el partido. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Tarjeta (
            id_partido, 
            id_convocatoria, 
            id_tipo_tarjeta, 
            id_motivo_tarjeta, 
            id_periodo_partido, 
            minuto
        )
        VALUES (
            @id_partido,
            @id_convocatoria,
            @id_tipo_tarjeta,
            @id_motivo_tarjeta,
            @id_periodo_partido,
            @minuto
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