-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Descripción: Carga de datos de prueba para poder generar reportes.
-- Se utiliza IF NOT EXISTS para evitar cargar duplicados y no generar errores.
-- Datos simulados:
-- - Jugadores y Convocatorias: Alta de Lionel Messi, Emiliano Martínez y Rodrigo De Paul.
-- - Alineaciones: Formación titular de Argentina en el partido contra Brasil.
-- - Gol de Messi con asistencia de De Paul.
-- - Tarjeta roja directa para De Paul y su suspensión activa.
-- - Arbitros: Designación de Néstor Pitana como árbitro principal del encuentro.
-- - Publicidad: Creación de anunciante Coca Cola, campaña, franja horaria y su exhibición en el partido.
------------------------------------------
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------

-- Variables para buscar IDs.
DECLARE @idArg INT = (SELECT TOP 1 id_pais FROM Participantes.Pais WHERE nombre LIKE '%Argentina%');
DECLARE @idBra INT = (SELECT TOP 1 id_pais FROM Participantes.Pais WHERE nombre LIKE '%Brasil%');
DECLARE @selArg INT = (SELECT TOP 1 id_seleccion FROM Participantes.Seleccion WHERE id_pais = @idArg);
DECLARE @selBra INT = (SELECT TOP 1 id_seleccion FROM Participantes.Seleccion WHERE id_pais = @idBra);

-- Partido de estos dos equipos
DECLARE @idPartido INT = (SELECT TOP 1 id_partido 
                          FROM Torneo.Partido 
                          WHERE id_seleccion_local = @selArg AND id_seleccion_visitante = @selBra);

-- Si el partido no existe, se crea
IF @idPartido IS NULL
BEGIN
    DECLARE @idSede INT = (SELECT TOP 1 id_sede FROM Torneo.Sede);
    DECLARE @idFase INT = (SELECT TOP 1 id_fase FROM Torneo.Fase WHERE nombre_fase LIKE '%Grupo%');
    DECLARE @idLog INT = (SELECT TOP 1 id_log FROM Torneo.Log_importacion);
    
    EXEC Torneo.Alta_Partido 
        @id_sede = @idSede, 
        @id_fase = @idFase, 
        @id_seleccion_local = @selArg, 
        @id_seleccion_visitante = @selBra, 
        @id_importacion_origen = @idLog, 
        @fecha_hora_local = '20260615 17:00:00', 
        @asistencia_publico = 10000, 
        @goles_local = NULL, 
        @goles_visitante = NULL, 
        @UTC = '20260615 20:00:00';
    
    SET @idPartido = (SELECT TOP 1 id_partido FROM Torneo.Partido WHERE id_seleccion_local = @selArg AND id_seleccion_visitante = @selBra);
END

-- jugadores, cuerpo tecnico y convocatoria:

-- Posiciones
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero')
    EXEC Participantes.Alta_Posicion @nombre_posicion = 'Arquero';
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Delantero')
    EXEC Participantes.Alta_Posicion @nombre_posicion = 'Delantero';
IF NOT EXISTS (SELECT 1 FROM Participantes.Posicion WHERE nombre_posicion = 'Mediocampista')
    EXEC Participantes.Alta_Posicion @nombre_posicion = 'Mediocampista';

DECLARE @idPosArquero INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Arquero');
DECLARE @idPosDelantero INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Delantero');
DECLARE @idPosMedio INT = (SELECT id_posicion FROM Participantes.Posicion WHERE nombre_posicion = 'Mediocampista');

-- Club
IF NOT EXISTS (SELECT 1 FROM Participantes.Club_origen WHERE nombre = 'Boca Juniors')
    EXEC Participantes.Alta_Club_origen @nombre = 'Boca Juniors', @id_pais_club = @idArg;
DECLARE @idClub INT = (SELECT TOP 1 id_club FROM Participantes.Club_origen);

-- Jugadores
IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE apellido = 'Messi')
    EXEC Participantes.Alta_Jugador @nombre = 'Lionel', @apellido = 'Messi', @fecha_nacimiento = '1987-06-24', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPosDelantero, @id_club_origen = @idClub;
IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE apellido = 'Martinez')
    EXEC Participantes.Alta_Jugador @nombre = 'Emiliano', @apellido = 'Martinez', @fecha_nacimiento = '1992-09-02', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPosArquero, @id_club_origen = @idClub;
