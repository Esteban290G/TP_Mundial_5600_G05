-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Scripts de testing para SP de Altas --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Moneda

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'ARS',
	@nombre_moneda = 'Peso Argentino';
GO

SELECT * FROM Participantes.Moneda;
GO

-- Test 02: Código con mas caracteres.
EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'ARS10',
	@nombre_moneda = 'Peso Argentino Especial Messi';
GO

-- Test 03: Código con menos caracteres. 
EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'AR',
	@nombre_moneda = 'Argentina';
GO

-- Test 04: Nombre vacío.
EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'CLP',
	@nombre_moneda = '';
GO

-- Test 05: Errores acumulados (Nombre vacío y menos caracteres)
EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'C',
	@nombre_moneda = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Confederacion

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Confederacion
	@nombre_confederacion = 'CONMEBOL';
GO

SELECT * FROM Participantes.Confederacion;
GO

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Confederacion
	@nombre_confederacion = '       ';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Posicion

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Posicion
	@nombre_posicion = 'Arquero';
GO

SELECT * FROM Participantes.Posicion;
GO

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Posicion
	@nombre_posicion = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Categoria_arbitro

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Categoria_arbitro
	@descripcion = 'Internacional';
GO

SELECT * FROM Participantes.Categoria_arbitro;
GO

-- Test 02: Descripción vacía.
EXEC Participantes.Alta_Categoria_arbitro
	@descripcion = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Rol_arbitro

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Rol_arbitro
	@descripcion = 'Árbitro Principal';
GO

SELECT * FROM Participantes.Rol_arbitro;
GO

-- Test 02: Descripción vacía.
EXEC Participantes.Alta_Rol_arbitro
	@descripcion = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Idioma

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Idioma
	@nombre = 'Español';
GO

SELECT * FROM Participantes.Idioma;
GO

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Idioma
	@nombre = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Grupo_Torneo

-- Test 01: Caso de éxito (mayus y minus). 
EXEC Torneo.Alta_Grupo_Torneo
	@nombre_grupo = 'a';
GO

EXEC Torneo.Alta_Grupo_Torneo
	@nombre_grupo = 'B';
GO

SELECT * FROM Torneo.Grupo_torneo;
GO

-- Test 02: Nombre vacío.
EXEC Torneo.Alta_Grupo_Torneo
	@nombre_grupo = ' ';
GO

-- Test 03: Formato inválido.
EXEC Torneo.Alta_Grupo_Torneo
	@nombre_grupo = '5';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Fase

-- Test 01: Caso de éxito. 
EXEC Torneo.Alta_Fase
	@nombre_fase = 'Fase de Grupos';
GO

SELECT * FROM Torneo.Fase;
GO

-- Test 02: Nombre vacío.
EXEC Torneo.Alta_Fase
	@nombre_fase = '         ';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Log_importacion

-- Test 01: Caso de éxito. 
EXEC Torneo.Alta_Log_importacion
    @nombre_archivo_o_fuente = 'jugadores_conmebol.csv',
    @fecha_hora_ejecucion = '20231020 14:30:00',
    @registros_procesados = 150,
    @registros_con_error = 2,
    @estado = 'Finalizado con advertencias';
GO

SELECT * FROM Torneo.Log_importacion;
GO

-- Test 02:Textos vacíos
EXEC Torneo.Alta_Log_importacion
    @nombre_archivo_o_fuente = '',
    @fecha_hora_ejecucion = '20231020 14:30:00',
    @registros_procesados = 150,
    @registros_con_error = 2,
    @estado = '   ';
GO

-- Test 03: Números negativos y fecha futura
EXEC Torneo.Alta_Log_importacion
    @nombre_archivo_o_fuente = 'arbitros_uefa.json',
    @fecha_hora_ejecucion = '20500101 10:00:00', 
    @registros_procesados = -5,
    @registros_con_error = -1,
    @estado = 'Fallido';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Esquema_tactico

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Esquema_tactico
	@descripcion_esquema = '4-4-2';
GO

SELECT * FROM Torneo.Esquema_tactico;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Alta_Esquema_tactico
	@descripcion_esquema = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Periodo_partido

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Periodo_partido
	@descripcion_periodo = 'Primer Tiempo';
