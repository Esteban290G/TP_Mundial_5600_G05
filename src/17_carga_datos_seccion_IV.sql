-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Carga de datos de prueba (seed data) - Sección IV "Criterios de Aceptación"
------------------------------------------
-- Genera el juego de datos mínimo que pide la consigna, usando los SP de alta, modificación y lógica de negocio
-- (las mismas validaciones que el resto del sistema):
--   - 13 sedes con 4 husos horarios distintos (UTC-4, UTC-5, UTC-6 y UTC-7).
--   - 16 selecciones (grupos H, J, K y L del Mundial 2026) con 23 convocados cada una y su cuerpo técnico.
--   - 32 partidos reales de esas selecciones (24 de fase de grupos y 8 de eliminación directa), con formación
--     titular y banco de suplentes de ambos equipos, goles, tarjetas, sustituciones y suspensiones.
--   - 15 árbitros con designación completa (principal, 2 asistentes, cuarto árbitro y VAR) en cada partido.
--   - 8 anunciantes de 8 países distintos, con campañas del Mundial 2026 y campañas históricas (Qatar 2022).
-- Casos obligatorios (ver la sección "CASOS OBLIGATORIOS" al final, que los verifica con consultas):
--   1. Expulsión por doble amarilla (Uruguay - Cabo Verde) y por roja directa (Jordania - Argelia).
--   2. Jugador de Portugal suspendido por acumulación de amarillas (amarilla con RD Congo y con Uzbekistán):
--      queda afuera de la planilla contra Colombia (el SP Confirmar_Planilla_Jugador lo rechaza).
--   3. Cambio por lesión a los 15 minutos (Argentina - Argelia).
--   4. Inglaterra - Croacia (20:00 UTC) cae en prime time en más de cuatro mercados candidatos (España, Portugal,
--      Francia, Italia, Alemania, Austria, Países Bajos, Inglaterra): Asignar_Publicidad_Partido prioriza 4 piezas.
--   5. Designación arbitral rechazada por conflicto de nacionalidad (árbitro argentino en Argentina - Argelia).
--   6. Importación con errores parciales (stadiums_prueba_errores.csv; también en los scripts 12 y 14).
--
-- Es independiente de las importaciones: si los países, sedes, selecciones o partidos ya existen (por ejemplo,
-- porque se ejecutó el script 14 con el XML de Wikipedia) los reutiliza; si no, los crea con los mismos datos.
-- Se puede ejecutar más de una vez: lo ya cargado no se duplica (los partidos que ya tienen planilla se saltean).
-- Los nombres de jugadores, cuerpos técnicos, árbitros y anunciantes son ficticios. Los partidos, sedes, horarios
-- y resultados son los reales (Wikipedia). Los PBI y husos que se usan al crear un país son aproximados.
-- No usa cursores: los recorridos se hacen con WHILE sobre tablas temporales numeradas.
------------------------------------------

USE COM5600_G05;
GO

SET NOCOUNT ON;

DROP TABLE IF EXISTS #paises;
DROP TABLE IF EXISTS #selecciones;
DROP TABLE IF EXISTS #sedes;
DROP TABLE IF EXISTS #partidos;
DROP TABLE IF EXISTS #nombres;
DROP TABLE IF EXISTS #clubes;
DROP TABLE IF EXISTS #nuevos_jugadores;
DROP TABLE IF EXISTS #arbitros;
DROP TABLE IF EXISTS #casos;
GO

------------------------------------------
-- 1. CATÁLOGOS
------------------------------------------
PRINT '1. Catálogos';

-- Confederaciones
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'UEFA') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'UEFA';
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'CONMEBOL') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'CONMEBOL';
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'CONCACAF') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'CONCACAF';
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'CAF') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'CAF';
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'AFC') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'AFC';
IF NOT EXISTS (SELECT 1 FROM Participantes.Confederacion WHERE nombre_confederacion = 'OFC') EXEC Participantes.Alta_Confederacion @nombre_confederacion = 'OFC';

-- Posiciones
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero') EXEC Participantes.Alta_Posicion @nombre_posicion = 'Arquero';
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Defensor') EXEC Participantes.Alta_Posicion @nombre_posicion = 'Defensor';
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Mediocampista') EXEC Participantes.Alta_Posicion @nombre_posicion = 'Mediocampista';
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Delantero') EXEC Participantes.Alta_Posicion @nombre_posicion = 'Delantero';

-- Árbitros: categoría y roles de la designación completa
IF NOT EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE descripcion = 'Internacional FIFA') EXEC Participantes.Alta_Categoria_arbitro @descripcion = 'Internacional FIFA';
IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'Principal') EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Principal';
IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'Asistente 1') EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Asistente 1';
IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'Asistente 2') EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Asistente 2';
IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'Cuarto árbitro') EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Cuarto árbitro';
IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'VAR') EXEC Participantes.Alta_Rol_arbitro @descripcion = 'VAR';

-- Idiomas (árbitros y piezas publicitarias)
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Español') EXEC Participantes.Alta_Idioma @nombre = 'Español';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Inglés') EXEC Participantes.Alta_Idioma @nombre = 'Inglés';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Portugués') EXEC Participantes.Alta_Idioma @nombre = 'Portugués';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Francés') EXEC Participantes.Alta_Idioma @nombre = 'Francés';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Alemán') EXEC Participantes.Alta_Idioma @nombre = 'Alemán';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Árabe') EXEC Participantes.Alta_Idioma @nombre = 'Árabe';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Italiano') EXEC Participantes.Alta_Idioma @nombre = 'Italiano';
IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Japonés') EXEC Participantes.Alta_Idioma @nombre = 'Japonés';

-- Grupos y fases del torneo
IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'H') EXEC Torneo.Alta_Grupo_Torneo @nombre_grupo = 'H';
IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'J') EXEC Torneo.Alta_Grupo_Torneo @nombre_grupo = 'J';
IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'K') EXEC Torneo.Alta_Grupo_Torneo @nombre_grupo = 'K';
IF NOT EXISTS (SELECT 1 FROM Torneo.Grupo_torneo WHERE nombre_grupo = 'L') EXEC Torneo.Alta_Grupo_Torneo @nombre_grupo = 'L';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos') EXEC Torneo.Alta_Fase @nombre_fase = 'Fase de Grupos';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Dieciseisavos de final') EXEC Torneo.Alta_Fase @nombre_fase = 'Dieciseisavos de final';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Octavos de final') EXEC Torneo.Alta_Fase @nombre_fase = 'Octavos de final';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Cuartos de final') EXEC Torneo.Alta_Fase @nombre_fase = 'Cuartos de final';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Semifinales') EXEC Torneo.Alta_Fase @nombre_fase = 'Semifinales';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Tercer puesto') EXEC Torneo.Alta_Fase @nombre_fase = 'Tercer puesto';
IF NOT EXISTS (SELECT 1 FROM Torneo.Fase WHERE nombre_fase = 'Final') EXEC Torneo.Alta_Fase @nombre_fase = 'Final';

-- Datos de los partidos
IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-3-3') EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '4-3-3';
IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-4-2') EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '4-4-2';
IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-2-3-1') EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '4-2-3-1';
IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '3-5-2') EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '3-5-2';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Jugada') EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Jugada';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Cabeza') EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Cabeza';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Penal') EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Penal';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Tiro libre') EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Tiro libre';
IF NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Primer tiempo') EXEC Torneo.Alta_Periodo_partido @descripcion_periodo = 'Primer tiempo';
IF NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Segundo tiempo') EXEC Torneo.Alta_Periodo_partido @descripcion_periodo = 'Segundo tiempo';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla') EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Amarilla';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja') EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Roja';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego brusco') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Juego brusco';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Protesta') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Protesta';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Mano intencional') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Mano intencional';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Demora en el juego') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Demora en el juego';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Conducta antideportiva') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Conducta antideportiva';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Falta grave') EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Falta grave';

-- Franjas tarifarias que cubren las 24 horas (la asignación de publicidad necesita una para cada horario)
IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Franja mañana')
    EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Franja mañana', @hora_inicio_local = '00:00:00', @hora_fin_local = '11:59:59', @tarifa_base_usd = 8000;
IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Franja tarde')
    EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Franja tarde', @hora_inicio_local = '12:00:00', @hora_fin_local = '17:59:59', @tarifa_base_usd = 12000;
IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Franja noche')
    EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Franja noche', @hora_inicio_local = '18:00:00', @hora_fin_local = '23:59:59', @tarifa_base_usd = 18000;

-- Criterios de suspensión (si no hay ninguno activo): 1 fecha por roja o doble amarilla, 2 amarillas acumuladas
-- en partidos distintos suspenden 1 fecha y las amarillas se limpian a partir de cuartos de final.
IF NOT EXISTS (SELECT 1 FROM Torneo.Parametros_suspension WHERE activo = 1)
BEGIN
    DECLARE @id_fase_cuartos INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Cuartos de final');
    EXEC Torneo.Alta_Parametros_suspension @id_fase_limpieza_amarillas = @id_fase_cuartos,
         @fechas_suspension_roja_directa = 1, @fechas_suspension_doble_amarilla = 1, @activo = 1,
         @cantidad_amarillas_suspension = 2;
END

-- Origen de los partidos que crea este script (Torneo.Partido exige el registro de importación de origen)
IF NOT EXISTS (SELECT 1 FROM Torneo.Log_importacion WHERE nombre_archivo_o_fuente = 'Carga de datos de prueba (script 17)')
BEGIN
    DECLARE @ahora DATETIME = DATEADD(SECOND, -1, GETDATE());
    EXEC Torneo.Alta_Log_importacion @nombre_archivo_o_fuente = 'Carga de datos de prueba (script 17)',
         @fecha_hora_ejecucion = @ahora, @registros_procesados = 32, @registros_con_error = 0, @estado = 'Completado';
END
GO

------------------------------------------
-- 2. MONEDAS Y PAÍSES
-- Selecciones, sedes, árbitros, anunciantes y mercados. Si el país ya existe (importación de países) solo se
-- completan el huso horario y el código FIFA cuando faltan. Huso = hora oficial en junio-julio (con horario de verano).
------------------------------------------
PRINT '2. Monedas y países';

CREATE TABLE #paises (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    codigo_iso CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    codigo_fifa CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    nombre VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    nombre_ingles VARCHAR(60) COLLATE DATABASE_DEFAULT NOT NULL,
    codigo_moneda CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    nombre_moneda VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    huso_horario VARCHAR(10) COLLATE DATABASE_DEFAULT NOT NULL,
    pbi_per_capita DECIMAL(18,2) NOT NULL,
    id_pais INT NULL
);

INSERT INTO #paises (codigo_iso, codigo_fifa, nombre, nombre_ingles, codigo_moneda, nombre_moneda, huso_horario, pbi_per_capita)
VALUES
    -- Selecciones (grupos H, J, K y L)
    ('ESP', 'ESP', 'España', 'Spain', 'EUR', 'Euro', 'UTC+2', 33500),
    ('URY', 'URU', 'Uruguay', 'Uruguay', 'UYU', 'Peso uruguayo', 'UTC-3', 22800),
    ('CPV', 'CPV', 'Cabo Verde', 'Cape Verde', 'CVE', 'Escudo caboverdiano', 'UTC-1', 4300),
    ('SAU', 'KSA', 'Arabia Saudí', 'Saudi Arabia', 'SAR', 'Riyal saudí', 'UTC+3', 32000),
    ('ARG', 'ARG', 'Argentina', 'Argentina', 'ARS', 'Peso argentino', 'UTC-3', 13700),
    ('DZA', 'ALG', 'Argelia', 'Algeria', 'DZD', 'Dinar argelino', 'UTC+1', 5300),
    ('AUT', 'AUT', 'Austria', 'Austria', 'EUR', 'Euro', 'UTC+2', 56000),
    ('JOR', 'JOR', 'Jordania', 'Jordan', 'JOD', 'Dinar jordano', 'UTC+3', 4500),
    ('PRT', 'POR', 'Portugal', 'Portugal', 'EUR', 'Euro', 'UTC+1', 27300),
    ('COD', 'COD', 'Congo (Rep. Dem.)', 'DR Congo', 'CDF', 'Franco congoleño', 'UTC+1', 650),
    ('COL', 'COL', 'Colombia', 'Colombia', 'COP', 'Peso colombiano', 'UTC-5', 7000),
    ('UZB', 'UZB', 'Uzbekistán', 'Uzbekistan', 'UZS', 'Som uzbeko', 'UTC+5', 2500),
    ('HRV', 'CRO', 'Croacia', 'Croatia', 'EUR', 'Euro', 'UTC+2', 21500),
    ('ENG', 'ENG', 'Inglaterra', 'England', 'GBP', 'Libra esterlina', 'UTC+1', 48800),
    ('GHA', 'GHA', 'Ghana', 'Ghana', 'GHS', 'Cedi', 'UTC', 2300),
    ('PAN', 'PAN', 'Panamá', 'Panama', 'PAB', 'Balboa', 'UTC-5', 18600),
    -- Países de las sedes
    ('USA', 'USA', 'Estados Unidos', 'United States', 'USD', 'Dólar estadounidense', 'UTC-4', 82700),
    ('MEX', 'MEX', 'México', 'Mexico', 'MXN', 'Peso mexicano', 'UTC-6', 13900),
    ('CAN', 'CAN', 'Canadá', 'Canada', 'CAD', 'Dólar canadiense', 'UTC-4', 53400),
    -- Países de árbitros, anunciantes y mercados
    ('ITA', 'ITA', 'Italia', 'Italy', 'EUR', 'Euro', 'UTC+2', 39000),
    ('DEU', 'GER', 'Alemania', 'Germany', 'EUR', 'Euro', 'UTC+2', 54300),
    ('NLD', 'NED', 'Países Bajos', 'Netherlands', 'EUR', 'Euro', 'UTC+2', 64600),
    ('FRA', 'FRA', 'Francia', 'France', 'EUR', 'Euro', 'UTC+2', 46000),
    ('BRA', 'BRA', 'Brasil', 'Brazil', 'BRL', 'Real brasileño', 'UTC-3', 10300),
    ('POL', 'POL', 'Polonia', 'Poland', 'PLN', 'Esloti', 'UTC+2', 22100),
    ('SWE', 'SWE', 'Suecia', 'Sweden', 'SEK', 'Corona sueca', 'UTC+2', 55500),
    ('AUS', 'AUS', 'Australia', 'Australia', 'AUD', 'Dólar australiano', 'UTC+10', 64700),
    ('MAR', 'MAR', 'Marruecos', 'Morocco', 'MAD', 'Dírham marroquí', 'UTC+1', 3900),
    ('QAT', 'QAT', 'Catar', 'Qatar', 'QAR', 'Riyal catarí', 'UTC+3', 80000),
    ('JPN', 'JPN', 'Japón', 'Japan', 'JPY', 'Yen', 'UTC+9', 33800),
    ('CHL', 'CHI', 'Chile', 'Chile', 'CLP', 'Peso chileno', 'UTC-4', 16800);

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #paises);
DECLARE @iso CHAR(3), @fifa CHAR(3), @nombre VARCHAR(50), @ingles VARCHAR(60), @moneda CHAR(3), @nombre_moneda VARCHAR(50),
        @huso VARCHAR(10), @pbi DECIMAL(18,2), @id_pais INT, @huso_actual VARCHAR(10), @fifa_actual CHAR(3);

