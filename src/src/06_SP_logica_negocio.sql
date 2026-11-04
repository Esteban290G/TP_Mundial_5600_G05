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
-- Validaciones: Jugador pertenece a selección, jugador suspendido para el partido y límite máximo de 11 titulares.

CREATE OR ALTER PROCEDURE Torneo.Confirmar_Planilla_Jugador
    @id_alineacion_partido INT,
    @id_convocatoria INT,
    @id_posicion_partido INT,
    @es_titular BIT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';
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

    -- Un jugador suspendido para este partido no puede integrar la planilla
    IF EXISTS (SELECT 1
               FROM Torneo.Suspension_jugador S
               INNER JOIN Torneo.Alineacion_partido A ON S.id_partido_sancion = A.id_partido
               WHERE A.id_alineacion_partido = @id_alineacion_partido AND S.id_convocatoria = @id_convocatoria)
        SET @MensajeError = @MensajeError + '- El jugador está suspendido para este partido y no puede integrar la planilla. ';

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
-- Descripción: Registra una tarjeta en un partido y, en la misma transacción, genera la suspensión que corresponda
--              según los criterios activos de Torneo.Parametros_suspension:
--                - Roja directa: suspensión por 'fechas_suspension_roja_directa'.
--                - Segunda amarilla en el mismo partido (expulsión por doble amarilla): suspensión por
--                  'fechas_suspension_doble_amarilla'. Las amarillas de ese partido no cuentan para la acumulación
--                  (si la primera había generado una suspensión por acumulación, se reemplaza por la de doble amarilla).
--                - Acumulación: cuando el jugador llega a 'cantidad_amarillas_suspension' amarillas en partidos
--                  distintos (o un múltiplo), 1 fecha de suspensión. Las amarillas se limpian a partir del primer
--                  partido de la fase indicada en 'id_fase_limpieza_amarillas'.
--              El partido de sanción es el siguiente partido programado de la selección del jugador (si existe).
-- Validaciones: El jugador debe jugar el partido, el partido y el tipo de tarjeta deben existir, el jugador no puede
--               haber sido expulsado antes en el partido, minuto entre 0 y 130 y debe haber criterios de suspensión activos.

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

    DECLARE @MensajeError VARCHAR(800) = '';
    DECLARE @id_seleccion_jugador INT;
    DECLARE @id_local INT;
    DECLARE @id_visitante INT;
    DECLARE @fecha_partido DATETIME;
    DECLARE @tipo_tarjeta VARCHAR(10);
    DECLARE @amarillas_partido INT = 0;
    DECLARE @rojas_partido INT = 0;
    DECLARE @fechas_roja TINYINT;
    DECLARE @fechas_doble TINYINT;
    DECLARE @amarillas_para_suspender TINYINT;
    DECLARE @id_fase_limpieza INT;
    DECLARE @fecha_corte DATETIME;
    DECLARE @amarillas_acumuladas INT;
    DECLARE @tipo_suspension VARCHAR(30) = NULL;
    DECLARE @cantidad_fechas TINYINT;
    DECLARE @id_partido_siguiente INT;

    -- selecciones que juegan el partido
    SELECT @id_local = id_seleccion_local, @id_visitante = id_seleccion_visitante, @fecha_partido = fecha_hora_local
    FROM Torneo.Partido 
    WHERE id_partido = @id_partido;

    -- selección a la que pertenece el jugador convocado
    SELECT @id_seleccion_jugador = id_seleccion 
    FROM Participantes.Convocatoria 
    WHERE id_convocatoria = @id_convocatoria;

    -- el partido debe existir
    IF (@id_local IS NULL)
        SET @MensajeError = @MensajeError + '- El partido indicado no existe. ';

    -- el jugador debe ser local o visitante
    IF (@id_seleccion_jugador IS NOT NULL AND @id_local IS NOT NULL AND @id_seleccion_jugador NOT IN (@id_local, @id_visitante))
        SET @MensajeError = @MensajeError + '- El jugador sancionado no pertenece a los equipos que disputan el partido. ';

    -- tipo de tarjeta existente
    SELECT @tipo_tarjeta = descripcion_tarjeta FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @id_tipo_tarjeta;

    IF (@tipo_tarjeta IS NULL)
        SET @MensajeError = @MensajeError + '- El tipo de tarjeta indicado no existe. ';

    -- el jugador no puede haber sido expulsado antes en este partido
    SELECT
        @amarillas_partido = ISNULL(SUM(CASE WHEN TT.descripcion_tarjeta = 'Amarilla' THEN 1 ELSE 0 END), 0),
        @rojas_partido = ISNULL(SUM(CASE WHEN TT.descripcion_tarjeta = 'Roja' THEN 1 ELSE 0 END), 0)
    FROM Torneo.Tarjeta T
    INNER JOIN Torneo.Tipo_tarjeta TT ON T.id_tipo_tarjeta = TT.id_tipo_tarjeta
    WHERE T.id_partido = @id_partido AND T.id_convocatoria = @id_convocatoria;

    IF (@rojas_partido > 0 OR @amarillas_partido >= 2)
        SET @MensajeError = @MensajeError + '- El jugador ya fue expulsado en este partido; no puede recibir otra tarjeta. ';

    -- minuto
    IF (@minuto > 130)
        SET @MensajeError = @MensajeError + '- El minuto de la tarjeta debe estar entre 0 y 130. ';

    -- criterios de suspensión activos (si hay más de uno activo se toma el último)
    SELECT TOP 1
        @fechas_roja = fechas_suspension_roja_directa,
        @fechas_doble = fechas_suspension_doble_amarilla,
        @amarillas_para_suspender = cantidad_amarillas_suspension,
        @id_fase_limpieza = id_fase_limpieza_amarillas
    FROM Torneo.Parametros_suspension
    WHERE activo = 1
    ORDER BY id_parametro DESC;

    IF (@tipo_tarjeta IN ('Amarilla', 'Roja') AND @fechas_roja IS NULL)
        SET @MensajeError = @MensajeError + '- No hay criterios de suspensión activos en Torneo.Parametros_suspension. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- Suspensión que genera la tarjeta
    IF (@tipo_tarjeta = 'Roja')
    BEGIN
        SET @tipo_suspension = 'Roja directa';
        SET @cantidad_fechas = @fechas_roja;
    END
    ELSE IF (@tipo_tarjeta = 'Amarilla' AND @amarillas_partido = 1)
    BEGIN
        SET @tipo_suspension = 'Doble amarilla';
        SET @cantidad_fechas = @fechas_doble;
    END
    ELSE IF (@tipo_tarjeta = 'Amarilla')
    BEGIN
        -- Las amarillas se cuentan desde el primer partido de la fase de limpieza (si este partido es posterior)
        SELECT @fecha_corte = MIN(fecha_hora_local) FROM Torneo.Partido WHERE id_fase = @id_fase_limpieza;

        IF (@fecha_corte IS NULL OR @fecha_partido < @fecha_corte)
            SET @fecha_corte = '19000101';

        -- Partidos anteriores con una sola amarilla del jugador, más la de este partido
        SELECT @amarillas_acumuladas = COUNT(*) + 1
        FROM (
            SELECT T.id_partido
            FROM Torneo.Tarjeta T
            INNER JOIN Torneo.Tipo_tarjeta TT ON T.id_tipo_tarjeta = TT.id_tipo_tarjeta
            INNER JOIN Torneo.Partido P ON T.id_partido = P.id_partido
            WHERE T.id_convocatoria = @id_convocatoria
              AND T.id_partido <> @id_partido
              AND P.fecha_hora_local >= @fecha_corte
              AND P.fecha_hora_local < @fecha_partido
            GROUP BY T.id_partido
            HAVING SUM(CASE WHEN TT.descripcion_tarjeta = 'Amarilla' THEN 1 ELSE 0 END) = 1
        ) AS partidos_con_amarilla;

        IF (@amarillas_acumuladas % @amarillas_para_suspender = 0)
        BEGIN
            SET @tipo_suspension = 'Acumulación de amarillas';
            SET @cantidad_fechas = 1;
        END
    END

    -- Partido en el que se cumple la sanción: el próximo de su selección
    IF (@tipo_suspension IS NOT NULL)
    BEGIN
        SELECT TOP 1 @id_partido_siguiente = id_partido
        FROM Torneo.Partido
        WHERE @id_seleccion_jugador IN (id_seleccion_local, id_seleccion_visitante)
          AND fecha_hora_local > @fecha_partido
        ORDER BY fecha_hora_local;
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

        IF (@tipo_suspension = 'Doble amarilla'
            AND EXISTS (SELECT 1 FROM Torneo.Suspension_jugador
                        WHERE id_convocatoria = @id_convocatoria AND id_partido_origen = @id_partido
                          AND tipo_suspension = 'Acumulación de amarillas'))
        BEGIN
            -- La primera amarilla de este partido había completado la acumulación: deja de contar y
            -- la suspensión pasa a ser por doble amarilla
            UPDATE Torneo.Suspension_jugador
            SET tipo_suspension = @tipo_suspension,
                cantidad_fechas = @cantidad_fechas
            WHERE id_convocatoria = @id_convocatoria AND id_partido_origen = @id_partido
              AND tipo_suspension = 'Acumulación de amarillas';
        END
        ELSE IF (@tipo_suspension IS NOT NULL)
        BEGIN
            INSERT INTO Torneo.Suspension_jugador (
                id_convocatoria,
                id_partido_origen,
                id_partido_sancion,
                cantidad_fechas,
                sancion_cumplida,
                tipo_suspension
            )
            VALUES (
                @id_convocatoria,
                @id_partido,
                @id_partido_siguiente,
                @cantidad_fechas,
                0,
                @tipo_suspension
            );
        END

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

    IF (@tipo_suspension IS NOT NULL)
        PRINT CONCAT('Se generó una suspensión de ', @cantidad_fechas, ' fecha(s) por ', LOWER(@tipo_suspension), '.');
