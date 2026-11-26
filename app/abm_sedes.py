# UNIVERSIDAD NACIONAL DE LA MATANZA
# BASES DE DATOS APLICADA
# Comision 5600 - Grupo 05
# Integrantes:
# Gonzalez Esteban Gabriel 42888511
# Vázquez Nahuel Domiciano 35756270
#
# Entrega 9 - Aplicación de escritorio para el ABM de sedes (Torneo.Sede)
# ---------------------------------------------------------------------------------------------------------------
# Lista las sedes y permite darlas de alta, modificarlas y eliminarlas. La aplicación no escribe en las tablas:
# llama a los SP Torneo.Alta_Sede, Torneo.Modificacion_Sede y Torneo.Baja_Sede, así se aplican las mismas
# validaciones que en la base. Los errores de los SP (THROW 50001) se muestran en un cuadro de diálogo.
#
# REQUISITOS: Python 3 (incluye tkinter), el paquete pyodbc y un driver ODBC de SQL Server
#             ("ODBC Driver 18/17 for SQL Server", o el driver "SQL Server" que viene con Windows).
#             pip install pyodbc
# USO:        python abm_sedes.py                       (se conecta a .\SQLEXPRESS con autenticación de Windows)
#             python abm_sedes.py NAPO\SQLEXPRESS       (otro servidor o instancia)
# ---------------------------------------------------------------------------------------------------------------

import re
import sys
import tkinter as tk
from decimal import Decimal, InvalidOperation
from tkinter import messagebox, ttk

try:
    import pyodbc
except ImportError:
    print("Falta el paquete pyodbc. Instalalo con:  pip install pyodbc")
    sys.exit(1)

BASE_DE_DATOS = "COM5600_G05"
SERVIDOR_POR_DEFECTO = r".\SQLEXPRESS"
DRIVERS_PREFERIDOS = ["ODBC Driver 18 for SQL Server", "ODBC Driver 17 for SQL Server", "SQL Server"]


# ---------------------------------------------------------------------------------------------------------------
# Acceso a datos
# ---------------------------------------------------------------------------------------------------------------

def elegir_driver():
    """Devuelve el primer driver de SQL Server instalado, en orden de preferencia."""
    instalados = pyodbc.drivers()
    for driver in DRIVERS_PREFERIDOS:
        if driver in instalados:
            return driver
    raise RuntimeError("No se encontró un driver ODBC de SQL Server. Drivers instalados: "
                       + (", ".join(instalados) or "ninguno"))


def conectar(servidor):
    driver = elegir_driver()
    cadena = (f"DRIVER={{{driver}}};SERVER={servidor};DATABASE={BASE_DE_DATOS};"
              "Trusted_Connection=yes;")
    if driver.startswith("ODBC Driver 18"):
        # El driver 18 cifra la conexión por defecto; el SQL Server local usa un certificado autofirmado
        cadena += "TrustServerCertificate=yes;"
    return pyodbc.connect(cadena, autocommit=True)


def mensaje_sql(error):
    """Deja solo el texto del mensaje de SQL Server, sin los prefijos del driver ni el código ODBC."""
    texto = str(error.args[1]) if len(error.args) > 1 else str(error)
    # Error 547: la sede tiene filas que la referencian (el texto cambia según el idioma de SQL Server)
    if "(547)" in str(error) or "REFERENCE" in texto:
        return "No se puede eliminar la sede porque tiene partidos asociados."
    partes = []
    for linea in texto.split(";"):
        linea = re.sub(r"\[[^\]]*\]", "", linea).strip()      # [Microsoft][ODBC Driver 17 ...][SQL Server]
        if linea.startswith("ERROR ("):                       # el PRINT de los SP repite el mismo error
            continue
        linea = re.sub(r"\(\d+\)\s*(\(SQL\w+\))?", "", linea)   # (50001) (SQLExecDirectW)
        linea = linea.strip(" .")
        if linea:
            partes.append(linea + ".")
    texto = " ".join(partes) or texto
    # Los SP acumulan los errores separados por "- ": se muestran uno por renglón
    return re.sub(r"\s*-\s+(?=[A-ZÁÉÍÓÚÑ])", "\n- ", texto).strip()