WHILE @i <= @n
BEGIN
    SET @id_pais = NULL;
    SELECT @iso = codigo_iso, @fifa = codigo_fifa, @nombre = nombre, @ingles = nombre_ingles, @moneda = codigo_moneda,
           @nombre_moneda = nombre_moneda, @huso = huso_horario, @pbi = pbi_per_capita
    FROM #paises WHERE nro = @i;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Participantes.Moneda WHERE codigo_moneda = @moneda)
            EXEC Participantes.Alta_Moneda @codigo_moneda = @moneda, @nombre_moneda = @nombre_moneda;

        SET @id_pais = (SELECT TOP 1 id_pais FROM Participantes.Pais
                        WHERE codigo_iso = @iso OR codigo_fifa = @fifa
                        ORDER BY CASE WHEN codigo_iso = @iso THEN 0 ELSE 1 END);

        IF (@id_pais IS NULL)
        BEGIN
            -- Si otro país ya usa el código FIFA, se crea sin él
            IF EXISTS (SELECT 1 FROM Participantes.Pais WHERE codigo_fifa = @fifa) SET @fifa = NULL;
            EXEC Participantes.Alta_Pais @codigo_moneda = @moneda, @nombre = @nombre, @codigo_iso = @iso,
                 @pbi_per_capita = @pbi, @huso_horario = @huso, @nombre_ingles = @ingles, @codigo_fifa = @fifa;
            SET @id_pais = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = @iso);
        END
        ELSE
        BEGIN
            SELECT @huso_actual = huso_horario, @fifa_actual = codigo_fifa FROM Participantes.Pais WHERE id_pais = @id_pais;

            IF (@huso_actual IS NULL OR Torneo.fn_Offset_Huso_Minutos(@huso_actual) IS NULL)
                EXEC Participantes.Modificacion_Pais @id_pais = @id_pais, @huso_horario = @huso;

            IF (@fifa_actual IS NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Pais WHERE codigo_fifa = @fifa))
                EXEC Participantes.Modificacion_Pais @id_pais = @id_pais, @codigo_fifa = @fifa;
        END

        UPDATE #paises SET id_pais = @id_pais WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  País ', @iso, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END
GO

------------------------------------------
-- 3. SELECCIONES (16, grupos H, J, K y L)
------------------------------------------
PRINT '3. Selecciones';

CREATE TABLE #selecciones (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    codigo_fifa CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    grupo CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,
    confederacion VARCHAR(20) COLLATE DATABASE_DEFAULT NOT NULL,
    esquema VARCHAR(10) COLLATE DATABASE_DEFAULT NOT NULL,  -- esquema táctico habitual
    idioma_nombres VARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL, -- pool de nombres ficticios
    id_pais INT NULL,
    id_seleccion INT NULL
);

INSERT INTO #selecciones (codigo_fifa, grupo, confederacion, esquema, idioma_nombres)
VALUES
    ('ESP', 'H', 'UEFA', '4-3-3', 'es'), ('CPV', 'H', 'CAF', '4-2-3-1', 'pt'),
    ('KSA', 'H', 'AFC', '4-4-2', 'ar'),  ('URU', 'H', 'CONMEBOL', '4-4-2', 'es'),
    ('ARG', 'J', 'CONMEBOL', '4-3-3', 'es'), ('ALG', 'J', 'CAF', '4-2-3-1', 'ar'),
    ('AUT', 'J', 'UEFA', '4-2-3-1', 'de'), ('JOR', 'J', 'AFC', '3-5-2', 'ar'),
    ('POR', 'K', 'UEFA', '4-3-3', 'pt'),  ('COD', 'K', 'CAF', '4-3-3', 'fr'),
    ('COL', 'K', 'CONMEBOL', '4-2-3-1', 'es'), ('UZB', 'K', 'AFC', '4-4-2', 'uz'),
    ('ENG', 'L', 'UEFA', '4-2-3-1', 'en'), ('CRO', 'L', 'UEFA', '4-3-3', 'hr'),
    ('GHA', 'L', 'CAF', '4-4-2', 'gh'),  ('PAN', 'L', 'CONCACAF', '3-5-2', 'es');

UPDATE S SET id_pais = P.id_pais
FROM #selecciones S INNER JOIN #paises P ON P.codigo_fifa = S.codigo_fifa;

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #selecciones);
DECLARE @id_pais INT, @id_seleccion INT, @id_grupo INT, @id_confederacion INT, @nombre_seleccion VARCHAR(50), @confed_actual INT,
        @grupo_actual INT;

WHILE @i <= @n
BEGIN
    SELECT @id_pais = NULL, @id_grupo = NULL, @id_confederacion = NULL, @nombre_seleccion = NULL, @confed_actual = NULL,
           @grupo_actual = NULL;

    SELECT @id_pais = S.id_pais,
           @id_grupo = G.id_grupo,
           @id_confederacion = C.id_confederacion,
           @nombre_seleccion = 'Selección de ' + P.nombre
    FROM #selecciones S
    INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais
    INNER JOIN Torneo.Grupo_torneo G ON G.nombre_grupo = S.grupo
    INNER JOIN Participantes.Confederacion C ON C.nombre_confederacion = S.confederacion
    WHERE S.nro = @i;

    BEGIN TRY
        SELECT @id_seleccion = id_seleccion, @confed_actual = id_confederacion, @grupo_actual = id_grupo
        FROM Participantes.Seleccion WHERE id_pais = @id_pais;

        IF (@@ROWCOUNT = 0)
        BEGIN
            SET @id_seleccion = NULL;
            EXEC Participantes.Alta_Seleccion @nombre_seleccion = @nombre_seleccion, @id_pais = @id_pais,
                 @id_confederacion = @id_confederacion, @id_grupo = @id_grupo;
            SET @id_seleccion = (SELECT id_seleccion FROM Participantes.Seleccion WHERE id_pais = @id_pais);
        END
        ELSE IF (@confed_actual IS NULL OR @grupo_actual <> @id_grupo)
            -- Las selecciones que llegan por la importación del XML no traen confederación; las de otras pruebas
            -- pueden tener otro grupo: se dejan con el grupo real del Mundial 2026
            EXEC Participantes.Modificacion_Seleccion @id_seleccion = @id_seleccion, @id_confederacion = @id_confederacion,
                 @id_grupo = @id_grupo;

        UPDATE #selecciones SET id_seleccion = @id_seleccion WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Selección ', @nombre_seleccion, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END
GO

------------------------------------------
-- 4. CIUDADES Y SEDES (13 estadios, 4 husos horarios)
------------------------------------------
PRINT '4. Sedes';

CREATE TABLE #sedes (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    estadio VARCHAR(30) COLLATE DATABASE_DEFAULT NOT NULL,
    ciudad VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    pais_iso CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    capacidad INT NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    huso_horario VARCHAR(10) COLLATE DATABASE_DEFAULT NOT NULL,
    id_sede INT NULL
);

-- Capacidad: la del Mundial (algunos estadios se amplían para el torneo, por eso BMO Field supera su capacidad habitual)
INSERT INTO #sedes (estadio, ciudad, pais_iso, capacidad, latitud, longitud, huso_horario)
VALUES
    ('AT&T Stadium', 'Arlington', 'USA', 80000, 32.747300, -97.094500, 'UTC-5'),
    ('Arrowhead Stadium', 'Kansas City', 'USA', 76416, 39.048900, -94.483900, 'UTC-5'),
    ('BMO Field', 'Toronto', 'CAN', 45000, 43.633200, -79.418600, 'UTC-4'),
    ('Estadio Akron', 'Zapopan', 'MEX', 49813, 20.681800, -103.462600, 'UTC-6'),
    ('Estadio Azteca', 'Mexico City', 'MEX', 87523, 19.302900, -99.150500, 'UTC-6'),
    ('Gillette Stadium', 'Foxborough', 'USA', 64628, 42.090900, -71.264300, 'UTC-4'),
    ('Hard Rock Stadium', 'Miami Gardens', 'USA', 64767, 25.958000, -80.238900, 'UTC-4'),
    ('Levi''s Stadium', 'Santa Clara', 'USA', 68500, 37.403000, -121.970000, 'UTC-7'),
    ('Lincoln Financial Field', 'Philadelphia', 'USA', 67594, 39.900800, -75.167500, 'UTC-4'),
    ('Mercedes-Benz Stadium', 'Atlanta', 'USA', 71000, 33.755300, -84.400600, 'UTC-4'),
    ('MetLife Stadium', 'East Rutherford', 'USA', 82500, 40.813500, -74.074500, 'UTC-4'),
    ('NRG Stadium', 'Houston', 'USA', 72220, 29.684700, -95.410700, 'UTC-5'),
    ('SoFi Stadium', 'Inglewood', 'USA', 70240, 33.953500, -118.339200, 'UTC-7');

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #sedes);
DECLARE @estadio VARCHAR(30), @ciudad VARCHAR(50), @id_pais INT, @capacidad INT, @lat DECIMAL(9,6), @lon DECIMAL(9,6),
        @huso VARCHAR(10), @id_ciudad INT, @id_sede INT;

WHILE @i <= @n
BEGIN
    SELECT @id_pais = NULL, @id_ciudad = NULL, @id_sede = NULL;

    SELECT @estadio = S.estadio, @ciudad = S.ciudad, @id_pais = P.id_pais, @capacidad = S.capacidad,
           @lat = S.latitud, @lon = S.longitud, @huso = S.huso_horario
    FROM #sedes S INNER JOIN #paises P ON P.codigo_iso = S.pais_iso
    WHERE S.nro = @i;

    BEGIN TRY
        -- Una sede ya cargada (por la importación del XML o del CSV) se reutiliza
        SET @id_sede = (SELECT TOP 1 SE.id_sede
                        FROM Torneo.Sede SE
                        INNER JOIN Participantes.Ciudad C ON C.id_ciudad = SE.id_ciudad
                        WHERE SE.nombre_estadio = @estadio
                        ORDER BY CASE WHEN C.id_pais = @id_pais THEN 0 ELSE 1 END, SE.id_sede);

        IF (@id_sede IS NULL)
        BEGIN
            SET @id_ciudad = (SELECT id_ciudad FROM Participantes.Ciudad WHERE id_pais = @id_pais AND nombre = @ciudad);
            IF (@id_ciudad IS NULL)
            BEGIN
                EXEC Participantes.Alta_Ciudad @id_pais = @id_pais, @nombre = @ciudad;
                SET @id_ciudad = (SELECT id_ciudad FROM Participantes.Ciudad WHERE id_pais = @id_pais AND nombre = @ciudad);
            END

            EXEC Torneo.Alta_Sede @id_ciudad = @id_ciudad, @nombre_estadio = @estadio, @capacidad = @capacidad,
                 @latitud = @lat, @longitud = @lon, @huso_horario = @huso;
            SET @id_sede = (SELECT id_sede FROM Torneo.Sede WHERE id_ciudad = @id_ciudad AND nombre_estadio = @estadio);
        END

        UPDATE #sedes SET id_sede = @id_sede WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Sede ', @estadio, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END
GO

------------------------------------------
-- 5. PARTIDOS (32 reales: 24 de grupos y 8 de eliminación directa entre estas selecciones)
-- Fuente: XML de Wikipedia (scraping/mundial_2026_wikipedia.xml). Si el partido ya existe (misma fase, local y
-- visitante) se reutiliza.
------------------------------------------
PRINT '5. Partidos';

CREATE TABLE #partidos (
    nro INT PRIMARY KEY,               -- orden cronológico (hora UTC)
    fase VARCHAR(30) COLLATE DATABASE_DEFAULT NOT NULL,
    grupo CHAR(1) COLLATE DATABASE_DEFAULT NULL,
    local_fifa CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    visitante_fifa CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    estadio VARCHAR(30) COLLATE DATABASE_DEFAULT NOT NULL,
    fecha_hora_local DATETIME NOT NULL,
    fecha_hora_utc DATETIME NOT NULL,
    goles_local TINYINT NOT NULL,
    goles_visitante TINYINT NOT NULL,
    asistencia INT NOT NULL,
    id_partido INT NULL,
    id_seleccion_local INT NULL,
    id_seleccion_visitante INT NULL
);

INSERT INTO #partidos (nro, fase, grupo, local_fifa, visitante_fifa, estadio, fecha_hora_local, fecha_hora_utc,
                       goles_local, goles_visitante, asistencia)
