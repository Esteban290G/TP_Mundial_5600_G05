-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 8 - Prueba de permisos del usuario usr_consulta (rol_consulta)
------------------------------------------
-- El usuario de consulta solo ejecuta los reportes de la Entrega 7. No modifica datos, no ejecuta otros SP y no
-- lee tablas con datos personales.
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
EXECUTE AS USER = 'usr_consulta';

SELECT USER_NAME() AS usuario_actual, IS_ROLEMEMBER('rol_consulta') AS pertenece_al_rol;

-- Prueba 01: Reporte de goleadores
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

-- Prueba 02: Reporte de tarjetas y suspensiones
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Reporte_Tarjetas_Suspensiones;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de tarjetas y suspensiones', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de tarjetas y suspensiones', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 03: Reporte de designaciones arbitrales (XML)
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Reporte_Designaciones_Arbitrales;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de designaciones arbitrales (XML)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de designaciones arbitrales (XML)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 04: Reporte de resultados del grupo J
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Torneo.Reporte_Resultados @nombre_grupo = 'J';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de resultados del grupo J', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de resultados del grupo J', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 05: Reporte de selecciones y plantillas del grupo L (XML)
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Participantes.Reporte_Selecciones_Plantillas @nombre_grupo = 'L';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de selecciones y plantillas del grupo L (XML)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de selecciones y plantillas del grupo L (XML)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 06: Reporte de ocupación publicitaria
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Publicidad.Reporte_Ocupacion_Publicitaria;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Reporte de ocupación publicitaria', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Reporte de ocupación publicitaria', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 07: Matriz de prime time de la final (SQL dinámico)
-- Resultado esperado: Permitido
BEGIN TRY
    EXEC Publicidad.Reporte_Matriz_Prime_Time @id_fase = @id_fase_final;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Matriz de prime time de la final (SQL dinámico)', 'Permitido', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Matriz de prime time de la final (SQL dinámico)', 'Permitido', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 08: Lectura directa de datos personales (Jugador)
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

-- Prueba 09: Consulta descifrada de jugadores (Consultar_Jugadores)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Participantes.Consultar_Jugadores @frase_clave = N'G05_Clave';
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Consulta descifrada de jugadores (Consultar_Jugadores)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Consulta descifrada de jugadores (Consultar_Jugadores)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 10: Registro de una tarjeta (Registrar_Tarjeta_Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Torneo.Registrar_Tarjeta_Partido @id_partido = -1, @id_convocatoria = @id_autor, @id_tipo_tarjeta = @id_tipo_tarjeta,
         @id_motivo_tarjeta = @id_motivo, @id_periodo_partido = @id_periodo, @minuto = 10;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Registro de una tarjeta (Registrar_Tarjeta_Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Registro de una tarjeta (Registrar_Tarjeta_Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 11: Modificación directa de un partido (UPDATE Torneo.Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    UPDATE Torneo.Partido SET goles_local = goles_local WHERE 1 = 0;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Modificación directa de un partido (UPDATE Torneo.Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Modificación directa de un partido (UPDATE Torneo.Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 12: Alta de un anunciante (Alta_Anunciante)
-- Resultado esperado: Denegado
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC Publicidad.Alta_Anunciante @nombre_anunciante = 'Anunciante de prueba G05', @id_pais_origen = @id_pais_arg,
         @identificacion_fiscal = 'CUIT 30-99999999-9';
    ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Alta de un anunciante (Alta_Anunciante)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Alta de un anunciante (Alta_Anunciante)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 13: Simulación de prime time (Simular_Prime_Time_Partido)
-- Resultado esperado: Denegado
BEGIN TRY
    EXEC Publicidad.Simular_Prime_Time_Partido @id_partido = @id_partido;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Simulación de prime time (Simular_Prime_Time_Partido)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Simulación de prime time (Simular_Prime_Time_Partido)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
            CONCAT('Error ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()));
END CATCH;

-- Prueba 14: Lectura de goles (Torneo.Gol)
-- Resultado esperado: Denegado
BEGIN TRY
    SELECT TOP (1) id_gol FROM Torneo.Gol;
    INSERT INTO @r (prueba, esperado, obtenido, detalle) VALUES ('Lectura de goles (Torneo.Gol)', 'Denegado', 'Permitido', 'Operación completada');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO @r (prueba, esperado, obtenido, detalle)
    VALUES ('Lectura de goles (Torneo.Gol)', 'Denegado', CASE WHEN ERROR_NUMBER() IN (229, 230, 262, 297, 300, 15151, 15247) THEN 'Denegado' ELSE 'Permitido' END,
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