class RepositorioSedes:
    def __init__(self, conexion):
        self.cx = conexion

    def _ejecutar(self, sql, *parametros):
        cursor = self.cx.cursor()
        cursor.execute(sql, parametros)
        # Se recorren todos los resultados para que lleguen los errores que el SP lanza después de un PRINT
        while cursor.nextset():
            pass
        cursor.close()

    def listar(self):
        cursor = self.cx.cursor()
        cursor.execute("""
            SELECT SE.id_sede, SE.nombre_estadio, CI.nombre, PA.nombre, SE.capacidad,
                   SE.latitud, SE.longitud, SE.huso_horario, SE.id_ciudad
            FROM Torneo.Sede SE
            INNER JOIN Participantes.Ciudad CI ON CI.id_ciudad = SE.id_ciudad
            INNER JOIN Participantes.Pais PA ON PA.id_pais = CI.id_pais
            ORDER BY PA.nombre, CI.nombre, SE.nombre_estadio""")
        filas = cursor.fetchall()
        cursor.close()
        return filas

    def ciudades(self):
        cursor = self.cx.cursor()
        cursor.execute("""
            SELECT CI.id_ciudad, CI.nombre + ' (' + PA.nombre + ')'
            FROM Participantes.Ciudad CI
            INNER JOIN Participantes.Pais PA ON PA.id_pais = CI.id_pais
            ORDER BY PA.nombre, CI.nombre""")
        filas = cursor.fetchall()
        cursor.close()
        return filas

    def alta(self, id_ciudad, estadio, capacidad, latitud, longitud, huso):
        self._ejecutar("EXEC Torneo.Alta_Sede @id_ciudad = ?, @nombre_estadio = ?, @capacidad = ?, "
                       "@latitud = ?, @longitud = ?, @huso_horario = ?",
                       id_ciudad, estadio, capacidad, latitud, longitud, huso)

    def modificacion(self, id_sede, id_ciudad, estadio, capacidad, latitud, longitud, huso):
        # Modificacion_Sede conserva el valor actual de los parámetros que llegan en NULL
        self._ejecutar("EXEC Torneo.Modificacion_Sede @id_sede = ?, @id_ciudad = ?, @nombre_estadio = ?, "
                       "@capacidad = ?, @latitud = ?, @longitud = ?, @huso_horario = ?",
                       id_sede, id_ciudad, estadio, capacidad, latitud, longitud, huso)

    def baja(self, id_sede):
        self._ejecutar("EXEC Torneo.Baja_Sede @id_sede = ?", id_sede)


# ---------------------------------------------------------------------------------------------------------------
# Interfaz
# ---------------------------------------------------------------------------------------------------------------