GO

SELECT * FROM Torneo.Periodo_partido;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Alta_Periodo_partido
	@descripcion_periodo = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Tipo_tarjeta

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Tipo_tarjeta
	@descripcion_tarjeta = 'Amarilla';
GO

SELECT * FROM Torneo.Tipo_tarjeta;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Alta_Tipo_tarjeta
	@descripcion_tarjeta = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Motivo_tarjeta

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Motivo_tarjeta
	@descripcion_motivo = 'Mano intencional';
GO

SELECT * FROM Torneo.Motivo_tarjeta;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Alta_Motivo_tarjeta
	@descripcion_motivo = '';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Franja_horaria_tarifa

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Franja_horaria_tarifa
    @descripcion_franja = 'Prime Time Nocturno',
    @hora_inicio_local = '20:00:00',
    @hora_fin_local = '23:59:59',
    @tarifa_base_usd = 150000.00;
GO

SELECT * FROM Publicidad.Franja_horaria_tarifa;
GO

-- Test 02: Descripción vacía y tarifa negativa.
EXEC Publicidad.Alta_Franja_horaria_tarifa
    @descripcion_franja = '',
    @hora_inicio_local = '08:00:00',
    @hora_fin_local = '12:00:00',
    @tarifa_base_usd = -500.00;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Cotizacion_moneda

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Cotizacion_moneda
    @codigo_moneda = 'ARS',
    @fecha_cotizacion = '20231020',
    @valor_en_usd = 0.0010; 
GO

SELECT * FROM Participantes.Cotizacion_moneda;
GO

-- Test 02: Valor negativo y fecha futura.
EXEC Participantes.Alta_Cotizacion_moneda
    @codigo_moneda = 'ARS',
    @fecha_cotizacion = '20501231', 
    @valor_en_usd = -0.50;
GO

-- Test 03: Codigo vacío.
EXEC Participantes.Alta_Cotizacion_moneda
    @codigo_moneda = '',
    @fecha_cotizacion = '20231021',
    @valor_en_usd = 1.0000;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Pais

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Pais
    @codigo_moneda = 'ARS',
    @nombre = 'Argentina',
    @codigo_iso = 'ARG',
    @pbi_per_capita = 13000.50;
GO

SELECT * FROM Participantes.Pais;
GO

-- Test 02: Nombre vacío, ISO corto y PBI negativo.
EXEC Participantes.Alta_Pais
    @codigo_moneda = 'ARS',
    @nombre = '   ',
    @codigo_iso = 'AR',
    @pbi_per_capita = -100.00;
GO

-- Test 03: Moneda inexistente.
EXEC Participantes.Alta_Pais
    @codigo_moneda = 'ZZZ',
    @nombre = 'País Inventado',
    @codigo_iso = 'ZZZ',
    @pbi_per_capita = 5000.00;
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Parametros_suspension

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Parametros_suspension
    @id_fase_limpieza_amarillas = 1,
    @fechas_suspension_roja_directa = 1,
    @fechas_suspension_doble_amarilla = 1,
    @activo = 1;
GO

SELECT * FROM Torneo.Parametros_suspension;
GO

-- Test 02: Cero fechas de suspension roja directa y fecha negativa con doble amarilla.
EXEC Torneo.Alta_Parametros_suspension
    @id_fase_limpieza_amarillas = 4,
    @fechas_suspension_roja_directa = 0,
    @fechas_suspension_doble_amarilla = 0,
    @activo = 1;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Feriado_pais

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Feriado_pais
    @id_pais = 1,
    @fecha = '20260525',
    @descripcion_feriado = 'Revolución de Mayo';
GO

SELECT * FROM Participantes.Feriado_pais;
GO

-- Test 02: Caso de éxito descripción vacía.
EXEC Participantes.Alta_Feriado_pais
    @id_pais = 1,
    @fecha = '20260709',
    @descripcion_feriado = '     ';
GO

SELECT * FROM Participantes.Feriado_pais;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Ciudad

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Ciudad
    @id_pais = 1,
    @nombre = 'Buenos Aires';
