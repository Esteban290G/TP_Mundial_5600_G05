-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Scripts de testing para SP de ABM --
------------------------------------------

USE COM5600_G05;
GO
------------------------------------------
-- PRUEBAS DE STORED PROCEDURES DE ALTA --
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
-- PRUEBAS: Torneo.Alta_Tipo_gol

-- Test 01: Caso de éxito.
EXEC Torneo.Alta_Tipo_gol
	@descripcion_tipo = 'Penal';
GO

SELECT * FROM Torneo.Tipo_gol;
GO

-- Test 02: Descripción vacía.
EXEC Torneo.Alta_Tipo_gol
	@descripcion_tipo = '';
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