class AppSedes(tk.Tk):
    COLUMNAS = [("id", "ID", 45), ("estadio", "Estadio", 190), ("ciudad", "Ciudad", 130), ("pais", "País", 110),
                ("capacidad", "Capacidad", 80), ("latitud", "Latitud", 90), ("longitud", "Longitud", 90),
                ("huso", "Huso horario", 90)]

    def __init__(self, repo, servidor):
        super().__init__()
        self.repo = repo
        self.id_sede_actual = None
        self.ciudades_por_texto = {}
        self.texto_por_ciudad = {}

        self.title(f"Mundial 2026 - ABM de sedes  [{servidor} / {BASE_DE_DATOS}]")
        self.geometry("980x600")
        self.minsize(820, 500)

        self._armar_lista()
        self._armar_formulario()
        self._armar_botones()

        self.estado = tk.StringVar()
        ttk.Label(self, textvariable=self.estado, anchor="w", relief="sunken").pack(fill="x", side="bottom")

        self.cargar_ciudades()
        self.refrescar()
        self.nuevo()

    def _armar_lista(self):
        marco = ttk.LabelFrame(self, text="Sedes registradas")
        marco.pack(fill="both", expand=True, padx=10, pady=(10, 5))

        self.tabla = ttk.Treeview(marco, columns=[c[0] for c in self.COLUMNAS], show="headings",
                                  selectmode="browse")
        for clave, titulo, ancho in self.COLUMNAS:
            self.tabla.heading(clave, text=titulo)
            alineacion = "w" if clave in ("estadio", "ciudad", "pais") else "center"
            self.tabla.column(clave, width=ancho, anchor=alineacion)
        barra = ttk.Scrollbar(marco, orient="vertical", command=self.tabla.yview)
        self.tabla.configure(yscrollcommand=barra.set)
        self.tabla.pack(side="left", fill="both", expand=True)
        barra.pack(side="right", fill="y")
        self.tabla.bind("<<TreeviewSelect>>", self.al_seleccionar)

    def _armar_formulario(self):
        marco = ttk.LabelFrame(self, text="Datos de la sede")
        marco.pack(fill="x", padx=10, pady=5)

        self.var_id = tk.StringVar()
        self.var_ciudad = tk.StringVar()
        self.var_estadio = tk.StringVar()
        self.var_capacidad = tk.StringVar()
        self.var_latitud = tk.StringVar()
        self.var_longitud = tk.StringVar()
        self.var_huso = tk.StringVar()

        campos = [
            ("ID", ttk.Entry(marco, textvariable=self.var_id, state="readonly", width=10)),
            ("Ciudad", None),
            ("Estadio", ttk.Entry(marco, textvariable=self.var_estadio, width=34)),
            ("Capacidad", ttk.Entry(marco, textvariable=self.var_capacidad, width=12)),
            ("Latitud", ttk.Entry(marco, textvariable=self.var_latitud, width=14)),
            ("Longitud", ttk.Entry(marco, textvariable=self.var_longitud, width=14)),
            ("Huso horario", ttk.Entry(marco, textvariable=self.var_huso, width=12)),
        ]
        self.combo_ciudad = ttk.Combobox(marco, textvariable=self.var_ciudad, state="readonly", width=40)
        campos[1] = ("Ciudad", self.combo_ciudad)

        for i, (etiqueta, widget) in enumerate(campos):
            fila, col = divmod(i, 2)
            ttk.Label(marco, text=etiqueta + ":").grid(row=fila, column=col * 2, sticky="e", padx=(10, 4), pady=4)
            widget.grid(row=fila, column=col * 2 + 1, sticky="w", pady=4)

        ttk.Label(marco, foreground="gray",
                  text="Huso horario con formato UTC-6 o UTC+5:30. Latitud y longitud son opcionales en el alta "
                       "(las completa la API Nominatim).").grid(row=4, column=0, columnspan=4, sticky="w",
                                                                padx=10, pady=(0, 6))

    def _armar_botones(self):
        marco = ttk.Frame(self)
        marco.pack(fill="x", padx=10, pady=(0, 8))
        ttk.Button(marco, text="Nuevo", command=self.nuevo).pack(side="left", padx=(0, 6))
        self.btn_alta = ttk.Button(marco, text="Dar de alta", command=self.dar_de_alta)
        self.btn_alta.pack(side="left", padx=6)
        self.btn_modificar = ttk.Button(marco, text="Guardar cambios", command=self.guardar_cambios)
        self.btn_modificar.pack(side="left", padx=6)
        self.btn_baja = ttk.Button(marco, text="Eliminar", command=self.eliminar)
        self.btn_baja.pack(side="left", padx=6)
        ttk.Button(marco, text="Refrescar", command=self.refrescar).pack(side="right")

    # ----- Carga de datos -------------------------------------------------------------------------------------

    def cargar_ciudades(self):
        self.ciudades_por_texto.clear()
        self.texto_por_ciudad.clear()
        for id_ciudad, texto in self.repo.ciudades():
            self.ciudades_por_texto[texto] = id_ciudad
            self.texto_por_ciudad[id_ciudad] = texto
        self.combo_ciudad["values"] = list(self.ciudades_por_texto)

    def refrescar(self, seleccionar=None):
        try:
            filas = self.repo.listar()
        except pyodbc.Error as e:
            messagebox.showerror("Error al leer las sedes", mensaje_sql(e))
            return
        self.tabla.delete(*self.tabla.get_children())
        self.datos = {}
        for f in filas:
            id_sede, estadio, ciudad, pais, capacidad, lat, lon, huso, id_ciudad = f
            self.datos[str(id_sede)] = f
            self.tabla.insert("", "end", iid=str(id_sede), values=(
                id_sede, estadio, ciudad, pais, f"{capacidad:,}".replace(",", "."),
                "" if lat is None else lat, "" if lon is None else lon, huso or ""))
        self.estado.set(f"{len(filas)} sedes")
        if seleccionar is not None and self.tabla.exists(str(seleccionar)):
            self.tabla.selection_set(str(seleccionar))
            self.tabla.see(str(seleccionar))

    def al_seleccionar(self, _evento=None):
        seleccion = self.tabla.selection()
        if not seleccion:
            return
        id_sede, estadio, _ciudad, _pais, capacidad, lat, lon, huso, id_ciudad = self.datos[seleccion[0]]
        self.id_sede_actual = id_sede
        self.var_id.set(id_sede)
        self.var_ciudad.set(self.texto_por_ciudad.get(id_ciudad, ""))
        self.var_estadio.set(estadio)
        self.var_capacidad.set(capacidad)
        self.var_latitud.set("" if lat is None else lat)
        self.var_longitud.set("" if lon is None else lon)
        self.var_huso.set(huso or "")
        self._habilitar(edicion=True)

    def nuevo(self):
        self.id_sede_actual = None
        self.tabla.selection_remove(*self.tabla.selection())
        for var in (self.var_id, self.var_ciudad, self.var_estadio, self.var_capacidad,
                    self.var_latitud, self.var_longitud, self.var_huso):
            var.set("")
        self._habilitar(edicion=False)

    def _habilitar(self, edicion):
        self.btn_alta.state(["disabled"] if edicion else ["!disabled"])
        self.btn_modificar.state(["!disabled"] if edicion else ["disabled"])
        self.btn_baja.state(["!disabled"] if edicion else ["disabled"])

    # ----- Lectura del formulario -----------------------------------------------------------------------------

    def _leer_formulario(self):
        """Convierte los campos al tipo de cada parámetro. Los campos vacíos se envían como NULL y el SP valida
        los obligatorios. Devuelve None si algún número está mal escrito."""
        errores = []

        def numero(texto, nombre, tipo):
            texto = texto.strip().replace(",", ".")
            if texto == "":
                return None
            try:
                return int(texto.replace(".", "")) if tipo is int else Decimal(texto)
            except (ValueError, InvalidOperation):
                errores.append(f"- {nombre} debe ser un número.")
                return None

        datos = {
            "id_ciudad": self.ciudades_por_texto.get(self.var_ciudad.get()),
            "estadio": self.var_estadio.get().strip() or None,
            "capacidad": numero(self.var_capacidad.get(), "La capacidad", int),
            "latitud": numero(self.var_latitud.get(), "La latitud", Decimal),
            "longitud": numero(self.var_longitud.get(), "La longitud", Decimal),
            "huso": self.var_huso.get().strip() or None,
        }
        if errores:
            messagebox.showwarning("Datos inválidos", "\n".join(errores))
            return None
        return datos

    # ----- Operaciones ----------------------------------------------------------------------------------------

    def dar_de_alta(self):
        d = self._leer_formulario()
        if d is None:
            return
        if d["id_ciudad"] is None:
            messagebox.showwarning("Datos incompletos", "Elegí la ciudad de la sede.")
            return
        try:
            self.repo.alta(d["id_ciudad"], d["estadio"], d["capacidad"], d["latitud"], d["longitud"], d["huso"])
        except pyodbc.Error as e:
            messagebox.showerror("No se pudo dar de alta la sede", mensaje_sql(e))
            return
        self.refrescar()
        # Se selecciona la sede recién creada (la de mayor id con ese estadio)
        nuevas = [f[0] for f in self.datos.values() if f[1] == d["estadio"] and f[8] == d["id_ciudad"]]
        if nuevas:
            self.refrescar(seleccionar=max(nuevas))
        self.estado.set(f"Sede \"{d['estadio']}\" dada de alta.")

    def guardar_cambios(self):
        if self.id_sede_actual is None:
            return
        d = self._leer_formulario()
        if d is None:
            return
        try:
            self.repo.modificacion(self.id_sede_actual, d["id_ciudad"], d["estadio"], d["capacidad"],
                                   d["latitud"], d["longitud"], d["huso"])
        except pyodbc.Error as e:
            messagebox.showerror("No se pudo modificar la sede", mensaje_sql(e))
            return
        self.refrescar(seleccionar=self.id_sede_actual)
        self.estado.set(f"Sede {self.id_sede_actual} modificada.")

    def eliminar(self):
        if self.id_sede_actual is None:
            return
        estadio = self.var_estadio.get()
        if not messagebox.askyesno("Eliminar sede", f"¿Eliminar la sede \"{estadio}\"?"):
            return
        try:
            self.repo.baja(self.id_sede_actual)
        except pyodbc.Error as e:
            messagebox.showerror("No se pudo eliminar la sede", mensaje_sql(e))
            return
        self.nuevo()
        self.refrescar()
        self.estado.set(f"Sede \"{estadio}\" eliminada.")


def main():
    servidor = sys.argv[1] if len(sys.argv) > 1 else SERVIDOR_POR_DEFECTO
    try:
        conexion = conectar(servidor)
    except (pyodbc.Error, RuntimeError) as e:
        raiz = tk.Tk()
        raiz.withdraw()
        messagebox.showerror("No se pudo conectar",
                             f"No se pudo conectar a {servidor} / {BASE_DE_DATOS}.\n\n"
                             f"{mensaje_sql(e) if isinstance(e, pyodbc.Error) else e}\n\n"
                             "Si tu instancia tiene otro nombre, pasalo como parámetro:\n"
                             "python abm_sedes.py NOMBRE_PC\\SQLEXPRESS")
        return
    AppSedes(RepositorioSedes(conexion), servidor).mainloop()


if __name__ == "__main__":
    main()