IF NOT EXISTS (SELECT 1 FROM Participantes.Jugador WHERE apellido = 'De Paul')
    EXEC Participantes.Alta_Jugador @nombre = 'Rodrigo', @apellido = 'De Paul', @fecha_nacimiento = '1994-05-24', @id_pais_nacimiento = @idArg, @id_posicion_habitual = @idPosMedio, @id_club_origen = @idClub;

DECLARE @jugMessi INT = (SELECT TOP 1 id_jugador FROM Participantes.Jugador WHERE apellido = 'Messi');
DECLARE @jugDibu INT = (SELECT TOP 1 id_jugador FROM Participantes.Jugador WHERE apellido = 'Martinez');
DECLARE @jugDePaul INT = (SELECT TOP 1 id_jugador FROM Participantes.Jugador WHERE apellido = 'De Paul');

-- Convocatorias
IF NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_jugador = @jugMessi)
    EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jugMessi, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-01', @dorsal = 10;
IF NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_jugador = @jugDibu)
    EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jugDibu, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-01', @dorsal = 23;
IF NOT EXISTS (SELECT 1 FROM Participantes.Convocatoria WHERE id_jugador = @jugDePaul)
    EXEC Participantes.Alta_Convocatoria @id_seleccion = @selArg, @id_jugador = @jugDePaul, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-01', @dorsal = 7;

DECLARE @convMessi INT = (SELECT TOP 1 id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jugMessi);
DECLARE @convDibu INT = (SELECT TOP 1 id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jugDibu);
DECLARE @convDePaul INT = (SELECT TOP 1 id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jugDePaul);

-- Alineaciones:
-- Esquema tactico
IF NOT EXISTS (SELECT 1 FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-3-3')
    EXEC Torneo.Alta_Esquema_tactico @descripcion_esquema = '4-3-3';
DECLARE @idEsq INT = (SELECT TOP 1 id_esquema_tactico FROM Torneo.Esquema_tactico WHERE descripcion_esquema = '4-3-3');

IF NOT EXISTS (SELECT 1 FROM Torneo.Alineacion_partido WHERE id_partido = @idPartido AND id_seleccion = @selArg)
    EXEC Torneo.Alta_Alineacion_partido @id_partido = @idPartido, @id_seleccion = @selArg, @id_esquema_tactico = @idEsq;

DECLARE @aliArg INT = (SELECT TOP 1 id_alineacion_partido FROM Torneo.Alineacion_partido WHERE id_partido = @idPartido AND id_seleccion = @selArg);

-- Detalle alineacion jugador
IF NOT EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador WHERE id_alineacion_partido = @aliArg AND id_convocatoria = @convMessi)
    INSERT INTO Torneo.Detalle_alineacion_jugador (id_alineacion_partido, id_convocatoria, id_posicion_partido, es_titular) VALUES (@aliArg, @convMessi, @idPosDelantero, 1);
IF NOT EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador WHERE id_alineacion_partido = @aliArg AND id_convocatoria = @convDibu)
    INSERT INTO Torneo.Detalle_alineacion_jugador (id_alineacion_partido, id_convocatoria, id_posicion_partido, es_titular) VALUES (@aliArg, @convDibu, @idPosArquero, 1);
IF NOT EXISTS (SELECT 1 FROM Torneo.Detalle_alineacion_jugador WHERE id_alineacion_partido = @aliArg AND id_convocatoria = @convDePaul)
    INSERT INTO Torneo.Detalle_alineacion_jugador (id_alineacion_partido, id_convocatoria, id_posicion_partido, es_titular) VALUES (@aliArg, @convDePaul, @idPosMedio, 1);

-- Goles y tarjetas:
-- Tarjetas y motivo
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja')
    EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Roja';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla')
    EXEC Torneo.Alta_Tipo_tarjeta @descripcion_tarjeta = 'Amarilla';