END;
GO
------------------------------------------
-- Procedimiento: Publicidad.Simular_Prime_Time_Partido
-- Descripción: Simula, para un partido, en qué mercados (países con huso horario registrado) el horario
--              de disputa cae en prime time. Convierte el horario UTC del partido a la hora local de cada país.
--              El rango de prime time es parametrizable (por defecto de 19:00 a 23:00, hora local del mercado).
-- Validaciones: El partido debe existir y tener horario UTC, el rango de prime time debe ser válido
--               y debe haber al menos un país con huso horario registrado.

CREATE OR ALTER PROCEDURE Publicidad.Simular_Prime_Time_Partido
    @id_partido INT,
    @hora_inicio_prime TIME(0) = '19:00:00',
    @hora_fin_prime TIME(0) = '23:00:00'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    -- El partido debe existir y tener horario UTC
    IF NOT EXISTS (SELECT 1 FROM Torneo.Partido WHERE id_partido = @id_partido)
        SET @MensajeError = @MensajeError + '- El partido indicado no existe. ';
    ELSE IF EXISTS (SELECT 1 FROM Torneo.Partido WHERE id_partido = @id_partido AND UTC IS NULL)
        SET @MensajeError = @MensajeError + '- El partido no tiene registrado su horario UTC. ';

    -- Rango de prime time válido
    IF (@hora_inicio_prime IS NULL OR @hora_fin_prime IS NULL OR @hora_inicio_prime = @hora_fin_prime)
        SET @MensajeError = @MensajeError + '- El rango de prime time debe tener hora de inicio y de fin distintas. ';

    -- Países con huso horario registrado
    IF NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE Torneo.fn_Offset_Huso_Minutos(huso_horario) IS NOT NULL)
        SET @MensajeError = @MensajeError + '- No hay países con huso horario registrado para simular. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    SELECT
        PT.id_partido,
        PT.mercado,
        PT.huso_horario,
        PT.fecha_hora_utc_partido,
        PT.fecha_hora_mercado AS fecha_hora_local_mercado,
        PT.es_prime_time
    FROM Publicidad.fn_Mercados_Prime_Time(@id_partido, @hora_inicio_prime, @hora_fin_prime) PT
    ORDER BY PT.es_prime_time DESC, PT.fecha_hora_mercado, PT.mercado;
