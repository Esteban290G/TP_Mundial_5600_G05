-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- SP de consultas del torneo (alcance To Be):
--   - Torneo.Consultar_Fixture: fixture completo filtrado por sede, fase, selección o fecha.
--   - Torneo.Consultar_Historial_Titularidad: partidos jugados como titular y suplente por jugador.
--   - Torneo.Consultar_Equipo_En_Cancha: reconstrucción de los jugadores en cancha en un minuto dado.
--   - Torneo.Consultar_Historial_Arbitro: partidos arbitrados junto con informes y sanciones post-partido
--
-- Al final del script se asignan permisos EXECUTE a los roles correspondientes.
------------------------------------------

USE COM5600_G05;
GO
------------------------------------------

-- Torneo.Consultar_Fixture
-- Descripción: Devuelve el fixture de partidos con su fase, grupo (si aplica), horario local y UTC,
--              sede (estadio, ciudad, país y huso horario), selecciones, resultado y asistencia.
--              Se ordena cronológicamente por horario UTC.
-- Validaciones: Sede, fase y selección existentes; fecha desde no posterior a fecha hasta.

CREATE OR ALTER PROCEDURE Torneo.Consultar_Fixture
    @id_sede INT = NULL,
    @id_fase INT = NULL,
    @id_seleccion INT = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';

    IF (@id_sede IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_sede = @id_sede))
        SET @MensajeError = @MensajeError + '- La sede indicada no existe. ';

    IF (@id_fase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase))
        SET @MensajeError = @MensajeError + '- La fase indicada no existe. ';

    IF (@id_seleccion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion))
        SET @MensajeError = @MensajeError + '- La selección indicada no existe. ';

    IF (@fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta)
        SET @MensajeError = @MensajeError + '- La fecha desde no puede ser posterior a la fecha hasta. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    SELECT
        P.id_partido,
        F.nombre_fase AS fase,
        CASE WHEN F.nombre_fase = 'Fase de Grupos' AND GL.id_grupo = GV.id_grupo THEN GL.nombre_grupo END AS grupo,
        P.fecha_hora_local,
        P.UTC AS fecha_hora_utc,
        SE.huso_horario,
        SE.nombre_estadio AS estadio,
        CI.nombre AS ciudad,
        PA.nombre AS pais_sede,
        SL.nombre_seleccion AS local,
        CASE WHEN P.goles_local IS NULL OR P.goles_visitante IS NULL THEN 'Sin jugar'
             ELSE CONCAT(P.goles_local, ' - ', P.goles_visitante) END AS resultado,
        SV.nombre_seleccion AS visitante,
        P.asistencia_publico
    FROM Torneo.Partido P
    INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
    INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
    INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
    INNER JOIN Participantes.Pais PA ON PA.id_pais = CI.id_pais
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Torneo.Grupo_torneo GL ON GL.id_grupo = SL.id_grupo
    INNER JOIN Torneo.Grupo_torneo GV ON GV.id_grupo = SV.id_grupo
    WHERE (@id_sede IS NULL OR P.id_sede = @id_sede)
      AND (@id_fase IS NULL OR P.id_fase = @id_fase)
      AND (@id_seleccion IS NULL OR @id_seleccion IN (P.id_seleccion_local, P.id_seleccion_visitante))
      AND (@fecha_desde IS NULL OR CAST(P.fecha_hora_local AS DATE) >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR CAST(P.fecha_hora_local AS DATE) <= @fecha_hasta)
    ORDER BY P.UTC, P.fecha_hora_local, P.id_partido;
END;
GO

------------------------------------------
-- Torneo.Consultar_Historial_Titularidad
-- Descripción: Devuelve el historial de titularidad de los jugadores a lo largo del torneo en dos resultados:
--              1. Resumen por jugador convocado
--              2. Detalle cronológico partido por partido
-- Parámetros: @id_jugador (opcional) y @id_seleccion (opcional).
-- Validaciones: El jugador y la selección indicados deben existir.

