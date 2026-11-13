-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Stored Procedures de reportes (Entrega 7) - segunda parte
--   - Publicidad.Reporte_Ocupacion_Publicitaria: anunciantes en los 4 espacios por sede y partido, e ingresos.
--   - Publicidad.Reporte_Matriz_Prime_Time: tabla cruzada (PIVOT dinámico) partido x mercado.
--   - Participantes.Reporte_Selecciones_Plantillas: selecciones con sus convocados anidados (devuelve XML).
--   - Torneo.Reporte_Resultados: resultados de los encuentros y tabla de posiciones de cada grupo.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Reporte: Publicidad.Reporte_Ocupacion_Publicitaria
-- Descripción: Ocupación publicitaria por sede y partido: qué anunciante (y pieza) ocupó cada uno de los cuatro
--              espacios y cuánto se facturó. Usa GROUPING SETS para agregar, en la misma consulta, el subtotal
--              de cada sede y el total general. Un segundo resultado resume los ingresos por anunciante.
-- Parámetros: @id_sede (opcional) y rango de fechas locales de los partidos (opcional).
-- Validaciones: La sede debe existir y la fecha desde no puede ser posterior a la fecha hasta.

CREATE OR ALTER PROCEDURE Publicidad.Reporte_Ocupacion_Publicitaria
    @id_sede INT = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(300) = '';

    IF (@id_sede IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Sede WHERE id_sede = @id_sede))
        SET @MensajeError = @MensajeError + '- La sede indicada no existe. ';

    IF (@fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta)
        SET @MensajeError = @MensajeError + '- La fecha desde no puede ser posterior a la fecha hasta. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    ;WITH exhibiciones AS (
        SELECT
            SE.id_sede,
            SE.nombre_estadio + ' (' + CI.nombre + ')' AS sede,
            P.id_partido,
            P.fecha_hora_local,
            SL.nombre_seleccion + ' vs ' + SV.nombre_seleccion AS partido,
            E.numero_espacio,
            A.nombre_anunciante + ' - ' + PZ.nombre_pieza AS anunciante_pieza,
            E.tarifa_aplicada_usd
        FROM Publicidad.Exhibicion_publicidad_partido E
        INNER JOIN Torneo.Partido P ON P.id_partido = E.id_partido
        INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
        INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
        INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
        INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
        INNER JOIN Publicidad.Pieza_publicitaria PZ ON PZ.id_pieza = E.id_pieza
        INNER JOIN Publicidad.Campania_publicitaria C ON C.id_campania = PZ.id_campania
        INNER JOIN Publicidad.Anunciante A ON A.id_anunciante = C.id_anunciante
        WHERE (@id_sede IS NULL OR P.id_sede = @id_sede)
          AND (@fecha_desde IS NULL OR CAST(P.fecha_hora_local AS DATE) >= @fecha_desde)
          AND (@fecha_hasta IS NULL OR CAST(P.fecha_hora_local AS DATE) <= @fecha_hasta)
    )
    SELECT
        CASE WHEN GROUPING(sede) = 1 THEN 'TOTAL GENERAL' ELSE sede END AS sede,
        CASE WHEN GROUPING(sede) = 1 THEN NULL
             WHEN GROUPING(id_partido) = 1 THEN 'Subtotal de la sede'
             ELSE partido END AS partido,
        CASE WHEN GROUPING(id_partido) = 0 THEN MAX(fecha_hora_local) END AS fecha_hora_local,
        CASE WHEN GROUPING(id_partido) = 0 THEN MAX(CASE WHEN numero_espacio = 1 THEN anunciante_pieza END) END AS espacio_1,
        CASE WHEN GROUPING(id_partido) = 0 THEN MAX(CASE WHEN numero_espacio = 2 THEN anunciante_pieza END) END AS espacio_2,
        CASE WHEN GROUPING(id_partido) = 0 THEN MAX(CASE WHEN numero_espacio = 3 THEN anunciante_pieza END) END AS espacio_3,
        CASE WHEN GROUPING(id_partido) = 0 THEN MAX(CASE WHEN numero_espacio = 4 THEN anunciante_pieza END) END AS espacio_4,
        COUNT(*) AS espacios_ocupados,
        COUNT(DISTINCT id_partido) AS partidos,
        SUM(tarifa_aplicada_usd) AS ingresos_usd
    FROM exhibiciones
    GROUP BY GROUPING SETS ((sede, id_partido, partido), (sede), ())
    ORDER BY GROUPING(sede), sede, GROUPING(id_partido), MAX(fecha_hora_local);

    -- Ingresos por anunciante en el mismo período
    SELECT
        A.nombre_anunciante,
        PA.nombre AS pais_anunciante,
        COUNT(*) AS espacios_ocupados,
        COUNT(DISTINCT E.id_partido) AS partidos,
        SUM(E.tarifa_aplicada_usd) AS ingresos_usd,
        CAST(100.0 * SUM(E.tarifa_aplicada_usd) / NULLIF(SUM(SUM(E.tarifa_aplicada_usd)) OVER (), 0) AS DECIMAL(5,2)) AS porcentaje_ingresos
    FROM Publicidad.Exhibicion_publicidad_partido E
    INNER JOIN Torneo.Partido P ON P.id_partido = E.id_partido
    INNER JOIN Publicidad.Pieza_publicitaria PZ ON PZ.id_pieza = E.id_pieza
    INNER JOIN Publicidad.Campania_publicitaria C ON C.id_campania = PZ.id_campania
    INNER JOIN Publicidad.Anunciante A ON A.id_anunciante = C.id_anunciante
    INNER JOIN Participantes.Pais PA ON PA.id_pais = A.id_pais_origen
    WHERE (@id_sede IS NULL OR P.id_sede = @id_sede)
      AND (@fecha_desde IS NULL OR CAST(P.fecha_hora_local AS DATE) >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR CAST(P.fecha_hora_local AS DATE) <= @fecha_hasta)
    GROUP BY A.nombre_anunciante, PA.nombre
    ORDER BY ingresos_usd DESC, A.nombre_anunciante;
