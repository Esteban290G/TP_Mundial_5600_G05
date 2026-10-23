-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes: 
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
-- Creacion de la base de datos --
------------------------------------------

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'COM5600_G05')
BEGIN
	ALTER DATABASE COM5600_G05 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE COM5600_G05;
END
GO

IF DB_ID('COM5600_G05') IS NULL
	CREATE DATABASE COM5600_G05
	COLLATE Modern_Spanish_CI_AI;
GO

USE COM5600_G05;
GO

------------------------------------------
-- Creacion de esquemas --

IF SCHEMA_ID('Torneo') IS NULL
    EXEC('CREATE SCHEMA Torneo');
GO

IF SCHEMA_ID('Participantes') IS NULL
    EXEC('CREATE SCHEMA Participantes');
GO

IF SCHEMA_ID('Publicidad') IS NULL
    EXEC('CREATE SCHEMA Publicidad');
GO