CREATE OR ALTER PROCEDURE Torneo.Consultar_Historial_Titularidad
    @id_jugador INT = NULL,
    @id_seleccion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    IF (@id_jugador IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE id_jugador = @id_jugador))
        SET @MensajeError = @MensajeError + '- El jugador indicado no existe. ';

    IF (@id_seleccion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion))
        SET @MensajeError = @MensajeError + '- La selección indicada no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- Resumen acumulado por jugador convocado
    SELECT
        S.nombre_seleccion AS seleccion,
        C.dorsal,
        J.apellido + ', ' + J.nombre AS jugador,
        PO.nombre_posicion AS posicion_habitual,
        C.estado_convocatoria,
        COUNT(D.id_alineacion_partido) AS partidos_en_planilla,
        SUM(CASE WHEN D.es_titular = 1 THEN 1 ELSE 0 END) AS partidos_titular,
        SUM(CASE WHEN D.es_titular = 0 THEN 1 ELSE 0 END) AS partidos_suplente,
        SUM(CASE WHEN SE.minuto_ingreso IS NOT NULL THEN 1 ELSE 0 END) AS ingresos_desde_banco,
        SUM(CASE WHEN SS.minuto_salida IS NOT NULL THEN 1 ELSE 0 END) AS salidas_por_cambio,
        ISNULL(
            CAST(100.0 * SUM(CASE WHEN D.es_titular = 1 THEN 1 ELSE 0 END)
                 / NULLIF(COUNT(D.id_alineacion_partido), 0) AS DECIMAL(5,2)),
            0.00
        ) AS porcentaje_titularidad
    FROM Participantes.Convocatoria C
    INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
    INNER JOIN Participantes.Seleccion S ON S.id_seleccion = C.id_seleccion
    INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
    LEFT JOIN Torneo.Detalle_alineacion_jugador D ON D.id_convocatoria = C.id_convocatoria
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_entra, MIN(minuto) AS minuto_ingreso
        FROM Torneo.Sustitucion
        GROUP BY id_alineacion_partido, id_convocatoria_entra
    ) SE ON SE.id_alineacion_partido = D.id_alineacion_partido AND SE.id_convocatoria_entra = D.id_convocatoria
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_sale, MIN(minuto) AS minuto_salida
        FROM Torneo.Sustitucion
        GROUP BY id_alineacion_partido, id_convocatoria_sale
    ) SS ON SS.id_alineacion_partido = D.id_alineacion_partido AND SS.id_convocatoria_sale = D.id_convocatoria
    WHERE (@id_jugador IS NULL OR C.id_jugador = @id_jugador)
      AND (@id_seleccion IS NULL OR C.id_seleccion = @id_seleccion)
    GROUP BY
        C.id_convocatoria,
        S.nombre_seleccion,
        C.dorsal,
        J.apellido,
        J.nombre,
        PO.nombre_posicion,
        C.estado_convocatoria
    ORDER BY
        S.nombre_seleccion,
        partidos_titular DESC,
        partidos_en_planilla DESC,
        C.dorsal;

    -- Detalle partido por partido en orden cronológico
    SELECT
        S.nombre_seleccion AS seleccion,
        C.dorsal,
        J.apellido + ', ' + J.nombre AS jugador,
        F.nombre_fase AS fase,
        P.fecha_hora_local,
        CASE WHEN P.id_seleccion_local = C.id_seleccion THEN SV.nombre_seleccion ELSE SL.nombre_seleccion END AS rival,
        ET.descripcion_esquema AS esquema_tactico,
        PP.nombre_posicion AS posicion_en_partido,
        CASE WHEN D.es_titular = 1 THEN 'Titular' ELSE 'Suplente' END AS condicion,
        SE.minuto_ingreso,
        SS.minuto_salida
    FROM Torneo.Detalle_alineacion_jugador D
    INNER JOIN Torneo.Alineacion_partido A ON A.id_alineacion_partido = D.id_alineacion_partido
    INNER JOIN Torneo.Esquema_tactico ET ON ET.id_esquema_tactico = A.id_esquema_tactico
    INNER JOIN Torneo.Partido P ON P.id_partido = A.id_partido
    INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
    INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = D.id_convocatoria
    INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
    INNER JOIN Participantes.Seleccion S ON S.id_seleccion = C.id_seleccion
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Participantes.Posicion PP ON PP.id_posicion = D.id_posicion_partido
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_entra, MIN(minuto) AS minuto_ingreso
        FROM Torneo.Sustitucion
        GROUP BY id_alineacion_partido, id_convocatoria_entra
    ) SE ON SE.id_alineacion_partido = D.id_alineacion_partido AND SE.id_convocatoria_entra = D.id_convocatoria
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_sale, MIN(minuto) AS minuto_salida
        FROM Torneo.Sustitucion
        GROUP BY id_alineacion_partido, id_convocatoria_sale
    ) SS ON SS.id_alineacion_partido = D.id_alineacion_partido AND SS.id_convocatoria_sale = D.id_convocatoria
    WHERE (@id_jugador IS NULL OR C.id_jugador = @id_jugador)
      AND (@id_seleccion IS NULL OR C.id_seleccion = @id_seleccion)
    ORDER BY
        S.nombre_seleccion,
        C.dorsal,
        P.UTC,
        P.id_partido;