END;
GO

------------------------------------------
-- Reporte: Publicidad.Reporte_Matriz_Prime_Time
-- Descripción: Tabla cruzada (PIVOT) que muestra, para cada partido (filas), en qué mercados (columnas) el
--              horario cae en prime time. Cada celda indica 'Sí' o 'No' y la hora local del mercado. Como los
--              mercados no son fijos, las columnas se arman con SQL dinámico (QUOTENAME + sp_executesql).
--              La última columna cuenta en cuántos mercados de la fila el partido es prime time.
-- Parámetros: rango de prime time (por defecto 19:00 a 23:00, hora local del mercado), @solo_mercados_candidatos
--             (1 = solo los países que son mercado de interés de alguna campaña; 0 = además los países de las
--             selecciones del partido) y filtros opcionales por fase y fechas.
-- Validaciones: Rango de prime time válido, fase existente, fechas coherentes y al menos un mercado con huso.

CREATE OR ALTER PROCEDURE Publicidad.Reporte_Matriz_Prime_Time
    @hora_inicio_prime TIME(0) = '19:00:00',
    @hora_fin_prime TIME(0) = '23:00:00',
    @solo_mercados_candidatos BIT = 1,
    @id_fase INT = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(500) = '';
    DECLARE @columnas NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);

    IF (@hora_inicio_prime IS NULL OR @hora_fin_prime IS NULL OR @hora_inicio_prime = @hora_fin_prime)
        SET @MensajeError = @MensajeError + '- El rango de prime time debe tener hora de inicio y de fin distintas. ';

    IF (@id_fase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase))
        SET @MensajeError = @MensajeError + '- La fase indicada no existe. ';

    IF (@fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta)
        SET @MensajeError = @MensajeError + '- La fecha desde no puede ser posterior a la fecha hasta. ';

    -- Mercados a mostrar: países con huso horario válido
    CREATE TABLE #mercados (
        id_pais INT PRIMARY KEY,
        mercado VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL
    );

    INSERT INTO #mercados (id_pais, mercado)
    SELECT DISTINCT PA.id_pais, PA.nombre
    FROM Participantes.Pais PA
    WHERE Torneo.fn_Offset_Huso_Minutos(PA.huso_horario) IS NOT NULL
      AND (PA.id_pais IN (SELECT id_pais FROM Publicidad.Mercado_interes_campania)
           OR (@solo_mercados_candidatos = 0
               AND PA.id_pais IN (SELECT S.id_pais
                                  FROM Torneo.Partido P
                                  INNER JOIN Participantes.Seleccion S ON S.id_seleccion IN (P.id_seleccion_local, P.id_seleccion_visitante))));

    IF NOT EXISTS (SELECT 1 FROM #mercados)
        SET @MensajeError = @MensajeError + '- No hay mercados con huso horario registrado para armar la matriz. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- Lista de columnas del PIVOT: [Alemania], [Argentina], ...
    SELECT @columnas = STRING_AGG(CAST(QUOTENAME(mercado) AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY mercado)
    FROM #mercados;

    SET @sql = N'
    ;WITH celdas AS (
        SELECT
            P.id_partido,
            P.UTC AS fecha_hora_utc,
            F.nombre_fase AS fase,
            SL.nombre_seleccion + '' vs '' + SV.nombre_seleccion AS partido,
            M.mercado,
            PT.es_prime_time,
            CASE WHEN PT.es_prime_time = 1 THEN ''Sí '' ELSE ''No '' END
                + CONVERT(VARCHAR(5), PT.fecha_hora_mercado, 108) AS celda
        FROM Torneo.Partido P
        INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
        INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
        INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
        CROSS APPLY Publicidad.fn_Mercados_Prime_Time(P.id_partido, @ini, @fin) PT
        INNER JOIN #mercados M ON M.id_pais = PT.id_pais
        WHERE (@fase IS NULL OR P.id_fase = @fase)
          AND (@desde IS NULL OR CAST(P.fecha_hora_local AS DATE) >= @desde)
          AND (@hasta IS NULL OR CAST(P.fecha_hora_local AS DATE) <= @hasta)
    ),
    totales AS (
        SELECT id_partido, SUM(CAST(es_prime_time AS INT)) AS mercados_en_prime_time
        FROM celdas
        GROUP BY id_partido
    )
    SELECT PV.fecha_hora_utc, PV.fase, PV.partido, ' + @columnas + N', T.mercados_en_prime_time
    FROM (SELECT id_partido, fecha_hora_utc, fase, partido, mercado, celda FROM celdas) AS origen
    PIVOT (MAX(celda) FOR mercado IN (' + @columnas + N')) AS PV
    INNER JOIN totales T ON T.id_partido = PV.id_partido
    ORDER BY PV.fecha_hora_utc, PV.partido;';

    EXEC sp_executesql @sql,
         N'@ini TIME(0), @fin TIME(0), @fase INT, @desde DATE, @hasta DATE',
         @ini = @hora_inicio_prime, @fin = @hora_fin_prime, @fase = @id_fase, @desde = @fecha_desde, @hasta = @fecha_hasta;
END;
GO

------------------------------------------
-- Reporte: Participantes.Reporte_Selecciones_Plantillas
-- Descripción: Listado de selecciones con un vector anidado de convocados (nombre, posición, club y dorsal) y
--              su cuerpo técnico. Devuelve XML (FOR XML PATH con subconsultas anidadas):
--              <selecciones>
--                <seleccion nombre=".." pais=".." codigo_fifa=".." grupo=".." confederacion=".." cantidad_convocados="..">
--                  <cuerpo_tecnico><integrante cargo="..">Nombre</integrante>...</cuerpo_tecnico>
--                  <convocados><jugador dorsal=".."><nombre>..</nombre><posicion>..</posicion>
--                    <club nombre=".." pais=".."/></jugador>...</convocados>
--                </seleccion>
--              </selecciones>
--              Los jugadores desafectados (reemplazados) no se incluyen.
-- Parámetros: @id_seleccion (opcional, NULL = todas) y @nombre_grupo (opcional).
-- Validaciones: La selección y el grupo deben existir.

CREATE OR ALTER PROCEDURE Participantes.Reporte_Selecciones_Plantillas
    @id_seleccion INT = NULL,
    @nombre_grupo CHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(200) = '';
    DECLARE @resultado XML;

    IF (@id_seleccion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Seleccion WHERE id_seleccion = @id_seleccion))
        SET @MensajeError = @MensajeError + '- La selección indicada no existe. ';

    IF (@nombre_grupo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = @nombre_grupo))
        SET @MensajeError = @MensajeError + '- El grupo indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    SET @resultado = (
        SELECT
            S.nombre_seleccion AS '@nombre',
            PA.nombre AS '@pais',
            PA.codigo_fifa AS '@codigo_fifa',
            G.nombre_grupo AS '@grupo',
            CF.nombre_confederacion AS '@confederacion',
            (SELECT COUNT(*) FROM Participantes.Convocatoria C
             WHERE C.id_seleccion = S.id_seleccion AND C.estado_convocatoria <> 'Desafectado') AS '@cantidad_convocados',
            (SELECT
                 I.cargo_rol AS '@cargo',
                 I.nombre + ' ' + I.apellido AS 'text()'
             FROM Participantes.Integrante_cuerpo_tecnico I
             WHERE I.id_seleccion = S.id_seleccion
             ORDER BY I.id_integrante_ct
             FOR XML PATH('integrante'), ROOT('cuerpo_tecnico'), TYPE),
            (SELECT
                 C.dorsal AS '@dorsal',
                 J.nombre + ' ' + J.apellido AS 'nombre',
                 PO.nombre_posicion AS 'posicion',
                 CL.nombre AS 'club/@nombre',
                 PC.nombre AS 'club/@pais'
             FROM Participantes.Convocatoria C
             INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
             INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
             INNER JOIN Participantes.Club_origen CL ON CL.id_club = J.id_club_origen
             INNER JOIN Participantes.Pais PC ON PC.id_pais = CL.id_pais_club
             WHERE C.id_seleccion = S.id_seleccion AND C.estado_convocatoria <> 'Desafectado'
             ORDER BY C.dorsal
             FOR XML PATH('jugador'), ROOT('convocados'), TYPE)
        FROM Participantes.Seleccion S
        INNER JOIN Participantes.Pais PA ON PA.id_pais = S.id_pais
        INNER JOIN Torneo.Grupo_torneo G ON G.id_grupo = S.id_grupo
        LEFT JOIN Participantes.Confederacion CF ON CF.id_confederacion = S.id_confederacion
        WHERE (@id_seleccion IS NULL OR S.id_seleccion = @id_seleccion)
          AND (@nombre_grupo IS NULL OR G.nombre_grupo = @nombre_grupo)
        ORDER BY G.nombre_grupo, S.nombre_seleccion
        FOR XML PATH('seleccion'), ROOT('selecciones'), TYPE
    );

    SELECT ISNULL(@resultado, CAST('<selecciones/>' AS XML)) AS selecciones_plantillas;
