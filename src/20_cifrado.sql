-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Cifrado de datos sensibles.
-- - Tablas afectadas: Participantes.Jugador, Participantes.Arbitro y Participantes.Integrante_cuerpo_tecnico.
-- - Se agregan columnas cifradas VARBINARY(256)
-- - Se crean SPs de cifrado y de consulta descifrada sobre las columnas cifradas.
-- - Clave de cifrado utilizada en la carga inicial: 'G05_Clave'
-- NOTA: Ejecutar luego de los scripts previos.
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- AGREGADO DE COLUMNAS CIFRADAS (VARBINARY(256))
------------------------------------------

ALTER TABLE Participantes.Jugador
ADD nombre_cifrado VARBINARY(256) NULL,
    apellido_cifrado VARBINARY(256) NULL,
    fecha_nacimiento_cifrada VARBINARY(256) NULL;

ALTER TABLE Participantes.Arbitro
ADD nombre_cifrado VARBINARY(256) NULL,
    apellido_cifrado VARBINARY(256) NULL,
    fecha_nacimiento_cifrada VARBINARY(256) NULL;

ALTER TABLE Participantes.Integrante_cuerpo_tecnico
ADD nombre_cifrado VARBINARY(256) NULL,
    apellido_cifrado VARBINARY(256) NULL;
GO

------------------------------------------
-- SP PARA CIFRAR LOS DATOS SENSIBLES
------------------------------------------
-- Procedimiento: Torneo.Cifrar_Datos_Sensibles
-- Descripción: Cifra con EncryptByPassPhrase (autenticador = PK) los datos personales
--              de Participantes.Jugador (nombre, apellido, fecha_nacimiento),
--              Participantes.Arbitro (nombre, apellido, fecha_nacimiento) y
--              Participantes.Integrante_cuerpo_tecnico (nombre, apellido) en una
--              única transacción.
-- Parámetros: @frase_clave: frase clave utilizada para cifrar las columnas VARBINARY(256).
-- Validaciones: Frase clave nula o vacía.