END;
GO

------------------------------------------
-- Procedimiento: Publicidad.Asignar_Publicidad_Partido
-- Descripción: Propone y registra las cuatro (4) piezas publicitarias que ocupan los espacios de un partido.
--              Piezas candidatas: las de campañas vigentes en la fecha del partido que tengan al menos un
--              mercado de interés. Para cada pieza se toma su "mejor mercado" y se ordena por estos criterios
--              (definidos por el grupo, en este orden):
--                1. El mercado es el país de alguna de las selecciones que juegan el partido.
--                2. El horario del partido cae en prime time en ese mercado (hora local del país).
--                3. Mayor PBI per cápita del mercado (poder adquisitivo).
--                4. Desempate: mayor presupuesto de la campaña y, por último, el id de la pieza.
--              Se priorizó el prime time sobre el PBI porque un mercado rico que ve el partido de madrugada
--              aporta menos audiencia; el PBI funciona mejor como desempate porque es un valor continuo.
--              La tarifa aplicada es la tarifa base de la franja horaria que cubre la hora local del partido.
--              Las exhibiciones quedan registradas como historial para facturar al anunciante.
--              Devuelve el ranking completo de candidatas indicando qué espacio ocupa cada una.
-- Validaciones: El partido debe existir, no debe tener publicidad asignada, debe existir una franja tarifaria
--               para su horario, el rango de prime time debe ser válido y debe haber al menos 4 piezas candidatas.