GO

SELECT * FROM Participantes.Ciudad;
GO

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Ciudad
    @id_pais = 1,
    @nombre = '     ';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Club_origen

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Club_origen
    @nombre = 'River Plate',
    @id_pais_club = 1;
GO

SELECT * FROM Participantes.Club_origen

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Club_origen
    @nombre = '     ',
    @id_pais_club = 1;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Arbitro

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Arbitro
    @id_pais = 1,
    @id_categoria = 1,
    @nombre = 'Néstor',
    @apellido = 'Pitana',
    @fecha_nacimiento = '19750617';
GO

SELECT * FROM Participantes.Arbitro;
GO

-- Test 02: Nombre y apellido vacío y menor de edad.
EXEC Participantes.Alta_Arbitro
    @id_pais = 1,
    @id_categoria = 1,
    @nombre = '   ',
    @apellido = '   ',
    @fecha_nacimiento = '20150101';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Seleccion

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Seleccion
    @nombre_seleccion = 'Selección Argentina',
    @id_pais = 1,
    @id_confederacion = 1,
    @id_grupo = 1;
GO

SELECT * FROM Participantes.Seleccion;
GO

-- Test 02: Nombre vacío.
EXEC Participantes.Alta_Seleccion
    @nombre_seleccion = '',
    @id_pais = 1,
    @id_confederacion = 1,
    @id_grupo = 1;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Idioma_arbitro

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Idioma_arbitro
    @id_arbitro = 1,
    @id_idioma = 1;
GO

SELECT * FROM Participantes.Idioma_arbitro;
GO

-- Test 02: error de FK.
EXEC Participantes.Alta_Idioma_arbitro
    @id_arbitro = 1,
    @id_idioma = 999;
GO

-- Test 03: PK duplicada.
EXEC Participantes.Alta_Idioma_arbitro
    @id_arbitro = 1,
    @id_idioma = 1;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Anunciante

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Anunciante
    @nombre_anunciante = 'Coca-Cola',
    @id_pais_origen = 1,
    @identificacion_fiscal = '30-12345678-9';
GO

SELECT * FROM Publicidad.Anunciante;
GO

-- Test 02: Nombre e id fiscal vacíos.
EXEC Publicidad.Alta_Anunciante
    @nombre_anunciante = ' ',
    @id_pais_origen = 1,
    @identificacion_fiscal = '';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Sede

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Sede
    @id_ciudad = 1,
    @nombre_estadio = 'Monumental',
    @capacidad = 84567,
    @latitud = -34.545270,
    @longitud = -58.449735,
    @huso_horario = 'UTC-3';
GO

SELECT * FROM Torneo.Sede;
GO

-- Test 02: Nombre vacío, huso vacío, capacidad negativa, y coordenadas fuera de rango.
EXEC Torneo.Alta_Sede
    @id_ciudad = 1,
    @nombre_estadio = '',
    @capacidad = -10,
    @latitud = 150.000000,
    @longitud = -200.000000,
    @huso_horario = '';
GO


------------------------------------------
-- PRUEBAS: Participantes.Alta_Jugador

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Jugador
    @nombre = 'Lionel',
    @apellido = 'Messi',
    @fecha_nacimiento = '19870624',
    @id_pais_nacimiento = 1,
    @id_posicion_habitual = 1,
    @id_club_origen = 1;
GO

SELECT * FROM Participantes.Jugador;
GO

-- Test 02: Nombre y apellido vacíos, menor de 15 años.
EXEC Participantes.Alta_Jugador
    @nombre = '',
    @apellido = '   ',
    @fecha_nacimiento = '20150101',
    @id_pais_nacimiento = 1,
    @id_posicion_habitual = 1,
    @id_club_origen = 1;
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Integrante_cuerpo_tecnico

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Integrante_cuerpo_tecnico
    @id_seleccion = 1,
    @nombre = 'Lionel',
    @apellido = 'Scaloni',
    @cargo_rol = 'Director Técnico';
GO

SELECT * FROM Participantes.Integrante_cuerpo_tecnico;
GO

