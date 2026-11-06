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

------------------------------------------
-- Vista: Torneo.vw_Staging_stadiums
-- Descripcion: Vista utilizada para la carga masiva del archivo stadiums.csv
--              muestra solamente 8 columnas para coincidir con el archivo original

CREATE OR ALTER VIEW Torneo.vw_Staging_stadiums
AS
SELECT 
    key_id, stadium_id, stadium_name, city_name, country_name, 
    stadium_capacity, stadium_wikipedia_link, city_wikipedia_link
FROM Torneo.Staging_stadiums;
GO

------------------------------------------
-- Función: Torneo.fn_Huso_Desde_Segundos
-- Descripción: Convierte una diferencia con UTC expresada en segundos (como la devuelven las APIs)
--              al formato de texto que usa la base: -10800 -> 'UTC-3', 19800 -> 'UTC+5:30', 0 -> 'UTC'.

CREATE OR ALTER FUNCTION Torneo.fn_Huso_Desde_Segundos (@segundos INT)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @minutos_totales INT;
    DECLARE @horas INT;
    DECLARE @minutos INT;

    IF (@segundos IS NULL OR ABS(@segundos) > 14 * 3600)
        RETURN NULL;

    IF (@segundos = 0)
        RETURN 'UTC';

    SET @minutos_totales = ABS(@segundos) / 60;
    SET @horas = @minutos_totales / 60;
    SET @minutos = @minutos_totales % 60;

    RETURN 'UTC' + CASE WHEN @segundos < 0 THEN '-' ELSE '+' END
         + CAST(@horas AS VARCHAR(2))
         + CASE WHEN @minutos > 0 THEN ':' + RIGHT('0' + CAST(@minutos AS VARCHAR(2)), 2) ELSE '' END;
END;
GO

------------------------------------------
-- Función: Torneo.fn_Url_Encode
-- Descripción: Codifica un texto para usarlo en la URL de una API (percent-encoding sobre UTF-8),
--              así los nombres con tildes, eñes o espacios se envían correctamente (ej: 'Estadio Akron, Zapopan').
-- Nota: usa una intercalación UTF-8, disponible desde SQL Server 2019.

CREATE OR ALTER FUNCTION Torneo.fn_Url_Encode (@texto NVARCHAR(400))
RETURNS VARCHAR(2000)
AS
BEGIN
    DECLARE @bytes VARBINARY(1600);
    DECLARE @resultado VARCHAR(2000) = '';
    DECLARE @posicion INT = 1;
    DECLARE @byte INT;

    IF (@texto IS NULL)
        RETURN NULL;

    -- Bytes UTF-8 del texto
    SET @bytes = CAST(CONVERT(VARCHAR(1600), @texto COLLATE Latin1_General_100_CI_AS_SC_UTF8) AS VARBINARY(1600));

    WHILE (@posicion <= DATALENGTH(@bytes))
    BEGIN
        SET @byte = CAST(SUBSTRING(@bytes, @posicion, 1) AS INT);

        -- Caracteres no reservados (RFC 3986): letras, dígitos y - _ . ~
        IF ((@byte BETWEEN 48 AND 57) OR (@byte BETWEEN 65 AND 90) OR (@byte BETWEEN 97 AND 122) OR @byte IN (45, 46, 95, 126))
            SET @resultado = @resultado + CHAR(@byte);
        ELSE
            SET @resultado = @resultado + '%' + CONVERT(VARCHAR(2), CAST(@byte AS BINARY(1)), 2);

        SET @posicion = @posicion + 1;
    END

    RETURN @resultado;
END;
GO
