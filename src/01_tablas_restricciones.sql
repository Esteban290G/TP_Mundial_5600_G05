-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creacion de tablas y restricciones --
------------------------------------------

USE COM5600_G05;
GO

set nocount on

------- Eliminar tablas existentes -------

DROP TABLE IF EXISTS Torneo.Sustitucion;
DROP TABLE IF EXISTS Torneo.Informe_post_partido;
DROP TABLE IF EXISTS Torneo.Detalle_alineacion_jugador;
DROP TABLE IF EXISTS Torneo.Suspension_jugador;
DROP TABLE IF EXISTS Torneo.Tarjeta;
DROP TABLE IF EXISTS Torneo.Gol;
DROP TABLE IF EXISTS Torneo.Alineacion_partido;
DROP TABLE IF EXISTS Torneo.Designacion_arbitral;
DROP TABLE IF EXISTS Torneo.Partido;
DROP TABLE IF EXISTS Participantes.Novedad_convocatoria;
DROP TABLE IF EXISTS Participantes.Convocatoria;
DROP TABLE IF EXISTS Participantes.Integrante_cuerpo_tecnico;
DROP TABLE IF EXISTS Participantes.Jugador;
DROP TABLE IF EXISTS Torneo.Sede;
DROP TABLE IF EXISTS Participantes.Idioma_arbitro;
DROP TABLE IF EXISTS Participantes.Seleccion;
DROP TABLE IF EXISTS Participantes.Arbitro;
DROP TABLE IF EXISTS Participantes.Club_origen;
DROP TABLE IF EXISTS Participantes.Ciudad;
DROP TABLE IF EXISTS Participantes.Feriado_pais;
DROP TABLE IF EXISTS Participantes.Pais;
DROP TABLE IF EXISTS Participantes.Cotizacion_moneda;
DROP TABLE IF EXISTS Torneo.Motivo_tarjeta;
DROP TABLE IF EXISTS Torneo.Tipo_tarjeta;
DROP TABLE IF EXISTS Torneo.Periodo_partido;
DROP TABLE IF EXISTS Torneo.Tipo_gol;
DROP TABLE IF EXISTS Torneo.Esquema_tactico;
DROP TABLE IF EXISTS Torneo.Log_importacion;
DROP TABLE IF EXISTS Torneo.Fase;
DROP TABLE IF EXISTS Torneo.Grupo_torneo;
DROP TABLE IF EXISTS Participantes.Idioma;
DROP TABLE IF EXISTS Participantes.Rol_arbitro;
DROP TABLE IF EXISTS Participantes.Categoria_arbitro;
DROP TABLE IF EXISTS Participantes.Posicion;
DROP TABLE IF EXISTS Participantes.Confederacion;
DROP TABLE IF EXISTS Participantes.Moneda;
GO
------------------------------------------
------- Tablas que no tienen FK ----------

CREATE TABLE Participantes.Moneda (
	codigo_moneda CHAR(3) NOT NULL,
	nombre_moneda VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Moneda PRIMARY KEY (codigo_moneda)
	);
GO

CREATE TABLE Participantes.Confederacion (
	id_confederacion INT IDENTITY(1,1),
	nombre_confederacion VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Confederacion PRIMARY KEY (id_confederacion),
	CONSTRAINT UQ_Confederacion_Nombre UNIQUE (nombre_confederacion)
);
GO

CREATE TABLE Participantes.Posicion (
	id_posicion INT IDENTITY(1,1),
	nombre_posicion VARCHAR(30) NOT NULL,

	CONSTRAINT PK_posicion PRIMARY KEY (id_posicion),
	CONSTRAINT UQ_Posicion_Nombre UNIQUE (nombre_posicion)
);
GO

CREATE TABLE Participantes.Categoria_arbitro (
	id_categoria INT IDENTITY(1,1),
	descripcion VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Categoria_Arbitro PRIMARY KEY (id_categoria),
	CONSTRAINT UQ_Categoria_Arbitro_Descripcion UNIQUE (descripcion)
);
GO