END;
GO

------------------------------------------
-- Consulta 3: Torneo.Consultar_Equipo_En_Cancha
-- Descripción: Reconstruye qué jugadores estaban en cancha en un minuto dado de un partido.
-- Parámetros: @id_partido (obligatorio), @minuto (obligatorio, 0 a 130) y @id_seleccion (opcional,
--             si es NULL devuelve ambos equipos del encuentro).
-- Validaciones: Partido existente, minuto entre 0 y 130, selección existente y participante del partido.

CREATE OR ALTER PROCEDURE Torneo.Consultar_Equipo_En_Cancha
    @id_partido INT,
    @minuto INT,
    @id_seleccion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @id_local INT;
    DECLARE @id_visitante INT;

    SELECT
        @id_local = id_seleccion_local,
        @id_visitante = id_seleccion_visitante
    FROM Torneo.Partido
    WHERE id_partido = @id_partido;

    IF (@id_partido IS NULL OR @id_local IS NULL)
        SET @MensajeError = @MensajeError + '- El partido indicado no existe. ';

    IF (@minuto IS NULL OR @minuto < 0 OR @minuto > 130)
        SET @MensajeError = @MensajeError + '- El minuto debe estar entre 0 y 130. ';

    IF (@id_seleccion IS NOT NULL)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion)
            SET @MensajeError = @MensajeError + '- La selección indicada no existe. ';
        ELSE IF (@id_local IS NOT NULL AND @id_seleccion NOT IN (@id_local, @id_visitante))
            SET @MensajeError = @MensajeError + '- La selección indicada no participa en ese partido. ';
    END

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    ;WITH expulsiones AS (
        -- Detecta el minuto exacto de expulsión (roja directa o segunda amarilla en el partido)
        SELECT
            T.id_convocatoria,
            MIN(T.minuto) AS minuto_expulsion
        FROM (
            SELECT
                T.id_convocatoria,
                T.minuto,
                TT.descripcion_tarjeta,
                SUM(CASE WHEN TT.descripcion_tarjeta = 'Amarilla' THEN 1 ELSE 0 END)
                    OVER (PARTITION BY T.id_convocatoria ORDER BY T.minuto, T.id_tarjeta) AS amarillas_acum
            FROM Torneo.Tarjeta T
            INNER JOIN Torneo.Tipo_tarjeta TT ON TT.id_tipo_tarjeta = T.id_tipo_tarjeta
            WHERE T.id_partido = @id_partido
        ) AS T
        WHERE T.descripcion_tarjeta = 'Roja'
           OR (T.descripcion_tarjeta = 'Amarilla' AND T.amarillas_acum >= 2)
        GROUP BY T.id_convocatoria
    )
    SELECT
        @minuto AS minuto_consultado,
        S.nombre_seleccion AS seleccion,
        ET.descripcion_esquema AS esquema_tactico,
        C.dorsal,
        J.apellido + ', ' + J.nombre AS jugador,
        PO.nombre_posicion AS posicion_en_partido,
        CASE WHEN D.es_titular = 1 THEN 'Titular' ELSE 'Ingresó por cambio' END AS origen,
        CASE WHEN D.es_titular = 1 THEN 0 ELSE SE.minuto_ingreso END AS en_cancha_desde_minuto
    FROM Torneo.Alineacion_partido A
    INNER JOIN Torneo.Esquema_tactico ET ON ET.id_esquema_tactico = A.id_esquema_tactico
    INNER JOIN Torneo.Detalle_alineacion_jugador D ON D.id_alineacion_partido = A.id_alineacion_partido
    INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = D.id_convocatoria
    INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
    INNER JOIN Participantes.Seleccion S ON S.id_seleccion = A.id_seleccion
    INNER JOIN Participantes.Posicion PO ON PO.id_posicion = D.id_posicion_partido
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_entra, MIN(minuto) AS minuto_ingreso
        FROM Torneo.Sustitucion
        WHERE minuto <= @minuto
        GROUP BY id_alineacion_partido, id_convocatoria_entra
    ) AS SE ON SE.id_alineacion_partido = D.id_alineacion_partido AND SE.id_convocatoria_entra = D.id_convocatoria
    LEFT JOIN (
        SELECT id_alineacion_partido, id_convocatoria_sale, MIN(minuto) AS minuto_salida
        FROM Torneo.Sustitucion
        WHERE minuto <= @minuto
        GROUP BY id_alineacion_partido, id_convocatoria_sale
    ) AS SS ON SS.id_alineacion_partido = D.id_alineacion_partido AND SS.id_convocatoria_sale = D.id_convocatoria
    LEFT JOIN expulsiones EXP ON EXP.id_convocatoria = D.id_convocatoria
    WHERE A.id_partido = @id_partido
      AND (@id_seleccion IS NULL OR A.id_seleccion = @id_seleccion)
      AND (D.es_titular = 1 OR SE.minuto_ingreso IS NOT NULL)
      AND SS.minuto_salida IS NULL
      AND (EXP.minuto_expulsion IS NULL OR EXP.minuto_expulsion > @minuto)
    ORDER BY
        CASE WHEN A.id_seleccion = @id_local THEN 0 ELSE 1 END,
        CASE WHEN PO.nombre_posicion LIKE 'Arquer%' THEN 1
             WHEN PO.nombre_posicion LIKE 'Defens%' THEN 2
             WHEN PO.nombre_posicion LIKE 'Medioc%' THEN 3
             ELSE 4 END,
        C.dorsal;
