-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creación de vistas y funciones --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- Función: Torneo.fn_Offset_Huso_Minutos
-- Descripción: Convierte un huso horario en texto ('UTC', 'UTC-3', 'UTC+5:30', 'GMT-03:00')
--              a su diferencia con UTC expresada en minutos (ej: 'UTC-3' -> -180).
-- Retorna NULL si el texto no tiene un formato válido.
-- Nota: no contempla horario de verano; se toma el huso registrado como fijo durante el torneo.

CREATE OR ALTER FUNCTION Torneo.fn_Offset_Huso_Minutos (@huso_horario VARCHAR(10))
RETURNS INT
AS
BEGIN
    DECLARE @texto VARCHAR(10) = UPPER(REPLACE(LTRIM(RTRIM(@huso_horario)), ' ', ''));
    DECLARE @signo INT;
    DECLARE @parte_horas VARCHAR(10);
    DECLARE @parte_minutos VARCHAR(10) = '0';
    DECLARE @posicion_separador INT;
    DECLARE @horas INT;
    DECLARE @minutos INT;

    IF (@texto IS NULL OR @texto = '')
        RETURN NULL;

    -- Se quita el prefijo UTC o GMT
    IF (LEFT(@texto, 3) IN ('UTC', 'GMT'))
        SET @texto = SUBSTRING(@texto, 4, 10);
    ELSE
        RETURN NULL;

    -- 'UTC' sin desplazamiento
    IF (@texto = '')
        RETURN 0;

    SET @signo = CASE LEFT(@texto, 1) WHEN '+' THEN 1 WHEN '-' THEN -1 ELSE NULL END;
    IF (@signo IS NULL)
        RETURN NULL;

    SET @texto = SUBSTRING(@texto, 2, 10);
    SET @posicion_separador = CHARINDEX(':', @texto);

    IF (@posicion_separador > 0)
    BEGIN
        SET @parte_horas = LEFT(@texto, @posicion_separador - 1);
        SET @parte_minutos = SUBSTRING(@texto, @posicion_separador + 1, 10);
    END
    ELSE
        SET @parte_horas = @texto;

    -- Solo se aceptan dígitos
    IF (@parte_horas = '' OR @parte_horas LIKE '%[^0-9]%' OR @parte_minutos = '' OR @parte_minutos LIKE '%[^0-9]%')
        RETURN NULL;

    SET @horas = CAST(@parte_horas AS INT);
    SET @minutos = CAST(@parte_minutos AS INT);

    -- Los husos reales van de UTC-12 a UTC+14 y los minutos solo pueden ser 00, 15, 30 o 45
    IF (@horas > 14 OR @minutos NOT IN (0, 15, 30, 45))
        RETURN NULL;

    RETURN @signo * (@horas * 60 + @minutos);
END;
GO

------------------------------------------
-- Función: Publicidad.fn_Mercados_Prime_Time
-- Descripción: Para un partido, calcula la hora local en cada país (mercado) que tenga huso horario
--              registrado, a partir del horario UTC del partido, e indica si cae en prime time.
-- Parámetros: rango de prime time en hora local del mercado (ej: 19:00 a 23:00).
--             Si la hora de fin es menor a la de inicio se interpreta que el rango cruza la medianoche.

CREATE OR ALTER FUNCTION Publicidad.fn_Mercados_Prime_Time (
    @id_partido INT,
    @hora_inicio_prime TIME(0),
    @hora_fin_prime TIME(0)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        P.id_partido,
        PA.id_pais,
        PA.nombre AS mercado,
        PA.huso_horario,
        P.UTC AS fecha_hora_utc_partido,
        HL.fecha_hora_mercado,
        CAST(CASE
                WHEN @hora_inicio_prime <= @hora_fin_prime
                     AND CAST(HL.fecha_hora_mercado AS TIME(0)) >= @hora_inicio_prime
                     AND CAST(HL.fecha_hora_mercado AS TIME(0)) <  @hora_fin_prime THEN 1
                WHEN @hora_inicio_prime > @hora_fin_prime
                     AND (CAST(HL.fecha_hora_mercado AS TIME(0)) >= @hora_inicio_prime
                          OR CAST(HL.fecha_hora_mercado AS TIME(0)) < @hora_fin_prime) THEN 1
                ELSE 0
             END AS BIT) AS es_prime_time
    FROM Torneo.Partido P
    CROSS JOIN Participantes.Pais PA
    CROSS APPLY (SELECT Torneo.fn_Offset_Huso_Minutos(PA.huso_horario) AS offset_minutos) OFS
    CROSS APPLY (SELECT DATEADD(MINUTE, OFS.offset_minutos, P.UTC) AS fecha_hora_mercado) HL
    WHERE P.id_partido = @id_partido
      AND OFS.offset_minutos IS NOT NULL
);
GO