CREATE TABLE Participantes.Rol_arbitro (
	id_rol_arbitro INT IDENTITY(1,1),
	descripcion VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Rol_Arbitro PRIMARY KEY (id_rol_arbitro),
	CONSTRAINT UQ_Rol_Arbitro_Descripcion UNIQUE (descripcion)
);
GO

CREATE TABLE Participantes.Idioma (
	id_idioma INT IDENTITY(1,1),
	nombre VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Idioma PRIMARY KEY (id_idioma),
	CONSTRAINT UQ_Idioma_Nombre UNIQUE (nombre)
);
GO

CREATE TABLE Torneo.Grupo_torneo (
	id_grupo INT IDENTITY(1,1),
	nombre_grupo CHAR(1) NOT NULL,

	CONSTRAINT PK_Grupo PRIMARY KEY (id_grupo),
	CONSTRAINT UQ_Grupo_Nombre UNIQUE (nombre_grupo)
);
GO

CREATE TABLE Torneo.Fase (
	id_fase INT IDENTITY(1,1),
	nombre_fase VARCHAR(30) NOT NULL,

	CONSTRAINT PK_fase PRIMARY KEY (id_fase),
	CONSTRAINT UQ_Fase_Nombre UNIQUE (nombre_fase)
);
GO

CREATE TABLE Torneo.Log_importacion (
    id_log INT IDENTITY(1,1),
    nombre_archivo_o_fuente VARCHAR(255) NOT NULL,
    fecha_hora_ejecucion DATETIME NOT NULL,
    registros_procesados INT NOT NULL,
    registros_con_error INT NOT NULL,
    estado VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Log_Importacion PRIMARY KEY (id_log),
    CONSTRAINT CK_Log_Registros CHECK (registros_procesados >= 0 AND registros_con_error >= 0),
    CONSTRAINT CK_Log_Fecha CHECK (fecha_hora_ejecucion <= GETDATE())
);
GO

CREATE TABLE Torneo.Esquema_tactico (
	id_esquema_tactico INT IDENTITY(1,1),
	descripcion_esquema VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Esquema PRIMARY KEY (id_esquema_tactico),
	CONSTRAINT UQ_Esquema_Descripcion UNIQUE (descripcion_esquema)
);
GO

CREATE TABLE Torneo.Tipo_gol (
	id_tipo INT IDENTITY(1,1),
	descripcion_tipo VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Tipo_Gol PRIMARY KEY (id_tipo),
	CONSTRAINT UQ_Tipo_Gol_Descripcion UNIQUE (descripcion_tipo)
);
GO

CREATE TABLE Torneo.Periodo_partido (
	id_periodo_partido INT IDENTITY(1,1),
	descripcion_periodo VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Periodo_Partido PRIMARY KEY (id_periodo_partido),
	CONSTRAINT UQ_Periodo_Partido_Descripcion UNIQUE (descripcion_periodo)
);
GO

CREATE TABLE Torneo.Tipo_tarjeta (
	id_tipo_tarjeta INT IDENTITY(1,1),
	descripcion_tarjeta VARCHAR(10) NOT NULL,

	CONSTRAINT PK_Tipo_Tarjeta PRIMARY KEY (id_tipo_tarjeta),
	CONSTRAINT UQ_Descripcion_Tarjeta UNIQUE (descripcion_tarjeta)
);
GO

CREATE TABLE Torneo.Motivo_tarjeta (
	id_motivo INT IDENTITY(1,1),
	descripcion_motivo VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Motivo_Tarjeta PRIMARY KEY (id_motivo),
	CONSTRAINT UQ_Descripcion_Motivo UNIQUE (descripcion_motivo)
);
GO

------------------------------------------