VALUES
    (1, 'Fase de Grupos', 'H', 'ESP', 'CPV', 'Mercedes-Benz Stadium', '20260615 12:00:00', '20260615 16:00:00', 0, 0, 67640),
    (2, 'Fase de Grupos', 'H', 'KSA', 'URU', 'Hard Rock Stadium', '20260615 18:00:00', '20260615 22:00:00', 1, 1, 62764),
    (3, 'Fase de Grupos', 'J', 'ARG', 'ALG', 'Arrowhead Stadium', '20260616 20:00:00', '20260617 01:00:00', 3, 0, 69045),
    (4, 'Fase de Grupos', 'J', 'AUT', 'JOR', 'Levi''s Stadium', '20260616 21:00:00', '20260617 04:00:00', 3, 1, 68527),
    (5, 'Fase de Grupos', 'K', 'POR', 'COD', 'NRG Stadium', '20260617 12:00:00', '20260617 17:00:00', 1, 1, 68777),
    (6, 'Fase de Grupos', 'L', 'ENG', 'CRO', 'AT&T Stadium', '20260617 15:00:00', '20260617 20:00:00', 4, 2, 70389),
    (7, 'Fase de Grupos', 'L', 'GHA', 'PAN', 'BMO Field', '20260617 19:00:00', '20260617 23:00:00', 1, 0, 42942),
    (8, 'Fase de Grupos', 'K', 'UZB', 'COL', 'Estadio Azteca', '20260617 20:00:00', '20260618 02:00:00', 1, 3, 80824),
    (9, 'Fase de Grupos', 'H', 'ESP', 'KSA', 'Mercedes-Benz Stadium', '20260621 12:00:00', '20260621 16:00:00', 4, 0, 68239),
    (10, 'Fase de Grupos', 'H', 'URU', 'CPV', 'Hard Rock Stadium', '20260621 18:00:00', '20260621 22:00:00', 2, 2, 64003),
    (11, 'Fase de Grupos', 'J', 'ARG', 'AUT', 'AT&T Stadium', '20260622 12:00:00', '20260622 17:00:00', 2, 0, 70649),
    (12, 'Fase de Grupos', 'J', 'JOR', 'ALG', 'Levi''s Stadium', '20260622 20:00:00', '20260623 03:00:00', 1, 2, 68371),
    (13, 'Fase de Grupos', 'K', 'POR', 'UZB', 'NRG Stadium', '20260623 12:00:00', '20260623 17:00:00', 5, 0, 68777),
    (14, 'Fase de Grupos', 'L', 'ENG', 'GHA', 'Gillette Stadium', '20260623 16:00:00', '20260623 20:00:00', 0, 0, 63983),
    (15, 'Fase de Grupos', 'L', 'PAN', 'CRO', 'BMO Field', '20260623 19:00:00', '20260623 23:00:00', 0, 1, 43036),
    (16, 'Fase de Grupos', 'K', 'COL', 'COD', 'Estadio Akron', '20260623 20:00:00', '20260624 02:00:00', 1, 0, 45358),
    (17, 'Fase de Grupos', 'H', 'URU', 'ESP', 'Estadio Akron', '20260626 18:00:00', '20260627 00:00:00', 0, 1, 45065),
    (18, 'Fase de Grupos', 'H', 'CPV', 'KSA', 'NRG Stadium', '20260626 19:00:00', '20260627 00:00:00', 0, 0, 68278),
    (19, 'Fase de Grupos', 'L', 'PAN', 'ENG', 'MetLife Stadium', '20260627 17:00:00', '20260627 21:00:00', 0, 2, 80663),
    (20, 'Fase de Grupos', 'L', 'CRO', 'GHA', 'Lincoln Financial Field', '20260627 17:00:00', '20260627 21:00:00', 2, 1, 68324),
    (21, 'Fase de Grupos', 'K', 'COL', 'POR', 'Hard Rock Stadium', '20260627 19:30:00', '20260627 23:30:00', 0, 0, 64478),
    (22, 'Fase de Grupos', 'K', 'COD', 'UZB', 'Mercedes-Benz Stadium', '20260627 19:30:00', '20260627 23:30:00', 3, 1, 68239),
    (23, 'Fase de Grupos', 'J', 'ALG', 'AUT', 'Arrowhead Stadium', '20260627 21:00:00', '20260628 02:00:00', 3, 3, 69045),
    (24, 'Fase de Grupos', 'J', 'JOR', 'ARG', 'AT&T Stadium', '20260627 21:00:00', '20260628 02:00:00', 1, 3, 70649),
    (25, 'Dieciseisavos de final', NULL, 'ENG', 'COD', 'Mercedes-Benz Stadium', '20260701 12:00:00', '20260701 16:00:00', 2, 1, 68239),
    (26, 'Dieciseisavos de final', NULL, 'ESP', 'AUT', 'SoFi Stadium', '20260702 12:00:00', '20260702 19:00:00', 3, 0, 70492),
    (27, 'Dieciseisavos de final', NULL, 'POR', 'CRO', 'BMO Field', '20260702 19:00:00', '20260702 23:00:00', 2, 1, 43036),
    (28, 'Dieciseisavos de final', NULL, 'ARG', 'CPV', 'Hard Rock Stadium', '20260703 18:00:00', '20260703 22:00:00', 3, 2, 64478),
    (29, 'Dieciseisavos de final', NULL, 'COL', 'GHA', 'Arrowhead Stadium', '20260703 20:30:00', '20260704 01:30:00', 1, 0, 69045),
    (30, 'Octavos de final', NULL, 'POR', 'ESP', 'AT&T Stadium', '20260706 14:00:00', '20260706 19:00:00', 0, 1, 70649),
    (31, 'Semifinales', NULL, 'ENG', 'ARG', 'Mercedes-Benz Stadium', '20260715 15:00:00', '20260715 19:00:00', 1, 2, 68239),
    (32, 'Final', NULL, 'ESP', 'ARG', 'MetLife Stadium', '20260719 15:00:00', '20260719 19:00:00', 1, 0, 80663);

UPDATE P
SET id_seleccion_local = SL.id_seleccion,
    id_seleccion_visitante = SV.id_seleccion
FROM #partidos P
INNER JOIN #selecciones SL ON SL.codigo_fifa = P.local_fifa
INNER JOIN #selecciones SV ON SV.codigo_fifa = P.visitante_fifa;

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #partidos);
DECLARE @id_partido INT, @id_fase INT, @id_sede INT, @local INT, @visitante INT, @fecha_local DATETIME, @fecha_utc DATETIME,
        @gl TINYINT, @gv TINYINT, @asistencia INT, @capacidad INT;
DECLARE @id_log INT = (SELECT TOP 1 id_log FROM Torneo.Log_importacion
                       WHERE nombre_archivo_o_fuente = 'Carga de datos de prueba (script 17)' ORDER BY id_log);

WHILE @i <= @n
BEGIN
    SELECT @id_fase = NULL, @id_sede = NULL, @local = NULL, @visitante = NULL, @id_partido = NULL;

    SELECT @id_fase = F.id_fase, @id_sede = S.id_sede, @local = P.id_seleccion_local, @visitante = P.id_seleccion_visitante,
           @fecha_local = P.fecha_hora_local, @fecha_utc = P.fecha_hora_utc, @gl = P.goles_local, @gv = P.goles_visitante,
           @asistencia = P.asistencia
    FROM #partidos P
    INNER JOIN Torneo.Fase F ON F.nombre_fase = P.fase
    INNER JOIN #sedes S ON S.estadio = P.estadio
    WHERE P.nro = @i;

    BEGIN TRY
        SET @id_partido = (SELECT id_partido FROM Torneo.Partido
                           WHERE id_fase = @id_fase AND id_seleccion_local = @local AND id_seleccion_visitante = @visitante);

        IF (@id_partido IS NULL)
        BEGIN
            -- La asistencia no puede superar la capacidad registrada de la sede (si la sede vino de otra fuente)
            SET @capacidad = (SELECT capacidad FROM Torneo.Sede WHERE id_sede = @id_sede);
            IF (@asistencia > @capacidad) SET @asistencia = @capacidad;

            EXEC Torneo.Alta_Partido @id_sede = @id_sede, @id_fase = @id_fase, @id_seleccion_local = @local,
                 @id_seleccion_visitante = @visitante, @id_importacion_origen = @id_log, @fecha_hora_local = @fecha_local,
                 @asistencia_publico = @asistencia, @goles_local = @gl, @goles_visitante = @gv, @UTC = @fecha_utc;

            SET @id_partido = (SELECT id_partido FROM Torneo.Partido
                               WHERE id_fase = @id_fase AND id_seleccion_local = @local AND id_seleccion_visitante = @visitante);
        END
        ELSE IF EXISTS (SELECT 1 FROM Torneo.Partido WHERE id_partido = @id_partido AND (goles_local IS NULL OR goles_visitante IS NULL))
            EXEC Torneo.Modificacion_Partido @id_partido = @id_partido, @goles_local = @gl, @goles_visitante = @gv;

        UPDATE #partidos SET id_partido = @id_partido WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Partido ', @i, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END
GO

------------------------------------------
-- 6. CLUBES, JUGADORES Y CONVOCATORIAS (23 por selección)
-- Si una selección ya tiene convocados (por ejemplo los del script 15), se completa hasta llegar a
-- 3 arqueros, 8 defensores, 7 mediocampistas y 5 delanteros. Los dorsales siguen la numeración habitual
-- de cada puesto. Los nombres son ficticios, armados con apellidos y nombres frecuentes de cada país.
------------------------------------------
PRINT '6. Jugadores y convocatorias';

CREATE TABLE #clubes (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    pais_iso CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    id_club INT NULL
);

INSERT INTO #clubes (nombre, pais_iso)
VALUES
    ('River Plate', 'ARG'), ('Racing Club', 'ARG'), ('Peñarol', 'URY'), ('Nacional', 'URY'),
    ('Atlético Nacional', 'COL'), ('Real Madrid CF', 'ESP'), ('FC Barcelona', 'ESP'), ('Atlético de Madrid', 'ESP'),
    ('Sevilla FC', 'ESP'), ('Arsenal FC', 'ENG'), ('Liverpool FC', 'ENG'), ('Manchester City FC', 'ENG'),
    ('Chelsea FC', 'ENG'), ('FC Bayern Múnich', 'DEU'), ('Borussia Dortmund', 'DEU'), ('Inter de Milán', 'ITA'),
    ('Juventus FC', 'ITA'), ('Paris Saint-Germain', 'FRA'), ('Olympique de Lyon', 'FRA'), ('SL Benfica', 'PRT'),
    ('FC Porto', 'PRT'), ('Sporting CP', 'PRT'), ('Al-Hilal', 'SAU'), ('Al-Nassr', 'SAU'),
    ('AFC Ajax', 'NLD'), ('Club América', 'MEX'), ('Inter Miami CF', 'USA'), ('Dinamo Zagreb', 'HRV'),
    ('Red Bull Salzburgo', 'AUT');

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #clubes);
DECLARE @club VARCHAR(50), @id_pais INT, @id_club INT;

WHILE @i <= @n
BEGIN
    SELECT @club = C.nombre, @id_pais = P.id_pais
    FROM #clubes C INNER JOIN #paises P ON P.codigo_iso = C.pais_iso
    WHERE C.nro = @i;

    BEGIN TRY
        SET @id_club = (SELECT id_club FROM Participantes.Club_origen WHERE id_pais_club = @id_pais AND nombre = @club);
        IF (@id_club IS NULL)
        BEGIN
            EXEC Participantes.Alta_Club_origen @nombre = @club, @id_pais_club = @id_pais;
            SET @id_club = (SELECT id_club FROM Participantes.Club_origen WHERE id_pais_club = @id_pais AND nombre = @club);
        END
        UPDATE #clubes SET id_club = @id_club WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Club ', @club, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END

-- Nombres y apellidos frecuentes por idioma (12 nombres y 16 apellidos por idioma)
CREATE TABLE #nombres (
    idioma VARCHAR(2) COLLATE DATABASE_DEFAULT NOT NULL,
    tipo CHAR(1) COLLATE DATABASE_DEFAULT NOT NULL,   -- N = nombre, A = apellido
    idx INT NOT NULL,
    valor VARCHAR(30) COLLATE DATABASE_DEFAULT NOT NULL,
    PRIMARY KEY (idioma, tipo, idx)
);

INSERT INTO #nombres (idioma, tipo, idx, valor)
SELECT L.idioma, L.tipo, CAST(V.[key] AS INT), V.[value]
FROM (VALUES
    ('es', 'N', '["Matías","Nicolás","Joaquín","Facundo","Santiago","Lucas","Tomás","Agustín","Diego","Gonzalo","Federico","Ramiro"]'),
    ('es', 'A', '["Fernández","González","Rodríguez","López","Martínez","Pérez","Sosa","Romero","Acosta","Benítez","Medina","Herrera","Suárez","Aguirre","Giménez","Molina"]'),
    ('pt', 'N', '["João","Pedro","Tiago","Rúben","André","Gonçalo","Nuno","Diogo","Rafael","Bruno","Ricardo","Hélder"]'),
    ('pt', 'A', '["Silva","Santos","Ferreira","Pereira","Costa","Oliveira","Rodrigues","Martins","Sousa","Fernandes","Gomes","Lopes","Marques","Almeida","Ribeiro","Pinto"]'),
    ('en', 'N', '["Harry","Jack","Oliver","George","Charlie","James","Thomas","Mason","Jordan","Luke","Callum","Reece"]'),
    ('en', 'A', '["Smith","Taylor","Walker","Wright","Robinson","Thompson","Hughes","Edwards","Green","Hall","Wood","Clarke","Jackson","Turner","Hill","Cooper"]'),
    ('ar', 'N', '["Mohamed","Ahmed","Youssef","Omar","Khalid","Hamza","Ali","Karim","Bilal","Yazan","Fahad","Salem"]'),
    ('ar', 'A', '["Al-Harbi","Haddad","Mansour","Benali","Saidi","Nasser","Al-Qahtani","Khalil","Boudiaf","Hamdan","Taha","Zayed","Brahimi","Al-Dawsari","Amrani","Faris"]'),
    ('de', 'N', '["Lukas","David","Florian","Stefan","Marcel","Maximilian","Philipp","Julian","Kevin","Patrick","Christoph","Markus"]'),
    ('de', 'A', '["Gruber","Huber","Bauer","Wagner","Pichler","Steiner","Moser","Mayer","Hofer","Leitner","Berger","Fuchs","Eder","Fischer","Schmid","Winkler"]'),
    ('hr', 'N', '["Luka","Ivan","Marko","Josip","Mateo","Ante","Nikola","Dominik","Petar","Filip","Karlo","Toni"]'),
    ('hr', 'A', '["Horvat","Kovacevic","Babic","Maric","Juric","Novak","Knezevic","Vukovic","Peric","Pavlovic","Matic","Tomic","Simic","Bozic","Grgic","Blazevic"]'),
    ('fr', 'N', '["Chancel","Cédric","Gaël","Arthur","Yoane","Dylan","Samuel","Merveille","Fiston","Jonathan","Christian","Neeskens"]'),
    ('fr', 'A', '["Mbemba","Kabongo","Bakambu","Masuaku","Kalulu","Mukoko","Tshibola","Ilunga","Kasongo","Mpasi","Kayembe","Bolasie","Mulumba","Ngoy","Banza","Lukebakio"]'),
    ('uz', 'N', '["Eldor","Jaloliddin","Otabek","Abbosbek","Rustam","Sherzod","Jasur","Odil","Dostonbek","Akmal","Bobur","Azizbek"]'),
    ('uz', 'A', '["Shomurodov","Masharipov","Alikulov","Fayzullaev","Ashurmatov","Nasrullaev","Khamdamov","Erkinov","Yusupov","Tursunov","Karimov","Rakhimov","Sobirov","Abdullaev","Islomov","Nematov"]'),
    ('gh', 'N', '["Kwame","Kofi","Kwabena","Yaw","Kojo","Kwasi","Ebenezer","Emmanuel","Daniel","Samuel","Isaac","Joseph"]'),
    ('gh', 'A', '["Mensah","Owusu","Boateng","Asante","Addo","Osei","Agyemang","Opoku","Ansah","Amoah","Badu","Frimpong","Sarpong","Danso","Appiah","Acheampong"]')
) AS L (idioma, tipo, lista)
CROSS APPLY OPENJSON(L.lista) AS V;

