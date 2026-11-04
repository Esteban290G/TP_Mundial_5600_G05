-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Scripts de testing para SP de Bajas --
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Moneda

EXEC Participantes.Alta_Moneda
	@codigo_moneda = 'ZZZ',
	@nombre_moneda = 'Moneda';
GO

-- Test 01: Caso de éxito.
EXEC Participantes.Baja_Moneda
	@codigo_moneda = 'ZZZ';
GO

SELECT * FROM Participantes.Moneda WHERE codigo_moneda = 'ZZZ';
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Moneda @codigo_moneda = 'XXX';
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Confederacion

EXEC Participantes.Alta_Confederacion
	@nombre_confederacion = 'Confederacion Borrable';
DECLARE @idConf INT = IDENT_CURRENT('Participantes.Confederacion');
GO

-- Test 01: Caso de éxito.
DECLARE @idConf INT = IDENT_CURRENT('Participantes.Confederacion');
EXEC Participantes.Baja_Confederacion
	@id_confederacion = @idConf;
GO

DECLARE @idConf INT = IDENT_CURRENT('Participantes.Confederacion');
SELECT * FROM Participantes.Confederacion WHERE id_confederacion = @idConf;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Confederacion
	@id_confederacion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Posicion

EXEC Participantes.Alta_Posicion
	@nombre_posicion = 'Aguatero';
DECLARE @idPos INT = IDENT_CURRENT('Participantes.Posicion');
GO

-- Test 01: Caso de éxito.
DECLARE @idPos INT = IDENT_CURRENT('Participantes.Posicion');
EXEC Participantes.Baja_Posicion
	@id_posicion = @idPos;
GO

DECLARE @idPos INT = IDENT_CURRENT('Participantes.Posicion');
SELECT * FROM Participantes.Posicion WHERE id_posicion = @idPos;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Posicion
	@id_posicion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Categoria_arbitro

EXEC Participantes.Alta_Categoria_arbitro
	@descripcion = 'Borrable';
DECLARE @idCat INT = IDENT_CURRENT('Participantes.Categoria_arbitro');
GO

-- Test 01: Caso de éxito.
DECLARE @idCat INT = IDENT_CURRENT('Participantes.Categoria_arbitro');
EXEC Participantes.Baja_Categoria_arbitro
	@id_categoria = @idCat;
GO

DECLARE @idCat INT = IDENT_CURRENT('Participantes.Categoria_arbitro');
SELECT * FROM Participantes.Categoria_arbitro WHERE id_categoria = @idCat;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Categoria_arbitro
	@id_categoria = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Rol_arbitro

EXEC Participantes.Alta_Rol_arbitro
	@descripcion = 'Rol Borrable';
DECLARE @idRol INT = IDENT_CURRENT('Participantes.Rol_arbitro');
GO

-- Test 01: Caso de éxito.
DECLARE @idRol INT = IDENT_CURRENT('Participantes.Rol_arbitro');
EXEC Participantes.Baja_Rol_arbitro
	@id_rol_arbitro = @idRol;
GO

DECLARE @idRol INT = IDENT_CURRENT('Participantes.Rol_arbitro');
SELECT * FROM Participantes.Rol_arbitro WHERE id_rol_arbitro = @idRol;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Rol_arbitro
	@id_rol_arbitro = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Idioma

EXEC Participantes.Alta_Idioma 
    @nombre = 'Idioma';
DECLARE @idIdioma INT = IDENT_CURRENT('Participantes.Idioma');
GO

-- Test 01: Caso de éxito.
DECLARE @idIdioma INT = IDENT_CURRENT('Participantes.Idioma');
EXEC Participantes.Baja_Idioma 
    @id_idioma = @idIdioma;
GO

DECLARE @idIdioma INT = IDENT_CURRENT('Participantes.Idioma');
SELECT * FROM Participantes.Idioma WHERE id_idioma = @idIdioma;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Idioma 
    @id_idioma = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Grupo_Torneo

EXEC Torneo.Alta_Grupo_Torneo 
    @nombre_grupo = 'Z';
DECLARE @idGrupo INT = IDENT_CURRENT('Torneo.Grupo_torneo');
GO

-- Test 01: Caso de éxito.
DECLARE @idGrupo INT = IDENT_CURRENT('Torneo.Grupo_torneo');
EXEC Torneo.Baja_Grupo_Torneo 
    @id_grupo = @idGrupo;
GO

DECLARE @idGrupo INT = IDENT_CURRENT('Torneo.Grupo_torneo');
SELECT * FROM Torneo.Grupo_torneo WHERE id_grupo = @idGrupo;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Grupo_Torneo 
    @id_grupo = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Fase

EXEC Torneo.Alta_Fase 
    @nombre_fase = 'Fase';
DECLARE @idFase INT = IDENT_CURRENT('Torneo.Fase');
GO

-- Test 01: Caso de éxito.
DECLARE @idFase INT = IDENT_CURRENT('Torneo.Fase');
EXEC Torneo.Baja_Fase 
    @id_fase = @idFase;
GO

DECLARE @idFase INT = IDENT_CURRENT('Torneo.Fase');
SELECT * FROM Torneo.Fase WHERE id_fase = @idFase;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Fase 
    @id_fase = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Log_importacion

