# ABM de sedes (Entrega 9)

Aplicación de escritorio en Python para dar de alta, modificar y eliminar sedes (`Torneo.Sede`).
No escribe en las tablas: usa los SP `Torneo.Alta_Sede`, `Torneo.Modificacion_Sede` y `Torneo.Baja_Sede`,
así que aplica las mismas validaciones que la base y muestra sus mensajes de error.

## Requisitos

- Python 3 (en Windows ya incluye tkinter).
- El paquete pyodbc: `pip install -r requirements.txt`
- Un driver ODBC de SQL Server. Sirve "ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server"
  o el driver "SQL Server" que viene con Windows.
- La base `COM5600_G05` creada con los scripts de `src`.

## Uso

```
cd app
python abm_sedes.py
```

Se conecta a `.\SQLEXPRESS` con autenticación de Windows. Para otra instancia:

```
python abm_sedes.py NOMBRE_PC\SQLEXPRESS
```

- **Alta:** tocar "Nuevo", completar los datos y "Dar de alta".
- **Modificación:** elegir una sede de la lista, cambiar los datos y "Guardar cambios".
- **Baja:** elegir una sede y "Eliminar". Una sede con partidos no se puede eliminar.
