-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Entrega 8 - Roles de seguridad
------------------------------------------
-- Crea el esquema Seguridad y sus SP:
--   - Seguridad.Configurar_Roles: crea los 4 roles y les asigna permisos granulares.
--   - Seguridad.Crear_Usuario_Rol: crea un login y un usuario (o un usuario sin login) y lo agrega a un rol.
--   - Seguridad.Reporte_Permisos_Roles: muestra el cuadro de permisos de cada rol y sus miembros.
--
-- Roles:
--   rol_administrador        Administra los datos de los tres esquemas (lectura y escritura directa, todos los SP).
--   rol_cargador_resultados  Carga planillas, goles, tarjetas, sustituciones y resultados de los partidos, solo con SP.
--   rol_gestor_publicidad    Administra anunciantes, campañas, piezas y la asignación de publicidad, solo con SP.
--   rol_consulta             Solo ejecuta los reportes.
--
-- Criterios comunes:
--   - Salvo el administrador, nadie escribe directamente en las tablas: INSERT, UPDATE y DELETE quedan denegados y
--     las altas, bajas y modificaciones se hacen con los SP (que acceden a las tablas por encadenamiento de propiedad).
--   - Las tablas con datos personales (Jugador, Arbitro, Integrante_cuerpo_tecnico) no se pueden leer directamente
--     salvo el administrador. Los datos cifrados se consultan con los SP de consulta del script 20 y la frase clave.
--   - La creación de logins, la importación de archivos (BULK INSERT) y el consumo de APIs (Ole Automation) requieren
--     permisos de servidor: los ejecuta el DBA (sysadmin), no estos roles.
--
-- Se ejecuta después de los scripts 00 a 21. Los usuarios de prueba se crean al final de este script.
------------------------------------------

USE COM5600_G05;
GO

IF SCHEMA_ID('Seguridad') IS NULL
    EXEC('CREATE SCHEMA Seguridad');
GO

------------------------------------------
-- Procedimiento: Seguridad.Configurar_Roles
-- Descripción: Crea los roles que no existan y les asigna los permisos. Se puede ejecutar más de una vez:
--              GRANT y DENY no duplican permisos. Los permisos sobre objetos puntuales solo se asignan si el
--              objeto existe.
------------------------------------------