EXEC Torneo.Alta_Log_importacion 
    @nombre_archivo_o_fuente = 'log.csv', 
    @fecha_hora_ejecucion = '20231020', 
    @registros_procesados = 1, 
    @registros_con_error = 0, 
    @estado = 'Fin';
DECLARE @idLog INT = IDENT_CURRENT('Torneo.Log_importacion');
GO

-- Test 01: Caso de éxito.
DECLARE @idLog INT = IDENT_CURRENT('Torneo.Log_importacion');
EXEC Torneo.Baja_Log_importacion 
    @id_log = @idLog;
GO

DECLARE @idLog INT = IDENT_CURRENT('Torneo.Log_importacion');
SELECT * FROM Torneo.Log_importacion WHERE id_log = @idLog;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Log_importacion 
    @id_log = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Esquema_tactico

EXEC Torneo.Alta_Esquema_tactico 
    @descripcion_esquema = '5-5-5';
DECLARE @idEsquema INT = IDENT_CURRENT('Torneo.Esquema_tactico');
GO

-- Test 01: Caso de éxito.
DECLARE @idEsquema INT = IDENT_CURRENT('Torneo.Esquema_tactico');
EXEC Torneo.Baja_Esquema_tactico 
    @id_esquema_tactico = @idEsquema;
GO

DECLARE @idEsquema INT = IDENT_CURRENT('Torneo.Esquema_tactico');
SELECT * FROM Torneo.Esquema_tactico WHERE id_esquema_tactico = @idEsquema;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Esquema_tactico 
    @id_esquema_tactico = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Tipo_gol

EXEC Torneo.Alta_Tipo_gol 
    @descripcion_tipo = 'Gol';
DECLARE @idTipoGol INT = IDENT_CURRENT('Torneo.Tipo_gol');
GO

-- Test 01: Caso de éxito.
DECLARE @idTipoGol INT = IDENT_CURRENT('Torneo.Tipo_gol');
EXEC Torneo.Baja_Tipo_gol 
    @id_tipo = @idTipoGol;
GO

DECLARE @idTipoGol INT = IDENT_CURRENT('Torneo.Tipo_gol');
SELECT * FROM Torneo.Tipo_gol WHERE id_tipo = @idTipoGol;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Tipo_gol 
    @id_tipo = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Periodo_partido

EXEC Torneo.Alta_Periodo_partido 
    @descripcion_periodo = 'Periodo';
DECLARE @idPeriodo INT = IDENT_CURRENT('Torneo.Periodo_partido');
GO

-- Test 01: Caso de éxito.
DECLARE @idPeriodo INT = IDENT_CURRENT('Torneo.Periodo_partido');
EXEC Torneo.Baja_Periodo_partido 
    @id_periodo_partido = @idPeriodo;
GO

DECLARE @idPeriodo INT = IDENT_CURRENT('Torneo.Periodo_partido');
SELECT * FROM Torneo.Periodo_partido WHERE id_periodo_partido = @idPeriodo;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Periodo_partido 
    @id_periodo_partido = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Tipo_tarjeta

EXEC Torneo.Alta_Tipo_tarjeta 
    @descripcion_tarjeta = 'Tipo';
DECLARE @idTipoTarjeta INT = IDENT_CURRENT('Torneo.Tipo_tarjeta');
GO

-- Test 01: Caso de éxito.
DECLARE @idTipoTarjeta INT = IDENT_CURRENT('Torneo.Tipo_tarjeta');
EXEC Torneo.Baja_Tipo_tarjeta 
    @id_tipo_tarjeta = @idTipoTarjeta;
GO

DECLARE @idTipoTarjeta INT = IDENT_CURRENT('Torneo.Tipo_tarjeta');
SELECT * FROM Torneo.Tipo_tarjeta WHERE id_tipo_tarjeta = @idTipoTarjeta;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Tipo_tarjeta 
    @id_tipo_tarjeta = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Motivo_tarjeta

EXEC Torneo.Alta_Motivo_tarjeta 
    @descripcion_motivo = 'Motivo';
DECLARE @idMotivo INT = IDENT_CURRENT('Torneo.Motivo_tarjeta');
GO

-- Test 01: Caso de éxito.
DECLARE @idMotivo INT = IDENT_CURRENT('Torneo.Motivo_tarjeta');
EXEC Torneo.Baja_Motivo_tarjeta 
    @id_motivo = @idMotivo;
GO

DECLARE @idMotivo INT = IDENT_CURRENT('Torneo.Motivo_tarjeta');
SELECT * FROM Torneo.Motivo_tarjeta WHERE id_motivo = @idMotivo;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Motivo_tarjeta 
    @id_motivo = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Franja_horaria_tarifa

EXEC Publicidad.Alta_Franja_horaria_tarifa 
    @descripcion_franja = 'Franja', 
    @hora_inicio_local = '00:00:00', 
    @hora_fin_local = '01:00:00', 
    @tarifa_base_usd = 10.0;
DECLARE @idFranja INT = IDENT_CURRENT('Publicidad.Franja_horaria_tarifa');
GO

-- Test 01: Caso de éxito.
DECLARE @idFranja INT = IDENT_CURRENT('Publicidad.Franja_horaria_tarifa');
EXEC Publicidad.Baja_Franja_horaria_tarifa 
    @id_franja = @idFranja;
