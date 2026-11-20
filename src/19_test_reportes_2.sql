-- UNIVERSIDAD NACIONAL DE LA MATANZA
-- BASES DE DATOS APLICADA
-- Comision 5600 - Grupo 05
-- Integrantes:
-- Gonzalez Esteban Gabriel 42888511
-- Vázquez Nahuel Domiciano 35756270
--
-- Pruebas de los reportes de la Entrega 7 (segunda parte, script 18)
-- Requiere haber ejecutado la carga de datos de prueba (script 17).
------------------------------------------

USE COM5600_G05;
GO

------------------------------------------
-- PRUEBAS: Publicidad.Reporte_Ocupacion_Publicitaria
------------------------------------------

-- Test 01: Ocupación de todas las sedes.
-- Resultado esperado: una fila por partido con el anunciante y la pieza de los espacios 1 a 4 y sus ingresos,
--                     una fila 'Subtotal de la sede' por sede y una fila 'TOTAL GENERAL' al final.
--                     Segundo resultado: ingresos por anunciante con su porcentaje sobre el total.
EXEC Publicidad.Reporte_Ocupacion_Publicitaria;
GO

-- Test 02: Una sede y un rango de fechas (Mercedes-Benz Stadium, fase de grupos).
-- Resultado esperado: solo los partidos de esa sede jugados entre el 11 y el 27 de junio, su subtotal y el total.
DECLARE @id_sede INT = (SELECT TOP 1 id_sede FROM Torneo.Sede WHERE nombre_estadio = 'Mercedes-Benz Stadium');
EXEC Publicidad.Reporte_Ocupacion_Publicitaria @id_sede = @id_sede, @fecha_desde = '20260611', @fecha_hasta = '20260627';
GO

-- Test 03: Sede inexistente y fechas invertidas.
-- Resultado esperado: error '- La sede indicada no existe. - La fecha desde no puede ser posterior a la fecha hasta.'
EXEC Publicidad.Reporte_Ocupacion_Publicitaria @id_sede = -1, @fecha_desde = '20260720', @fecha_hasta = '20260601';
GO

------------------------------------------
-- PRUEBAS: Publicidad.Reporte_Matriz_Prime_Time
------------------------------------------

-- Test 04: Matriz de todos los partidos con los mercados candidatos (países de las campañas).
-- Resultado esperado: una fila por partido, una columna por mercado con 'Sí hh:mm' o 'No hh:mm' (hora local del
--                     mercado) y la cantidad de mercados en prime time. Inglaterra - Croacia (20:00 UTC) aparece
--                     en prime time en los mercados europeos (más de cuatro).
EXEC Publicidad.Reporte_Matriz_Prime_Time;
GO

-- Test 05: Solo la fase de grupos, sumando como columnas los países de las selecciones y con otro rango (18 a 22 h).
-- Resultado esperado: más columnas que el test anterior; solo partidos de la fase de grupos.
DECLARE @id_fase INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Fase de Grupos');
EXEC Publicidad.Reporte_Matriz_Prime_Time @hora_inicio_prime = '18:00', @hora_fin_prime = '22:00',
     @solo_mercados_candidatos = 0, @id_fase = @id_fase;
GO

-- Test 06: Rango de prime time inválido y fase inexistente.
-- Resultado esperado: error '- El rango de prime time debe tener hora de inicio y de fin distintas. - La fase indicada no existe.'
EXEC Publicidad.Reporte_Matriz_Prime_Time @hora_inicio_prime = '20:00', @hora_fin_prime = '20:00', @id_fase = -1;
GO

------------------------------------------
-- PRUEBAS: Participantes.Reporte_Selecciones_Plantillas (XML)
------------------------------------------

-- Test 07: Todas las selecciones.
-- Resultado esperado: un XML <selecciones> con un nodo <seleccion> por selección, su cuerpo técnico y el vector
--                     <convocados> (dorsal, nombre, posición y club). Las 16 selecciones del script 17 tienen 23.
EXEC Participantes.Reporte_Selecciones_Plantillas;
GO

-- Test 08: Una sola selección (Argentina) y lectura del XML devuelto.
-- Resultado esperado: el XML de Argentina y, a partir de él, una fila por convocado ordenada por dorsal.
DECLARE @id_seleccion INT = (SELECT S.id_seleccion FROM Participantes.Seleccion S
                             INNER JOIN Participantes.Pais P ON P.id_pais = S.id_pais WHERE P.codigo_iso = 'ARG');
DECLARE @salida TABLE (plantilla XML);

INSERT INTO @salida EXEC Participantes.Reporte_Selecciones_Plantillas @id_seleccion = @id_seleccion;

SELECT plantilla FROM @salida;

SELECT
    J.value('@dorsal', 'TINYINT') AS dorsal,
    J.value('(nombre)[1]', 'VARCHAR(70)') AS jugador,
    J.value('(posicion)[1]', 'VARCHAR(30)') AS posicion,
    J.value('(club/@nombre)[1]', 'VARCHAR(50)') AS club
FROM @salida
CROSS APPLY plantilla.nodes('/selecciones/seleccion/convocados/jugador') AS T(J)
ORDER BY dorsal;
GO

-- Test 09: Un grupo (L).
-- Resultado esperado: XML con Inglaterra, Croacia, Ghana y Panamá.
EXEC Participantes.Reporte_Selecciones_Plantillas @nombre_grupo = 'L';
GO

-- Test 10: Selección y grupo inexistentes.
-- Resultado esperado: error '- La selección indicada no existe. - El grupo indicado no existe.'
EXEC Participantes.Reporte_Selecciones_Plantillas @id_seleccion = -1, @nombre_grupo = 'Z';
GO

------------------------------------------
-- PRUEBAS: Torneo.Reporte_Resultados
------------------------------------------

-- Test 11: Todos los resultados y todas las tablas de posiciones.
-- Resultado esperado: primer resultado con todos los partidos (marcador, ganador y goleadores con su minuto);
--                     segundo resultado con la tabla de cada grupo (en el grupo J: Argentina primera con 9 puntos).
EXEC Torneo.Reporte_Resultados;
GO

-- Test 12: Un grupo (J).
-- Resultado esperado: los 6 partidos del grupo J y su tabla de posiciones.
EXEC Torneo.Reporte_Resultados @nombre_grupo = 'J';
GO

-- Test 13: Una fase de eliminación directa (Final).
-- Resultado esperado: solo la final (España 1 - 0 Argentina) y la tabla de posiciones vacía.
DECLARE @id_final INT = (SELECT id_fase FROM Torneo.Fase WHERE nombre_fase = 'Final');
EXEC Torneo.Reporte_Resultados @id_fase = @id_final;
GO

-- Test 14: Fase y grupo inexistentes.
-- Resultado esperado: error '- La fase indicada no existe. - El grupo indicado no existe.'
EXEC Torneo.Reporte_Resultados @id_fase = -1, @nombre_grupo = 'Z';
GO