-- Dorsales habituales por puesto (24 a 26 quedan de reserva)
DECLARE @dorsales TABLE (grupo CHAR(3), prioridad INT, dorsal TINYINT);
INSERT INTO @dorsales (grupo, prioridad, dorsal)
VALUES ('ARQ', 1, 1), ('ARQ', 2, 12), ('ARQ', 3, 23),
       ('DEF', 1, 2), ('DEF', 2, 3), ('DEF', 3, 4), ('DEF', 4, 5), ('DEF', 5, 6), ('DEF', 6, 13), ('DEF', 7, 14), ('DEF', 8, 15),
       ('MED', 1, 8), ('MED', 2, 10), ('MED', 3, 16), ('MED', 4, 17), ('MED', 5, 18), ('MED', 6, 19), ('MED', 7, 20),
       ('DEL', 1, 9), ('DEL', 2, 7), ('DEL', 3, 11), ('DEL', 4, 21), ('DEL', 5, 22),
       ('ARQ', 9, 24), ('DEF', 9, 25), ('MED', 9, 26), ('DEL', 9, 24);

-- Cupo por puesto y puesto (posición) que corresponde a cada grupo
DECLARE @cupos TABLE (grupo CHAR(3), orden INT, cupo INT, posicion VARCHAR(30));
INSERT INTO @cupos (grupo, orden, cupo, posicion)
VALUES ('ARQ', 1, 3, 'Arquero'), ('DEF', 2, 8, 'Defensor'), ('MED', 3, 7, 'Mediocampista'), ('DEL', 4, 5, 'Delantero');

-- Convocados actuales (activos) por selección y grupo de puesto
;WITH actuales AS (
    SELECT C.id_seleccion,
           CASE WHEN PO.nombre_posicion LIKE 'Arquer%' OR PO.nombre_posicion LIKE 'Porter%' THEN 'ARQ'
                WHEN PO.nombre_posicion LIKE 'Defens%' THEN 'DEF'
                WHEN PO.nombre_posicion LIKE 'Delanter%' THEN 'DEL'
                ELSE 'MED' END AS grupo
    FROM Participantes.Convocatoria C
    INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
    INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
    WHERE C.estado_convocatoria <> 'Desafectado'
),
faltantes AS (
    SELECT S.nro AS nro_seleccion, S.id_seleccion, S.id_pais, S.idioma_nombres, CU.grupo, CU.orden, CU.posicion,
           CU.cupo - (SELECT COUNT(*) FROM actuales A WHERE A.id_seleccion = S.id_seleccion AND A.grupo = CU.grupo) AS cantidad
    FROM #selecciones S
    CROSS JOIN @cupos CU
    WHERE S.id_seleccion IS NOT NULL
),
filas AS (
    SELECT F.*, N.numero AS rn_grupo
    FROM faltantes F
    INNER JOIN (VALUES (1), (2), (3), (4), (5), (6), (7), (8)) AS N (numero) ON N.numero <= F.cantidad
),
dorsales_libres AS (
    SELECT S.id_seleccion, D.grupo, D.dorsal,
           ROW_NUMBER() OVER (PARTITION BY S.id_seleccion, D.grupo ORDER BY D.prioridad) AS rn_grupo
    FROM #selecciones S
    CROSS JOIN @dorsales D
    WHERE NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria C WHERE C.id_seleccion = S.id_seleccion AND C.dorsal = D.dorsal)
)
SELECT
    IDENTITY(INT, 1, 1) AS nro,
    F.id_seleccion,
    F.nro_seleccion,
    F.id_pais,
    F.idioma_nombres,
    F.grupo,
    F.posicion,
    F.orden,
    F.rn_grupo,
    D.dorsal
INTO #nuevos_jugadores
FROM filas F
LEFT JOIN dorsales_libres D ON D.id_seleccion = F.id_seleccion AND D.grupo = F.grupo AND D.rn_grupo = F.rn_grupo;

-- Dorsales de reserva: si una selección ya tenía convocados (por ejemplo, de los scripts de prueba) que ocupan
-- los dorsales habituales de un puesto, o si dos jugadores nuevos quedaron con el mismo, se usa el primer dorsal
-- libre entre 1 y 26.
;WITH repetidos AS (
    SELECT dorsal, ROW_NUMBER() OVER (PARTITION BY id_seleccion, dorsal ORDER BY nro) AS rn
    FROM #nuevos_jugadores
    WHERE dorsal IS NOT NULL
)
UPDATE repetidos SET dorsal = NULL WHERE rn > 1;

;WITH sin_dorsal AS (
    SELECT nro, id_seleccion, ROW_NUMBER() OVER (PARTITION BY id_seleccion ORDER BY nro) AS rn
    FROM #nuevos_jugadores
    WHERE dorsal IS NULL
),
numeros AS (
    SELECT TOP (26) CAST(ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS TINYINT) AS dorsal
    FROM sys.all_objects
),
libres AS (
    SELECT S.id_seleccion, N.dorsal, ROW_NUMBER() OVER (PARTITION BY S.id_seleccion ORDER BY N.dorsal) AS rn
    FROM (SELECT DISTINCT id_seleccion FROM sin_dorsal) S
    CROSS JOIN numeros N
    WHERE NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria C WHERE C.id_seleccion = S.id_seleccion AND C.dorsal = N.dorsal)
      AND NOT EXISTS (SELECT 1 FROM #nuevos_jugadores NJ WHERE NJ.id_seleccion = S.id_seleccion AND NJ.dorsal = N.dorsal)
)
UPDATE NJ SET dorsal = L.dorsal
FROM #nuevos_jugadores NJ
INNER JOIN sin_dorsal SD ON SD.nro = NJ.nro
INNER JOIN libres L ON L.id_seleccion = SD.id_seleccion AND L.rn = SD.rn;

ALTER TABLE #nuevos_jugadores ADD k INT NULL, nombre VARCHAR(30) NULL, apellido VARCHAR(30) NULL, fecha_nacimiento DATE NULL,
                                  id_posicion INT NULL, id_club INT NULL;
GO

-- Nombre, apellido, fecha de nacimiento (22 a 33 años), puesto y club de cada jugador nuevo
-- k = posición del jugador dentro del plantel (después de los convocados que la selección ya tenía): así una
-- nueva ejecución que completa faltantes no repite los nombres de los que ya se cargaron.
;WITH orden AS (
    SELECT NJ.nro,
           (SELECT COUNT(*) FROM Participantes.Convocatoria C
            WHERE C.id_seleccion = NJ.id_seleccion AND C.estado_convocatoria <> 'Desafectado')
           + ROW_NUMBER() OVER (PARTITION BY NJ.id_seleccion ORDER BY NJ.orden, NJ.rn_grupo) - 1 AS k
    FROM #nuevos_jugadores NJ
)
UPDATE NJ SET k = O.k
FROM #nuevos_jugadores NJ INNER JOIN orden O ON O.nro = NJ.nro;

DECLARE @cantidad_clubes INT = (SELECT COUNT(*) FROM #clubes WHERE id_club IS NOT NULL);

UPDATE NJ
SET nombre = NN.valor,
    apellido = NA.valor,
    fecha_nacimiento = DATEADD(DAY, (NJ.k * 137 + NJ.nro_seleccion * 53) % 3650, CAST('19930101' AS DATE)),
    id_posicion = PO.id_posicion,
    id_club = CL.id_club
FROM #nuevos_jugadores NJ
INNER JOIN #nombres NN ON NN.idioma = NJ.idioma_nombres AND NN.tipo = 'N'
                      AND NN.idx = (NJ.k + NJ.nro_seleccion * 3 + NJ.k / 16) % 12
INNER JOIN #nombres NA ON NA.idioma = NJ.idioma_nombres AND NA.tipo = 'A'
                      AND NA.idx = (NJ.k + NJ.nro_seleccion * 5) % 16
INNER JOIN Participantes.Posicion PO ON PO.nombre_posicion = NJ.posicion
INNER JOIN (SELECT id_club, ROW_NUMBER() OVER (ORDER BY nro) - 1 AS idx FROM #clubes WHERE id_club IS NOT NULL) CL
        ON CL.idx = (NJ.k * 7 + NJ.nro_seleccion * 3) % @cantidad_clubes;

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #nuevos_jugadores);
DECLARE @nombre VARCHAR(30), @apellido VARCHAR(30), @fecha DATE, @id_pais INT, @id_posicion INT, @id_club INT,
        @id_seleccion INT, @dorsal TINYINT, @id_jugador INT, @creados INT = 0;

WHILE @i <= ISNULL(@n, 0)
BEGIN
    SELECT @nombre = nombre, @apellido = apellido, @fecha = fecha_nacimiento, @id_pais = id_pais, @id_posicion = id_posicion,
           @id_club = id_club, @id_seleccion = id_seleccion, @dorsal = dorsal
    FROM #nuevos_jugadores WHERE nro = @i;

    BEGIN TRY
        -- Si ya existe un jugador convocado con el mismo nombre y fecha, se corre la fecha de nacimiento un día
        -- (un jugador creado en una ejecución anterior que no llegó a convocarse se reutiliza)
        WHILE EXISTS (SELECT 1 FROM Participantes.Jugador J
                      INNER JOIN Participantes.Convocatoria C ON C.id_jugador = J.id_jugador
                      WHERE J.nombre = @nombre AND J.apellido = @apellido AND J.fecha_nacimiento = @fecha
                        AND J.id_pais_nacimiento = @id_pais)
            SET @fecha = DATEADD(DAY, 1, @fecha);

        SET @id_jugador = (SELECT id_jugador FROM Participantes.Jugador
                           WHERE nombre = @nombre AND apellido = @apellido AND fecha_nacimiento = @fecha AND id_pais_nacimiento = @id_pais);
        IF (@id_jugador IS NULL)
        BEGIN
            EXEC Participantes.Alta_Jugador @nombre = @nombre, @apellido = @apellido, @fecha_nacimiento = @fecha,
                 @id_pais_nacimiento = @id_pais, @id_posicion_habitual = @id_posicion, @id_club_origen = @id_club;
            SET @id_jugador = (SELECT id_jugador FROM Participantes.Jugador
                               WHERE nombre = @nombre AND apellido = @apellido AND fecha_nacimiento = @fecha AND id_pais_nacimiento = @id_pais);
        END

        IF NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_jugador = @id_jugador)
        BEGIN
            EXEC Participantes.Alta_Convocatoria @id_seleccion = @id_seleccion, @id_jugador = @id_jugador,
                 @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260520', @dorsal = @dorsal;
            SET @creados += 1;
        END
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Jugador ', @nombre, ' ', @apellido, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END

PRINT CONCAT('  Convocatorias nuevas: ', @creados);
GO

------------------------------------------
-- 7. CUERPOS TÉCNICOS Y NOVEDAD DE CONVOCATORIA
------------------------------------------
PRINT '7. Cuerpos técnicos';

DECLARE @cargos TABLE (orden INT, cargo VARCHAR(30));
INSERT INTO @cargos VALUES (1, 'Director técnico'), (2, 'Ayudante de campo'), (3, 'Preparador físico');

DECLARE @ct TABLE (nro INT IDENTITY(1,1), id_seleccion INT, nombre VARCHAR(30), apellido VARCHAR(30), cargo VARCHAR(30));

INSERT INTO @ct (id_seleccion, nombre, apellido, cargo)
SELECT S.id_seleccion, NN.valor, NA.valor, CA.cargo
FROM #selecciones S
CROSS JOIN @cargos CA
INNER JOIN #nombres NN ON NN.idioma = S.idioma_nombres AND NN.tipo = 'N' AND NN.idx = (S.nro + CA.orden * 5) % 12
INNER JOIN #nombres NA ON NA.idioma = S.idioma_nombres AND NA.tipo = 'A' AND NA.idx = (S.nro * 3 + CA.orden * 7 + 2) % 16
WHERE S.id_seleccion IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM Participantes.Integrante_cuerpo_tecnico I
                  WHERE I.id_seleccion = S.id_seleccion AND I.cargo_rol = CA.cargo);

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM @ct);
DECLARE @id_seleccion INT, @nombre VARCHAR(30), @apellido VARCHAR(30), @cargo VARCHAR(30);

WHILE @i <= ISNULL(@n, 0)
BEGIN
    SELECT @id_seleccion = id_seleccion, @nombre = nombre, @apellido = apellido, @cargo = cargo FROM @ct WHERE nro = @i;
    BEGIN TRY
        EXEC Participantes.Alta_Integrante_cuerpo_tecnico @id_seleccion = @id_seleccion, @nombre = @nombre,
             @apellido = @apellido, @cargo_rol = @cargo;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Cuerpo técnico: ', ERROR_MESSAGE());
    END CATCH;
    SET @i += 1;
END

-- Novedad: un mediocampista de España se lesiona antes del torneo y lo reemplaza un jugador nuevo (dorsal 24)
DECLARE @sel_esp INT = (SELECT id_seleccion FROM #selecciones WHERE codigo_fifa = 'ESP');
DECLARE @pais_esp INT = (SELECT id_pais FROM #selecciones WHERE codigo_fifa = 'ESP');
DECLARE @pos_med INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Mediocampista');
DECLARE @club_esp INT = (SELECT TOP 1 id_club FROM #clubes WHERE pais_iso = 'ESP' AND id_club IS NOT NULL ORDER BY nro);
DECLARE @conv_baja INT, @conv_alta INT, @id_jugador INT;

IF (@sel_esp IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM Participantes.Novedad_convocatoria N
                    INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = N.id_convocatoria_baja
                    WHERE C.id_seleccion = @sel_esp)
    AND NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_seleccion = @sel_esp AND dorsal = 24))
BEGIN
    BEGIN TRY
        SET @conv_baja = (SELECT TOP 1 C.id_convocatoria
                          FROM Participantes.Convocatoria C
                          INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
                          WHERE C.id_seleccion = @sel_esp AND J.id_posicion_habitual = @pos_med AND C.estado_convocatoria <> 'Desafectado'
                          ORDER BY C.dorsal DESC);

        IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE nombre = 'Pablo' AND apellido = 'Ibarra' AND fecha_nacimiento = '20000314')
            EXEC Participantes.Alta_Jugador @nombre = 'Pablo', @apellido = 'Ibarra', @fecha_nacimiento = '20000314',
                 @id_pais_nacimiento = @pais_esp, @id_posicion_habitual = @pos_med, @id_club_origen = @club_esp;
        SET @id_jugador = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Pablo' AND apellido = 'Ibarra' AND fecha_nacimiento = '20000314');

        EXEC Participantes.Alta_Convocatoria @id_seleccion = @sel_esp, @id_jugador = @id_jugador,
             @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260603', @dorsal = 24;
        SET @conv_alta = (SELECT id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @id_jugador);

        EXEC Participantes.Registrar_Reemplazo_Convocatoria @id_convocatoria_baja = @conv_baja, @id_convocatoria_alta = @conv_alta,
             @motivo_cambio = 'Lesión', @fecha_cambio = '20260603', @observaciones = 'Desgarro en el entrenamiento';
        PRINT '  Novedad registrada: reemplazo por lesión en España.';
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Novedad de convocatoria: ', ERROR_MESSAGE());
    END CATCH;
