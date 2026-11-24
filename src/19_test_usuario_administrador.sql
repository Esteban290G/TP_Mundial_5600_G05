-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 8 - Prueba de permisos del usuario usr_administrador (rol_administrador)
------------------------------------------
-- El administrador lee y modifica los datos de los tres esquemas (también en forma directa) y ejecuta todos los SP,
-- pero no administra la seguridad (esquema Seguridad, roles, objetos nuevos).
--
-- Cada prueba se ejecuta con la identidad del usuario (EXECUTE AS USER) y se clasifica según el error:
--   - Permitido: la operación se completó, o el SP llegó a sus propias validaciones (error 50001), lo que
--     demuestra que el usuario tiene permiso para ejecutarlo.
--   - Denegado: SQL Server rechazó la operación por permisos (errores 229, 230, 262, 297, 300, 15151 y 15247).
-- Las operaciones que modifican datos se hacen dentro de una transacción que se deshace (ROLLBACK), así la prueba
-- no cambia la base. Al final se muestra el cuadro de resultados: la columna "coincide" debe ser 'Sí' en todas.
------------------------------------------

USE COM5600_G05;
GO

SET NOCOUNT ON;

DECLARE @r TABLE (
    nro INT IDENTITY(1,1),
    prueba VARCHAR(120),
    esperado VARCHAR(10),
    obtenido VARCHAR(10),
    detalle NVARCHAR(400)
);

-- Datos de referencia (se leen antes de cambiar de usuario)
DECLARE @id_partido INT = (SELECT TOP 1 P.id_partido FROM Torneo.Partido P
                           INNER JOIN Participantes.Seleccion SL ON SL.id_seleccion = P.id_seleccion_local
                           INNER JOIN Participantes.Pais PL ON PL.id_pais = SL.id_pais
                           INNER JOIN Participantes.Seleccion SV ON SV.id_seleccion = P.id_seleccion_visitante
                           INNER JOIN Participantes.Pais PV ON PV.id_pais = SV.id_pais
                           WHERE PL.codigo_iso = 'ENG' AND PV.codigo_iso = 'HRV'
                           ORDER BY P.id_partido);
DECLARE @id_autor INT = (SELECT TOP 1 D.id_convocatoria
                         FROM Torneo.Alineacion_partido A
                         INNER JOIN Torneo.Detalle_alineacion_jugador D ON D.id_alineacion_partido = A.id_alineacion_partido
                         INNER JOIN Torneo.Partido P ON P.id_partido = A.id_partido
                         WHERE A.id_partido = @id_partido AND A.id_seleccion = P.id_seleccion_local AND D.es_titular = 1
                         ORDER BY D.id_convocatoria);
DECLARE @id_tipo_gol INT = (SELECT TOP 1 id_tipo FROM Torneo.Tipo_gol ORDER BY id_tipo);
DECLARE @id_periodo INT = (SELECT TOP 1 id_periodo_partido FROM Torneo.Periodo_partido ORDER BY id_periodo_partido);
DECLARE @id_tipo_tarjeta INT = (SELECT TOP 1 id_tipo_tarjeta FROM Torneo.Tipo_tarjeta ORDER BY id_tipo_tarjeta);
DECLARE @id_motivo INT = (SELECT TOP 1 id_motivo FROM Torneo.Motivo_tarjeta ORDER BY id_motivo);
DECLARE @id_pais_arg INT = (SELECT id_pais FROM Participantes.Pais WHERE codigo_iso = 'ARG');
DECLARE @id_sel_arg INT = (SELECT id_seleccion FROM Participantes.Seleccion WHERE id_pais = @id_pais_arg);
DECLARE @id_rol_principal INT = (SELECT TOP 1 id_rol_arbitro FROM Participantes.Rol_arbitro ORDER BY id_rol_arbitro);
DECLARE @id_arbitro INT = (SELECT TOP 1 id_arbitro FROM Participantes.Arbitro ORDER BY id_arbitro);
DECLARE @id_fase_final INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Final');