GO

DECLARE @idFranja INT = IDENT_CURRENT('Publicidad.Franja_horaria_tarifa');
SELECT * FROM Publicidad.Franja_horaria_tarifa WHERE id_franja = @idFranja;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Franja_horaria_tarifa 
    @id_franja = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Cotizacion_moneda

EXEC Participantes.Alta_Cotizacion_moneda 
    @codigo_moneda = 'ARS', 
    @fecha_cotizacion = '2023-01-01', 
    @valor_en_usd = 0.005;
DECLARE @idCotizacion INT = IDENT_CURRENT('Participantes.Cotizacion_moneda');
GO

-- Test 01: Caso de éxito.
DECLARE @idCotizacion INT = IDENT_CURRENT('Participantes.Cotizacion_moneda');
EXEC Participantes.Baja_Cotizacion_moneda 
    @id_cotizacion = @idCotizacion;
GO

DECLARE @idCotizacion INT = IDENT_CURRENT('Participantes.Cotizacion_moneda');
SELECT * FROM Participantes.Cotizacion_moneda WHERE id_cotizacion = @idCotizacion;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Cotizacion_moneda 
    @id_cotizacion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Pais

EXEC Participantes.Alta_Pais 
    @codigo_moneda = 'ARS', 
    @nombre = 'Pais', 
    @codigo_iso = 'PAI', 
    @pbi_per_capita = 1000;
DECLARE @idPais INT = IDENT_CURRENT('Participantes.Pais');
GO

-- Test 01: Caso de éxito.
DECLARE @idPais INT = IDENT_CURRENT('Participantes.Pais');
EXEC Participantes.Baja_Pais 
    @id_pais = @idPais;
GO

DECLARE @idPais INT = IDENT_CURRENT('Participantes.Pais');
SELECT * FROM Participantes.Pais WHERE id_pais = @idPais;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Pais 
    @id_pais = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Parametros_suspension

EXEC Torneo.Alta_Parametros_suspension 
    @id_fase_limpieza_amarillas = 1, 
    @fechas_suspension_roja_directa = 1, 
    @fechas_suspension_doble_amarilla = 1, 
    @activo = 0;
DECLARE @idParam INT = IDENT_CURRENT('Torneo.Parametros_suspension');
GO

-- Test 01: Caso de éxito.
DECLARE @idParam INT = IDENT_CURRENT('Torneo.Parametros_suspension');
EXEC Torneo.Baja_Parametros_suspension 
    @id_parametro = @idParam;
GO

DECLARE @idParam INT = IDENT_CURRENT('Torneo.Parametros_suspension');
SELECT * FROM Torneo.Parametros_suspension WHERE id_parametro = @idParam;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Parametros_suspension 
    @id_parametro = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Feriado_pais

EXEC Participantes.Alta_Feriado_pais 
    @id_pais = 1, 
    @fecha = '2050-01-01', 
    @descripcion_feriado = 'Feriado';
DECLARE @idFeriado INT = IDENT_CURRENT('Participantes.Feriado_pais');
GO

-- Test 01: Caso de éxito.
DECLARE @idFeriado INT = IDENT_CURRENT('Participantes.Feriado_pais');
EXEC Participantes.Baja_Feriado_pais 
    @id_feriado = @idFeriado;
GO

DECLARE @idFeriado INT = IDENT_CURRENT('Participantes.Feriado_pais');
SELECT * FROM Participantes.Feriado_pais WHERE id_feriado = @idFeriado;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Feriado_pais 
    @id_feriado = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Ciudad

EXEC Participantes.Alta_Ciudad 
    @id_pais = 1, 
    @nombre = 'Ciudad';
DECLARE @idCiudad INT = IDENT_CURRENT('Participantes.Ciudad');
GO

-- Test 01: Caso de éxito.
DECLARE @idCiudad INT = IDENT_CURRENT('Participantes.Ciudad');
EXEC Participantes.Baja_Ciudad 
    @id_ciudad = @idCiudad;
GO

DECLARE @idCiudad INT = IDENT_CURRENT('Participantes.Ciudad');
SELECT * FROM Participantes.Ciudad WHERE id_ciudad = @idCiudad;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Ciudad 
    @id_ciudad = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Club_origen

EXEC Participantes.Alta_Club_origen 
    @nombre = 'Club', 
    @id_pais_club = 1;
DECLARE @idClub INT = IDENT_CURRENT('Participantes.Club_origen');
GO

-- Test 01: Caso de éxito.
DECLARE @idClub INT = IDENT_CURRENT('Participantes.Club_origen');
EXEC Participantes.Baja_Club_origen 
    @id_club = @idClub;
GO

DECLARE @idClub INT = IDENT_CURRENT('Participantes.Club_origen');
SELECT * FROM Participantes.Club_origen WHERE id_club = @idClub;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Club_origen 
    @id_club = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Arbitro

EXEC Participantes.Alta_Arbitro 
    @id_pais = 1, 
    @id_categoria = 1, 
    @nombre = 'Arbitro', 
    @apellido = 'Arbitral', 
    @fecha_nacimiento = '1980-01-01';
DECLARE @idArbitro INT = IDENT_CURRENT('Participantes.Arbitro');
GO