END
GO

------------------------------------------
-- 8. ÁRBITROS (15, con sus idiomas)
-- El árbitro argentino se usa para el caso de designación rechazada por nacionalidad.
------------------------------------------
PRINT '8. Árbitros';

CREATE TABLE #arbitros (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    apellido VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    pais_iso CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    idioma_1 VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL,
    idioma_2 VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
    id_pais INT NULL,
    id_arbitro INT NULL
);

INSERT INTO #arbitros (nombre, apellido, fecha_nacimiento, pais_iso, idioma_1, idioma_2)
VALUES
    ('Marco', 'Bellini', '19840312', 'ITA', 'Italiano', 'Inglés'),
    ('Tobias', 'Kramer', '19850721', 'DEU', 'Alemán', 'Inglés'),
    ('Ruud', 'van Dijkstra', '19831102', 'NLD', 'Inglés', 'Alemán'),
    ('Julien', 'Marchand', '19860130', 'FRA', 'Francés', 'Inglés'),
    ('Rafael', 'Antunes', '19820514', 'BRA', 'Portugués', 'Español'),
    ('Arturo', 'Villaseñor', '19840909', 'MEX', 'Español', 'Inglés'),
    ('Ryan', 'Whitfield', '19870418', 'USA', 'Inglés', 'Español'),
    ('Kenta', 'Morimoto', '19851201', 'JPN', 'Japonés', 'Inglés'),
    ('Cristián', 'Valdebenito', '19830625', 'CHL', 'Español', NULL),
    ('Tomasz', 'Wisniewski', '19821007', 'POL', 'Inglés', NULL),
    ('Erik', 'Lindqvist', '19860211', 'SWE', 'Inglés', 'Alemán'),
    ('Liam', 'Prescott', '19880803', 'AUS', 'Inglés', NULL),
    ('Youssef', 'Bennani', '19840422', 'MAR', 'Árabe', 'Francés'),
    ('Abdullah', 'Al-Kuwari', '19870116', 'QAT', 'Árabe', 'Inglés'),
    ('Sebastián', 'Correa', '19830305', 'ARG', 'Español', 'Inglés');

UPDATE A SET id_pais = P.id_pais FROM #arbitros A INNER JOIN #paises P ON P.codigo_iso = A.pais_iso;

DECLARE @i INT = 1, @n INT = (SELECT MAX(nro) FROM #arbitros);
DECLARE @nombre VARCHAR(50), @apellido VARCHAR(50), @fecha DATE, @id_pais INT, @id_arbitro INT, @idioma1 VARCHAR(50),
        @idioma2 VARCHAR(50), @id_idioma INT;
DECLARE @id_categoria INT = (SELECT id_categoria FROM Participantes.Categoria_arbitro WHERE descripcion = 'Internacional FIFA');

WHILE @i <= @n
BEGIN
    SELECT @nombre = nombre, @apellido = apellido, @fecha = fecha_nacimiento, @id_pais = id_pais,
           @idioma1 = idioma_1, @idioma2 = idioma_2
    FROM #arbitros WHERE nro = @i;

    BEGIN TRY
        SET @id_arbitro = (SELECT id_arbitro FROM Participantes.Arbitro
                           WHERE nombre = @nombre AND apellido = @apellido AND fecha_nacimiento = @fecha AND id_pais = @id_pais);
        IF (@id_arbitro IS NULL)
        BEGIN
            EXEC Participantes.Alta_Arbitro @id_pais = @id_pais, @id_categoria = @id_categoria, @nombre = @nombre,
                 @apellido = @apellido, @fecha_nacimiento = @fecha;
            SET @id_arbitro = (SELECT id_arbitro FROM Participantes.Arbitro
                               WHERE nombre = @nombre AND apellido = @apellido AND fecha_nacimiento = @fecha AND id_pais = @id_pais);
        END

        SET @id_idioma = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = @idioma1);
        IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma_arbitro WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma)
            EXEC Participantes.Alta_Idioma_arbitro @id_arbitro = @id_arbitro, @id_idioma = @id_idioma;

        SET @id_idioma = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = @idioma2);
        IF (@id_idioma IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Participantes.Idioma_arbitro WHERE id_arbitro = @id_arbitro AND id_idioma = @id_idioma))
            EXEC Participantes.Alta_Idioma_arbitro @id_arbitro = @id_arbitro, @id_idioma = @id_idioma;

        UPDATE #arbitros SET id_arbitro = @id_arbitro WHERE nro = @i;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Árbitro ', @nombre, ' ', @apellido, ': ', ERROR_MESSAGE());
    END CATCH;

    SET @i += 1;
END
GO

------------------------------------------
-- 9. PUBLICIDAD: 8 anunciantes de 8 países, campañas 2026 e históricas (Qatar 2022), mercados y piezas
-- Las campañas 2026 están vigentes en todo el torneo, así cada partido tiene más de 4 piezas candidatas.
-- Mercados europeos (España, Portugal, Francia, Italia, Alemania, Austria, Países Bajos, Inglaterra): un partido a
-- las 20:00 UTC (Inglaterra - Croacia) cae en prime time en todos ellos a la vez.
------------------------------------------
PRINT '9. Publicidad';

DECLARE @anunciantes TABLE (nro INT IDENTITY(1,1), nombre VARCHAR(50), pais_iso CHAR(3), fiscal VARCHAR(50));
INSERT INTO @anunciantes (nombre, pais_iso, fiscal)
VALUES ('Cervecería del Plata', 'ARG', 'CUIT 30-70000001-1'),
       ('Banco Ibérico', 'ESP', 'NIF A00000002'),
       ('Autos Rhein', 'DEU', 'USt-IdNr DE000000003'),
       ('Maison Lumière', 'FRA', 'SIREN 000000004'),
       ('Café Andino', 'COL', 'NIT 900000005-1'),
       ('TechNova', 'USA', 'EIN 00-0000006'),
       ('Aerolíneas Sol Azteca', 'MEX', 'RFC SAZ000000007'),
       ('Sakura Electronics', 'JPN', 'JCN 0000000000008');

DECLARE @campanias TABLE (nro INT IDENTITY(1,1), anunciante VARCHAR(50), nombre VARCHAR(100), inicio DATE, fin DATE,
                          presupuesto DECIMAL(18,2), mercados VARCHAR(100));
INSERT INTO @campanias (anunciante, nombre, inicio, fin, presupuesto, mercados)
VALUES ('Cervecería del Plata', 'Pasión Mundialista 2026', '20260601', '20260731', 2500000, 'ARG,URY,CHL,ESP'),
       ('Cervecería del Plata', 'Qatar 2022 - Vamos Juntos', '20221101', '20221220', 1800000, 'ARG,URY'),
       ('Banco Ibérico', 'Banco Ibérico Mundial 2026', '20260601', '20260731', 3200000, 'ESP,PRT,FRA,ITA'),
       ('Autos Rhein', 'Rhein Eléctrico 2026', '20260605', '20260725', 4000000, 'DEU,AUT,NLD,ENG'),
       ('Autos Rhein', 'Rhein Qatar 2022', '20221115', '20221218', 2500000, 'DEU,AUT'),
       ('Maison Lumière', 'Lumière Été 2026', '20260601', '20260720', 2100000, 'FRA,ITA,ESP,NLD'),
       ('Café Andino', 'Café Andino Mundial 2026', '20260601', '20260731', 900000, 'COL,USA,MEX,PAN'),
       ('TechNova', 'TechNova World Cup 2026', '20260601', '20260731', 5000000, 'USA,CAN,MEX,ENG,JPN'),
       ('TechNova', 'TechNova Qatar 2022', '20221101', '20221218', 3500000, 'USA,CAN'),
       ('Aerolíneas Sol Azteca', 'Vuela al Mundial 2026', '20260520', '20260731', 1500000, 'MEX,USA,COL,ESP,ARG'),
       ('Sakura Electronics', 'Sakura Vision 2026', '20260601', '20260731', 2800000, 'JPN,DEU,NLD,ENG,AUS');

DECLARE @piezas TABLE (nro INT IDENTITY(1,1), campania VARCHAR(100), nombre VARCHAR(50), idioma VARCHAR(50), duracion SMALLINT, url VARCHAR(255));
INSERT INTO @piezas (campania, nombre, idioma, duracion, url)
VALUES ('Pasión Mundialista 2026', 'Spot Asado 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/plata-asado-30.mp4'),
       ('Pasión Mundialista 2026', 'Spot Hinchada 20s', 'Español', 20, 'https://cdn.ejemplo.com/spots/plata-hinchada-20.mp4'),
       ('Qatar 2022 - Vamos Juntos', 'Spot Qatar 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/plata-qatar-30.mp4'),
       ('Banco Ibérico Mundial 2026', 'Spot Ahorro 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/iberico-ahorro-30.mp4'),
       ('Banco Ibérico Mundial 2026', 'Spot Ahorro PT 30s', 'Portugués', 30, 'https://cdn.ejemplo.com/spots/iberico-ahorro-pt-30.mp4'),
       ('Rhein Eléctrico 2026', 'Spot Eléctrico 45s', 'Alemán', 45, 'https://cdn.ejemplo.com/spots/rhein-elektro-45.mp4'),
       ('Rhein Eléctrico 2026', 'Spot Electric EN 45s', 'Inglés', 45, 'https://cdn.ejemplo.com/spots/rhein-electric-en-45.mp4'),
       ('Rhein Qatar 2022', 'Spot Rhein 2022', 'Alemán', 30, 'https://cdn.ejemplo.com/spots/rhein-2022-30.mp4'),
       ('Lumière Été 2026', 'Spot Parfum 20s', 'Francés', 20, 'https://cdn.ejemplo.com/spots/lumiere-parfum-20.mp4'),
       ('Café Andino Mundial 2026', 'Spot Café 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/andino-cafe-30.mp4'),
       ('TechNova World Cup 2026', 'Spot Smartphone 30s', 'Inglés', 30, 'https://cdn.ejemplo.com/spots/technova-phone-30.mp4'),
       ('TechNova World Cup 2026', 'Spot Smartphone ES 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/technova-phone-es-30.mp4'),
       ('TechNova Qatar 2022', 'Spot TechNova 2022', 'Inglés', 30, 'https://cdn.ejemplo.com/spots/technova-2022-30.mp4'),
       ('Vuela al Mundial 2026', 'Spot Vuelos 30s', 'Español', 30, 'https://cdn.ejemplo.com/spots/solazteca-vuelos-30.mp4'),
       ('Sakura Vision 2026', 'Spot TV 8K 30s', 'Japonés', 30, 'https://cdn.ejemplo.com/spots/sakura-8k-30.mp4'),
       ('Sakura Vision 2026', 'Spot TV 8K EN 30s', 'Inglés', 30, 'https://cdn.ejemplo.com/spots/sakura-8k-en-30.mp4');

DECLARE @i INT, @n INT;
DECLARE @nombre VARCHAR(100), @pais_iso CHAR(3), @fiscal VARCHAR(50), @id_pais INT, @id_anunciante INT, @id_campania INT,
        @inicio DATE, @fin DATE, @presupuesto DECIMAL(18,2), @mercados VARCHAR(100), @campania VARCHAR(100),
        @idioma VARCHAR(50), @id_idioma INT, @duracion SMALLINT, @url VARCHAR(255), @id_mercado INT;

-- Anunciantes
SELECT @i = 1, @n = MAX(nro) FROM @anunciantes;
WHILE @i <= @n
BEGIN
    SELECT @nombre = A.nombre, @fiscal = A.fiscal, @id_pais = P.id_pais
    FROM @anunciantes A INNER JOIN #paises P ON P.codigo_iso = A.pais_iso WHERE A.nro = @i;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE nombre_anunciante = @nombre)
            EXEC Publicidad.Alta_Anunciante @nombre_anunciante = @nombre, @id_pais_origen = @id_pais, @identificacion_fiscal = @fiscal;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Anunciante ', @nombre, ': ', ERROR_MESSAGE());
    END CATCH;
    SET @i += 1;
END

-- Campañas y mercados de interés
DECLARE @lista_mercados TABLE (nro INT IDENTITY(1,1), id_pais INT);
DECLARE @m INT, @mmax INT;
SELECT @i = 1, @n = MAX(nro) FROM @campanias;
WHILE @i <= @n
BEGIN
    SELECT @campania = C.nombre, @inicio = C.inicio, @fin = C.fin, @presupuesto = C.presupuesto, @mercados = C.mercados,
           @id_anunciante = A.id_anunciante
    FROM @campanias C INNER JOIN Publicidad.Anunciante A ON A.nombre_anunciante = C.anunciante
    WHERE C.nro = @i;

    BEGIN TRY
        SET @id_campania = (SELECT TOP 1 id_campania FROM Publicidad.Campania_publicitaria
                            WHERE id_anunciante = @id_anunciante AND nombre_campania = @campania);
        IF (@id_campania IS NULL)
        BEGIN
            EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @id_anunciante, @nombre_campania = @campania,
                 @fecha_inicio = @inicio, @fecha_fin = @fin, @presupuesto = @presupuesto;
            SET @id_campania = (SELECT TOP 1 id_campania FROM Publicidad.Campania_publicitaria
                                WHERE id_anunciante = @id_anunciante AND nombre_campania = @campania);
        END

        -- Mercados (lista separada por comas de códigos ISO)
        DELETE FROM @lista_mercados;
        INSERT INTO @lista_mercados (id_pais)
        SELECT P.id_pais
        FROM STRING_SPLIT(@mercados, ',') AS M
        INNER JOIN #paises P ON P.codigo_iso = LTRIM(RTRIM(M.value))
        WHERE P.id_pais IS NOT NULL;

        SELECT @m = MIN(nro), @mmax = MAX(nro) FROM @lista_mercados;
        WHILE @m <= @mmax
        BEGIN
            SET @id_mercado = (SELECT id_pais FROM @lista_mercados WHERE nro = @m);
            IF NOT EXISTS (SELECT 1 FROM Publicidad.Mercado_interes_campania WHERE id_campania = @id_campania AND id_pais = @id_mercado)
                EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = @id_campania, @id_pais = @id_mercado;
            SET @m += 1;
        END
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Campaña ', @campania, ': ', ERROR_MESSAGE());
    END CATCH;
    SET @i += 1;