CREATE OR ALTER PROCEDURE Publicidad.Asignar_Publicidad_Partido
    @id_partido INT,
    @hora_inicio_prime TIME(0) = '19:00:00',
    @hora_fin_prime TIME(0) = '23:00:00'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(1000) = '';
    DECLARE @fecha_hora_local DATETIME;
    DECLARE @fecha_partido DATE;
    DECLARE @id_pais_local INT;
    DECLARE @id_pais_visitante INT;
    DECLARE @id_franja INT;
    DECLARE @tarifa_base DECIMAL(18,2);
    DECLARE @cantidad_candidatas INT;
    DECLARE @espacios_por_partido TINYINT = 4;

    -- Datos del partido y países de las selecciones que lo disputan
    SELECT
        @fecha_hora_local = P.fecha_hora_local,
        @id_pais_local = SL.id_pais,
        @id_pais_visitante = SV.id_pais
    FROM Torneo.Partido P
    INNER JOIN Participantes.Seleccion SL ON P.id_seleccion_local = SL.id_seleccion
    INNER JOIN Participantes.Seleccion SV ON P.id_seleccion_visitante = SV.id_seleccion
    WHERE P.id_partido = @id_partido;

    -- El partido debe existir
    IF (@fecha_hora_local IS NULL)
        SET @MensajeError = @MensajeError + '- El partido indicado no existe. ';
    ELSE
    BEGIN
        SET @fecha_partido = CAST(@fecha_hora_local AS DATE);

        -- No debe tener publicidad asignada (se preserva el historial de lo ya facturable)
        IF EXISTS (SELECT 1 FROM Publicidad.Exhibicion_publicidad_partido WHERE id_partido = @id_partido)
            SET @MensajeError = @MensajeError + '- El partido ya tiene publicidad asignada; para reasignar primero deben darse de baja sus exhibiciones. ';

        -- Franja tarifaria que cubre la hora local del partido (si hay más de una, la de mayor tarifa)
        SELECT TOP 1
            @id_franja = id_franja,
            @tarifa_base = tarifa_base_usd
        FROM Publicidad.Franja_horaria_tarifa
        WHERE CAST(@fecha_hora_local AS TIME(0)) BETWEEN hora_inicio_local AND hora_fin_local
        ORDER BY tarifa_base_usd DESC, id_franja;

        IF (@id_franja IS NULL)
            SET @MensajeError = @MensajeError + '- No hay una franja tarifaria que cubra el horario local del partido ('
                + CONVERT(VARCHAR(5), @fecha_hora_local, 108) + '). ';
    END

    -- Rango de prime time válido
    IF (@hora_inicio_prime IS NULL OR @hora_fin_prime IS NULL OR @hora_inicio_prime = @hora_fin_prime)
        SET @MensajeError = @MensajeError + '- El rango de prime time debe tener hora de inicio y de fin distintas. ';

    -- Piezas candidatas con cada uno de sus mercados de interés
    CREATE TABLE #candidatas (
        id_pieza INT NOT NULL,
        id_campania INT NOT NULL,
        presupuesto DECIMAL(18,2) NOT NULL,
        id_pais_mercado INT NOT NULL,
        mercado VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
        es_mercado_partido BIT NOT NULL,
        es_prime_time BIT NOT NULL,
        pbi_per_capita DECIMAL(18,2) NOT NULL,
        fecha_hora_mercado DATETIME NULL
    );

    INSERT INTO #candidatas (id_pieza, id_campania, presupuesto, id_pais_mercado, mercado,
                             es_mercado_partido, es_prime_time, pbi_per_capita, fecha_hora_mercado)
    SELECT
        PZ.id_pieza,
        C.id_campania,
        C.presupuesto,
        M.id_pais,
        PA.nombre,
        CASE WHEN M.id_pais IN (@id_pais_local, @id_pais_visitante) THEN 1 ELSE 0 END,
        ISNULL(PT.es_prime_time, 0),
        ISNULL(PA.pbi_per_capita, 0),
        PT.fecha_hora_mercado
    FROM Publicidad.Pieza_publicitaria PZ
    INNER JOIN Publicidad.Campania_publicitaria C ON PZ.id_campania = C.id_campania
    INNER JOIN Publicidad.Mercado_interes_campania M ON C.id_campania = M.id_campania
    INNER JOIN Participantes.Pais PA ON M.id_pais = PA.id_pais
    LEFT JOIN Publicidad.fn_Mercados_Prime_Time(@id_partido, @hora_inicio_prime, @hora_fin_prime) PT ON PT.id_pais = M.id_pais
    WHERE @fecha_partido BETWEEN C.fecha_inicio AND C.fecha_fin;

    SELECT @cantidad_candidatas = COUNT(DISTINCT id_pieza) FROM #candidatas;

    -- Deben poder ocuparse los cuatro espacios
    IF (@fecha_hora_local IS NOT NULL AND @cantidad_candidatas < @espacios_por_partido)
        SET @MensajeError = @MensajeError + '- Solo hay ' + CAST(@cantidad_candidatas AS VARCHAR(10))
            + ' pieza(s) candidata(s) vigente(s) para la fecha del partido; se necesitan '
            + CAST(@espacios_por_partido AS VARCHAR(2)) + '. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- Ranking: mejor mercado de cada pieza y orden según los criterios de prioridad
    ;WITH mejor_mercado AS (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY id_pieza
                               ORDER BY es_mercado_partido DESC, es_prime_time DESC, pbi_per_capita DESC, id_pais_mercado) AS rn
        FROM #candidatas
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY es_mercado_partido DESC, es_prime_time DESC, pbi_per_capita DESC,
                                    presupuesto DESC, id_pieza) AS posicion,
        id_pieza,
        id_campania,
        mercado,
        es_mercado_partido,
        es_prime_time,
        pbi_per_capita,
        fecha_hora_mercado
    INTO #ranking
    FROM mejor_mercado
    WHERE rn = 1;

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
        SELECT
            @id_partido,
            posicion,
            id_pieza,
            @tarifa_base,
            @id_franja,
            @fecha_hora_local
        FROM #ranking
        WHERE posicion <= @espacios_por_partido;

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

    -- Resultado: ranking de candidatas y espacio asignado (NULL = quedó afuera)
    SELECT
        CASE WHEN R.posicion <= @espacios_por_partido THEN R.posicion END AS numero_espacio,
        R.posicion,
        A.nombre_anunciante,
        C.nombre_campania,
        PZ.nombre_pieza,
        R.mercado AS mercado_priorizado,
        R.es_mercado_partido,
        R.es_prime_time,
        R.fecha_hora_mercado AS hora_local_mercado,
        R.pbi_per_capita,
        CASE WHEN R.posicion <= @espacios_por_partido THEN @tarifa_base END AS tarifa_aplicada_usd
    FROM #ranking R
    INNER JOIN Publicidad.Pieza_publicitaria PZ ON R.id_pieza = PZ.id_pieza
    INNER JOIN Publicidad.Campania_publicitaria C ON R.id_campania = C.id_campania
    INNER JOIN Publicidad.Anunciante A ON C.id_anunciante = A.id_anunciante
    ORDER BY R.posicion;