------------------------------------------
-- Cambio de identidad
------------------------------------------
EXECUTE AS USER = 'usr_administrador';

SELECT USER_NAME() AS usuario_actual, IS_ROLEMEMBER('rol_administrador') AS pertenece_al_rol;

-- Prueba 01: Lectura directa de datos personales (Jugador)
-- Resultado esperado: Permitido
BEGIN TRY
    SELECT TOP (3) id_jugador, nombre, apellido, nombre_cifrado FROM Participantes.Jugador ORDER BY id_jugador;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Lectura directa de datos personales (Jugador)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Lectura directa de datos personales (Jugador)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 02: Consulta descifrada de árbitros con la frase clave
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Participantes.Consultar_Arbitros @frase_clave = N'G05_Clave';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Consulta descifrada de árbitros con la frase clave', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Consulta descifrada de árbitros con la frase clave', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 03: Actualización directa de una tabla (Pais)
-- Resultado esperado: Permitido
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE Participantes.Pais SET pbi_per_capita = pbi_per_capita WHERE id_pais = @id_pais_arg;
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Actualización directa de una tabla (Pais)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Actualización directa de una tabla (Pais)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 04: Alta con SP (Alta_Moneda)
-- Resultado esperado: Permitido
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC Participantes.Alta_Moneda @codigo_moneda = 'XTS', @nombre_moneda = 'Moneda de prueba';
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Alta con SP (Alta_Moneda)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Alta con SP (Alta_Moneda)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 05: Registro de un gol (Registrar_Gol_Partido)
-- Resultado esperado: Permitido
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC Torneo.Registrar_Gol_Partido @id_convocatoria_autor = @id_autor, @id_convocatoria_asistencia = NULL,
         @id_tipo_gol = @id_tipo_gol, @id_periodo_partido = @id_periodo, @id_partido = @id_partido, @minuto = 90;
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Registro de un gol (Registrar_Gol_Partido)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Registro de un gol (Registrar_Gol_Partido)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 06: Asignación de publicidad (ya asignada: valida el SP)
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @id_partido;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Asignación de publicidad (ya asignada: valida el SP)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Asignación de publicidad (ya asignada: valida el SP)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 07: Reporte de goleadores
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Reporte_Goleadores;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de goleadores', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de goleadores', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 08: Crear usuarios (Seguridad.Crear_Usuario_Rol)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_intruso', @rol = 'rol_administrador';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Crear usuarios (Seguridad.Crear_Usuario_Rol)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Crear usuarios (Seguridad.Crear_Usuario_Rol)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 09: Ver el cuadro de permisos (Seguridad.Reporte_Permisos_Roles)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Seguridad.Reporte_Permisos_Roles;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Ver el cuadro de permisos (Seguridad.Reporte_Permisos_Roles)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Ver el cuadro de permisos (Seguridad.Reporte_Permisos_Roles)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 10: Agregarse a otro rol (ALTER ROLE)
-- Resultado esperado: Denegado
BEGIN TRY
    ALTER ROLE rol_consulta ADD MEMBER usr_administrador;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Agregarse a otro rol (ALTER ROLE)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Agregarse a otro rol (ALTER ROLE)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 11: Crear una tabla nueva (CREATE TABLE)
-- Resultado esperado: Denegado
BEGIN TRY
    CREATE TABLE dbo.Tabla_Prueba_Admin (id INT);
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Crear una tabla nueva (CREATE TABLE)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Crear una tabla nueva (CREATE TABLE)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

------------------------------------------
-- Fin: se vuelve a la identidad original y se muestra el cuadro de resultados
------------------------------------------
REVERT;

SELECT nro, prueba, esperado, obtenido,
       CASE WHEN esperado = obtenido THEN 'Sí' ELSE 'NO' END AS coincide,
       detalle
FROM @r
ORDER BY nro;
GO