END

-- Piezas publicitarias
SELECT @i = 1, @n = MAX(nro) FROM @piezas;
WHILE @i <= @n
BEGIN
    SELECT @campania = P.campania, @nombre = P.nombre, @idioma = P.idioma, @duracion = P.duracion, @url = P.url
    FROM @piezas P WHERE P.nro = @i;

    BEGIN TRY
        SET @id_campania = (SELECT TOP 1 id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = @campania ORDER BY id_campania);
        SET @id_idioma = (SELECT id_idioma FROM Participantes.Idioma WHERE nombre = @idioma);
        IF NOT EXISTS (SELECT 1 FROM Publicidad.Pieza_publicitaria WHERE id_campania = @id_campania AND nombre_pieza = @nombre)
            EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @id_campania, @id_idioma = @id_idioma, @nombre_pieza = @nombre,
                 @duracion_segundos = @duracion, @url_contenido_media = @url;
    END TRY
    BEGIN CATCH
        PRINT CONCAT('  Pieza ', @nombre, ': ', ERROR_MESSAGE());
    END CATCH;
    SET @i += 1;
END
GO

------------------------------------------
-- 10. DESARROLLO DE LOS PARTIDOS (en orden cronológico)
-- Para cada partido que todavía no tiene planilla:
--   a. Planillas de ambos equipos con Confirmar_Planilla_Jugador: 11 titulares según el esquema habitual (arquero,
--      defensores, mediocampistas y delanteros por dorsal) y el resto como suplentes. Los suspendidos para ese
--      partido quedan afuera: primero se intenta cargarlos para mostrar que el SP los rechaza.
--   b. Goles (Registrar_Gol_Partido) que coinciden con el resultado real.
--   c. Tarjetas (Registrar_Tarjeta_Partido, que genera las suspensiones): las de los casos obligatorios y
--      1 o 2 amarillas por equipo.
--   d. Tres sustituciones por equipo (Registrar_Sustitucion_Partido).
--   e. Designación completa de 5 árbitros sin conflicto de nacionalidad (Asignar_Arbitro_Partido) e informe
--      post partido del principal.
--   f. Asignación de las 4 piezas publicitarias (Asignar_Publicidad_Partido).
--   g. Las suspensiones de 1 fecha que se cumplían en ese partido se marcan como cumplidas.
------------------------------------------
PRINT '10. Desarrollo de los partidos';

-- Jugadores de los casos obligatorios (se fijan antes de empezar, por puesto y dorsal)
CREATE TABLE #casos (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    caso VARCHAR(40) COLLATE DATABASE_DEFAULT NOT NULL,
    partido_nro INT NOT NULL,
    equipo_fifa CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    nro_defensor INT NOT NULL,       -- n-ésimo defensor de la selección por dorsal
    tarjeta VARCHAR(10) COLLATE DATABASE_DEFAULT NULL,
    minuto TINYINT NULL,
    motivo VARCHAR(30) COLLATE DATABASE_DEFAULT NULL,
    id_convocatoria INT NULL
);

INSERT INTO #casos (caso, partido_nro, equipo_fifa, nro_defensor, tarjeta, minuto, motivo)
VALUES
    ('Lesión antes de los 20 minutos', 3, 'ARG', 1, NULL, 15, NULL),             -- Argentina - Argelia
    ('Acumulación de amarillas', 5, 'POR', 3, 'Amarilla', 28, 'Protesta'),        -- Portugal - RD Congo
    ('Doble amarilla', 10, 'CPV', 1, 'Amarilla', 34, 'Juego brusco'),             -- Uruguay - Cabo Verde
    ('Doble amarilla', 10, 'CPV', 1, 'Amarilla', 71, 'Conducta antideportiva'),
    ('Roja directa', 12, 'JOR', 2, 'Roja', 55, 'Falta grave'),                    -- Jordania - Argelia
    ('Acumulación de amarillas', 13, 'POR', 3, 'Amarilla', 66, 'Demora en el juego'); -- Portugal - Uzbekistán (suspendido vs Colombia)

;WITH defensores AS (
    SELECT S.codigo_fifa, C.id_convocatoria,
           ROW_NUMBER() OVER (PARTITION BY S.codigo_fifa ORDER BY C.dorsal) AS rn
    FROM #selecciones S
    INNER JOIN Participantes.Convocatoria C ON C.id_seleccion = S.id_seleccion
    INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
    INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
    WHERE PO.nombre_posicion LIKE 'Defens%' AND C.estado_convocatoria <> 'Desafectado'
)
UPDATE CA SET id_convocatoria = D.id_convocatoria
FROM #casos CA INNER JOIN defensores D ON D.codigo_fifa = CA.equipo_fifa AND D.rn = CA.nro_defensor;
GO

CREATE TABLE #disp (
    nro INT IDENTITY(1,1) PRIMARY KEY,
    id_convocatoria INT NOT NULL,
    id_posicion INT NOT NULL,
    grupo CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    dorsal TINYINT NOT NULL,
    suspendido BIT NOT NULL,
    titular BIT NOT NULL
);

CREATE TABLE #jug (
    equipo TINYINT NOT NULL,            -- 1 = local, 2 = visitante
    id_convocatoria INT NOT NULL PRIMARY KEY,
    grupo CHAR(3) COLLATE DATABASE_DEFAULT NOT NULL,
    dorsal TINYINT NOT NULL,
    titular BIT NOT NULL,
    goleador BIT NOT NULL DEFAULT 0,
    amonestado BIT NOT NULL DEFAULT 0,
    expulsado BIT NOT NULL DEFAULT 0
);

CREATE TABLE #sale (nro INT IDENTITY(1,1) PRIMARY KEY, id_convocatoria INT NOT NULL, motivo VARCHAR(50) COLLATE DATABASE_DEFAULT NOT NULL);
CREATE TABLE #entra (nro INT IDENTITY(1,1) PRIMARY KEY, id_convocatoria INT NOT NULL);

-- Resultado de cada asignación de publicidad (misma estructura que devuelve Asignar_Publicidad_Partido)
CREATE TABLE #pub (
    numero_espacio BIGINT NULL,
    posicion BIGINT NULL,
    nombre_anunciante VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
    nombre_campania VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
    nombre_pieza VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
    mercado_priorizado VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
    es_mercado_partido BIT NULL,
    es_prime_time BIT NULL,
    hora_local_mercado DATETIME NULL,
    pbi_per_capita DECIMAL(18,2) NULL,
    tarifa_aplicada_usd DECIMAL(18,2) NULL,
    id_partido INT NULL
);
GO