-- Test 02: Nombre, apellido y cargo vacíos.
EXEC Participantes.Alta_Integrante_cuerpo_tecnico
    @id_seleccion = 1,
    @nombre = '',
    @apellido = '',
    @cargo_rol = '';
GO

------------------------------------------
-- PRUEBAS: Participantes.Alta_Convocatoria

-- Test 01: Caso de éxito.
EXEC Participantes.Alta_Convocatoria
    @id_seleccion = 1,
    @id_jugador = 1,
    @estado_convocatoria = 'Confirmado',
    @fecha_alta_convocatoria = '20260515',
    @dorsal = 10;
GO

SELECT * FROM Participantes.Convocatoria;
GO

-- Test 02: estado vacío, fecha futura y dorsal 99.
EXEC Participantes.Alta_Convocatoria
    @id_seleccion = 1,
    @id_jugador = 1,
    @estado_convocatoria = ' ',
    @fecha_alta_convocatoria = '20300101',
    @dorsal = 99;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Campania_publicitaria

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Campania_publicitaria
    @id_anunciante = 1,
    @nombre_campania = 'Campaña Mundial 2026',
    @fecha_inicio = '20260501',
    @fecha_fin = '20260731',
    @presupuesto = 1500000.00;
GO

SELECT * FROM Publicidad.Campania_publicitaria;
GO

-- Test 02: Nombre vacío.
EXEC Publicidad.Alta_Campania_publicitaria
    @id_anunciante = 1,
    @nombre_campania = '   ',
    @fecha_inicio = '20260501',
    @fecha_fin = '20260731',
    @presupuesto = 1500000.00;
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Partido

-- registros necesarios:
EXEC Participantes.Alta_Moneda @codigo_moneda = 'BRL', @nombre_moneda = 'Real Brasileño';
EXEC Participantes.Alta_Pais @codigo_moneda = 'BRL', @nombre = 'Brasil', @codigo_iso = 'BRA', @pbi_per_capita = 8900.50;
EXEC Participantes.Alta_Seleccion @nombre_seleccion = 'Selección de Brasil', @id_pais = 2, @id_confederacion = 1, @id_grupo = 1;

EXEC Participantes.Alta_Moneda @codigo_moneda = 'UYU', @nombre_moneda = 'Peso Uruguayo';
EXEC Participantes.Alta_Pais @codigo_moneda = 'UYU', @nombre = 'Uruguay', @codigo_iso = 'URY', @pbi_per_capita = 17000.00;
EXEC Participantes.Alta_Seleccion @nombre_seleccion = 'Selección de Uruguay', @id_pais = 3, @id_confederacion = 1, @id_grupo = 1;
GO

-- Test 01: Caso de éxito. Partido 1 (Arg vs Bra).
EXEC Torneo.Alta_Partido
    @id_sede = 1,
    @id_fase = 1,
    @id_seleccion_local = 1, 
    @id_seleccion_visitante = 2,
    @id_importacion_origen = 1,
    @fecha_hora_local = '20260615 17:00:00',
    @asistencia_publico = 80000,
    @goles_local = 2,
    @goles_visitante = 1,
    @UTC = '20260615 20:00:00';
GO

SELECT * FROM Torneo.Partido;
GO

-- Test 02: Caso de éxito con datos nulos. Partido 2 (Arg vs Uru).
EXEC Torneo.Alta_Partido
    @id_sede = 1,
    @id_fase = 1,
    @id_seleccion_local = 1, 
    @id_seleccion_visitante = 3,
    @id_importacion_origen = 1,
    @fecha_hora_local = '20260618 17:00:00',
    @asistencia_publico = NULL, 
    @goles_local = NULL,
    @goles_visitante = NULL,
    @UTC = '20260618 20:00:00';
GO

SELECT * FROM Torneo.Partido;
GO

-- Test 03: Asistencia excede capacidad. (Usa Bra vs Uru).
EXEC Torneo.Alta_Partido
    @id_sede = 1,
    @id_fase = 1,
    @id_seleccion_local = 2, 
    @id_seleccion_visitante = 3,
    @id_importacion_origen = 1,
    @fecha_hora_local = '20260622 17:00:00',
    @asistencia_publico = 90000,
    @goles_local = 0,
    @goles_visitante = 0,
    @UTC = '20260622 20:00:00';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Mercado_interes_campania

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Mercado_interes_campania
    @id_campania = 1,
    @id_pais = 1;