END;
GO

------------------------------------------
-- Reporte: Torneo.Reporte_Resultados
-- Descripción: Resultados de los encuentros, en dos vistas:
--              1. Partidos por fase y fecha con el marcador, el ganador, la asistencia y los goles de cada equipo
--                 (autor y minuto, armados con STRING_AGG).
--              2. Tabla de posiciones de cada grupo calculada a partir de los partidos jugados de la fase de grupos
--                 entre selecciones del mismo grupo:
--                 PJ, PG, PE, PP, GF, GC, DG y puntos (3 por victoria, 1 por empate), ordenada por puntos,
--                 diferencia de gol y goles a favor (ventana ROW_NUMBER por grupo).
-- Parámetros: @id_fase (opcional) y @nombre_grupo (opcional) para filtrar.
-- Validaciones: La fase y el grupo deben existir.

CREATE OR ALTER PROCEDURE Torneo.Reporte_Resultados
    @id_fase INT = NULL,
    @nombre_grupo CHAR(1) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError VARCHAR(200) = '';

    IF (@id_fase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE id_fase = @id_fase))
        SET @MensajeError = @MensajeError + '- La fase indicada no existe. ';

    IF (@nombre_grupo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = @nombre_grupo))
        SET @MensajeError = @MensajeError + '- El grupo indicado no existe. ';

    IF (@MensajeError <> '')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    -- 1. Partidos y resultados
    SELECT
        F.nombre_fase AS fase,
        CASE WHEN F.nombre_fase = 'Fase de Grupos' AND GL.id_grupo = GV.id_grupo THEN GL.nombre_grupo END AS grupo,
        P.fecha_hora_local,
        SE.nombre_estadio + ' (' + CI.nombre + ')' AS sede,
        SL.nombre_seleccion AS local,
        CASE WHEN P.goles_local IS NULL OR P.goles_visitante IS NULL THEN 'Sin jugar'
             ELSE CONCAT(P.goles_local, ' - ', P.goles_visitante) END AS resultado,
        SV.nombre_seleccion AS visitante,
        CASE WHEN P.goles_local IS NULL OR P.goles_visitante IS NULL THEN NULL
             WHEN P.goles_local > P.goles_visitante THEN SL.nombre_seleccion
             WHEN P.goles_local < P.goles_visitante THEN SV.nombre_seleccion
             ELSE 'Empate' END AS ganador,
        P.asistencia_publico,
        (SELECT STRING_AGG(CAST(J.apellido + ' ' + CAST(G.minuto AS VARCHAR(3)) + '''' AS VARCHAR(MAX)), ', ')
                WITHIN GROUP (ORDER BY G.minuto)
         FROM Torneo.Gol G
         INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = G.id_convocatoria_autor
         INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
         WHERE G.id_partido = P.id_partido AND C.id_seleccion = P.id_seleccion_local) AS goles_local_detalle,
        (SELECT STRING_AGG(CAST(J.apellido + ' ' + CAST(G.minuto AS VARCHAR(3)) + '''' AS VARCHAR(MAX)), ', ')
                WITHIN GROUP (ORDER BY G.minuto)
         FROM Torneo.Gol G
         INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = G.id_convocatoria_autor
         INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
         WHERE G.id_partido = P.id_partido AND C.id_seleccion = P.id_seleccion_visitante) AS goles_visitante_detalle
    FROM Torneo.Partido P
    INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
    INNER JOIN Torneo.Sede SE ON SE.id_sede = P.id_sede
    INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
    INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
    INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
    INNER JOIN Torneo.Grupo_torneo GL ON GL.id_grupo = SL.id_grupo
    INNER JOIN Torneo.Grupo_torneo GV ON GV.id_grupo = SV.id_grupo
    WHERE (@id_fase IS NULL OR P.id_fase = @id_fase)
      AND (@nombre_grupo IS NULL OR (F.nombre_fase = 'Fase de Grupos' AND GL.nombre_grupo = @nombre_grupo AND GV.nombre_grupo = @nombre_grupo))
    ORDER BY P.fecha_hora_local, SL.nombre_seleccion;

    -- 2. Tabla de posiciones de la fase de grupos (cada partido cuenta una vez para cada equipo)
    ;WITH jugados AS (
        -- Solo partidos de fase de grupos entre selecciones del mismo grupo
        SELECT P.id_seleccion_local AS id_seleccion, P.goles_local AS gf, P.goles_visitante AS gc
        FROM Torneo.Partido P
        INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
        INNER JOIN Participantes.Seleccion L ON L.id_seleccion = P.id_seleccion_local
        INNER JOIN Participantes.Seleccion V ON V.id_seleccion = P.id_seleccion_visitante
        WHERE F.nombre_fase = 'Fase de Grupos' AND L.id_grupo = V.id_grupo
          AND P.goles_local IS NOT NULL AND P.goles_visitante IS NOT NULL
        UNION ALL
        SELECT P.id_seleccion_visitante, P.goles_visitante, P.goles_local
        FROM Torneo.Partido P
        INNER JOIN Torneo.Fase F ON F.id_fase = P.id_fase
        INNER JOIN Participantes.Seleccion L ON L.id_seleccion = P.id_seleccion_local
        INNER JOIN Participantes.Seleccion V ON V.id_seleccion = P.id_seleccion_visitante
        WHERE F.nombre_fase = 'Fase de Grupos' AND L.id_grupo = V.id_grupo
          AND P.goles_local IS NOT NULL AND P.goles_visitante IS NOT NULL
    ),
    tabla AS (
        SELECT
            G.nombre_grupo AS grupo,
            S.nombre_seleccion AS seleccion,
            COUNT(J.id_seleccion) AS pj,
            SUM(CASE WHEN J.gf > J.gc THEN 1 ELSE 0 END) AS pg,
            SUM(CASE WHEN J.gf = J.gc THEN 1 ELSE 0 END) AS pe,
            SUM(CASE WHEN J.gf < J.gc THEN 1 ELSE 0 END) AS pp,
            ISNULL(SUM(J.gf), 0) AS gf,
            ISNULL(SUM(J.gc), 0) AS gc,
            ISNULL(SUM(J.gf), 0) - ISNULL(SUM(J.gc), 0) AS dg,
            SUM(CASE WHEN J.gf > J.gc THEN 3 WHEN J.gf = J.gc THEN 1 ELSE 0 END) AS pts
        FROM Participantes.Seleccion S
        INNER JOIN Torneo.Grupo_torneo G ON G.id_grupo = S.id_grupo
        LEFT JOIN jugados J ON J.id_seleccion = S.id_seleccion
        WHERE (@nombre_grupo IS NULL OR G.nombre_grupo = @nombre_grupo)
        GROUP BY G.nombre_grupo, S.nombre_seleccion
    )
    SELECT
        grupo,
        ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY ISNULL(pts, 0) DESC, dg DESC, gf DESC, seleccion) AS posicion,
        seleccion, pj, ISNULL(pg, 0) AS pg, ISNULL(pe, 0) AS pe, ISNULL(pp, 0) AS pp, gf, gc, dg, ISNULL(pts, 0) AS pts
    FROM tabla
    WHERE @id_fase IS NULL OR @id_fase IN (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos')
    ORDER BY grupo, posicion;
END;
GO