IF NOT EXISTS (SELECT 1 FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego Brusco')
    EXEC Torneo.Alta_Motivo_tarjeta @descripcion_motivo = 'Juego Brusco';

DECLARE @tipoRoja INT = (SELECT TOP 1 id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Roja');
DECLARE @tipoAmarilla INT = (SELECT TOP 1 id_tipo_tarjeta FROM Torneo.Tipo_tarjeta WHERE descripcion_tarjeta = 'Amarilla');
DECLARE @motivoFalta INT = (SELECT TOP 1 id_motivo FROM Torneo.Motivo_tarjeta WHERE descripcion_motivo = 'Juego Brusco');

-- Periodo de partido y gol
IF NOT EXISTS (SELECT 1 FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Primer Tiempo')
    EXEC Torneo.Alta_Periodo_partido @descripcion_periodo = 'Primer Tiempo';
IF NOT EXISTS (SELECT 1 FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Jugada')
    EXEC Torneo.Alta_Tipo_gol @descripcion_tipo = 'Jugada';

DECLARE @periodo1T INT = (SELECT TOP 1 id_periodo_partido FROM Torneo.Periodo_partido WHERE descripcion_periodo = 'Primer Tiempo');
DECLARE @tipoGol INT = (SELECT TOP 1 id_tipo FROM Torneo.Tipo_gol WHERE descripcion_tipo = 'Jugada');

-- Gol Messi asistencia De Paul
IF NOT EXISTS (SELECT 1 FROM Torneo.Gol WHERE id_partido = @idPartido)
    INSERT INTO Torneo.Gol (id_convocatoria_autor, id_convocatoria_asistencia, id_tipo_gol, id_periodo_partido, id_partido, minuto) 
    VALUES (@convMessi, @convDePaul, @tipoGol, @periodo1T, @idPartido, 22);

-- Roja directa
IF NOT EXISTS (SELECT 1 FROM Torneo.Tarjeta WHERE id_partido = @idPartido)
    INSERT INTO Torneo.Tarjeta (id_partido, id_convocatoria, id_tipo_tarjeta, id_motivo_tarjeta, id_periodo_partido, minuto) 
    VALUES (@idPartido, @convDePaul, @tipoRoja, @motivoFalta, @periodo1T, 38);

-- Suspensión de la roja directa
IF NOT EXISTS (SELECT 1 FROM Torneo.Suspension_jugador WHERE id_convocatoria = @convDePaul)
    INSERT INTO Torneo.Suspension_jugador (id_convocatoria, id_partido_origen, id_partido_sancion, cantidad_fechas, sancion_cumplida, tipo_suspension)
    VALUES (@convDePaul, @idPartido, NULL, 1, 0, 'Roja directa');

-- Designacion arbitral:
IF NOT EXISTS (SELECT 1 FROM Participantes.Categoria_arbitro WHERE descripcion = 'Internacional')
    EXEC Participantes.Alta_Categoria_arbitro @descripcion = 'Internacional';
DECLARE @catArbitro INT = (SELECT TOP 1 id_categoria FROM Participantes.Categoria_arbitro);

IF NOT EXISTS (SELECT 1 FROM Participantes.Arbitro WHERE apellido = 'Pitana')
    EXEC Participantes.Alta_Arbitro @id_pais = @idArg, @id_categoria = @catArbitro, @nombre = 'Nestor', @apellido = 'Pitana', @fecha_nacimiento = '1975-06-17';
DECLARE @arbPitana INT = (SELECT TOP 1 id_arbitro FROM Participantes.Arbitro WHERE apellido = 'Pitana');

IF NOT EXISTS (SELECT 1 FROM Participantes.Rol_arbitro WHERE descripcion = 'Principal')
    EXEC Participantes.Alta_Rol_arbitro @descripcion = 'Principal';
DECLARE @rolPpal INT = (SELECT TOP 1 id_rol_arbitro FROM Participantes.Rol_arbitro WHERE descripcion = 'Principal');

IF NOT EXISTS (SELECT 1 FROM Torneo.Designacion_arbitral WHERE id_partido = @idPartido AND id_arbitro = @arbPitana)
    INSERT INTO Torneo.Designacion_arbitral (id_partido, id_rol_arbitro, id_arbitro) VALUES (@idPartido, @rolPpal, @arbPitana);

-- Publicidad
IF NOT EXISTS (SELECT 1 FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Coca Cola')
    EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Coca Cola', @id_pais_origen = @idArg, @identificacion_fiscal = 'CUIT-1111';
DECLARE @idAnunciante INT = (SELECT TOP 1 id_anunciante FROM Publicidad.Anunciante WHERE nombre_anunciante = 'Coca Cola');

IF NOT EXISTS (SELECT 1 FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Mundial 2026')
    EXEC Publicidad.Alta_Campania_publicitaria @id_anunciante = @idAnunciante, @nombre_campania = 'Mundial 2026', @fecha_inicio = '2026-06-01', @fecha_fin = '2026-07-30', @presupuesto = 1000000;
DECLARE @idCampania INT = (SELECT TOP 1 id_campania FROM Publicidad.Campania_publicitaria WHERE nombre_campania = 'Mundial 2026');

IF NOT EXISTS (SELECT 1 FROM Participantes.Idioma WHERE nombre = 'Español')
    EXEC Participantes.Alta_Idioma @nombre = 'Español';
DECLARE @idIdioma INT = (SELECT TOP 1 id_idioma FROM Participantes.Idioma);

IF NOT EXISTS (SELECT 1 FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Spot TV')
    EXEC Publicidad.Alta_Pieza_publicitaria @id_campania = @idCampania, @id_idioma = @idIdioma, @nombre_pieza = 'Spot TV', @duracion_segundos = 30, @url_contenido_media = 'http://video';
DECLARE @idPieza INT = (SELECT TOP 1 id_pieza FROM Publicidad.Pieza_publicitaria WHERE nombre_pieza = 'Spot TV');

IF NOT EXISTS (SELECT 1 FROM Publicidad.Franja_horaria_tarifa WHERE descripcion_franja = 'Noche')
    EXEC Publicidad.Alta_Franja_horaria_tarifa @descripcion_franja = 'Noche', @hora_inicio_local = '19:00:00', @hora_fin_local = '23:59:59', @tarifa_base_usd = 15000;
DECLARE @idFranja INT = (SELECT TOP 1 id_franja FROM Publicidad.Franja_horaria_tarifa);

-- Exhibición en el partido.
IF NOT EXISTS (SELECT 1 FROM Publicidad.Exhibicion_publicidad_partido WHERE id_partido = @idPartido)
    INSERT INTO Publicidad.Exhibicion_publicidad_partido (id_partido, numero_espacio, id_pieza, tarifa_aplicada_usd, id_franja, fecha_hora_exhibicion)
    VALUES (@idPartido, 1, @idPieza, 25000, @idFranja, '20260615 17:15:00');

------------------------------------------
-- Comprobación de datos cargados

-- Jugadores y convocatorias
SELECT 
    J.nombre, 
    J.apellido, 
    C.dorsal, 
    S.nombre_seleccion,
    P.nombre_posicion AS posicion
FROM Participantes.Jugador J
INNER JOIN Participantes.Convocatoria C ON J.id_jugador = C.id_jugador
INNER JOIN Participantes.Seleccion S ON C.id_seleccion = S.id_seleccion
INNER JOIN Participantes.Posicion P ON J.id_posicion_habitual = P.id_posicion;

-- Goles
SELECT 
    P.id_partido, 
    G.minuto, 
    JA.apellido AS autor, 
    JAS.apellido AS asistencia,
    TG.descripcion_tipo AS tipo_gol
FROM Torneo.Gol G
INNER JOIN Torneo.Partido P ON G.id_partido = P.id_partido
INNER JOIN Participantes.Convocatoria CA ON G.id_convocatoria_autor = CA.id_convocatoria
INNER JOIN Participantes.Jugador JA ON CA.id_jugador = JA.id_jugador
LEFT JOIN Participantes.Convocatoria CAS ON G.id_convocatoria_asistencia = CAS.id_convocatoria
LEFT JOIN Participantes.Jugador JAS ON CAS.id_jugador = JAS.id_jugador
INNER JOIN Torneo.Tipo_gol TG ON G.id_tipo_gol = TG.id_tipo;

-- Tarjetas y suspensiones
SELECT 
    T.minuto, 
    J.apellido AS infractor,
    TT.descripcion_tarjeta AS tarjeta, 
    MT.descripcion_motivo AS motivo,
    SJ.cantidad_fechas AS fechas_suspension
FROM Torneo.Tarjeta T
INNER JOIN Torneo.Tipo_tarjeta TT ON T.id_tipo_tarjeta = TT.id_tipo_tarjeta
INNER JOIN Torneo.Motivo_tarjeta MT ON T.id_motivo_tarjeta = MT.id_motivo
INNER JOIN Participantes.Convocatoria C ON T.id_convocatoria = C.id_convocatoria
INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador
LEFT JOIN Torneo.Suspension_jugador SJ ON C.id_convocatoria = SJ.id_convocatoria;

-- Publicidad exhibida
SELECT 
    A.nombre_anunciante, 
    CP.nombre_campania, 
    E.numero_espacio, 
    E.tarifa_aplicada_usd,
    E.fecha_hora_exhibicion
FROM Publicidad.Exhibicion_publicidad_partido E
INNER JOIN Publicidad.Pieza_publicitaria PP ON E.id_pieza = PP.id_pieza
INNER JOIN Publicidad.Campania_publicitaria CP ON PP.id_campania = CP.id_campania
INNER JOIN Publicidad.Anunciante A ON CP.id_anunciante = A.id_anunciante;