-- Test 01: Caso de éxito.
DECLARE @idArbitro INT = IDENT_CURRENT('Participantes.Arbitro');
EXEC Participantes.Baja_Arbitro 
    @id_arbitro = @idArbitro;
GO

DECLARE @idArbitro INT = IDENT_CURRENT('Participantes.Arbitro');
SELECT * FROM Participantes.Arbitro WHERE id_arbitro = @idArbitro;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Arbitro 
    @id_arbitro = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Seleccion

EXEC Participantes.Alta_Pais @codigo_moneda = 'ARS', @nombre = 'Pais Auxiliar', @codigo_iso = 'AUX', @pbi_per_capita = 1000;
DECLARE @idPaisAux INT = IDENT_CURRENT('Participantes.Pais');
EXEC Participantes.Alta_Seleccion 
    @nombre_seleccion = 'Seleccion', 
    @id_pais = @idPaisAux, 
    @id_confederacion = 1, 
    @id_grupo = 1;
DECLARE @idSel INT = IDENT_CURRENT('Participantes.Seleccion');
GO

-- Test 01: Caso de éxito.
DECLARE @idSel INT = IDENT_CURRENT('Participantes.Seleccion');
EXEC Participantes.Baja_Seleccion 
    @id_seleccion = @idSel;
GO

DECLARE @idSel INT = IDENT_CURRENT('Participantes.Seleccion');
SELECT * FROM Participantes.Seleccion WHERE id_seleccion = @idSel;
GO

DECLARE @idPaisAux INT = IDENT_CURRENT('Participantes.Pais');
EXEC Participantes.Baja_Pais @id_pais = @idPaisAux;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Seleccion 
    @id_seleccion = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Idioma_arbitro

EXEC Participantes.Alta_Idioma @nombre = 'Idioma 2';
DECLARE @idIdio INT = IDENT_CURRENT('Participantes.Idioma');
EXEC Participantes.Alta_Idioma_arbitro @id_arbitro = 1, @id_idioma = @idIdio;
GO

-- Test 01: Caso de éxito.
DECLARE @idIdio INT = IDENT_CURRENT('Participantes.Idioma');
EXEC Participantes.Baja_Idioma_arbitro 
    @id_arbitro = 1, 
    @id_idioma = @idIdio;
GO

DECLARE @idIdio INT = IDENT_CURRENT('Participantes.Idioma');
SELECT * FROM Participantes.Idioma_arbitro WHERE id_arbitro = 1 AND id_idioma = @idIdio;
GO

DECLARE @idIdio INT = IDENT_CURRENT('Participantes.Idioma');
EXEC Participantes.Baja_Idioma @id_idioma = @idIdio;
GO

-- Test 02: La asociación no existe
EXEC Participantes.Baja_Idioma_arbitro 
    @id_arbitro = 9999, 
    @id_idioma = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Anunciante

EXEC Publicidad.Alta_Anunciante 
    @nombre_anunciante = 'Anunciante', 
    @id_pais_origen = 1, 
    @identificacion_fiscal = '99-99999999-9';
DECLARE @idAnun INT = IDENT_CURRENT('Publicidad.Anunciante');
GO

-- Test 01: Caso de éxito.
DECLARE @idAnun INT = IDENT_CURRENT('Publicidad.Anunciante');
EXEC Publicidad.Baja_Anunciante 
    @id_anunciante = @idAnun;
GO

DECLARE @idAnun INT = IDENT_CURRENT('Publicidad.Anunciante');
SELECT * FROM Publicidad.Anunciante WHERE id_anunciante = @idAnun;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Anunciante 
    @id_anunciante = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Sede

EXEC Torneo.Alta_Sede 
    @id_ciudad = 1, 
    @nombre_estadio = 'Estadio', 
    @capacidad = 10000, 
    @latitud = 0, 
    @longitud = 0, 
    @huso_horario = 'UTC';
DECLARE @idSede INT = IDENT_CURRENT('Torneo.Sede');
GO

-- Test 01: Caso de éxito.
DECLARE @idSede INT = IDENT_CURRENT('Torneo.Sede');
EXEC Torneo.Baja_Sede 
    @id_sede = @idSede;
GO

DECLARE @idSede INT = IDENT_CURRENT('Torneo.Sede');
SELECT * FROM Torneo.Sede WHERE id_sede = @idSede;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Sede 
    @id_sede = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Jugador

EXEC Participantes.Alta_Jugador 
    @nombre = 'Jugador', 
    @apellido = 'Jugado', 
    @fecha_nacimiento = '2000-01-01', 
    @id_pais_nacimiento = 1, 
    @id_posicion_habitual = 1, 
    @id_club_origen = 1;
DECLARE @idJug INT = IDENT_CURRENT('Participantes.Jugador');
GO

-- Test 01: Caso de éxito.
DECLARE @idJug INT = IDENT_CURRENT('Participantes.Jugador');
EXEC Participantes.Baja_Jugador 
    @id_jugador = @idJug;
GO

DECLARE @idJug INT = IDENT_CURRENT('Participantes.Jugador');
SELECT * FROM Participantes.Jugador WHERE id_jugador = @idJug;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Jugador 
    @id_jugador = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Integrante_cuerpo_tecnico