END;
GO

------------------------------------------
-- Procedimiento: Torneo.Importar_Fixture
-- Descripción: Importa el fixture (sedes, horarios y resultados) desde la tabla Torneo.Staging_fixture,
--              donde el proceso de lectura del archivo o del scraping deja los datos crudos en texto.
--              Procesa solo las filas en estado 'Pendiente' y hace un upsert sobre Torneo.Partido:
--                - Clave del partido: fase + selección local + selección visitante.
--                - Si el partido no existe se inserta; si existe se actualizan sede, horarios, resultado
--                  y asistencia (un resultado o asistencia vacíos en el archivo no borran lo ya cargado).
--              La fase, la sede y las selecciones se buscan por nombre (la selección también por nombre
--              o código ISO del país). Si no viene la hora UTC se calcula con el huso horario de la sede.
--              Importación parcial: las filas válidas se importan y las inválidas quedan marcadas con
--              estado 'Error' y el detalle de todos sus problemas. Si el mismo partido aparece repetido
--              en el archivo se importa la última aparición y las anteriores quedan como 'Duplicado'.
--              Cada ejecución queda registrada en Torneo.Log_importacion (también las fallidas).
-- Validaciones: Nombre del archivo vacío, staging sin filas pendientes y, por fila: datos obligatorios
--               faltantes, fase/sede/selecciones inexistentes, sede ambigua, local igual a visitante,
--               fechas inválidas, UTC incoherente con el huso de la sede, goles y asistencia no numéricos o
--               fuera de rango, resultado incompleto, resultado de un partido futuro, asistencia mayor a la
--               capacidad y choque de horario con otro partido de la sede (en la base o dentro del archivo).