DECLARE @k INT = 1, @kmax INT = (SELECT MAX(nro) FROM #partidos);
DECLARE @p INT, @sl INT, @sv INT, @gl TINYINT, @gv TINYINT, @pais_l INT, @pais_v INT, @titulo VARCHAR(80);
DECLARE @t TINYINT, @sel INT, @esquema VARCHAR(10), @id_esquema INT, @id_al INT, @q_def INT, @q_med INT, @q_del INT, @faltan INT;
DECLARE @r INT, @rmax INT, @pasada INT, @conv INT, @pos INT, @tit BIT;
DECLARE @g INT, @j INT, @n_atk INT, @autor INT, @asist INT, @tipo_gol VARCHAR(30), @minuto TINYINT, @n_cand INT, @n_amarillas INT;
DECLARE @id_tipo_gol INT, @id_periodo INT, @id_tipo_tarjeta INT, @id_motivo INT, @tarjeta VARCHAR(10), @motivo VARCHAR(30);
DECLARE @s INT, @smax INT, @sale INT, @entra INT, @motivo_sust VARCHAR(50), @hay_lesion BIT;
DECLARE @id_arbitro INT, @id_rol INT, @id_principal INT, @id_arbitro_arg INT;
DECLARE @id_susp INT, @calificacion TINYINT, @observaciones VARCHAR(255);
DECLARE @p1 INT = (SELECT id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Primer tiempo');
DECLARE @p2 INT = (SELECT id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Segundo tiempo');
DECLARE @amarilla INT = (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla');
DECLARE @roja INT = (SELECT id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja');
DECLARE @roles TABLE (orden INT, id_rol_arbitro INT);
DECLARE @designados TABLE (orden INT IDENTITY(1,1), id_arbitro INT);

INSERT INTO @roles (orden, id_rol_arbitro)
SELECT V.orden, R.id_rol_arbitro
FROM (VALUES (1, 'Principal'), (2, 'Asistente 1'), (3, 'Asistente 2'), (4, 'Cuarto árbitro'), (5, 'VAR')) AS V (orden, rol)
INNER JOIN Participantes.Rol_arbitro R ON R.descripcion = V.rol;

SET @id_arbitro_arg = (SELECT A.id_arbitro FROM #arbitros A WHERE A.pais_iso = 'ARG');

WHILE @k <= @kmax
BEGIN
    SELECT @p = NULL, @sl = NULL, @sv = NULL;
    SELECT @p = P.id_partido, @sl = P.id_seleccion_local, @sv = P.id_seleccion_visitante, @gl = P.goles_local, @gv = P.goles_visitante,
           @titulo = CONCAT(P.nro, '. ', P.local_fifa, ' ', P.goles_local, '-', P.goles_visitante, ' ', P.visitante_fifa, ' (', P.fase, ')')
    FROM #partidos P WHERE P.nro = @k;

    IF (@p IS NULL OR @sl IS NULL OR @sv IS NULL)
    BEGIN
        PRINT CONCAT('  Partido ', @k, ': no se pudo crear, se saltea.');
        SET @k += 1;
        CONTINUE;
    END

    IF EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador D
               INNER JOIN Torneo.Alineacion_partido A ON A.id_alineacion_partido = D.id_alineacion_partido
               WHERE A.id_partido = @p)
    BEGIN
        PRINT CONCAT('  ', @titulo, ': ya tiene planilla, se saltea.');
        SET @k += 1;
        CONTINUE;
    END

    SELECT @pais_l = id_pais FROM Participantes.Seleccion WHERE id_seleccion = @sl;
    SELECT @pais_v = id_pais FROM Participantes.Seleccion WHERE id_seleccion = @sv;
    TRUNCATE TABLE #jug;

    ------------------------------------------
    -- a. Planillas
    SET @t = 1;
    WHILE @t <= 2
    BEGIN
        SET @sel = CASE WHEN @t = 1 THEN @sl ELSE @sv END;
        SELECT @esquema = esquema FROM #selecciones WHERE id_seleccion = @sel;
        SET @id_esquema = (SELECT id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = @esquema);
        SET @q_def = CAST(LEFT(@esquema, CHARINDEX('-', @esquema) - 1) AS INT);
        SET @q_del = CAST(RIGHT(@esquema, CHARINDEX('-', REVERSE(@esquema)) - 1) AS INT);
        SET @q_med = 10 - @q_def - @q_del;

        SET @id_al = NULL;
        BEGIN TRY
            SET @id_al = (SELECT id_alineacion_partido FROM Torneo.Alineacion_partido WHERE id_partido = @p AND id_seleccion = @sel);
            IF (@id_al IS NULL)
            BEGIN
                EXEC Torneo.Alta_Alineacion_partido @id_partido = @p, @id_seleccion = @sel, @id_esquema_tactico = @id_esquema;
                SET @id_al = (SELECT id_alineacion_partido FROM Torneo.Alineacion_partido WHERE id_partido = @p AND id_seleccion = @sel);
            END
        END TRY
        BEGIN CATCH
            PRINT CONCAT('  ', @titulo, ' - alineación: ', ERROR_MESSAGE());
        END CATCH;

        TRUNCATE TABLE #disp;
        INSERT INTO #disp (id_convocatoria, id_posicion, grupo, dorsal, suspendido, titular)
        SELECT C.id_convocatoria, J.id_posicion_habitual,
               CASE WHEN PO.nombre_posicion LIKE 'Arquer%' OR PO.nombre_posicion LIKE 'Porter%' THEN 'ARQ'
                    WHEN PO.nombre_posicion LIKE 'Defens%' THEN 'DEF'
                    WHEN PO.nombre_posicion LIKE 'Delanter%' THEN 'DEL'
                    ELSE 'MED' END,
               C.dorsal,
               CASE WHEN EXISTS (SELECT 1 FROM Torneo.Suspension_jugador S
                                 WHERE S.id_convocatoria = C.id_convocatoria AND S.id_partido_sancion = @p) THEN 1 ELSE 0 END,
               0
        FROM Participantes.Convocatoria C
        INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
        INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
        WHERE C.id_seleccion = @sel AND C.estado_convocatoria <> 'Desafectado'
        ORDER BY C.dorsal;

        -- Titulares por puesto según el esquema (los de menor dorsal) y, si falta alguno, se completa con otros
        ;WITH ranking AS (
            SELECT titular, grupo, ROW_NUMBER() OVER (PARTITION BY grupo ORDER BY dorsal) AS rn
            FROM #disp WHERE suspendido = 0
        )
        UPDATE ranking SET titular = 1
        WHERE (grupo = 'ARQ' AND rn <= 1) OR (grupo = 'DEF' AND rn <= @q_def)
           OR (grupo = 'MED' AND rn <= @q_med) OR (grupo = 'DEL' AND rn <= @q_del);

        SET @faltan = 11 - (SELECT COUNT(*) FROM #disp WHERE titular = 1);
        IF (@faltan > 0)
        BEGIN
            ;WITH resto AS (
                SELECT TOP (@faltan) titular
                FROM #disp
                WHERE suspendido = 0 AND titular = 0 AND grupo <> 'ARQ'
                ORDER BY CASE grupo WHEN 'MED' THEN 1 WHEN 'DEF' THEN 2 ELSE 3 END, dorsal
            )
            UPDATE resto SET titular = 1;
        END

        -- Suspendidos: el SP de planilla los rechaza (caso obligatorio de suspensión)
        SELECT @r = MIN(nro), @rmax = MAX(nro) FROM #disp;
        WHILE @r <= @rmax
        BEGIN
            IF EXISTS (SELECT 1 FROM #disp WHERE nro = @r AND suspendido = 1)
            BEGIN
                SELECT @conv = id_convocatoria, @pos = id_posicion FROM #disp WHERE nro = @r;
                BEGIN TRY
                    EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @id_al, @id_convocatoria = @conv,
                         @id_posicion_partido = @pos, @es_titular = 1;
                    PRINT CONCAT('  ', @titulo, ': ATENCIÓN, se aceptó a un jugador suspendido (convocatoria ', @conv, ').');
                END TRY
                BEGIN CATCH
                    PRINT CONCAT('  ', @titulo, ': planilla rechazada para la convocatoria ', @conv, ' (esperado) ', ERROR_MESSAGE());
                END CATCH;
            END
            SET @r += 1;
        END

        -- Titulares primero y después suplentes
        SET @pasada = 1;
        WHILE @pasada <= 2
        BEGIN
            SELECT @r = MIN(nro), @rmax = MAX(nro) FROM #disp;
            WHILE @r <= @rmax
            BEGIN
                SELECT @conv = NULL;
                SELECT @conv = id_convocatoria, @pos = id_posicion, @tit = titular
                FROM #disp
                WHERE nro = @r AND suspendido = 0 AND titular = CASE WHEN @pasada = 1 THEN 1 ELSE 0 END;

                IF (@conv IS NOT NULL)
                BEGIN
                    BEGIN TRY
                        EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @id_al, @id_convocatoria = @conv,
                             @id_posicion_partido = @pos, @es_titular = @tit;
                    END TRY
                    BEGIN CATCH
                        PRINT CONCAT('  ', @titulo, ' - planilla: ', ERROR_MESSAGE());
                    END CATCH;
                END
                SET @r += 1;
            END
            SET @pasada += 1;
        END

        INSERT INTO #jug (equipo, id_convocatoria, grupo, dorsal, titular)
        SELECT @t, id_convocatoria, grupo, dorsal, titular FROM #disp WHERE suspendido = 0;

        SET @t += 1;
    END

    ------------------------------------------
    -- b. Goles (autores: delanteros y mediocampistas titulares, en rotación)
    SET @t = 1;
    WHILE @t <= 2
    BEGIN
        SET @g = CASE WHEN @t = 1 THEN @gl ELSE @gv END;
        SET @n_atk = (SELECT COUNT(*) FROM #jug WHERE equipo = @t AND titular = 1 AND grupo IN ('DEL', 'MED'));
        SET @j = 1;

        WHILE @j <= @g AND @n_atk > 0
        BEGIN
            SET @tipo_gol = CASE WHEN @j % 4 = 0 THEN 'Penal'
                                 WHEN @j % 3 = 0 THEN 'Cabeza'
                                 WHEN (@j + @k) % 7 = 0 THEN 'Tiro libre'
                                 ELSE 'Jugada' END;
            SET @minuto = 3 + ((@j * 29 + @k * 11 + @t * 17) % 87);

            SELECT @autor = id_convocatoria
            FROM (SELECT id_convocatoria, ROW_NUMBER() OVER (ORDER BY CASE grupo WHEN 'DEL' THEN 0 ELSE 1 END, dorsal) AS rn
                  FROM #jug WHERE equipo = @t AND titular = 1 AND grupo IN ('DEL', 'MED')) X
            WHERE X.rn = ((@j - 1 + @k) % @n_atk) + 1;

            SET @asist = NULL;
            IF (@tipo_gol NOT IN ('Penal', 'Tiro libre') AND @n_atk > 1)
                SELECT @asist = id_convocatoria
                FROM (SELECT id_convocatoria, ROW_NUMBER() OVER (ORDER BY CASE grupo WHEN 'DEL' THEN 0 ELSE 1 END, dorsal) AS rn
                      FROM #jug WHERE equipo = @t AND titular = 1 AND grupo IN ('DEL', 'MED')) X
                WHERE X.rn = ((@j + @k) % @n_atk) + 1;

            SET @id_tipo_gol = (SELECT id_tipo FROM Torneo.Tipo_gol WHERE descripcion_tipo = @tipo_gol);
            SET @id_periodo = CASE WHEN @minuto <= 45 THEN @p1 ELSE @p2 END;

            BEGIN TRY
                EXEC Torneo.Registrar_Gol_Partido @id_convocatoria_autor = @autor, @id_convocatoria_asistencia = @asist,
                     @id_tipo_gol = @id_tipo_gol, @id_periodo_partido = @id_periodo, @id_partido = @p, @minuto = @minuto;
                UPDATE #jug SET goleador = 1 WHERE id_convocatoria = @autor;
            END TRY
            BEGIN CATCH
                PRINT CONCAT('  ', @titulo, ' - gol: ', ERROR_MESSAGE());
            END CATCH;

            SET @j += 1;
        END
        SET @t += 1;
    END

    ------------------------------------------
    -- c. Tarjetas: casos obligatorios de este partido
    SELECT @r = MIN(nro), @rmax = MAX(nro) FROM #casos WHERE partido_nro = @k AND tarjeta IS NOT NULL;
    WHILE @r <= @rmax
    BEGIN
        SELECT @conv = NULL;
        SELECT @conv = id_convocatoria, @tarjeta = tarjeta, @minuto = minuto, @motivo = motivo
        FROM #casos WHERE nro = @r AND partido_nro = @k AND tarjeta IS NOT NULL;

        IF (@conv IS NOT NULL)
        BEGIN
            SET @id_tipo_tarjeta = CASE WHEN @tarjeta = 'Roja' THEN @roja ELSE @amarilla END;
            SET @id_motivo = (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = @motivo);
            SET @id_periodo = CASE WHEN @minuto <= 45 THEN @p1 ELSE @p2 END;
            BEGIN TRY
                EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @conv, @id_tipo_tarjeta = @id_tipo_tarjeta,
                     @id_motivo_tarjeta = @id_motivo, @id_periodo_partido = @id_periodo, @minuto = @minuto;
                UPDATE #jug SET amonestado = 1,
                                expulsado = CASE WHEN @tarjeta = 'Roja' OR amonestado = 1 THEN 1 ELSE expulsado END
                WHERE id_convocatoria = @conv;
            END TRY
            BEGIN CATCH
                PRINT CONCAT('  ', @titulo, ' - tarjeta (caso): ', ERROR_MESSAGE());
            END CATCH;
        END
        SET @r += 1;
    END

    -- Amarillas comunes: 1 o 2 por equipo, a defensores o mediocampistas titulares que no hicieron goles
    -- (los jugadores de los casos obligatorios no reciben otras tarjetas)
    SET @t = 1;
    WHILE @t <= 2
    BEGIN
        SET @n_cand = (SELECT COUNT(*) FROM #jug
                       WHERE equipo = @t AND titular = 1 AND grupo IN ('DEF', 'MED') AND goleador = 0 AND amonestado = 0
                         AND id_convocatoria NOT IN (SELECT id_convocatoria FROM #casos WHERE id_convocatoria IS NOT NULL));
        SET @n_amarillas = 1 + CASE WHEN (@k + @t) % 3 = 0 THEN 1 ELSE 0 END;
        IF (@n_amarillas > @n_cand) SET @n_amarillas = @n_cand;
        SET @j = 0;

        WHILE @j < @n_amarillas
        BEGIN
            SELECT @conv = id_convocatoria
            FROM (SELECT id_convocatoria, ROW_NUMBER() OVER (ORDER BY dorsal) AS rn
                  FROM #jug
                  WHERE equipo = @t AND titular = 1 AND grupo IN ('DEF', 'MED') AND goleador = 0 AND amonestado = 0
                    AND id_convocatoria NOT IN (SELECT id_convocatoria FROM #casos WHERE id_convocatoria IS NOT NULL)) X
            WHERE X.rn = ((@k * 3 + @t * 5) % @n_cand) + 1;

            SET @minuto = 18 + ((@k * 13 + @t * 7 + @j * 31) % 70);
            SET @motivo = CASE (@k + @j) % 4 WHEN 0 THEN 'Juego brusco' WHEN 1 THEN 'Protesta'
                                             WHEN 2 THEN 'Mano intencional' ELSE 'Demora en el juego' END;
            SET @id_motivo = (SELECT id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = @motivo);
            SET @id_periodo = CASE WHEN @minuto <= 45 THEN @p1 ELSE @p2 END;

            BEGIN TRY
                EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = @p, @id_convocatoria = @conv, @id_tipo_tarjeta = @amarilla,
                     @id_motivo_tarjeta = @id_motivo, @id_periodo_partido = @id_periodo, @minuto = @minuto;
            END TRY
            BEGIN CATCH
                PRINT CONCAT('  ', @titulo, ' - tarjeta: ', ERROR_MESSAGE());
            END CATCH;

            -- El amonestado sale de la lista de candidatos (así la siguiente amarilla es para otro jugador)
            UPDATE #jug SET amonestado = 1 WHERE id_convocatoria = @conv;
            SET @n_cand -= 1;
            SET @j += 1;
        END
        SET @t += 1;
    END

    ------------------------------------------
    -- d. Sustituciones: 3 por equipo. Salen titulares de campo sin goles ni tarjetas; entran suplentes de campo.
    SET @t = 1;
    WHILE @t <= 2
    BEGIN
        SET @sel = CASE WHEN @t = 1 THEN @sl ELSE @sv END;
        SET @id_al = (SELECT id_alineacion_partido FROM Torneo.Alineacion_partido WHERE id_partido = @p AND id_seleccion = @sel);
        TRUNCATE TABLE #sale;
        TRUNCATE TABLE #entra;

        -- Caso obligatorio: cambio por lesión a los 15 minutos
        SET @hay_lesion = 0;
        IF EXISTS (SELECT 1 FROM #casos CA INNER JOIN #jug J ON J.id_convocatoria = CA.id_convocatoria
                   WHERE CA.partido_nro = @k AND CA.tarjeta IS NULL AND J.equipo = @t AND J.titular = 1)
        BEGIN
            SET @hay_lesion = 1;
            INSERT INTO #sale (id_convocatoria, motivo)
            SELECT TOP 1 CA.id_convocatoria, 'Lesión'
            FROM #casos CA INNER JOIN #jug J ON J.id_convocatoria = CA.id_convocatoria
            WHERE CA.partido_nro = @k AND CA.tarjeta IS NULL AND J.equipo = @t;

            INSERT INTO #entra (id_convocatoria)
            SELECT TOP 1 id_convocatoria FROM #jug WHERE equipo = @t AND titular = 0 AND grupo = 'DEF' ORDER BY dorsal;
        END

        INSERT INTO #sale (id_convocatoria, motivo)
        SELECT TOP (3 - @hay_lesion) id_convocatoria, 'Táctico'
        FROM #jug
        WHERE equipo = @t AND titular = 1 AND grupo <> 'ARQ' AND goleador = 0 AND amonestado = 0 AND expulsado = 0
          AND id_convocatoria NOT IN (SELECT id_convocatoria FROM #sale)
        ORDER BY CASE grupo WHEN 'DEL' THEN 0 WHEN 'MED' THEN 1 ELSE 2 END, dorsal DESC;

        INSERT INTO #entra (id_convocatoria)
        SELECT TOP (3) id_convocatoria
        FROM #jug
        WHERE equipo = @t AND titular = 0 AND grupo <> 'ARQ'
          AND id_convocatoria NOT IN (SELECT id_convocatoria FROM #entra)
        ORDER BY CASE grupo WHEN 'MED' THEN 0 WHEN 'DEL' THEN 1 ELSE 2 END, dorsal;

        SET @smax = (SELECT MIN(cantidad) FROM (VALUES ((SELECT COUNT(*) FROM #sale)), ((SELECT COUNT(*) FROM #entra)), (3)) AS V (cantidad));
        SET @s = 1;
        WHILE @s <= @smax
        BEGIN
            SELECT @sale = id_convocatoria, @motivo_sust = motivo FROM #sale WHERE nro = @s;
            SELECT @entra = id_convocatoria FROM #entra WHERE nro = @s;
            SET @minuto = CASE WHEN @hay_lesion = 1 THEN CASE @s WHEN 1 THEN 15 WHEN 2 THEN 63 ELSE 77 END
                               ELSE CASE @s WHEN 1 THEN 58 + (@k % 5) WHEN 2 THEN 69 ELSE 81 END END;
            BEGIN TRY
                EXEC Torneo.Registrar_Sustitucion_Partido @id_alineacion_partido = @id_al, @id_convocatoria_sale = @sale,
                     @id_convocatoria_entra = @entra, @motivo_sustitucion = @motivo_sust, @minuto = @minuto,
                     @numero_ventanas = @s, @es_tiempo_suplementario = 0;
            END TRY
            BEGIN CATCH
                PRINT CONCAT('  ', @titulo, ' - sustitución: ', ERROR_MESSAGE());
            END CATCH;
            SET @s += 1;
        END
        SET @t += 1;
    END

    ------------------------------------------
    -- e. Designación arbitral completa (5 árbitros de países distintos a los de las selecciones)
    -- Caso obligatorio: el árbitro argentino no puede dirigir a Argentina (se intenta y se rechaza)
    IF (@id_arbitro_arg IS NOT NULL AND @k = 3)
    BEGIN
        SET @id_rol = (SELECT id_rol_arbitro FROM @roles WHERE orden = 1);
        BEGIN TRY
            EXEC Torneo.Asignar_Arbitro_Partido @id_partido = @p, @id_rol_arbitro = @id_rol, @id_arbitro = @id_arbitro_arg;
            PRINT CONCAT('  ', @titulo, ': ATENCIÓN, se aceptó un árbitro de la misma nacionalidad.');
        END TRY
        BEGIN CATCH
            PRINT CONCAT('  ', @titulo, ': designación del árbitro argentino rechazada (esperado) ', ERROR_MESSAGE());
        END CATCH;
    END

    DELETE FROM @designados;
    INSERT INTO @designados (id_arbitro)
    SELECT TOP (5) A.id_arbitro
    FROM #arbitros A
    WHERE A.id_arbitro IS NOT NULL AND A.id_pais NOT IN (@pais_l, @pais_v)
      AND NOT EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral D WHERE D.id_partido = @p AND D.id_arbitro = A.id_arbitro)
    ORDER BY (A.nro + @k * 2) % 15, A.nro;

    SET @id_principal = NULL;
    SET @r = 1;
    WHILE @r <= 5
    BEGIN
        SET @id_arbitro = (SELECT id_arbitro FROM @designados WHERE orden = (SELECT MIN(orden) FROM @designados) + @r - 1);
        SET @id_rol = (SELECT id_rol_arbitro FROM @roles WHERE orden = @r);
        IF (@id_arbitro IS NOT NULL AND @id_rol IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @p AND id_rol_arbitro = @id_rol))
        BEGIN
            BEGIN TRY
                EXEC Torneo.Asignar_Arbitro_Partido @id_partido = @p, @id_rol_arbitro = @id_rol, @id_arbitro = @id_arbitro;
                IF (@r = 1) SET @id_principal = @id_arbitro;
            END TRY
            BEGIN CATCH
                PRINT CONCAT('  ', @titulo, ' - designación: ', ERROR_MESSAGE());
            END CATCH;
        END
        SET @r += 1;
    END

    -- Informe post partido del árbitro principal
    IF (@id_principal IS NOT NULL)
    BEGIN
        BEGIN TRY
            SET @calificacion = 6 + (@k % 4);
            SET @observaciones = CASE @k % 3 WHEN 0 THEN 'Buen control del partido; correcto uso del VAR.'
                                                              WHEN 1 THEN 'Partido intenso, criterio disciplinario uniforme.'
                                                              ELSE 'Correcta lectura del juego; ubicación mejorable en jugadas a balón parado.' END;
            EXEC Torneo.Alta_Informe_post_partido @id_partido = @p, @id_arbitro = @id_principal, @calificacion_desempenio = @calificacion,
                 @observaciones = @observaciones, @sancion_aplicada = NULL;
        END TRY
        BEGIN CATCH
            PRINT CONCAT('  ', @titulo, ' - informe: ', ERROR_MESSAGE());
        END CATCH;
    END

    ------------------------------------------
    -- f. Publicidad: las 4 piezas del partido
    IF NOT EXISTS (SELECT 1 FROM Publicidad.Exhibicion_publicidad_partido WHERE id_partido = @p)
    BEGIN
        BEGIN TRY
            INSERT INTO #pub (numero_espacio, posicion, nombre_anunciante, nombre_campania, nombre_pieza, mercado_priorizado,
                              es_mercado_partido, es_prime_time, hora_local_mercado, pbi_per_capita, tarifa_aplicada_usd)
            EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @p;
            UPDATE #pub SET id_partido = @p WHERE id_partido IS NULL;
        END TRY
        BEGIN CATCH
            PRINT CONCAT('  ', @titulo, ' - publicidad: ', ERROR_MESSAGE());
        END CATCH;
    END

    ------------------------------------------
    -- g. Suspensiones de 1 fecha que se cumplieron en este partido
    SET @id_susp = (SELECT MIN(id_suspension) FROM Torneo.Suspension_jugador
                    WHERE id_partido_sancion = @p AND sancion_cumplida = 0 AND cantidad_fechas = 1);
    WHILE @id_susp IS NOT NULL
    BEGIN
        BEGIN TRY
            EXEC Torneo.Modificacion_Suspension_jugador @id_suspension = @id_susp, @sancion_cumplida = 1;
        END TRY
        BEGIN CATCH
            PRINT CONCAT('  ', @titulo, ' - suspensión cumplida: ', ERROR_MESSAGE());
        END CATCH;
        SET @id_susp = (SELECT MIN(id_suspension) FROM Torneo.Suspension_jugador
                        WHERE id_partido_sancion = @p AND sancion_cumplida = 0 AND cantidad_fechas = 1 AND id_suspension > @id_susp);
    END

    PRINT CONCAT('  ', @titulo, ': cargado.');
    SET @k += 1;
END
GO

------------------------------------------
-- 11. IMPORTACIÓN CON ERRORES PARCIALES (caso obligatorio)
-- Requiere el archivo en C:\Importar\ (ver script 12). Las filas válidas se importan y las erróneas se informan.
------------------------------------------
PRINT '11. Importación con errores parciales';

BEGIN TRY
    EXEC Torneo.Importar_CSV_Stadiums @nombre_archivo = 'C:\Importar\stadiums_prueba_errores.csv';
END TRY
BEGIN CATCH
    PRINT CONCAT('  No se pudo importar el archivo de prueba: ', ERROR_MESSAGE());
END CATCH;
GO

------------------------------------------
-- 12. VERIFICACIÓN DE LOS CRITERIOS DE ACEPTACIÓN
------------------------------------------
PRINT '12. Verificación';

-- Criterios generales (columna "cumple" = 1 si se alcanza el mínimo)
SELECT 'Sedes de los partidos cargados' AS criterio,
       COUNT(DISTINCT PA.id_sede) AS cantidad, 8 AS minimo,
       CASE WHEN COUNT(DISTINCT PA.id_sede) >= 8 AND COUNT(DISTINCT SE.huso_horario) >= 3 THEN 1 ELSE 0 END AS cumple,
       CONCAT(COUNT(DISTINCT SE.huso_horario), ' husos horarios distintos') AS detalle
FROM #partidos P
INNER JOIN Torneo.Partido PA ON PA.id_partido = P.id_partido
INNER JOIN Torneo.Sede SE ON SE.id_sede = PA.id_sede
UNION ALL
SELECT 'Selecciones con al menos 23 convocados', COUNT(*), 16, CASE WHEN COUNT(*) >= 16 THEN 1 ELSE 0 END,
       CONCAT('mínimo por selección: ', MIN(convocados))
FROM (SELECT S.id_seleccion, COUNT(*) AS convocados
      FROM #selecciones S
      INNER JOIN Participantes.Convocatoria C ON C.id_seleccion = S.id_seleccion AND C.estado_convocatoria <> 'Desafectado'
      GROUP BY S.id_seleccion
      HAVING COUNT(*) >= 23) X
UNION ALL
SELECT 'Partidos con titulares y suplentes de ambos equipos', COUNT(*), 24, CASE WHEN COUNT(*) >= 24 THEN 1 ELSE 0 END,
       CONCAT(SUM(CASE WHEN F.nombre_fase = 'Fase de Grupos' THEN 1 ELSE 0 END), ' de grupos y ',
              SUM(CASE WHEN F.nombre_fase <> 'Fase de Grupos' THEN 1 ELSE 0 END), ' de eliminación directa')
FROM #partidos P
INNER JOIN Torneo.Partido PA ON PA.id_partido = P.id_partido
INNER JOIN Torneo.Fase F ON F.id_fase = PA.id_fase
WHERE (SELECT COUNT(DISTINCT A.id_seleccion)
       FROM Torneo.Alineacion_partido A
       WHERE A.id_partido = P.id_partido
         AND (SELECT COUNT(*) FROM Torneo.Detalle_alineacion_jugador D WHERE D.id_alineacion_partido = A.id_alineacion_partido AND D.es_titular = 1) = 11
         AND EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador D WHERE D.id_alineacion_partido = A.id_alineacion_partido AND D.es_titular = 0)) = 2
UNION ALL
SELECT 'Árbitros con designaciones', COUNT(DISTINCT D.id_arbitro), 15, CASE WHEN COUNT(DISTINCT D.id_arbitro) >= 15 THEN 1 ELSE 0 END,
       CONCAT((SELECT COUNT(*) FROM #partidos P
               WHERE (SELECT COUNT(DISTINCT id_rol_arbitro) FROM Torneo.Designacion_arbitral WHERE id_partido = P.id_partido) = 5),
              ' partidos con los 5 roles cubiertos')
FROM Torneo.Designacion_arbitral D
INNER JOIN #partidos P ON P.id_partido = D.id_partido
UNION ALL
SELECT 'Países de los anunciantes con campañas', COUNT(DISTINCT A.id_pais_origen), 6,
       CASE WHEN COUNT(DISTINCT A.id_pais_origen) >= 6 THEN 1 ELSE 0 END,
       CONCAT(COUNT(DISTINCT C.id_campania), ' campañas (', SUM(CASE WHEN YEAR(C.fecha_inicio) < 2026 THEN 1 ELSE 0 END), ' históricas)')
FROM Publicidad.Anunciante A
INNER JOIN Publicidad.Campania_publicitaria C ON C.id_anunciante = A.id_anunciante;

-- Caso 1: expulsiones por doble amarilla y por roja directa
SELECT 'Caso 1 - Expulsiones' AS caso, PL.nombre_seleccion + ' vs ' + PV.nombre_seleccion AS partido,
       J.nombre + ' ' + J.apellido AS jugador, S.tipo_suspension, S.cantidad_fechas,
       PS.fecha_hora_local AS partido_de_sancion
FROM Torneo.Suspension_jugador S
INNER JOIN Torneo.Partido P ON P.id_partido = S.id_partido_origen
INNER JOIN Participantes.Seleccion PL ON PL.id_seleccion = P.id_seleccion_local
INNER JOIN Participantes.Seleccion PV ON PV.id_seleccion = P.id_seleccion_visitante
INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = S.id_convocatoria
INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
LEFT JOIN Torneo.Partido PS ON PS.id_partido = S.id_partido_sancion
WHERE S.id_convocatoria IN (SELECT id_convocatoria FROM #casos WHERE caso IN ('Doble amarilla', 'Roja directa'))
  AND S.tipo_suspension IN ('Doble amarilla', 'Roja directa');

-- Caso 2: suspendido por acumulación que queda afuera de la planilla del partido siguiente
SELECT 'Caso 2 - Acumulación' AS caso, J.nombre + ' ' + J.apellido AS jugador, S.tipo_suspension,
       PL.nombre_seleccion + ' vs ' + PV.nombre_seleccion AS partido_de_sancion,
       CASE WHEN EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador D
                         INNER JOIN Torneo.Alineacion_partido A ON A.id_alineacion_partido = D.id_alineacion_partido
                         WHERE A.id_partido = S.id_partido_sancion AND D.id_convocatoria = S.id_convocatoria)
            THEN 'En la planilla (error)' ELSE 'Fuera de la planilla' END AS situacion
FROM Torneo.Suspension_jugador S
INNER JOIN Participantes.Convocatoria C ON C.id_convocatoria = S.id_convocatoria
INNER JOIN Participantes.Jugador J ON J.id_jugador = C.id_jugador
INNER JOIN Torneo.Partido P ON P.id_partido = S.id_partido_sancion
INNER JOIN Participantes.Seleccion PL ON PL.id_seleccion = P.id_seleccion_local
INNER JOIN Participantes.Seleccion PV ON PV.id_seleccion = P.id_seleccion_visitante
WHERE S.id_convocatoria IN (SELECT id_convocatoria FROM #casos WHERE caso = 'Acumulación de amarillas')
  AND S.tipo_suspension = 'Acumulación de amarillas';

-- Caso 3: cambio por lesión dentro de los primeros 20 minutos
SELECT 'Caso 3 - Lesión' AS caso, SL.nombre_seleccion, JS.nombre + ' ' + JS.apellido AS sale,
       JE.nombre + ' ' + JE.apellido AS entra, SU.minuto, SU.motivo_sustitucion
FROM Torneo.Sustitucion SU
INNER JOIN Torneo.Alineacion_partido A ON A.id_alineacion_partido = SU.id_alineacion_partido
INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = A.id_seleccion
INNER JOIN Participantes.Convocatoria CS ON CS.id_convocatoria = SU.id_convocatoria_sale
INNER JOIN Participantes.Jugador JS ON JS.id_jugador = CS.id_jugador
INNER JOIN Participantes.Convocatoria CE ON CE.id_convocatoria = SU.id_convocatoria_entra
INNER JOIN Participantes.Jugador JE ON JE.id_jugador = CE.id_jugador
WHERE SU.motivo_sustitucion = 'Lesión' AND SU.minuto <= 20;

-- Caso 4: partido en prime time en más de cuatro mercados candidatos y las 4 piezas que eligió el sistema
DECLARE @id_eng_cro INT = (SELECT id_partido FROM #partidos WHERE local_fifa = 'ENG' AND visitante_fifa = 'CRO');

SELECT 'Caso 4 - Prime time' AS caso, COUNT(DISTINCT PT.id_pais) AS mercados_candidatos_en_prime_time,
       STRING_AGG(PT.mercado, ', ') AS mercados
FROM Publicidad.fn_Mercados_Prime_Time(@id_eng_cro, '19:00', '23:00') PT
WHERE PT.es_prime_time = 1
  AND PT.id_pais IN (SELECT M.id_pais FROM Publicidad.Mercado_interes_campania M
                     INNER JOIN Publicidad.Campania_publicitaria C ON C.id_campania = M.id_campania
                     WHERE '20260617' BETWEEN C.fecha_inicio AND C.fecha_fin);

SELECT 'Caso 4 - Piezas asignadas' AS caso, E.numero_espacio, A.nombre_anunciante, PZ.nombre_pieza, E.tarifa_aplicada_usd
FROM Publicidad.Exhibicion_publicidad_partido E
INNER JOIN Publicidad.Pieza_publicitaria PZ ON PZ.id_pieza = E.id_pieza
INNER JOIN Publicidad.Campania_publicitaria C ON C.id_campania = PZ.id_campania
INNER JOIN Publicidad.Anunciante A ON A.id_anunciante = C.id_anunciante
WHERE E.id_partido = @id_eng_cro
ORDER BY E.numero_espacio;

-- Caso 5: designación descartada por conflicto de nacionalidad (ver los mensajes del punto 10): el árbitro
-- argentino no tiene designaciones en partidos de Argentina
SELECT 'Caso 5 - Nacionalidad' AS caso, AR.nombre + ' ' + AR.apellido AS arbitro, PA.nombre AS pais,
       (SELECT COUNT(*) FROM Torneo.Designacion_arbitral D
        INNER JOIN Torneo.Partido P ON P.id_partido = D.id_partido
        INNER JOIN Participantes.Seleccion S ON S.id_seleccion IN (P.id_seleccion_local, P.id_seleccion_visitante)
        WHERE D.id_arbitro = AR.id_arbitro AND S.id_pais = AR.id_pais) AS designaciones_en_partidos_de_su_pais,
       (SELECT COUNT(*) FROM Torneo.Designacion_arbitral D WHERE D.id_arbitro = AR.id_arbitro) AS designaciones_totales
FROM #arbitros A
INNER JOIN Participantes.Arbitro AR ON AR.id_arbitro = A.id_arbitro
INNER JOIN Participantes.Pais PA ON PA.id_pais = AR.id_pais
WHERE A.pais_iso = 'ARG';

-- Caso 6: importación con errores parciales (último registro del log del archivo de prueba)
SELECT TOP 1 'Caso 6 - Importación parcial' AS caso, nombre_archivo_o_fuente, registros_procesados, registros_con_error, estado
FROM Torneo.Log_importacion
WHERE nombre_archivo_o_fuente LIKE '%stadiums_prueba_errores%'
ORDER BY id_log DESC;
GO