EXEC Participantes.Alta_Integrante_cuerpo_tecnico 
    @id_seleccion = 1, 
    @nombre = 'CT', 
    @apellido = 'Borrable', 
    @cargo_rol = 'Ayudante';
DECLARE @idCT INT = IDENT_CURRENT('Participantes.Integrante_cuerpo_tecnico');
GO

-- Test 01: Caso de éxito.
DECLARE @idCT INT = IDENT_CURRENT('Participantes.Integrante_cuerpo_tecnico');
EXEC Participantes.Baja_Integrante_cuerpo_tecnico 
    @id_integrante_ct = @idCT;
GO

DECLARE @idCT INT = IDENT_CURRENT('Participantes.Integrante_cuerpo_tecnico');
SELECT * FROM Participantes.Integrante_cuerpo_tecnico WHERE id_integrante_ct = @idCT;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Integrante_cuerpo_tecnico 
    @id_integrante_ct = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Convocatoria

EXEC Participantes.Alta_Jugador @nombre = 'Convocado', @apellido = 'Borrable', @fecha_nacimiento = '2000-01-01', @id_pais_nacimiento = 1, @id_posicion_habitual = 1, @id_club_origen = 1;
DECLARE @idJugConv INT = IDENT_CURRENT('Participantes.Jugador');
EXEC Participantes.Alta_Convocatoria 
    @id_seleccion = 1, 
    @id_jugador = @idJugConv, 
    @estado_convocatoria = 'Confirmado', 
    @fecha_alta_convocatoria = '2026-05-15', 
    @dorsal = 26;
DECLARE @idConv INT = IDENT_CURRENT('Participantes.Convocatoria');
GO

-- Test 01: Caso de éxito.
DECLARE @idConv INT = IDENT_CURRENT('Participantes.Convocatoria');
EXEC Participantes.Baja_Convocatoria 
    @id_convocatoria = @idConv;
GO

DECLARE @idConv INT = IDENT_CURRENT('Participantes.Convocatoria');
SELECT * FROM Participantes.Convocatoria WHERE id_convocatoria = @idConv;
GO

DECLARE @idJugConv INT = IDENT_CURRENT('Participantes.Jugador');
EXEC Participantes.Baja_Jugador @id_jugador = @idJugConv;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Convocatoria 
    @id_convocatoria = 9999;
GO

------------------------------------------
-- PRUEBAS: Participantes.Baja_Novedad_convocatoria

EXEC Participantes.Alta_Jugador @nombre = 'Novedad', @apellido = 'Borrable', @fecha_nacimiento = '2000-01-01', @id_pais_nacimiento = 1, @id_posicion_habitual = 1, @id_club_origen = 1;
DECLARE @idJugNov INT = IDENT_CURRENT('Participantes.Jugador');
EXEC Participantes.Alta_Convocatoria @id_seleccion = 1, @id_jugador = @idJugNov, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-15', @dorsal = 25;
DECLARE @idConvNov INT = IDENT_CURRENT('Participantes.Convocatoria');

EXEC Participantes.Registrar_Reemplazo_Convocatoria 
    @id_convocatoria_baja = 1, 
    @id_convocatoria_alta = @idConvNov, 
    @motivo_cambio = 'Prueba Borrado', 
    @fecha_cambio = '2026-06-05', 
    @observaciones = 'Auxiliar';
DECLARE @idNov INT = IDENT_CURRENT('Participantes.Novedad_convocatoria');
GO

-- Test 01: Caso de éxito.
DECLARE @idNov INT = IDENT_CURRENT('Participantes.Novedad_convocatoria');
EXEC Participantes.Baja_Novedad_convocatoria 
    @id_novedad = @idNov;
GO

DECLARE @idNov INT = IDENT_CURRENT('Participantes.Novedad_convocatoria');
SELECT * FROM Participantes.Novedad_convocatoria WHERE id_novedad = @idNov;
GO

DECLARE @idConvNov INT = IDENT_CURRENT('Participantes.Convocatoria');
DECLARE @idJugNov INT = IDENT_CURRENT('Participantes.Jugador');
EXEC Participantes.Baja_Convocatoria @id_convocatoria = @idConvNov;
EXEC Participantes.Baja_Jugador @id_jugador = @idJugNov;
GO

-- Test 02: Registro no existe
EXEC Participantes.Baja_Novedad_convocatoria 
    @id_novedad = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Campania_publicitaria

EXEC Publicidad.Alta_Campania_publicitaria 
    @id_anunciante = 1, 
    @nombre_campania = 'Campania', 
    @fecha_inicio = '2026-01-01', 
    @fecha_fin = '2026-01-31', 
    @presupuesto = 1000;
DECLARE @idCamp INT = IDENT_CURRENT('Publicidad.Campania_publicitaria');
GO

-- Test 01: Caso de éxito.
DECLARE @idCamp INT = IDENT_CURRENT('Publicidad.Campania_publicitaria');
EXEC Publicidad.Baja_Campania_publicitaria 
    @id_campania = @idCamp;
GO

DECLARE @idCamp INT = IDENT_CURRENT('Publicidad.Campania_publicitaria');
SELECT * FROM Publicidad.Campania_publicitaria WHERE id_campania = @idCamp;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Campania_publicitaria 
    @id_campania = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Pieza_publicitaria