CREATE TABLE Participantes.Cotizacion_moneda (
	id_cotizacion INT IDENTITY(1,1),
	codigo_moneda CHAR(3) NOT NULL,
	fecha_cotizacion DATE NOT NULL,
	valor_en_usd DECIMAL(10,4),

	CONSTRAINT PK_Cotizacion PRIMARY KEY (id_cotizacion),
	CONSTRAINT FK_Cotizacion_Moneda FOREIGN KEY (codigo_moneda) REFERENCES Participantes.Moneda(codigo_moneda),
	CONSTRAINT CK_Cotizacion_Valor CHECK (valor_en_usd > 0),
	CONSTRAINT UQ_Cotizacion_Fecha UNIQUE (codigo_moneda, fecha_cotizacion)
	);
GO

CREATE TABLE Participantes.Pais (
	id_pais INT IDENTITY(1,1),
	codigo_moneda CHAR(3) NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	codigo_iso CHAR(3) NOT NULL,
	pbi_per_capita DECIMAL(18,2) NULL,

	CONSTRAINT PK_Pais PRIMARY KEY (id_pais),
    CONSTRAINT FK_Pais_Moneda FOREIGN KEY (codigo_moneda) REFERENCES Participantes.Moneda(codigo_moneda),
    CONSTRAINT UQ_Pais_CodigoISO UNIQUE (codigo_iso),
    CONSTRAINT CK_Pais_PBI CHECK (pbi_per_capita >= 0)
);
GO

CREATE TABLE Participantes.Feriado_pais (
	id_feriado INT IDENTITY(1,1),
	id_pais INT NOT NULL,
	fecha DATE NOT NULL,
	descripcion_feriado VARCHAR(100) NULL,

	CONSTRAINT PK_Feriado PRIMARY KEY (id_feriado),
	CONSTRAINT FK_Feriado_Pais FOREIGN KEY (id_pais) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT UQ_Feriado_Pais_Fecha UNIQUE (id_pais, fecha)
);
GO

CREATE TABLE Participantes.Ciudad (
	id_ciudad INT IDENTITY(1,1),
	id_pais INT NOT NULL,
	nombre VARCHAR(50) NOT NULL

	CONSTRAINT PK_Ciudad PRIMARY KEY (id_ciudad),
	CONSTRAINT FK_Ciudad_Pais FOREIGN KEY (id_pais) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT UQ_Ciudad_Pais_Nombre UNIQUE (id_pais, nombre)
);
GO

CREATE TABLE Participantes.Club_origen (
	id_club INT IDENTITY(1,1),
	nombre VARCHAR(50) NOT NULL,
	id_pais_club INT NOT NULL,

	CONSTRAINT PK_Club PRIMARY KEY (id_club),
	CONSTRAINT FK_Club_Pais FOREIGN KEY (id_pais_club) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT UQ_Club_Pais_Nombre UNIQUE (id_pais_club, nombre)
);
GO

CREATE TABLE Participantes.Arbitro (
	id_arbitro INT IDENTITY(1,1),
	id_pais INT NOT NULL,
	id_categoria INT NOT NULL,
	nombre VARCHAR(50) NOT NULL,
	apellido VARCHAR(50) NOT NULL,
	fecha_nacimiento DATE NOT NULL,

	CONSTRAINT PK_Arbitro PRIMARY KEY (id_arbitro),
	CONSTRAINT FK_Arbitro_Pais FOREIGN KEY (id_pais) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT FK_Arbitro_Categoria FOREIGN KEY (id_categoria) REFERENCES Participantes.Categoria_arbitro(id_categoria),
	CONSTRAINT UQ_Arbitro UNIQUE (nombre, apellido, fecha_nacimiento, id_pais),
	CONSTRAINT CK_Arbitro_Nacimiento CHECK (fecha_nacimiento <= GETDATE())
);
GO

CREATE TABLE Participantes.Seleccion (
	id_seleccion INT IDENTITY(1,1),
	nombre_seleccion VARCHAR(50) NOT NULL,
	id_pais INT NOT NULL,
	id_confederacion INT NOT NULL,
	id_grupo INT NOT NULL,

	CONSTRAINT PK_Seleccion PRIMARY KEY (id_seleccion),
	CONSTRAINT UQ_Seleccion_Nombre UNIQUE (nombre_seleccion),
	CONSTRAINT FK_Seleccion_Pais FOREIGN KEY (id_pais) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT UQ_Seleccion_Pais UNIQUE (id_pais),
	CONSTRAINT FK_Seleccion_Confederacion FOREIGN KEY (id_confederacion) REFERENCES Participantes.Confederacion(id_confederacion),
	CONSTRAINT FK_Seleccion_Grupo FOREIGN KEY (id_grupo) REFERENCES Torneo.Grupo_torneo(id_grupo)
);
GO