CREATE OR ALTER PROCEDURE Torneo.Importar_Fixture
    @nombre_archivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_log INT;
    DECLARE @total INT = 0;
    DECLARE @insertados INT = 0;
    DECLARE @actualizados INT = 0;
    DECLARE @con_error INT = 0;
    DECLARE @duplicados INT = 0;
    DECLARE @estado_log VARCHAR(50);

    -- Nombre del archivo
    IF (@nombre_archivo IS NULL OR LTRIM(RTRIM(@nombre_archivo)) = '')
        SET @MensajeError = @MensajeError + '- Debe indicarse el nombre del archivo o fuente importada. ';

    -- Filas pendientes
    IF NOT EXISTS (SELECT 1 FROM Torneo.Staging_fixture WHERE estado_proceso = 'Pendiente')
        SET @MensajeError = @MensajeError + '- No hay filas pendientes de procesar en Torneo.Staging_fixture. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    ------------------------------------------
    -- 1) Copia de trabajo de las filas pendientes (textos sin espacios y vacíos como NULL)
    CREATE TABLE #filas (
        id_fila INT NOT NULL PRIMARY KEY,
        fase_txt VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        estadio_txt VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        local_txt VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        visitante_txt VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
        fecha_local_txt VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        fecha_utc_txt VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
        goles_local_txt VARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        goles_visitante_txt VARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
        asistencia_txt VARCHAR(20) COLLATE DATABASE_DEFAULT NULL,
        id_fase INT NULL,
        id_sede INT NULL,
        cantidad_sedes INT NULL,
        capacidad INT NULL,
        offset_sede INT NULL,
        id_local INT NULL,
        id_visitante INT NULL,
        fecha_local DATETIME2(0) NULL,
        fecha_utc DATETIME2(0) NULL,
        goles_local INT NULL,
        goles_visitante INT NULL,
        asistencia INT NULL,
        id_partido_existente INT NULL,
        mensaje_error VARCHAR(2000) COLLATE DATABASE_DEFAULT NULL,
        estado VARCHAR(20) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #filas (id_fila, fase_txt, estadio_txt, local_txt, visitante_txt, fecha_local_txt,
                        fecha_utc_txt, goles_local_txt, goles_visitante_txt, asistencia_txt)
    SELECT
        id_fila,
        NULLIF(LTRIM(RTRIM(fase)), ''),
        NULLIF(LTRIM(RTRIM(estadio)), ''),
        NULLIF(LTRIM(RTRIM(seleccion_local)), ''),
        NULLIF(LTRIM(RTRIM(seleccion_visitante)), ''),
        NULLIF(LTRIM(RTRIM(fecha_hora_local)), ''),
        NULLIF(LTRIM(RTRIM(fecha_hora_utc)), ''),
        NULLIF(LTRIM(RTRIM(goles_local)), ''),
        NULLIF(LTRIM(RTRIM(goles_visitante)), ''),
        NULLIF(LTRIM(RTRIM(asistencia)), '')
    FROM Torneo.Staging_fixture
    WHERE estado_proceso = 'Pendiente';

    SELECT @total = COUNT(*) FROM #filas;

    ------------------------------------------
    -- 2) Resolución de claves por nombre

    -- Fase
    UPDATE F
    SET id_fase = FA.id_fase
    FROM #filas F
    INNER JOIN Torneo.Fase FA ON FA.nombre_fase = F.fase_txt;

    -- Sede (por nombre de estadio; si hay más de una con el mismo nombre se informa como ambigua)
    UPDATE F
    SET cantidad_sedes = S.cantidad,
        id_sede = CASE WHEN S.cantidad = 1 THEN S.id_sede END,
        capacidad = CASE WHEN S.cantidad = 1 THEN S.capacidad END,
        offset_sede = CASE WHEN S.cantidad = 1 THEN S.offset_minutos END
    FROM #filas F
    CROSS APPLY (
        SELECT
            COUNT(*) AS cantidad,
            MIN(SE.id_sede) AS id_sede,
            MIN(SE.capacidad) AS capacidad,
            MIN(Torneo.fn_Offset_Huso_Minutos(SE.huso_horario)) AS offset_minutos
        FROM Torneo.Sede SE
        WHERE SE.nombre_estadio = F.estadio_txt
    ) S;

    -- Selecciones (por nombre de la selección, nombre del país o código ISO; prioriza el nombre de la selección)
    UPDATE F
    SET id_local = (SELECT TOP 1 SE.id_seleccion
                    FROM Participantes.Seleccion SE
                    INNER JOIN Participantes.Pais PA ON SE.id_pais = PA.id_pais
                    WHERE F.local_txt IN (SE.nombre_seleccion, PA.nombre, PA.codigo_iso)
                    ORDER BY CASE WHEN SE.nombre_seleccion = F.local_txt THEN 0 ELSE 1 END, SE.id_seleccion),
        id_visitante = (SELECT TOP 1 SE.id_seleccion
                        FROM Participantes.Seleccion SE
                        INNER JOIN Participantes.Pais PA ON SE.id_pais = PA.id_pais
                        WHERE F.visitante_txt IN (SE.nombre_seleccion, PA.nombre, PA.codigo_iso)
                        ORDER BY CASE WHEN SE.nombre_seleccion = F.visitante_txt THEN 0 ELSE 1 END, SE.id_seleccion)
    FROM #filas F;

    ------------------------------------------
    -- 3) Conversión de tipos (formato de fecha recomendado: ISO 'aaaa-mm-dd hh:mm:ss')
    UPDATE #filas
    SET fecha_local = TRY_CAST(fecha_local_txt AS DATETIME2(0)),
        fecha_utc = TRY_CAST(fecha_utc_txt AS DATETIME2(0)),
        goles_local = TRY_CAST(goles_local_txt AS INT),
        goles_visitante = TRY_CAST(goles_visitante_txt AS INT),
        asistencia = TRY_CAST(asistencia_txt AS INT);

    -- Fechas fuera de un rango razonable se consideran inválidas (y se evita el desborde al pasar a DATETIME)
    UPDATE #filas SET fecha_local = NULL WHERE YEAR(fecha_local) NOT BETWEEN 1930 AND 2100;
    UPDATE #filas SET fecha_utc = NULL WHERE YEAR(fecha_utc) NOT BETWEEN 1930 AND 2100;

    -- Si no vino la hora UTC, se calcula con el huso horario de la sede
    UPDATE #filas
    SET fecha_utc = DATEADD(MINUTE, -offset_sede, fecha_local)
    WHERE fecha_utc_txt IS NULL AND fecha_local IS NOT NULL AND offset_sede IS NOT NULL;

    -- Partido existente con la misma clave (para decidir insert o update)
    UPDATE F
    SET id_partido_existente = P.id_partido
    FROM #filas F
    INNER JOIN Torneo.Partido P ON P.id_fase = F.id_fase
                               AND P.id_seleccion_local = F.id_local
                               AND P.id_seleccion_visitante = F.id_visitante;

    ------------------------------------------
    -- 4) Validaciones por fila: se acumulan todos los problemas de cada fila
    UPDATE F
    SET mensaje_error = NULLIF(CONCAT(
        CASE WHEN F.fase_txt IS NULL THEN '- Falta la fase. '
             WHEN F.id_fase IS NULL THEN '- La fase "' + F.fase_txt + '" no existe. ' END,
        CASE WHEN F.estadio_txt IS NULL THEN '- Falta el estadio. '
             WHEN F.cantidad_sedes = 0 THEN '- El estadio "' + F.estadio_txt + '" no existe. '
             WHEN F.cantidad_sedes > 1 THEN '- Hay más de una sede llamada "' + F.estadio_txt + '". ' END,
        CASE WHEN F.local_txt IS NULL THEN '- Falta la selección local. '
             WHEN F.id_local IS NULL THEN '- La selección "' + F.local_txt + '" no existe. ' END,
        CASE WHEN F.visitante_txt IS NULL THEN '- Falta la selección visitante. '
             WHEN F.id_visitante IS NULL THEN '- La selección "' + F.visitante_txt + '" no existe. ' END,
        CASE WHEN F.id_local = F.id_visitante THEN '- La selección local y la visitante son la misma. ' END,
        CASE WHEN F.fecha_local_txt IS NULL THEN '- Falta la fecha y hora local. '
             WHEN F.fecha_local IS NULL THEN '- Fecha y hora local inválida: "' + F.fecha_local_txt + '". ' END,
        CASE WHEN F.fecha_utc_txt IS NOT NULL AND F.fecha_utc IS NULL THEN '- Fecha y hora UTC inválida: "' + F.fecha_utc_txt + '". '
             WHEN F.fecha_utc_txt IS NULL AND F.fecha_local IS NOT NULL AND F.id_sede IS NOT NULL AND F.offset_sede IS NULL
                  THEN '- No vino la hora UTC y no se puede calcular porque la sede no tiene un huso horario válido. '
             WHEN F.fecha_utc_txt IS NOT NULL AND F.fecha_local IS NOT NULL AND F.offset_sede IS NOT NULL
                  AND DATEDIFF(MINUTE, F.fecha_utc, F.fecha_local) <> F.offset_sede
                  THEN '- La hora UTC no coincide con la hora local según el huso horario de la sede. ' END,
        CASE WHEN F.goles_local_txt IS NOT NULL AND (F.goles_local IS NULL OR F.goles_local NOT BETWEEN 0 AND 255)
             THEN '- Goles del local inválidos: "' + F.goles_local_txt + '". ' END,
        CASE WHEN F.goles_visitante_txt IS NOT NULL AND (F.goles_visitante IS NULL OR F.goles_visitante NOT BETWEEN 0 AND 255)
             THEN '- Goles del visitante inválidos: "' + F.goles_visitante_txt + '". ' END,
        CASE WHEN (F.goles_local_txt IS NULL AND F.goles_visitante_txt IS NOT NULL)
               OR (F.goles_local_txt IS NOT NULL AND F.goles_visitante_txt IS NULL)
             THEN '- El resultado debe informar los goles de ambas selecciones. ' END,
        CASE WHEN F.goles_local_txt IS NOT NULL AND F.fecha_local > GETDATE()
             THEN '- No se puede informar el resultado de un partido que todavía no se jugó. ' END,
        CASE WHEN F.asistencia_txt IS NOT NULL AND (F.asistencia IS NULL OR F.asistencia < 0)
                  THEN '- Asistencia inválida: "' + F.asistencia_txt + '". '
             WHEN F.asistencia > F.capacidad
                  THEN CONCAT('- La asistencia (', F.asistencia, ') supera la capacidad del estadio (', F.capacidad, '). ') END,
        CASE WHEN F.id_sede IS NOT NULL AND F.fecha_local IS NOT NULL
                  AND EXISTS (SELECT 1 FROM Torneo.Partido P
                              WHERE P.id_sede = F.id_sede
                                AND P.fecha_hora_local = F.fecha_local
                                AND P.id_partido <> ISNULL(F.id_partido_existente, 0))
             THEN '- La sede ya tiene otro partido programado en ese horario. ' END
    ), '')
    FROM #filas F;

    UPDATE #filas SET estado = 'Error' WHERE mensaje_error IS NOT NULL;

    -- Partidos repetidos dentro del archivo: se conserva la última aparición válida
    ;WITH repetidos AS (
        SELECT estado, mensaje_error,
               ROW_NUMBER() OVER (PARTITION BY id_fase, id_local, id_visitante ORDER BY id_fila DESC) AS rn
        FROM #filas
        WHERE estado IS NULL
    )
    UPDATE repetidos
    SET estado = 'Duplicado',
        mensaje_error = '- Partido repetido en el archivo: se importa su última aparición. '
    WHERE rn > 1;

    -- Dos partidos distintos del archivo en la misma sede y horario: se importa el primero
    ;WITH choques AS (
        SELECT estado, mensaje_error,
               ROW_NUMBER() OVER (PARTITION BY id_sede, fecha_local ORDER BY id_fila) AS rn
        FROM #filas
        WHERE estado IS NULL
    )
    UPDATE choques
    SET estado = 'Error',
        mensaje_error = '- Otra fila del archivo programa un partido distinto en la misma sede y horario. '
    WHERE rn > 1;

    UPDATE #filas
    SET estado = CASE WHEN id_partido_existente IS NULL THEN 'Insertado' ELSE 'Actualizado' END
    WHERE estado IS NULL;

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
    -- 5) Upsert y registro del resultado en una única transacción
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados,
                                            registros_con_error, estado)
        VALUES (LTRIM(RTRIM(@nombre_archivo)), GETDATE(), @total, @con_error + @duplicados, @estado_log);

        SET @id_log = SCOPE_IDENTITY();

        -- Update de los partidos existentes (un resultado o asistencia vacíos no pisan lo ya cargado)
        UPDATE P
        SET id_sede = F.id_sede,
            fecha_hora_local = F.fecha_local,
            UTC = F.fecha_utc,
            goles_local = ISNULL(F.goles_local, P.goles_local),
            goles_visitante = ISNULL(F.goles_visitante, P.goles_visitante),
            asistencia_publico = ISNULL(F.asistencia, P.asistencia_publico)
        FROM Torneo.Partido P
        INNER JOIN #filas F ON P.id_partido = F.id_partido_existente
        WHERE F.estado = 'Actualizado';

        -- Insert de los partidos nuevos
        INSERT INTO Torneo.Partido (id_sede, id_fase, id_seleccion_local, id_seleccion_visitante, id_importacion_origen,
                                    fecha_hora_local, asistencia_publico, goles_local, goles_visitante, UTC)
        SELECT id_sede, id_fase, id_local, id_visitante, @id_log,
               fecha_local, asistencia, goles_local, goles_visitante, fecha_utc
        FROM #filas
        WHERE estado = 'Insertado';

        -- Resultado de cada fila en el staging
        UPDATE S
        SET estado_proceso = F.estado,
            mensaje_error = F.mensaje_error,
            id_log = @id_log
        FROM Torneo.Staging_fixture S
        INNER JOIN #filas F ON S.id_fila = F.id_fila;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Queda registrado el intento fallido (las filas siguen pendientes para reintentar)
        INSERT INTO Torneo.Log_importacion (nombre_archivo_o_fuente, fecha_hora_ejecucion, registros_procesados,
                                            registros_con_error, estado)
        VALUES (LTRIM(RTRIM(@nombre_archivo)), GETDATE(), @total, @total, 'Fallido');

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;

    ------------------------------------------
    -- 6) Reporte de la importación
    PRINT CONCAT('Importación "', @nombre_archivo, '": ', @total, ' filas leídas, ', @insertados, ' insertadas, ',
                 @actualizados, ' actualizadas, ', @con_error, ' con error y ', @duplicados, ' duplicadas.');

    SELECT
        F.id_fila,
        F.estado,
        F.fase_txt AS fase,
        F.local_txt AS seleccion_local,
        F.visitante_txt AS seleccion_visitante,
        F.fecha_local_txt AS fecha_hora_local,
        ISNULL(F.mensaje_error, '') AS detalle
    FROM #filas F
    ORDER BY F.id_fila;
END;
GO