EXEC Publicidad.Alta_Pieza_publicitaria 
    @id_campania = 1, 
    @id_idioma = 1, 
    @nombre_pieza = 'Pieza', 
    @duracion_segundos = 10, 
    @url_contenido_media = 'url';
DECLARE @idPieza INT = IDENT_CURRENT('Publicidad.Pieza_publicitaria');
GO

-- Test 01: Caso de éxito.
DECLARE @idPieza INT = IDENT_CURRENT('Publicidad.Pieza_publicitaria');
EXEC Publicidad.Baja_Pieza_publicitaria 
    @id_pieza = @idPieza;
GO

DECLARE @idPieza INT = IDENT_CURRENT('Publicidad.Pieza_publicitaria');
SELECT * FROM Publicidad.Pieza_publicitaria WHERE id_pieza = @idPieza;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Pieza_publicitaria 
    @id_pieza = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Sustitucion

-- Registros necesarios: dos jugadores auxiliares de Argentina en la planilla del partido 1 (uno titular y uno suplente)
DECLARE @idPaisArg INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
DECLARE @idSelArg INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección Argentina');
EXEC Participantes.Alta_Jugador @nombre = 'Sale', @apellido = 'Borrable', @fecha_nacimiento = '2000-01-01', @id_pais_nacimiento = @idPaisArg, @id_posicion_habitual = 1, @id_club_origen = 1;
EXEC Participantes.Alta_Jugador @nombre = 'Entra', @apellido = 'Borrable', @fecha_nacimiento = '2000-01-01', @id_pais_nacimiento = @idPaisArg, @id_posicion_habitual = 1, @id_club_origen = 1;
DECLARE @jSale INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Sale' AND apellido = 'Borrable');
DECLARE @jEntra INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Entra' AND apellido = 'Borrable');
EXEC Participantes.Alta_Convocatoria @id_seleccion = @idSelArg, @id_jugador = @jSale, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-15', @dorsal = 22;
EXEC Participantes.Alta_Convocatoria @id_seleccion = @idSelArg, @id_jugador = @jEntra, @estado_convocatoria = 'Confirmado', @fecha_alta_convocatoria = '2026-05-15', @dorsal = 23;
DECLARE @cSale INT = (SELECT id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jSale);
DECLARE @cEntra INT = (SELECT id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jEntra);
DECLARE @idAli INT = (SELECT A.id_alineacion_partido FROM Torneo.Alineacion_partido A
                        INNER JOIN Participantes.Seleccion S ON A.id_seleccion = S.id_seleccion
                        WHERE A.id_partido = 1 AND S.nombre_seleccion = 'Selección Argentina');
EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAli, @id_convocatoria = @cSale, @id_posicion_partido = 1, @es_titular = 1;
EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAli, @id_convocatoria = @cEntra, @id_posicion_partido = 1, @es_titular = 0;
EXEC Torneo.Registrar_Sustitucion_Partido @id_alineacion_partido = @idAli, @id_convocatoria_sale = @cSale, @id_convocatoria_entra = @cEntra, @motivo_sustitucion = 'Test Baja', @minuto = 90, @numero_ventanas = 3, @es_tiempo_suplementario = 0;
GO

-- Test 01: Caso de éxito.
DECLARE @idSust INT = IDENT_CURRENT('Torneo.Sustitucion');
EXEC Torneo.Baja_Sustitucion 
    @id_sustitucion = @idSust;
GO

DECLARE @idSust INT = IDENT_CURRENT('Torneo.Sustitucion');
SELECT * FROM Torneo.Sustitucion WHERE id_sustitucion = @idSust;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Sustitucion 
    @id_sustitucion = 9999;
GO

-- Limpieza de los registros auxiliares
DECLARE @idAli INT = (SELECT A.id_alineacion_partido FROM Torneo.Alineacion_partido A
                        INNER JOIN Participantes.Seleccion S ON A.id_seleccion = S.id_seleccion
                        WHERE A.id_partido = 1 AND S.nombre_seleccion = 'Selección Argentina');
DECLARE @jSale INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Sale' AND apellido = 'Borrable');
DECLARE @jEntra INT = (SELECT id_jugador FROM Participantes.Jugador WHERE nombre = 'Entra' AND apellido = 'Borrable');
DECLARE @cSale INT = (SELECT id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jSale);
DECLARE @cEntra INT = (SELECT id_convocatoria FROM Participantes.Convocatoria WHERE id_jugador = @jEntra);
EXEC Torneo.Baja_Detalle_alineacion_jugador @id_alineacion_partido = @idAli, @id_convocatoria = @cSale;
EXEC Torneo.Baja_Detalle_alineacion_jugador @id_alineacion_partido = @idAli, @id_convocatoria = @cEntra;
EXEC Participantes.Baja_Convocatoria @id_convocatoria = @cSale;
EXEC Participantes.Baja_Convocatoria @id_convocatoria = @cEntra;
EXEC Participantes.Baja_Jugador @id_jugador = @jSale;
EXEC Participantes.Baja_Jugador @id_jugador = @jEntra;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Informe_post_partido