END;
GO

------------------------------------------
-- Consulta 4: Torneo.Consultar_Historial_Arbitro
-- Descripción: Devuelve el historial de partidos arbitrados junto con los informes y sanciones post-partido
--              en dos resultados:
--              1. Resumen por árbitro
--              2. Detalle cronológico partido por partido
-- Parámetros: @id_arbitro (opcional), @id_pais (opcional), @solo_con_informe (1 = solo partidos con informe)
--             y @solo_con_sancion (1 = solo partidos donde el árbitro recibió una sanción).
-- Validaciones: Árbitro y país existentes.

CREATE OR ALTER PROCEDURE Torneo.Consultar_Historial_Arbitro
    @id_arbitro INT = NULL,
    @id_pais INT = NULL,
    @solo_con_informe BIT = 0,
    @solo_con_sancion BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    IF (@id_arbitro IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Arbitro WHERE id_arbitro = @id_arbitro))
        SET @MensajeError = @MensajeError + '- El árbitro indicado no existe. ';

    IF (@id_pais IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE id_pais = @id_pais))
        SET @MensajeError = @MensajeError + '- El país indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- Resumen por árbitro
    SELECT
        A.id_arbitro,
        A.apellido + ', ' + A.nombre AS arbitro,
        PA.nombre AS pais,
        CA.descripcion AS categoria,
        ISNULL((
            SELECT STRING_AGG(CAST(ID.nombre AS VARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY ID.nombre)
            FROM Participantes.Idioma_arbitro IA
            INNER JOIN Participantes.Idioma ID ON ID.id_idioma = IA.id_idioma
            WHERE IA.id_arbitro = A.id_arbitro
        ), 'Sin registrar') AS idiomas,
        COUNT(DA.id_partido) AS partidos_designados,
        SUM(CASE WHEN RA.descripcion LIKE '%Principal%' THEN 1 ELSE 0 END) AS como_principal,
        SUM(CASE WHEN RA.descripcion LIKE '%Asistente%' THEN 1 ELSE 0 END) AS como_asistente,
        SUM(CASE WHEN RA.descripcion LIKE '%Cuarto%' THEN 1 ELSE 0 END) AS como_cuarto_arbitro,
        SUM(CASE WHEN RA.descripcion LIKE '%VAR%' THEN 1 ELSE 0 END) AS como_var,
        COUNT(IP.id_informe) AS informes_recibidos,
        CAST(AVG(CAST(IP.calificacion_desempenio AS DECIMAL(5,2))) AS DECIMAL(4,2)) AS calificacion_promedio,
        SUM(CASE WHEN IP.sancion_aplicada IS NOT NULL THEN 1 ELSE 0 END) AS sanciones_recibidas
    FROM Participantes.Arbitro A
    INNER JOIN Participantes.Pais PA ON PA.id_pais = A.id_pais
    INNER JOIN Participantes.Categoria_arbitro CA ON CA.id_categoria = A.id_categoria
    LEFT JOIN Torneo.Designacion_arbitral DA ON DA.id_arbitro = A.id_arbitro
    LEFT JOIN Participantes.Rol_arbitro RA ON RA.id_rol_arbitro = DA.id_rol_arbitro
    LEFT JOIN Torneo.Informe_post_partido IP ON IP.id_partido = DA.id_partido AND IP.id_arbitro = DA.id_arbitro
    WHERE (@id_arbitro IS NULL OR A.id_arbitro = @id_arbitro)
      AND (@id_pais IS NULL OR A.id_pais = @id_pais)
    GROUP BY
        A.id_arbitro,
        A.apellido,
        A.nombre,
        PA.nombre,
        CA.descripcion
    HAVING (@solo_con_informe = 0 OR COUNT(IP.id_informe) > 0)
       AND (@solo_con_sancion = 0 OR SUM(CASE WHEN IP.sancion_aplicada IS NOT NULL THEN 1 ELSE 0 END) > 0)
    ORDER BY
        partidos_designados DESC,
        A.apellido,
        A.nombre;

    -- Detalle cronológico de partidos arbitrados e informes/sanciones post-partido
    SELECT
        A.apellido + ', ' + A.nombre AS arbitro,
        PA.nombre AS pais_arbitro,
        F.nombre_fase AS fase,
        P.fecha_hora_local,
        SE.nombre_estadio + ' (' + CI.nombre + ')' AS sede,
        SL.nombre_seleccion + ' vs ' + SV.nombre_seleccion AS partido,
        CASE WHEN P.goles_local IS NULL OR P.goles_visitante IS NULL THEN 'Sin jugar'
             ELSE CONCAT(P.goles_local, ' - ', P.goles_visitante) END AS resultado,
        RA.descripcion AS rol_arbitral,
        IP.calificacion_desempenio,
        ISNULL(IP.observaciones, 'Sin informe registrado') AS observaciones,
        ISNULL(IP.sancion_aplicada, 'Sin sanción') AS sancion_aplicada
    FROM Torneo.Designacion_arbitral DA
    INNER JOIN Participantes.Arbitro A ON A.id_arbitro = DA.id_arbitro
    INNER JOIN Participantes.Pais PA ON PA.id_pais = A.id_pais
    INNER JOIN Participantes.Rol_arbitro RA ON RA.id_rol_arbitro = DA.id_rol_arbitro
    INNER JOIN Torneo.Partido P ON P.id_partido = DA.id_partido
    INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
    INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
    INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    LEFT JOIN Torneo.Informe_post_partido IP ON IP.id_partido = DA.id_partido AND IP.id_arbitro = DA.id_arbitro
    WHERE (@id_arbitro IS NULL OR A.id_arbitro = @id_arbitro)
      AND (@id_pais IS NULL OR A.id_pais = @id_pais)
      AND (@solo_con_informe = 0 OR IP.id_informe IS NOT NULL)
      AND (@solo_con_sancion = 0 OR IP.sancion_aplicada IS NOT NULL)
    ORDER BY
        A.apellido,
        A.nombre,
        P.UTC,
        P.id_partido;
END;
GO

------------------------------------------
-- PERMISOS PARA LOS ROLES DE SEGURIDAD (script 18)
-- rol_administrador hereda EXECUTE automáticamente por tener CONTROL ON SCHEMA::Torneo.
------------------------------------------

IF DATABASE_PRINCIPAL_ID('rol_consulta') IS NOT NULL
BEGIN
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Fixture TO rol_consulta;
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Historial_Titularidad TO rol_consulta;
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Equipo_En_Cancha TO rol_consulta;
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Historial_Arbitro TO rol_consulta;
END

IF DATABASE_PRINCIPAL_ID('rol_cargador_resultados') IS NOT NULL
BEGIN
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Fixture TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Historial_Titularidad TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::Torneo.Consultar_Equipo_En_Cancha TO rol_cargador_resultados;
END
GO