CREATE TABLE Participantes.Idioma_arbitro (
	id_arbitro INT NOT NULL,
	id_idioma INT NOT NULL,

	CONSTRAINT PK_Idioma_Arbitro PRIMARY KEY (id_arbitro, id_idioma),
	CONSTRAINT FK_IdiomaArbitro_Arbitro FOREIGN KEY (id_arbitro) REFERENCES Participantes.Arbitro (id_arbitro),
	CONSTRAINT FK_IdiomaArbitro_Idioma FOREIGN KEY (id_idioma) REFERENCES Participantes.Idioma (id_idioma)
);
GO

CREATE TABLE Torneo.Sede (
	id_sede INT IDENTITY(1,1),
	id_ciudad INT NOT NULL,
	nombre_estadio VARCHAR(30) NOT NULL,
	capacidad INT NOT NULL,
	latitud DECIMAL(9, 6) NOT NULL,
	longitud DECIMAL(9, 6) NOT NULL,
	huso_horario VARCHAR(10) NOT NULL,

	CONSTRAINT PK_Sede PRIMARY KEY (id_sede),
    CONSTRAINT FK_Sede_Ciudad FOREIGN KEY (id_ciudad) REFERENCES Participantes.Ciudad(id_ciudad),
    CONSTRAINT UQ_Sede_Estadio UNIQUE (id_ciudad, nombre_estadio),
    CONSTRAINT CK_Sede_Capacidad CHECK (capacidad > 0)
);
GO

CREATE TABLE Participantes.Jugador (
	id_jugador INT IDENTITY(1,1),
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR(30) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	id_pais_nacimiento INT NOT NULL,
	id_posicion_habitual INT NOT NULL,
	id_club_origen INT NOT NULL,

	CONSTRAINT PK_Jugador PRIMARY KEY (id_jugador),
	CONSTRAINT CK_Jugador_Nacimiento CHECK (fecha_nacimiento <= GETDATE()),
	CONSTRAINT FK_Jugador_Pais FOREIGN KEY (id_pais_nacimiento) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT FK_Jugador_Posicion FOREIGN KEY (id_posicion_habitual) REFERENCES Participantes.Posicion(id_posicion),
	CONSTRAINT FK_Jugador_Club FOREIGN KEY (id_club_origen) REFERENCES Participantes.Club_origen(id_club),
	CONSTRAINT UQ_Jugador UNIQUE (nombre, apellido, fecha_nacimiento, id_pais_nacimiento)
);
GO

CREATE TABLE Participantes.Integrante_cuerpo_tecnico (
	id_integrante_ct INT IDENTITY(1,1),
	id_seleccion INT NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR(30) NOT NULL,
	cargo_rol VARCHAR(30) NOT NULL,

	CONSTRAINT PK_Integrante PRIMARY KEY (id_integrante_ct),
	CONSTRAINT FK_Integrante_Seleccion FOREIGN KEY (id_seleccion) REFERENCES Participantes.Seleccion(id_seleccion),
	CONSTRAINT UQ_Integrante_Seleccion UNIQUE (id_seleccion, nombre, apellido, cargo_rol)
);
GO