-- Registros necesarios: un árbitro uruguayo auxiliar designado en el partido 1
-- (Ostojich ya tiene informe en ese partido desde el script 07). Se borra en las pruebas de Baja_Designacion_arbitral.
DECLARE @idPaisUru INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'URY');
DECLARE @idRol INT = (SELECT MIN(id_rol_arbitro) FROM Participantes.Rol_arbitro);
EXEC Participantes.Alta_Arbitro @id_pais = @idPaisUru, @id_categoria = 1, @nombre = 'Arbitro', @apellido = 'Borrable', @fecha_nacimiento = '1980-01-01';
DECLARE @idArb INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE nombre = 'Arbitro' AND apellido = 'Borrable');
EXEC Torneo.Asignar_Arbitro_Partido @id_partido = 1, @id_rol_arbitro = @idRol, @id_arbitro = @idArb;
EXEC Torneo.Alta_Informe_post_partido @id_partido = 1, @id_arbitro = @idArb, @calificacion_desempenio = 5, @observaciones = 'Informe a borrar', @sancion_aplicada = NULL;
GO

-- Test 01: Caso de éxito.
DECLARE @idInf INT = IDENT_CURRENT('Torneo.Informe_post_partido');
EXEC Torneo.Baja_Informe_post_partido 
    @id_informe = @idInf;
GO

DECLARE @idInf INT = IDENT_CURRENT('Torneo.Informe_post_partido');
SELECT * FROM Torneo.Informe_post_partido WHERE id_informe = @idInf;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Informe_post_partido 
    @id_informe = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Detalle_alineacion_jugador

-- Registros necesarios: Messi como suplente en la planilla de Argentina del partido 1
DECLARE @idAli INT = (SELECT A.id_alineacion_partido FROM Torneo.Alineacion_partido A
                        INNER JOIN Participantes.Seleccion S ON A.id_seleccion = S.id_seleccion
                        WHERE A.id_partido = 1 AND S.nombre_seleccion = 'Selección Argentina');
