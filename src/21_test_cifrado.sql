-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Pruebas del cifrado de datos sensibles
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------

DECLARE @clave_ok NVARCHAR(128) = N'G05_Clave';
DECLARE @clave_mal NVARCHAR(128) = N'ClaveIncorrecta';
DECLARE @id_arg INT = (
    SELECT S.id_seleccion
    FROM Participantes.Seleccion S
    INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais
    WHERE P.codigo_iso = 'ARG'
);

------------------------------------------
-- Test 01: Lectura directa de las columnas cifradas (formato binario VARBINARY)
SELECT TOP 5 id_jugador, nombre_cifrado, apellido_cifrado, fecha_nacimiento_cifrada
FROM Participantes.Jugador;

SELECT TOP 5 id_arbitro, nombre_cifrado, apellido_cifrado, fecha_nacimiento_cifrada
FROM Participantes.Arbitro;

SELECT TOP 5 id_integrante_ct, nombre_cifrado, apellido_cifrado, cargo_rol
FROM Participantes.Integrante_cuerpo_tecnico;

------------------------------------------
-- Test 02: Consulta descifrada de Jugadores (clave correcta, filtro por selección y clave incorrecta)
-- Resultado esperado: con @clave_ok muestra datos legibles; con @clave_mal devuelve NULL en los campos cifrados.
EXEC Participantes.Consultar_Jugadores @frase_clave = @clave_ok;
EXEC Participantes.Consultar_Jugadores @frase_clave = @clave_ok, @id_seleccion = @id_arg;
EXEC Participantes.Consultar_Jugadores @frase_clave = @clave_mal, @id_seleccion = @id_arg;

------------------------------------------
-- Test 03: Consulta descifrada de Árbitros (clave correcta y clave incorrecta)
EXEC Participantes.Consultar_Arbitros @frase_clave = @clave_ok;
EXEC Participantes.Consultar_Arbitros @frase_clave = @clave_mal;

------------------------------------------
-- Test 04: Consulta descifrada de Cuerpo Técnico (clave correcta, filtro por selección y clave incorrecta)
EXEC Participantes.Consultar_Cuerpo_Tecnico @frase_clave = @clave_ok;
EXEC Participantes.Consultar_Cuerpo_Tecnico @frase_clave = @clave_ok, @id_seleccion = @id_arg;
EXEC Participantes.Consultar_Cuerpo_Tecnico @frase_clave = @clave_mal, @id_seleccion = @id_arg;
GO

------------------------------------------
-- Test 05: Validaciones de error por frase clave vacía
EXEC Participantes.Consultar_Jugadores @frase_clave = N'';
GO

EXEC Torneo.Cifrar_Datos_Sensibles @frase_clave = N'';
GO