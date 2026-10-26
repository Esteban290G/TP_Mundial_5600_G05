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

------- Eliminar tablas existentes -------

---------- Schema Participantes ----------
DROP TABLE IF EXISTS Participantes.Idioma_arbitro;
DROP TABLE IF EXISTS Participantes.Novedad_convocatoria;
DROP TABLE IF EXISTS Participantes.Convocatoria;
DROP TABLE IF EXISTS Participantes.Jugador;
DROP TABLE IF EXISTS Participantes.Integrante_cuerpo_tecnico;
DROP TABLE IF EXISTS Participantes.Seleccion;
DROP TABLE IF EXISTS Participantes.Arbitro;
DROP TABLE IF EXISTS Participantes.Rol_arbitro;
DROP TABLE IF EXISTS Participantes.Idioma;
DROP TABLE IF EXISTS Participantes.Categoria_arbitro;
DROP TABLE IF EXISTS Participantes.Posicion;
DROP TABLE IF EXISTS Participantes.Club_origen;
DROP TABLE IF EXISTS Participantes.Confederacion;
DROP TABLE IF EXISTS Participantes.Ciudad;
DROP TABLE IF EXISTS Participantes.Feriado_pais;
DROP TABLE IF EXISTS Participantes.Pais;
DROP TABLE IF EXISTS Participantes.Cotizacion_moneda;
DROP TABLE IF EXISTS Participantes.Moneda;
GO
------------------------------------------

-- Tablas pertenecientes al schema Torneo --

-- Tablas pertenecientes al schema Participantes --

CREATE TABLE Participantes.Moneda (
	codigo_moneda CHAR(3) NOT NULL,
	nombre_moneda VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Moneda PRIMARY KEY (codigo_moneda)
	);
GO

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

CREATE TABLE Participantes.Confederacion (
	id_confederacion INT IDENTITY(1,1),
	nombre_confederacion VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Confederacion PRIMARY KEY (id_confederacion),
	CONSTRAINT UQ_Confederacion_Nombre UNIQUE (nombre_confederacion)
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
	CONSTRAINT FK_Seleccion_Grupo FOREIGN KEY (id_grupo) REFERENCES Torneo.Grupo(id_grupo)
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

CREATE TABLE Participantes.Club_origen (
	id_club INT IDENTITY(1,1),
	nombre VARCHAR(50) NOT NULL,
	id_pais_club INT NOT NULL,

	CONSTRAINT PK_Club PRIMARY KEY (id_club),
	CONSTRAINT FK_Club_Pais FOREIGN KEY (id_pais_club) REFERENCES Participantes.Pais(id_pais),
	CONSTRAINT UQ_Club_Pais_Nombre UNIQUE (id_pais_club, nombre)
);
GO

CREATE TABLE Participantes.Posicion (
	id_posicion INT IDENTITY(1,1),
	nombre_posicion VARCHAR(30) NOT NULL,

	CONSTRAINT PK_posicion PRIMARY KEY (id_posicion),
	CONSTRAINT UQ_Posicion_Nombre UNIQUE (nombre_posicion)
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

CREATE TABLE Participantes.Categoria_arbitro (
	id_categoria INT IDENTITY(1,1),
	descripcion VARCHAR(50) NOT NULL,

	CONSTRAINT PK_Categoria_Arbitro PRIMARY KEY (id_categoria),
	CONSTRAINT UQ_Categoria_Arbitro_Descripcion UNIQUE (descripcion)
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

CREATE TABLE Participantes.Idioma_arbitro (
	id_arbitro INT NOT NULL,
	id_idioma INT NOT NULL,

	CONSTRAINT PK_Idioma_Arbitro PRIMARY KEY (id_arbitro, id_idioma),
	CONSTRAINT FK_IdiomaArbitro_Arbitro FOREIGN KEY (id_arbitro) REFERENCES Participantes.Arbitro (id_arbitro),
	CONSTRAINT FK_IdiomaArbitro_Idioma FOREIGN KEY (id_idioma) REFERENCES Participantes.Idioma (id_idioma)
);
GO