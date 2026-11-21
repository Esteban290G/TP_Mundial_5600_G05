-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 8 - Prueba de permisos del usuario usr_cargador (rol_cargador_resultados)
------------------------------------------
-- El cargador de resultados registra con los SP lo que pasa en cada partido (planillas, goles, tarjetas,
-- sustituciones y resultado) y consulta los reportes deportivos. No escribe directamente en las tablas, no lee
-- datos personales sin la frase clave y no accede a la publicidad.
--
-- Cada prueba se ejecuta con la identidad del usuario (EXECUTE AS USER) y se clasifica según el error:
--   - Permitido: la operación se completó, o el SP llegó a sus propias validaciones (error 50001), lo que
--     demuestra que el usuario tiene permiso para ejecutarlo.
--   - Denegado: SQL Server rechazó la operación por permisos (errores 229, 230, 262, 297, 300, 15151 y 15247).
-- Las operaciones que modifican datos se hacen dentro de una transacción que se deshace (ROLLBACK), así la prueba
-- no cambia la base. Al final se muestra el cuadro de resultados: la columna "coincide" debe ser 'Sí' en todas.
-- Requiere haber ejecutado los scripts 00 a 22 (datos del script 17 y usuarios del script 22).
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
EXECUTE AS USER = 'usr_cargador';

SELECT USER_NAME() AS usuario_actual, IS_ROLEMEMBER('rol_cargador_resultados') AS pertenece_al_rol;

-- Prueba 01: Lectura de partidos (Torneo.Partido)
-- Resultado esperado: Permitido
BEGIN TRY
    SELECT TOP (3) id_partido, fecha_hora_local, goles_local, goles_visitante FROM Torneo.Partido ORDER BY id_partido;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Lectura de partidos (Torneo.Partido)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Lectura de partidos (Torneo.Partido)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 02: Registro de un gol (Registrar_Gol_Partido)
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

-- Prueba 03: Registro de tarjeta con partido inexistente (valida el SP)
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = -1, @id_convocatoria = @id_autor, @id_tipo_tarjeta = @id_tipo_tarjeta,
         @id_motivo_tarjeta = @id_motivo, @id_periodo_partido = @id_periodo, @minuto = 10;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Registro de tarjeta con partido inexistente (valida el SP)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Registro de tarjeta con partido inexistente (valida el SP)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 04: Carga del resultado y la asistencia (Modificacion_Partido)
-- Resultado esperado: Permitido
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC Torneo.Modificacion_Partido @id_partido = @id_partido, @goles_local = 4, @goles_visitante = 2;
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Carga del resultado y la asistencia (Modificacion_Partido)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Carga del resultado y la asistencia (Modificacion_Partido)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 05: Reporte de resultados del grupo L
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Reporte_Resultados @nombre_grupo = 'L';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de resultados del grupo L', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de resultados del grupo L', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 06: Consulta descifrada de jugadores de Argentina
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Participantes.Consultar_Jugadores @frase_clave = N'G05_Clave', @id_seleccion = @id_sel_arg;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Consulta descifrada de jugadores de Argentina', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Consulta descifrada de jugadores de Argentina', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 07: Lectura directa de datos personales (Jugador)
-- Resultado esperado: Denegado
BEGIN TRY
    SELECT TOP (1) nombre, apellido FROM Participantes.Jugador;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Lectura directa de datos personales (Jugador)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Lectura directa de datos personales (Jugador)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 08: Escritura directa en una tabla (DELETE Torneo.Gol)
-- Resultado esperado: Denegado
BEGIN TRY
    DELETE FROM Torneo.Gol WHERE 1 = 0;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Escritura directa en una tabla (DELETE Torneo.Gol)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Escritura directa en una tabla (DELETE Torneo.Gol)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 09: Modificación directa del resultado (UPDATE Torneo.Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    UPDATE Torneo.Partido SET goles_local = goles_local WHERE 1 = 0;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Modificación directa del resultado (UPDATE Torneo.Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Modificación directa del resultado (UPDATE Torneo.Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 10: Alta de jugadores (Alta_Jugador)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Participantes.Alta_Jugador @nombre = 'Prueba', @apellido = 'Cargador', @fecha_nacimiento = '20000101',
         @id_pais_nacimiento = @id_pais_arg, @id_posicion_habitual = 1, @id_club_origen = 1;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Alta de jugadores (Alta_Jugador)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Alta de jugadores (Alta_Jugador)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 11: Designación de árbitros (Asignar_Arbitro_Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Torneo.Asignar_Arbitro_Partido @id_partido = @id_partido, @id_rol_arbitro = @id_rol_principal, @id_arbitro = @id_arbitro;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Designación de árbitros (Asignar_Arbitro_Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Designación de árbitros (Asignar_Arbitro_Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 12: Asignación de publicidad (Asignar_Publicidad_Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Publicidad.Asignar_Publicidad_Partido @id_partido = @id_partido;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Asignación de publicidad (Asignar_Publicidad_Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Asignación de publicidad (Asignar_Publicidad_Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 13: Lectura de anunciantes (Publicidad.Anunciante)
-- Resultado esperado: Denegado
BEGIN TRY
    SELECT TOP (1) nombre_anunciante FROM Publicidad.Anunciante;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Lectura de anunciantes (Publicidad.Anunciante)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Lectura de anunciantes (Publicidad.Anunciante)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 14: Cifrado de datos (Cifrar_Datos_Sensibles)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Torneo.Cifrar_Datos_Sensibles @frase_clave = N'G05_Clave';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Cifrado de datos (Cifrar_Datos_Sensibles)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Cifrado de datos (Cifrar_Datos_Sensibles)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
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