CREATE OR ALTER PROCEDURE Seguridad.Configurar_Roles
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        ------------------------------------------
        -- Roles
        IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL CREATE ROLE rol_administrador;
        IF DATABASE_PRINCIPAL_ID('rol_cargador_resultados') IS NULL CREATE ROLE rol_cargador_resultados;
        IF DATABASE_PRINCIPAL_ID('rol_gestor_publicidad') IS NULL CREATE ROLE rol_gestor_publicidad;
        IF DATABASE_PRINCIPAL_ID('rol_consulta') IS NULL CREATE ROLE rol_consulta;

        ------------------------------------------
        -- rol_administrador: control total sobre los esquemas de datos (no sobre Seguridad)
        GRANT CONTROL ON SCHEMA::Torneo TO rol_administrador;
        GRANT CONTROL ON SCHEMA::Participantes TO rol_administrador;
        GRANT CONTROL ON SCHEMA::Publicidad TO rol_administrador;

        ------------------------------------------
        -- rol_cargador_resultados
        -- Lectura del torneo (partidos, alineaciones, goles, tarjetas, catálogos) y de las convocatorias
        GRANT SELECT ON SCHEMA::Torneo TO rol_cargador_resultados;
        GRANT SELECT ON OBJECT::Participantes.Seleccion TO rol_cargador_resultados;
        GRANT SELECT ON OBJECT::Participantes.Convocatoria TO rol_cargador_resultados;
        GRANT SELECT ON OBJECT::Participantes.Posicion TO rol_cargador_resultados;
        GRANT SELECT ON OBJECT::Participantes.Pais TO rol_cargador_resultados;

        -- Carga de lo que pasa en el partido, solo con SP
        IF OBJECT_ID('Torneo.Alta_Alineacion_partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Alta_Alineacion_partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Alineacion_partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Alineacion_partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Baja_Alineacion_partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Baja_Alineacion_partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Confirmar_Planilla_Jugador', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Confirmar_Planilla_Jugador TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Detalle_alineacion_jugador', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Detalle_alineacion_jugador TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Baja_Detalle_alineacion_jugador', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Baja_Detalle_alineacion_jugador TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Registrar_Gol_Partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Registrar_Gol_Partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Gol', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Gol TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Baja_Gol', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Baja_Gol TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Registrar_Tarjeta_Partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Registrar_Tarjeta_Partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Tarjeta', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Tarjeta TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Baja_Tarjeta', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Baja_Tarjeta TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Registrar_Sustitucion_Partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Registrar_Sustitucion_Partido TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Sustitucion', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Sustitucion TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Baja_Sustitucion', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Baja_Sustitucion TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Modificacion_Partido', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Modificacion_Partido TO rol_cargador_resultados;

        -- Reportes deportivos y consulta de jugadores con la frase clave del cifrado
        IF OBJECT_ID('Torneo.Reporte_Goleadores', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Goleadores TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Reporte_Tarjetas_Suspensiones', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Tarjetas_Suspensiones TO rol_cargador_resultados;
        IF OBJECT_ID('Torneo.Reporte_Resultados', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Resultados TO rol_cargador_resultados;
        IF OBJECT_ID('Participantes.Consultar_Jugadores', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Participantes.Consultar_Jugadores TO rol_cargador_resultados;

        -- Restricciones
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Torneo TO rol_cargador_resultados;
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Participantes TO rol_cargador_resultados;
        DENY SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Publicidad TO rol_cargador_resultados;
        DENY SELECT ON OBJECT::Participantes.Jugador TO rol_cargador_resultados;
        DENY SELECT ON OBJECT::Participantes.Arbitro TO rol_cargador_resultados;
        DENY SELECT ON OBJECT::Participantes.Integrante_cuerpo_tecnico TO rol_cargador_resultados;

        ------------------------------------------
        -- rol_gestor_publicidad
        -- Todo el esquema Publicidad por SP (ABM, asignación, simulación de prime time y reportes de publicidad)
        GRANT SELECT, EXECUTE ON SCHEMA::Publicidad TO rol_gestor_publicidad;
        -- Datos de referencia que necesita para planificar (partidos, sedes, fases, selecciones, mercados)
        GRANT SELECT ON OBJECT::Torneo.Partido TO rol_gestor_publicidad;
        GRANT SELECT ON OBJECT::Torneo.Sede TO rol_gestor_publicidad;
        GRANT SELECT ON OBJECT::Torneo.Fase TO rol_gestor_publicidad;
        GRANT SELECT ON OBJECT::Participantes.Seleccion TO rol_gestor_publicidad;
        GRANT SELECT ON OBJECT::Participantes.Pais TO rol_gestor_publicidad;
        GRANT SELECT ON OBJECT::Participantes.Idioma TO rol_gestor_publicidad;

        -- Restricciones
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Publicidad TO rol_gestor_publicidad;
        DENY INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Torneo TO rol_gestor_publicidad;
        DENY INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::Participantes TO rol_gestor_publicidad;
        DENY SELECT ON OBJECT::Participantes.Jugador TO rol_gestor_publicidad;
        DENY SELECT ON OBJECT::Participantes.Arbitro TO rol_gestor_publicidad;
        DENY SELECT ON OBJECT::Participantes.Integrante_cuerpo_tecnico TO rol_gestor_publicidad;

        ------------------------------------------
        -- rol_consulta: solo los reportes de la Entrega 7
        IF OBJECT_ID('Torneo.Reporte_Goleadores', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Goleadores TO rol_consulta;
        IF OBJECT_ID('Torneo.Reporte_Tarjetas_Suspensiones', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Tarjetas_Suspensiones TO rol_consulta;
        IF OBJECT_ID('Torneo.Reporte_Designaciones_Arbitrales', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Designaciones_Arbitrales TO rol_consulta;
        IF OBJECT_ID('Torneo.Reporte_Resultados', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Torneo.Reporte_Resultados TO rol_consulta;
        IF OBJECT_ID('Publicidad.Reporte_Ocupacion_Publicitaria', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Publicidad.Reporte_Ocupacion_Publicitaria TO rol_consulta;
        IF OBJECT_ID('Publicidad.Reporte_Matriz_Prime_Time', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Publicidad.Reporte_Matriz_Prime_Time TO rol_consulta;
        IF OBJECT_ID('Participantes.Reporte_Selecciones_Plantillas', 'P') IS NOT NULL GRANT EXECUTE ON OBJECT::Participantes.Reporte_Selecciones_Plantillas TO rol_consulta;

        -- La matriz de prime time arma su consulta con SQL dinámico, que no usa el encadenamiento de propiedad:
        -- necesita lectura sobre estas tablas (sin datos personales) y sobre la función de mercados
        GRANT SELECT ON OBJECT::Torneo.Partido TO rol_consulta;
        GRANT SELECT ON OBJECT::Torneo.Fase TO rol_consulta;
        GRANT SELECT ON OBJECT::Participantes.Seleccion TO rol_consulta;
        GRANT SELECT ON OBJECT::Publicidad.fn_Mercados_Prime_Time TO rol_consulta;

        -- Restricciones
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Torneo TO rol_consulta;
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Participantes TO rol_consulta;
        DENY INSERT, UPDATE, DELETE ON SCHEMA::Publicidad TO rol_consulta;
        DENY SELECT ON OBJECT::Participantes.Jugador TO rol_consulta;
        DENY SELECT ON OBJECT::Participantes.Arbitro TO rol_consulta;
        DENY SELECT ON OBJECT::Participantes.Integrante_cuerpo_tecnico TO rol_consulta;

        PRINT 'Roles configurados: rol_administrador, rol_cargador_resultados, rol_gestor_publicidad y rol_consulta.';
    END TRY
    BEGIN CATCH
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Seguridad.Crear_Usuario_Rol
-- Descripción: Crea un usuario de la base y lo agrega a uno de los roles.
--              - Con contraseña: crea también el login de SQL Server (si no existe) y el usuario asociado.
--              - Sin contraseña: crea un usuario sin login, útil para probar permisos con EXECUTE AS USER.
--              Si el login o el usuario ya existen se reutilizan. Los nombres van entre corchetes (QUOTENAME) y la
--              contraseña se escapa: CREATE LOGIN, CREATE USER y ALTER ROLE no aceptan variables, por eso se usa
--              SQL dinámico. Crear logins requiere permiso de servidor (ALTER ANY LOGIN): lo ejecuta el DBA.
-- Parámetros: @nombre_usuario, @rol y @contrasenia (opcional).
-- Validaciones: Nombre vacío, con caracteres no permitidos o de más de 50 caracteres; rol inexistente o que no
--               es uno de los cuatro del sistema; contraseña de menos de 8 caracteres; usuario que ya pertenece
--               al rol.

CREATE OR ALTER PROCEDURE Seguridad.Crear_Usuario_Rol
    @nombre_usuario SYSNAME,
    @rol SYSNAME,
    @contrasenia NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MensajeError NVARCHAR(600) = N'';
    DECLARE @sql NVARCHAR(MAX);

    IF (@nombre_usuario IS NULL OR LTRIM(RTRIM(@nombre_usuario)) = N'')
        SET @MensajeError = @MensajeError + N'- El nombre de usuario no puede estar vacío. ';
    ELSE IF (@nombre_usuario LIKE N'%[^A-Za-z0-9_]%' OR LEN(@nombre_usuario) > 50)
        SET @MensajeError = @MensajeError + N'- El nombre de usuario solo admite letras, números y guion bajo (hasta 50 caracteres). ';

    IF (@rol IS NULL OR @rol NOT IN (N'rol_administrador', N'rol_cargador_resultados', N'rol_gestor_publicidad', N'rol_consulta'))
        SET @MensajeError = @MensajeError + N'- El rol debe ser rol_administrador, rol_cargador_resultados, rol_gestor_publicidad o rol_consulta. ';
    ELSE IF (DATABASE_PRINCIPAL_ID(@rol) IS NULL)
        SET @MensajeError = @MensajeError + N'- El rol no existe: ejecute primero Seguridad.Configurar_Roles. ';

    IF (@contrasenia IS NOT NULL AND LEN(@contrasenia) < 8)
        SET @MensajeError = @MensajeError + N'- La contraseña debe tener al menos 8 caracteres. ';

    IF (@MensajeError = N'' AND DATABASE_PRINCIPAL_ID(@nombre_usuario) IS NOT NULL
        AND IS_ROLEMEMBER(@rol, @nombre_usuario) = 1)
        SET @MensajeError = @MensajeError + N'- El usuario ya pertenece a ese rol. ';

    IF (@MensajeError <> N'')
    BEGIN
        ;THROW 50001, @MensajeError, 1;
        RETURN;
    END

    BEGIN TRY
        -- Login de SQL Server (solo si se indicó contraseña y no existe)
        IF (@contrasenia IS NOT NULL AND SUSER_ID(@nombre_usuario) IS NULL)
        BEGIN
            SET @sql = N'CREATE LOGIN ' + QUOTENAME(@nombre_usuario)
                     + N' WITH PASSWORD = N''' + REPLACE(@contrasenia, N'''', N'''''') + N''''
                     + N', DEFAULT_DATABASE = ' + QUOTENAME(DB_NAME())
                     + N', CHECK_EXPIRATION = OFF;';
            EXEC sp_executesql @sql;
        END

        -- Usuario de la base
        IF (DATABASE_PRINCIPAL_ID(@nombre_usuario) IS NULL)
        BEGIN
            IF (SUSER_ID(@nombre_usuario) IS NOT NULL)
                SET @sql = N'CREATE USER ' + QUOTENAME(@nombre_usuario) + N' FOR LOGIN ' + QUOTENAME(@nombre_usuario) + N';';
            ELSE
                SET @sql = N'CREATE USER ' + QUOTENAME(@nombre_usuario) + N' WITHOUT LOGIN;';
            EXEC sp_executesql @sql;
        END

        -- Pertenencia al rol
        SET @sql = N'ALTER ROLE ' + QUOTENAME(@rol) + N' ADD MEMBER ' + QUOTENAME(@nombre_usuario) + N';';
        EXEC sp_executesql @sql;

        PRINT CONCAT('Usuario ', @nombre_usuario, ' agregado a ', @rol,
                     CASE WHEN SUSER_ID(@nombre_usuario) IS NOT NULL THEN ' (con login).' ELSE ' (sin login).' END);
    END TRY
    BEGIN CATCH
        DECLARE @Msg NVARCHAR(500) = ERROR_MESSAGE();
        DECLARE @Num INT = ERROR_NUMBER();
        PRINT CONCAT('ERROR (', @Num, '): ', @Msg);
        ;THROW;
    END CATCH;
END;
GO

------------------------------------------
-- Procedimiento: Seguridad.Reporte_Permisos_Roles
-- Descripción: Cuadro de permisos de los roles del sistema, leído del catálogo (sys.database_permissions):
--              rol, estado (GRANT o DENY), permiso y objeto o esquema al que aplica. Un segundo resultado
--              lista los usuarios de cada rol.
-- Parámetros: @rol (opcional, NULL = los cuatro roles).
-- Validaciones: Rol inexistente.

CREATE OR ALTER PROCEDURE Seguridad.Reporte_Permisos_Roles
    @rol SYSNAME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF (@rol IS NOT NULL AND DATABASE_PRINCIPAL_ID(@rol) IS NULL)
    BEGIN
        ;THROW 50001, '- El rol indicado no existe. ', 1;
        RETURN;
    END

    SELECT
        R.name AS rol,
        CASE DP.state WHEN 'D' THEN 'DENY' ELSE 'GRANT' END AS estado,
        DP.permission_name AS permiso,
        CASE DP.class WHEN 3 THEN 'Esquema' WHEN 1 THEN CASE O.type WHEN 'P' THEN 'Procedimiento' WHEN 'U' THEN 'Tabla'
                                                                      ELSE 'Función' END
                      ELSE DP.class_desc END AS tipo,
        CASE DP.class WHEN 3 THEN SC.name
                      WHEN 1 THEN OBJECT_SCHEMA_NAME(DP.major_id) + '.' + O.name
                      ELSE NULL END AS objeto
    FROM sys.database_principals R
    INNER JOIN sys.database_permissions DP ON DP.grantee_principal_id = R.principal_id
    LEFT JOIN sys.schemas SC ON DP.class = 3 AND SC.schema_id = DP.major_id
    LEFT JOIN sys.objects O ON DP.class = 1 AND O.object_id = DP.major_id
    WHERE R.type = 'R'
      AND R.name IN ('rol_administrador', 'rol_cargador_resultados', 'rol_gestor_publicidad', 'rol_consulta')
      AND (@rol IS NULL OR R.name = @rol)
    ORDER BY rol, estado DESC, tipo, objeto, permiso;

    SELECT R.name AS rol, U.name AS usuario,
           CASE WHEN U.type = 'S' AND U.authentication_type = 0 THEN 'Sin login' ELSE 'Con login' END AS tipo_usuario
    FROM sys.database_role_members RM
    INNER JOIN sys.database_principals R ON R.principal_id = RM.role_principal_id
    INNER JOIN sys.database_principals U ON U.principal_id = RM.member_principal_id
    WHERE R.name IN ('rol_administrador', 'rol_cargador_resultados', 'rol_gestor_publicidad', 'rol_consulta')
      AND (@rol IS NULL OR R.name = @rol)
    ORDER BY rol, usuario;
END;
GO

------------------------------------------
-- EJECUCIÓN: roles y un usuario de prueba por rol
-- Los logins se crean con autenticación de SQL Server. Si la instancia solo admite autenticación de Windows, el
-- login se crea igual pero no puede conectarse; las pruebas (scripts 19 a 22) usan EXECUTE AS USER, que funciona
-- en ambos casos.
------------------------------------------

EXEC Seguridad.Configurar_Roles;
GO

IF DATABASE_PRINCIPAL_ID('usr_administrador') IS NULL OR IS_ROLEMEMBER('rol_administrador', 'usr_administrador') = 0
    EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_administrador', @rol = 'rol_administrador', @contrasenia = N'G05#Admin2026';
IF DATABASE_PRINCIPAL_ID('usr_cargador') IS NULL OR IS_ROLEMEMBER('rol_cargador_resultados', 'usr_cargador') = 0
    EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_cargador', @rol = 'rol_cargador_resultados', @contrasenia = N'G05#Carga2026';
IF DATABASE_PRINCIPAL_ID('usr_publicidad') IS NULL OR IS_ROLEMEMBER('rol_gestor_publicidad', 'usr_publicidad') = 0
    EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_publicidad', @rol = 'rol_gestor_publicidad', @contrasenia = N'G05#Public2026';
IF DATABASE_PRINCIPAL_ID('usr_consulta') IS NULL OR IS_ROLEMEMBER('rol_consulta', 'usr_consulta') = 0
    EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_consulta', @rol = 'rol_consulta', @contrasenia = N'G05#Consulta2026';
GO

-- Validaciones de Seguridad.Crear_Usuario_Rol
-- Resultado esperado: error '- El nombre de usuario solo admite letras, números y guion bajo (hasta 50 caracteres).
--                     - El rol debe ser rol_administrador, ... - La contraseña debe tener al menos 8 caracteres.'
EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr prueba;', @rol = 'db_owner', @contrasenia = N'123';
GO

-- Resultado esperado: error '- El usuario ya pertenece a ese rol.'
EXEC Seguridad.Crear_Usuario_Rol @nombre_usuario = 'usr_consulta', @rol = 'rol_consulta';
GO

-- Cuadro de permisos y usuarios de cada rol
EXEC Seguridad.Reporte_Permisos_Roles;
GO