CREATE TABLE Participantes.Convocatoria (
	id_convocatoria INT IDENTITY(1,1),
	id_seleccion INT NOT NULL,
	id_jugador INT NOT NULL,
	estado_convocatoria VARCHAR(30) NOT NULL,
	fecha_alta_convocatoria DATE NOT NULL,
	dorsal TINYINT NOT NULL,

	CONSTRAINT PK_Convocatoria PRIMARY KEY (id_convocatoria),
	CONSTRAINT FK_Convocatoria_Seleccion FOREIGN KEY (id_seleccion) REFERENCES Participantes.Seleccion(id_seleccion),
	CONSTRAINT FK_Convocatoria_Jugador FOREIGN KEY (id_jugador) REFERENCES Participantes.Jugador(id_jugador),
	CONSTRAINT UQ_Convocatoria_Jugador UNIQUE (id_jugador),
	CONSTRAINT UQ_Convocatoria_Dorsal UNIQUE (id_seleccion, dorsal),
	CONSTRAINT CK_Convocatoria_Dorsal CHECK (dorsal BETWEEN 1 AND 26)
);
GO

CREATE TABLE Participantes.Novedad_convocatoria (
	id_novedad INT IDENTITY(1,1),
	id_convocatoria_baja INT NOT NULL,
	id_convocatoria_alta INT NOT NULL,
	motivo_cambio VARCHAR(50) NOT NULL,
	fecha_cambio DATE NOT NULL,
	observaciones VARCHAR(50) NULL,

	CONSTRAINT PK_Novedad PRIMARY KEY(id_novedad),
	CONSTRAINT FK_Novedad_convocatoria_baja FOREIGN KEY (id_convocatoria_baja) REFERENCES Participantes.Convocatoria(id_convocatoria),
	CONSTRAINT FK_Novedad_convocatoria_alta FOREIGN KEY (id_convocatoria_alta) REFERENCES Participantes.Convocatoria(id_convocatoria),
	CONSTRAINT CK_Novedad_Distintos CHECK (id_convocatoria_baja <> id_convocatoria_alta)
);
GO

CREATE TABLE Torneo.Partido (
	id_partido INT IDENTITY(1,1),
	id_sede INT NOT NULL,
	id_fase INT NOT NULL,
	id_seleccion_local INT NOT NULL,
	id_seleccion_visitante INT NOT NULL,
	id_importacion_origen INT NOT NULL,
	fecha_hora_local DATETIME NOT NULL,
	asistencia_publico INT NULL,
	goles_local TINYINT NULL,
	goles_visitante TINYINT NULL,
	UTC DATETIME NOT NULL,

	CONSTRAINT PK_Partido PRIMARY KEY (id_partido),
	CONSTRAINT FK_Partido_Sede FOREIGN KEY (id_sede) REFERENCES Torneo.Sede (id_sede),
	CONSTRAINT FK_Partido_Fase FOREIGN KEY (id_fase) REFERENCES Torneo.Fase (id_fase),
	CONSTRAINT FK_Partido_Local FOREIGN KEY (id_seleccion_local) REFERENCES Participantes.Seleccion(id_seleccion),
	CONSTRAINT FK_Partido_Visitante FOREIGN KEY (id_seleccion_visitante) REFERENCES Participantes.Seleccion(id_seleccion),
	CONSTRAINT FK_Partido_Importacion FOREIGN KEY (id_importacion_origen) REFERENCES Torneo.Log_importacion(id_log),
	CONSTRAINT CK_Partido_Distintos CHECK (id_seleccion_local <> id_seleccion_visitante),
	CONSTRAINT UQ_Partido_Fase_Equipos UNIQUE (id_fase, id_seleccion_local, id_seleccion_visitante),
	CONSTRAINT UQ_Partido_Sede_Horario UNIQUE (id_sede, fecha_hora_local)
);
GO

CREATE TABLE Torneo.Designacion_arbitral (
	id_partido INT NOT NULL,
	id_rol_arbitro INT NOT NULL,
	id_arbitro INT NOT NULL,

	CONSTRAINT PK_Designacion_Arbitral PRIMARY KEY (id_partido,id_arbitro),
	CONSTRAINT FK_Designacion_Partido FOREIGN KEY (id_partido) REFERENCES Torneo.Partido(id_partido),
	CONSTRAINT FK_Designacion_Rol_Arbitro FOREIGN KEY (id_rol_arbitro) REFERENCES Participantes.Rol_arbitro(id_rol_arbitro),
	CONSTRAINT FK_Designacion_Arbitro FOREIGN KEY (id_arbitro) REFERENCES Participantes.Arbitro(id_arbitro)
);
GO