DECLARE @cMessi INT = (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
EXEC Torneo.Confirmar_Planilla_Jugador @id_alineacion_partido = @idAli, @id_convocatoria = @cMessi, @id_posicion_partido = 1, @es_titular = 0;
GO

-- Test 01: Caso de éxito.
DECLARE @idAli INT = (SELECT A.id_alineacion_partido FROM Torneo.Alineacion_partido A
                        INNER JOIN Participantes.Seleccion S ON A.id_seleccion = S.id_seleccion
                        WHERE A.id_partido = 1 AND S.nombre_seleccion = 'Selección Argentina');
DECLARE @cMessi INT = (SELECT C.id_convocatoria FROM Participantes.Convocatoria C INNER JOIN Participantes.Jugador J ON C.id_jugador = J.id_jugador WHERE J.apellido = 'Messi');
EXEC Torneo.Baja_Detalle_alineacion_jugador 
    @id_alineacion_partido = @idAli, 
    @id_convocatoria = @cMessi;

SELECT * FROM Torneo.Detalle_alineacion_jugador WHERE id_alineacion_partido = @idAli AND id_convocatoria = @cMessi;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Detalle_alineacion_jugador 
    @id_alineacion_partido = 9999, 
    @id_convocatoria = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Exhibicion_publicidad_partido

EXEC Publicidad.Alta_Exhibicion_publicidad_partido @id_partido = 1, @numero_espacio = 4, @id_pieza = 1, @tarifa_aplicada_usd = 200000, @id_franja = 1, @fecha_hora_exhibicion = '20260615 21:00:00';
GO

-- Test 01: Caso de éxito.
EXEC Publicidad.Baja_Exhibicion_publicidad_partido 
    @id_partido = 1, 
    @numero_espacio = 4;
GO

SELECT * FROM Publicidad.Exhibicion_publicidad_partido WHERE id_partido = 1 AND numero_espacio = 4;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Exhibicion_publicidad_partido 
    @id_partido = 9999, 
    @numero_espacio = 1;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Suspension_jugador

EXEC Torneo.Alta_Suspension_jugador @id_convocatoria = 1, @id_partido_origen = 1, @id_partido_sancion = NULL, @cantidad_fechas = 2, @sancion_cumplida = 0;
DECLARE @idSusp INT = IDENT_CURRENT('Torneo.Suspension_jugador');
GO

-- Test 01: Caso de éxito.
DECLARE @idSusp INT = IDENT_CURRENT('Torneo.Suspension_jugador');
EXEC Torneo.Baja_Suspension_jugador 
    @id_suspension = @idSusp;
GO

DECLARE @idSusp INT = IDENT_CURRENT('Torneo.Suspension_jugador');
SELECT * FROM Torneo.Suspension_jugador WHERE id_suspension = @idSusp;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Suspension_jugador 
    @id_suspension = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Tarjeta

EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = 1, @id_convocatoria = 1, @id_tipo_tarjeta = 1, @id_motivo_tarjeta = 1, @id_periodo_partido = 1, @minuto = 10;
DECLARE @idTar INT = IDENT_CURRENT('Torneo.Tarjeta');
GO

-- Test 01: Caso de éxito.
DECLARE @idTar INT = IDENT_CURRENT('Torneo.Tarjeta');
EXEC Torneo.Baja_Tarjeta 
    @id_tarjeta = @idTar;
GO

DECLARE @idTar INT = IDENT_CURRENT('Torneo.Tarjeta');
SELECT * FROM Torneo.Tarjeta WHERE id_tarjeta = @idTar;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Tarjeta 
    @id_tarjeta = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Gol

EXEC Torneo.Registrar_Gol_Partido @id_convocatoria_autor = 1, @id_convocatoria_asistencia = NULL, @id_tipo_gol = 1, @id_periodo_partido = 1, @id_partido = 1, @minuto = 1;
DECLARE @idGol INT = IDENT_CURRENT('Torneo.Gol');
GO

-- Test 01: Caso de éxito.
DECLARE @idGol INT = IDENT_CURRENT('Torneo.Gol');
EXEC Torneo.Baja_Gol 
    @id_gol = @idGol;
GO

DECLARE @idGol INT = IDENT_CURRENT('Torneo.Gol');
SELECT * FROM Torneo.Gol WHERE id_gol = @idGol;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Gol 
    @id_gol = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Alineacion_partido

EXEC Torneo.Alta_Alineacion_partido @id_partido = 1, @id_seleccion = 2, @id_esquema_tactico = 1;
DECLARE @idAli INT = IDENT_CURRENT('Torneo.Alineacion_partido');
GO

-- Test 01: Caso de éxito.
DECLARE @idAli INT = IDENT_CURRENT('Torneo.Alineacion_partido');
EXEC Torneo.Baja_Alineacion_partido 
    @id_alineacion_partido = @idAli;
GO

DECLARE @idAli INT = IDENT_CURRENT('Torneo.Alineacion_partido');
SELECT * FROM Torneo.Alineacion_partido WHERE id_alineacion_partido = @idAli;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Alineacion_partido 
    @id_alineacion_partido = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Designacion_arbitral

-- Registro necesario: la designación del árbitro auxiliar (se cargó en las pruebas de Baja_Informe_post_partido,
-- y su informe ya se borró).

-- Test 01: Caso de éxito.
DECLARE @idArb INT = (SELECT id_arbitro FROM Participantes.Arbitro WHERE nombre = 'Arbitro' AND apellido = 'Borrable');
EXEC Torneo.Baja_Designacion_arbitral 
    @id_partido = 1, 
    @id_arbitro = @idArb;

SELECT * FROM Torneo.Designacion_arbitral WHERE id_partido = 1 AND id_arbitro = @idArb;

-- Limpieza del árbitro auxiliar
EXEC Participantes.Baja_Arbitro @id_arbitro = @idArb;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Designacion_arbitral 
    @id_partido = 9999, 
    @id_arbitro = 9999;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Baja_Mercado_interes_campania

EXEC Participantes.Alta_Pais @codigo_moneda = 'ARS', @nombre = 'Pais Mercado', @codigo_iso = 'MER', @pbi_per_capita = 100;
DECLARE @idPaisMer INT = IDENT_CURRENT('Participantes.Pais');
EXEC Publicidad.Alta_Mercado_interes_campania @id_campania = 1, @id_pais = @idPaisMer;
GO

-- Test 01: Caso de éxito.
DECLARE @idPaisMer INT = IDENT_CURRENT('Participantes.Pais');
EXEC Publicidad.Baja_Mercado_interes_campania 
    @id_campania = 1, 
    @id_pais = @idPaisMer;
GO

DECLARE @idPaisMer INT = IDENT_CURRENT('Participantes.Pais');
SELECT * FROM Publicidad.Mercado_interes_campania WHERE id_campania = 1 AND id_pais = @idPaisMer;
GO

DECLARE @idPaisMer INT = IDENT_CURRENT('Participantes.Pais');
EXEC Participantes.Baja_Pais @id_pais = @idPaisMer;
GO

-- Test 02: Registro no existe
EXEC Publicidad.Baja_Mercado_interes_campania 
    @id_campania = 9999, 
    @id_pais = 9999;
GO

------------------------------------------
-- PRUEBAS: Torneo.Baja_Partido

DECLARE @idArg INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección Argentina');
DECLARE @idBra INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE nombre_seleccion = 'Selección de Brasil');
-- (Brasil de local: Argentina - Brasil en la fase 1 ya existe y la clave única lo rechazaría)
EXEC Torneo.Alta_Partido @id_sede = 1, @id_fase = 1, @id_seleccion_local = @idBra, @id_seleccion_visitante = @idArg, @id_importacion_origen = 1, @fecha_hora_local = '20300101 10:00:00', @asistencia_publico = 100, @goles_local = 0, @goles_visitante = 0, @UTC = '2030-01-01 13:00:00';
DECLARE @idPartidoAux INT = IDENT_CURRENT('Torneo.Partido');
GO

-- Test 01: Caso de éxito.
DECLARE @idPartidoAux INT = IDENT_CURRENT('Torneo.Partido');
EXEC Torneo.Baja_Partido 
    @id_partido = @idPartidoAux;
GO

DECLARE @idPartidoAux INT = IDENT_CURRENT('Torneo.Partido');
SELECT * FROM Torneo.Partido WHERE id_partido = @idPartidoAux;
GO

-- Test 02: Registro no existe
EXEC Torneo.Baja_Partido 
    @id_partido = 9999;
GO