GO

SELECT * FROM Publicidad.Mercado_interes_campania;
GO

-- Test 02: Error de FK.
EXEC Publicidad.Alta_Mercado_interes_campania
    @id_campania = 999,
    @id_pais = 1;
GO

-- Test 03: PK duplicado.
EXEC Publicidad.Alta_Mercado_interes_campania
    @id_campania = 1,
    @id_pais = 1;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Pieza_publicitaria

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Pieza_publicitaria
    @id_campania = 1,
    @id_idioma = 1,
    @nombre_pieza = 'Spot TV Mundial 30s',
    @duracion_segundos = 30,
    @url_contenido_media = 'https://videofifa.com/campanias/spot_30s.mp4';
GO

SELECT * FROM Publicidad.Pieza_publicitaria;
GO

-- Test 02: Nombre vacío, URL vacía, duracion 0.
EXEC Publicidad.Alta_Pieza_publicitaria
    @id_campania = 1,
    @id_idioma = 1,
    @nombre_pieza = '   ',
    @duracion_segundos = 0,
    @url_contenido_media = '   ';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Alineacion_partido

-- Test 01: Caso de éxito (Argentina en el partido 1).
EXEC Torneo.Alta_Alineacion_partido
    @id_partido = 1,
    @id_seleccion = 1,
    @id_esquema_tactico = 1;
GO

SELECT * FROM Torneo.Alineacion_partido;
GO

-- Test 02: Seleccion que no participa (Uruguay en partido Arg vs Bra).
EXEC Torneo.Alta_Alineacion_partido
    @id_partido = 1,
    @id_seleccion = 3,
    @id_esquema_tactico = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Gol

-- registros necesarios:
EXEC Participantes.Alta_Jugador @nombre = 'Julián', @apellido = 'Álvarez', @fecha_nacimiento = '20000131', @id_pais_nacimiento = 1, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 1, @id_jugador = 2, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 9;

EXEC Participantes.Alta_Jugador @nombre = 'Neymar', @apellido = 'Jr', @fecha_nacimiento = '19920205', @id_pais_nacimiento = 2, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 2, @id_jugador = 3, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 10;

EXEC Participantes.Alta_Jugador @nombre = 'Federico', @apellido = 'Valverde', @fecha_nacimiento = '19980722', @id_pais_nacimiento = 3, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Convocatoria @id_seleccion = 3, @id_jugador = 4, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '20260515', @dorsal = 15;
GO

-- Test 01: Caso de éxito sin asistencia (Messi ID 1).
EXEC Torneo.Alta_Gol
    @id_convocatoria_autor = 1,
    @id_convocatoria_asistencia = NULL,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = 1,
    @minuto = 15;
GO

SELECT * FROM Torneo.Gol;
GO

-- Test 02: Caso de éxito con asistencia (Julián asiste a Messi).
EXEC Torneo.Alta_Gol
    @id_convocatoria_autor = 1,
    @id_convocatoria_asistencia = 2,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = 1,
    @minuto = 30;
GO

SELECT * FROM Torneo.Gol;
GO

-- Test 03: Asistencia del equipo rival (Julián asiste a Neymar).
EXEC Torneo.Alta_Gol
    @id_convocatoria_autor = 3,
    @id_convocatoria_asistencia = 2,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = 1,
    @minuto = 45;
GO

-- Test 04: Gol de un jugador de otra seleccion (Valverde en Arg vs Bra).
EXEC Torneo.Alta_Gol
    @id_convocatoria_autor = 4,
    @id_convocatoria_asistencia = NULL,
    @id_tipo_gol = 1,
    @id_periodo_partido = 1,
    @id_partido = 1,
    @minuto = 60;
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Suspension_jugador

-- Test 01: Caso de éxito con suspensión pendiente (Messi 1 en Partido 1).
EXEC Torneo.Alta_Suspension_jugador
    @id_convocatoria = 1,
    @id_partido_origen = 1,
    @id_partido_sancion = NULL,
    @cantidad_fechas = 1,
    @sancion_cumplida = 0;