CREATE TABLE Torneo.Alineacion_partido (
	id_alineacion_partido INT IDENTITY(1,1),
	id_partido INT NOT NULL,
	id_seleccion INT NOT NULL,
	id_esquema_tactico INT NOT NULL,

	CONSTRAINT PK_Alineacion PRIMARY KEY (id_alineacion_partido),
	CONSTRAINT FK_Alineacion_Partido FOREIGN KEY (id_partido) REFERENCES Torneo.Partido (id_partido),
	CONSTRAINT FK_Alineacion_Seleccion FOREIGN KEY (id_seleccion) REFERENCES Participantes.Seleccion (id_seleccion),
	CONSTRAINT FK_Alineacion_Esquema FOREIGN KEY (id_esquema_tactico) REFERENCES Torneo.Esquema_tactico (id_esquema_tactico),
	CONSTRAINT UQ_Alineacion_Partido_Seleccion UNIQUE (id_partido, id_seleccion)
);
GO

CREATE TABLE Torneo.Gol (
	id_gol INT IDENTITY(1,1),
	id_convocatoria_autor INT NOT NULL,
	id_convocatoria_asistencia INT NULL,
	id_tipo_gol INT NOT NULL,
	id_periodo_partido INT NOT NULL,
	id_partido INT NOT NULL,
	minuto TINYINT NOT NULL,

	CONSTRAINT PK_Gol PRIMARY KEY (id_gol),
	CONSTRAINT FK_Gol_Autor FOREIGN KEY (id_convocatoria_autor) REFERENCES Participantes.Convocatoria (id_convocatoria),
	CONSTRAINT FK_Gol_Asistencia FOREIGN KEY (id_convocatoria_asistencia) REFERENCES Participantes.Convocatoria (id_convocatoria),
	CONSTRAINT FK_Gol_Tipo FOREIGN KEY (id_tipo_gol) REFERENCES Torneo.Tipo_gol (id_tipo),
	CONSTRAINT FK_Gol_Periodo FOREIGN KEY (id_periodo_partido) REFERENCES Torneo.Periodo_partido (id_periodo_partido),
	CONSTRAINT FK_Gol_Partido FOREIGN KEY (id_partido) REFERENCES Torneo.Partido (id_partido),
	CONSTRAINT CK_Gol_Autor_Asistencia CHECK (id_convocatoria_autor <> id_convocatoria_asistencia)
);
GO

CREATE TABLE Torneo.Tarjeta (
    id_tarjeta INT IDENTITY(1,1),
    id_partido INT NOT NULL,
    id_convocatoria INT NOT NULL,
    id_tipo_tarjeta INT NOT NULL,
    id_motivo_tarjeta INT NOT NULL,
    id_periodo_partido INT NOT NULL,
    minuto TINYINT NOT NULL,

    CONSTRAINT PK_Tarjeta PRIMARY KEY (id_tarjeta),
    CONSTRAINT FK_Tarjeta_Partido FOREIGN KEY (id_partido) REFERENCES Torneo.Partido(id_partido),
    CONSTRAINT FK_Tarjeta_Convocatoria FOREIGN KEY (id_convocatoria) REFERENCES Participantes.Convocatoria(id_convocatoria),
    CONSTRAINT FK_Tarjeta_Tipo FOREIGN KEY (id_tipo_tarjeta) REFERENCES Torneo.Tipo_tarjeta(id_tipo_tarjeta),
    CONSTRAINT FK_Tarjeta_Motivo FOREIGN KEY (id_motivo_tarjeta) REFERENCES Torneo.Motivo_tarjeta(id_motivo),
    CONSTRAINT FK_Tarjeta_Periodo FOREIGN KEY (id_periodo_partido) REFERENCES Torneo.Periodo_partido(id_periodo_partido)
);
GO