CREATE OR ALTER PROCEDURE Torneo.Cifrar_Datos_Sensibles
    @frase_clave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@frase_clave IS NULL OR LTRIM(RTRIM(@frase_clave)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la frase clave para cifrar los datos. ', 1;
        RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Participantes.Jugador
        SET nombre_cifrado = EncryptByPassPhrase(@frase_clave, CAST(nombre AS VARCHAR(30)), 1, CONVERT(VARBINARY, id_jugador)),
            apellido_cifrado = EncryptByPassPhrase(@frase_clave, CAST(apellido AS VARCHAR(30)), 1, CONVERT(VARBINARY, id_jugador)),
            fecha_nacimiento_cifrada = EncryptByPassPhrase(@frase_clave, CONVERT(VARCHAR(10), fecha_nacimiento, 120), 1, CONVERT(VARBINARY, id_jugador));

        UPDATE Participantes.Arbitro
        SET nombre_cifrado = EncryptByPassPhrase(@frase_clave, CAST(nombre AS VARCHAR(50)), 1, CONVERT(VARBINARY, id_arbitro)),
            apellido_cifrado = EncryptByPassPhrase(@frase_clave, CAST(apellido AS VARCHAR(50)), 1, CONVERT(VARBINARY, id_arbitro)),
            fecha_nacimiento_cifrada = EncryptByPassPhrase(@frase_clave, CONVERT(VARCHAR(10), fecha_nacimiento, 120), 1, CONVERT(VARBINARY, id_arbitro));

        UPDATE Participantes.Integrante_cuerpo_tecnico
        SET nombre_cifrado = EncryptByPassPhrase(@frase_clave, CAST(nombre AS VARCHAR(30)), 1, CONVERT(VARBINARY, id_integrante_ct)),
            apellido_cifrado = EncryptByPassPhrase(@frase_clave, CAST(apellido AS VARCHAR(30)), 1, CONVERT(VARBINARY, id_integrante_ct));

        COMMIT TRANSACTION;
        PRINT 'Cifrado completado correctamente en Jugador, Arbitro e Integrante_cuerpo_tecnico.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT           = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

-- Ejecución de cifrado sobre los registros ya cargados
EXEC Torneo.Cifrar_Datos_Sensibles @frase_clave = N'G05_Clave';
GO

------------------------------------------
-- SPs DE CONSULTA SOBRE LOS CAMPOS CIFRADOS
------------------------------------------
-- Procedimiento: Participantes.Consultar_Jugadores
-- Descripción: Consulta los datos personales de los jugadores descifrando nombre, apellido
--              y fecha de nacimiento desde sus columnas cifradas. Permite filtrar por selección.
--              Si la frase clave no coincide, los campos protegidos retornan NULL.
-- Validaciones: Frase clave nula o vacía.

CREATE OR ALTER PROCEDURE Participantes.Consultar_Jugadores
    @frase_clave NVARCHAR(128),
    @id_seleccion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@frase_clave IS NULL OR LTRIM(RTRIM(@frase_clave)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la frase clave de cifrado. ', 1;
        RETURN;
    END

    SELECT
        J.id_jugador,
        CAST(DecryptByPassPhrase(@frase_clave, J.nombre_cifrado, 1, CONVERT(VARBINARY, J.id_jugador)) AS VARCHAR(30)) AS nombre,
        CAST(DecryptByPassPhrase(@frase_clave, J.apellido_cifrado, 1, CONVERT(VARBINARY, J.id_jugador)) AS VARCHAR(30)) AS apellido,
        TRY_CONVERT(DATE, CAST(DecryptByPassPhrase(@frase_clave, J.fecha_nacimiento_cifrada, 1, CONVERT(VARBINARY, J.id_jugador)) AS VARCHAR(10)), 120) AS fecha_nacimiento,
        P.nombre AS pais_nacimiento,
        PO.nombre_posicion AS posicion,
        CL.nombre AS club,
        S.nombre_seleccion AS seleccion
    FROM Participantes.Jugador J
    INNER JOIN Participantes.Pais P ON P.id_pais = J.id_pais_nacimiento
    INNER JOIN Participantes.Posicion PO ON PO.id_posicion = J.id_posicion_habitual
    INNER JOIN Participantes.Club_origen CL ON CL.id_club = J.id_club_origen
    LEFT JOIN Participantes.Convocatoria C ON C.id_jugador = J.id_jugador
    LEFT JOIN Participantes.Seleccion S ON S.id_seleccion = C.id_seleccion
    WHERE (@id_seleccion IS NULL OR C.id_seleccion = @id_seleccion)
    ORDER BY seleccion, apellido, nombre;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Consultar_Arbitros
-- Descripción: Consulta los datos personales de los árbitros descifrando nombre, apellido
--              y fecha de nacimiento desde sus columnas cifradas.
--              Si la frase clave no coincide, los campos protegidos retornan NULL.
-- Validaciones: Frase clave nula o vacía.

CREATE OR ALTER PROCEDURE Participantes.Consultar_Arbitros
    @frase_clave NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@frase_clave IS NULL OR LTRIM(RTRIM(@frase_clave)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la frase clave de cifrado. ', 1;
        RETURN;
    END

    SELECT
        A.id_arbitro,
        CAST(DecryptByPassPhrase(@frase_clave, A.nombre_cifrado, 1, CONVERT(VARBINARY, A.id_arbitro)) AS VARCHAR(50)) AS nombre,
        CAST(DecryptByPassPhrase(@frase_clave, A.apellido_cifrado, 1, CONVERT(VARBINARY, A.id_arbitro)) AS VARCHAR(50)) AS apellido,
        TRY_CONVERT(DATE, CAST(DecryptByPassPhrase(@frase_clave, A.fecha_nacimiento_cifrada, 1, CONVERT(VARBINARY, A.id_arbitro)) AS VARCHAR(10)), 120) AS fecha_nacimiento,
        P.nombre AS pais,
        CA.descripcion AS categoria
    FROM Participantes.Arbitro A
    INNER JOIN Participantes.Pais P ON P.id_pais = A.id_pais
    INNER JOIN Participantes.Categoria_arbitro CA ON CA.id_categoria = A.id_categoria
    ORDER BY apellido, nombre;
END;
GO

------------------------------------------
-- Procedimiento: Participantes.Consultar_Cuerpo_Tecnico
-- Descripción: Consulta los integrantes de cuerpos técnicos descifrando nombre y apellido
--              desde sus columnas cifradas. Permite filtrar por selección.
--              Si la frase clave no coincide, los campos protegidos retornan NULL.
-- Validaciones: Frase clave nula o vacía.

CREATE OR ALTER PROCEDURE Participantes.Consultar_Cuerpo_Tecnico
    @frase_clave NVARCHAR(128),
    @id_seleccion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@frase_clave IS NULL OR LTRIM(RTRIM(@frase_clave)) = '')
    BEGIN
        ;THROW 50001, '- Debe indicarse la frase clave de cifrado. ', 1;
        RETURN;
    END

    SELECT
        I.id_integrante_ct,
        S.nombre_seleccion AS seleccion,
        CAST(DecryptByPassPhrase(@frase_clave, I.nombre_cifrado, 1, CONVERT(VARBINARY, I.id_integrante_ct)) AS VARCHAR(30)) AS nombre,
        CAST(DecryptByPassPhrase(@frase_clave, I.apellido_cifrado, 1, CONVERT(VARBINARY, I.id_integrante_ct)) AS VARCHAR(30)) AS apellido,
        I.cargo_rol
    FROM Participantes.Integrante_cuerpo_tecnico I
    INNER JOIN Participantes.Seleccion S ON S.id_seleccion = I.id_seleccion
    WHERE (@id_seleccion IS NULL OR I.id_seleccion = @id_seleccion)
    ORDER BY seleccion, I.cargo_rol, apellido, nombre;
END;
GO