GO

SELECT * FROM Torneo.Suspension_jugador;
GO

-- Test 02: Cantidad de fechas 0.
EXEC Torneo.Alta_Suspension_jugador
    @id_convocatoria = 2,
    @id_partido_origen = 1,
    @id_partido_sancion = NULL,
    @cantidad_fechas = 0,
    @sancion_cumplida = 0;
GO

-- Test 03: Jugador de otra seleccion (Valverde 4 en Partido 1).
EXEC Torneo.Alta_Suspension_jugador
    @id_convocatoria = 4,
    @id_partido_origen = 1,
    @id_partido_sancion = NULL,
    @cantidad_fechas = 1,
    @sancion_cumplida = 0;
GO

-- Test 04: Fechas cruzadas (Cumplida en Partido 1 pero originada en Partido 2 futuro).
EXEC Torneo.Alta_Suspension_jugador
    @id_convocatoria = 1,
    @id_partido_origen = 2,
    @id_partido_sancion = 1,
    @cantidad_fechas = 1,
    @sancion_cumplida = 1;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Alta_Exhibicion_publicidad_partido

-- Test 01: Caso de éxito.
EXEC Publicidad.Alta_Exhibicion_publicidad_partido
    @id_partido = 1,
    @numero_espacio = 1,
    @id_pieza = 1,
    @tarifa_aplicada_usd = 160000.00,
    @id_franja = 1,
    @fecha_hora_exhibicion = '20260615 21:30:00';
GO

SELECT * FROM Publicidad.Exhibicion_publicidad_partido;
GO

-- Test 02:Fuera de horario
EXEC Publicidad.Alta_Exhibicion_publicidad_partido
    @id_partido = 1,
    @numero_espacio = 2,
    @id_pieza = 1,
    @tarifa_aplicada_usd = 160000.00,
    @id_franja = 1,
    @fecha_hora_exhibicion = '20260615 14:00:00';
GO

-- Test 03: tarifa menor que la base
EXEC Publicidad.Alta_Exhibicion_publicidad_partido
    @id_partido = 1,
    @numero_espacio = 3,
    @id_pieza = 1,
    @tarifa_aplicada_usd = 100000.00,
    @id_franja = 1,
    @fecha_hora_exhibicion = '20260615 22:00:00';
GO

-- Test 04: numero espacio fuera de rango y tarifa negativa
EXEC Publicidad.Alta_Exhibicion_publicidad_partido
    @id_partido = 1,
    @numero_espacio = 5,
    @id_pieza = 1,
    @tarifa_aplicada_usd = -100.00,
    @id_franja = 1,
    @fecha_hora_exhibicion = '20260615 21:00:00';
GO

------------------------------------------
-- PRUEBAS: Torneo.Alta_Informe_post_partido

-- registros necesarios:
EXEC Participantes.Alta_Arbitro @id_pais = 3, @id_categoria = 1, @nombre = 'Esteban', @apellido = 'Ostojich', @fecha_nacimiento = '19820412';
INSERT INTO Torneo.Designacion_arbitral (id_partido, id_rol_arbitro, id_arbitro) VALUES (1, 1, 2);
GO

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Informe_post_partido
    @id_partido = 1,
    @id_arbitro = 2,
    @calificacion_desempenio = 8,
    @observaciones = 'Excelente manejo del partido, tarjetas correctas.',
    @sancion_aplicada = NULL;
GO

SELECT * FROM Torneo.Informe_post_partido;
GO
-- Test 02: Error FK.
EXEC Torneo.Alta_Informe_post_partido
    @id_partido = 1,
    @id_arbitro = 1,
    @calificacion_desempenio = 5,
    @observaciones = '   ',
    @sancion_aplicada = '   ';
GO

-- Test 03: Calificación fuera de rango.
EXEC Torneo.Alta_Informe_post_partido
    @id_partido = 1,
    @id_arbitro = 2,
    @calificacion_desempenio = 11,
    @observaciones = NULL,
    @sancion_aplicada = NULL;
GO