CREATE TABLE Torneo.Suspension_jugador (
	id_suspension INT IDENTITY(1,1),
	id_convocatoria INT NOT NULL,
	id_partido_origen INT NOT NULL,
	id_partido_sancion INT NULL,
	cantidad_fechas TINYINT NOT NULL,
	sancion_cumplida BIT NOT NULL,

	CONSTRAINT PK_Suspension PRIMARY KEY (id_suspension),
	CONSTRAINT FK_Suspension_Convocatoria FOREIGN KEY (id_convocatoria) REFERENCES Participantes.Convocatoria(id_convocatoria),
	CONSTRAINT FK_Suspension_Partido_Origen FOREIGN KEY (id_partido_origen) REFERENCES Torneo.Partido(id_partido),
	CONSTRAINT FK_Suspension_Partido_Sancion FOREIGN KEY (id_partido_sancion) REFERENCES Torneo.Partido(id_partido),
	CONSTRAINT CK_Suspension_Partidos_Distintos CHECK (id_partido_origen <> ISNULL(id_partido_sancion, 0))
);
GO

CREATE TABLE Torneo.Detalle_alineacion_jugador (
    id_alineacion_partido INT NOT NULL,
    id_convocatoria INT NOT NULL,
    id_posicion_partido INT NOT NULL,
    es_titular BIT NOT NULL,

    CONSTRAINT PK_Detalle_Alineacion PRIMARY KEY (id_alineacion_partido, id_convocatoria),
    CONSTRAINT FK_DetalleAlineacion_Alineacion FOREIGN KEY (id_alineacion_partido) REFERENCES Torneo.Alineacion_partido(id_alineacion_partido),
    CONSTRAINT FK_DetalleAlineacion_Convocatoria FOREIGN KEY (id_convocatoria) REFERENCES Participantes.Convocatoria(id_convocatoria),
    CONSTRAINT FK_DetalleAlineacion_Posicion FOREIGN KEY (id_posicion_partido) REFERENCES Participantes.Posicion(id_posicion)
);
GO

CREATE TABLE Torneo.Informe_post_partido (
	id_informe INT IDENTITY(1,1),
	id_partido INT NOT NULL,
	id_arbitro INT NOT NULL,
	calificacion_desempenio TINYINT NOT NULL,
	observaciones VARCHAR(255) NULL,
	sancion_aplicada VARCHAR(50) NULL,

	CONSTRAINT PK_Informe_Post_Partido PRIMARY KEY (id_informe),
	CONSTRAINT UQ_Informe_Partido_Arbitro UNIQUE (id_partido, id_arbitro),
	CONSTRAINT FK_Informe_Designacion FOREIGN KEY (id_partido, id_arbitro) REFERENCES Torneo.Designacion_arbitral(id_partido, id_arbitro),
	CONSTRAINT CK_Informe_Calificacion CHECK (calificacion_desempenio BETWEEN 1 AND 10)
);
GO

CREATE TABLE Torneo.Sustitucion (
    id_sustitucion INT IDENTITY(1,1),
    id_alineacion_partido INT NOT NULL,
    id_convocatoria_sale INT NOT NULL,
    id_convocatoria_entra INT NOT NULL,
    motivo_sustitucion VARCHAR(50) NULL,
    minuto TINYINT NOT NULL,
    numero_ventanas TINYINT NOT NULL,
    es_tiempo_suplementario BIT NOT NULL,

    CONSTRAINT PK_Sustitucion PRIMARY KEY (id_sustitucion),
    CONSTRAINT FK_Sustitucion_Sale FOREIGN KEY (id_alineacion_partido, id_convocatoria_sale) REFERENCES Torneo.Detalle_alineacion_jugador(id_alineacion_partido, id_convocatoria), 
    CONSTRAINT FK_Sustitucion_Entra FOREIGN KEY (id_alineacion_partido, id_convocatoria_entra) REFERENCES Torneo.Detalle_alineacion_jugador(id_alineacion_partido, id_convocatoria),
    CONSTRAINT CK_Sustitucion_Distintos CHECK (id_convocatoria_sale <> id_convocatoria_entra)
);
GO