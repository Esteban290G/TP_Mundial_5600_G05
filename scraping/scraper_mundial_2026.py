# UNIVERSIDAD NACIONAL DE LA MATANZA
# BASES DE DATOS APLICADA
# Comision 5600 - Grupo 05
# Integrantes:
# Gonzalez Esteban Gabriel 42888511
# Vázquez Nahuel Domiciano 35756270
#
# Scraping del fixture y los resultados del Mundial 2026 desde Wikipedia (en inglés).
#
# TÉCNICA DE SCRAPING
#   - Páginas de origen:
#       https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_Group_A ... Group_L   (fase de grupos)
#       https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_knockout_stage        (fase eliminatoria)
#       y el artículo de cada estadio (para obtener su capacidad).
#   - Se descarga el código fuente de cada página (wikitext, con ?action=raw) y se extraen los
#     "match boxes" (plantilla {{Football box}}) con un parser de llaves balanceadas y expresiones
#     regulares: fecha, hora y huso (UTC-6), selecciones (código FIFA de la plantilla {{fb|MEX}}),
#     resultado, estadio, ciudad, asistencia y árbitro. La fase se toma del título de la sección.
#   - La capacidad de cada estadio se toma del campo "capacity" de la ficha (infobox) de su artículo.
#   - El país de cada sede se deduce de la ciudad (las 16 sedes están en México, Canadá o EE. UU.).
#   - Solo usa la biblioteca estándar de Python 3 (no hay que instalar nada).
#   - Respeta la política de Wikipedia: User-Agent identificable y una pausa entre pedidos.
#
# SALIDA: un archivo XML (formato distinto al CSV de estadios) que se importa con el SP
#         Torneo.Importar_XML_Mundial (script 13). El archivo no se modifica a mano.
#
# USO:   python scraper_mundial_2026.py C:\Importar\mundial_2026_wikipedia.xml
#        python scraper_mundial_2026.py --prueba salida.xml      (usa un wikitext de ejemplo, sin Internet)

import os
import re
import sys
import time
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from collections import Counter
from datetime import datetime, timedelta

WIKI = "https://en.wikipedia.org/w/index.php?title={}&action=raw"
USER_AGENT = "Proyecto_UNLaM_BDA_G05/1.0 (TP universitario Mundial 2026; scraping educativo)"
PAUSA_SEGUNDOS = 1.0

PAGINAS_GRUPOS = {letra: "2026 FIFA World Cup Group " + letra for letra in "ABCDEFGHIJKL"}
PAGINA_ELIMINATORIA = "2026 FIFA World Cup knockout stage"
PAGINA_FINAL = "2026 FIFA World Cup final"
CARPETA_CRUDO = "wikitext_crudo"   # copia del wikitext descargado, para revisar si algo no se reconoce

# Títulos de sección de la fase eliminatoria -> nombre de la fase en la base
FASES_ELIMINATORIA = [
    (r"round of 32", "Dieciseisavos de final"),
    (r"round of 16", "Octavos de final"),
    (r"quarter", "Cuartos de final"),
    (r"semi", "Semifinales"),
    (r"third", "Tercer puesto"),
    (r"final", "Final"),
]

# Ciudades sede (y sus municipios) -> país (ISO 3166 alfa-3)
CIUDADES_MEXICO = {"mexico city", "ciudad de méxico", "guadalajara", "zapopan", "monterrey", "guadalupe"}
CIUDADES_CANADA = {"toronto", "vancouver"}


# ------------------------------------------------------------------
# Descarga

def descargar_wikitext(titulo, redirecciones=2):
    url = WIKI.format(urllib.parse.quote(titulo.replace(" ", "_")))
    pedido = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(pedido, timeout=30) as respuesta:
        texto = respuesta.read().decode("utf-8")
    time.sleep(PAUSA_SEGUNDOS)
    # Si la página es una redirección (#REDIRECT [[Otra página]]) se sigue
    m = re.match(r"\s*#REDIRECT\s*\[\[([^\]#|]+)", texto, re.I)
    if m and redirecciones > 0:
        return descargar_wikitext(m.group(1).strip(), redirecciones - 1)
    return texto


# ------------------------------------------------------------------
# Utilidades de wikitext

def extraer_plantillas(texto, nombres):
    """Devuelve (posición, contenido) de cada plantilla {{nombre ...}} con llaves balanceadas."""
    patron = re.compile(r"\{\{\s*(" + "|".join(nombres) + r")\s*[|\n}]", re.IGNORECASE)
    resultado = []
    for m in patron.finditer(texto):
        inicio = m.start()
        nivel = 0
        i = inicio
        while i < len(texto) - 1:
            par = texto[i:i + 2]
            if par == "{{":
                nivel += 1
                i += 2
                continue
            if par == "}}":
                nivel -= 1
                i += 2
                if nivel == 0:
                    resultado.append((inicio, texto[inicio + 2:i - 2]))
                    break
                continue
            i += 1
    return resultado


def separar_parametros(contenido):
    """Separa los parámetros de una plantilla por '|' de primer nivel (ignora los de {{ }} y [[ ]])."""
    partes, actual, llaves, corchetes, i = [], "", 0, 0, 0
    while i < len(contenido):
        par = contenido[i:i + 2]
        if par == "{{":
            llaves += 1; actual += par; i += 2; continue
        if par == "}}":
            llaves -= 1; actual += par; i += 2; continue
        if par == "[[":
            corchetes += 1; actual += par; i += 2; continue
        if par == "]]":
            corchetes -= 1; actual += par; i += 2; continue
        c = contenido[i]
        if c == "|" and llaves == 0 and corchetes == 0:
            partes.append(actual); actual = ""
        else:
            actual += c
        i += 1
    partes.append(actual)
    parametros = {}
    for p in partes[1:]:
        if "=" in p:
            clave, valor = p.split("=", 1)
            parametros[clave.strip().lower()] = valor.strip()
    return parametros


def limpiar(texto):
    """Quita referencias, comentarios, plantillas de formato y enlaces; deja el texto visible."""
    if texto is None:
        return ""
    t = re.sub(r"<ref[^>]*/>", "", texto)
    t = re.sub(r"<ref[^>]*>.*?</ref>", "", t, flags=re.S)
    t = re.sub(r"<!--.*?-->", "", t, flags=re.S)
    t = re.sub(r"<br\s*/?>", " ", t)
    t = re.sub(r"<[^>]+>", "", t)
    t = re.sub(r"\{\{\s*(?:nowrap|nobr)\s*\|([^{}]*)\}\}", r"\1", t, flags=re.I)
    t = re.sub(r"\{\{[^{}]*\}\}", "", t)
    t = re.sub(r"\[\[(?:[^\]|]*\|)?([^\]]*)\]\]", r"\1", t)
    t = t.replace("&nbsp;", " ").replace("'''", "").replace("''", "")
    return re.sub(r"\s+", " ", t).strip()


def enlaces(texto):
    """Lista de (destino, texto visible) de los enlaces [[destino|texto]]."""
    salida = []
    for m in re.finditer(r"\[\[([^\]|]+)(?:\|([^\]]*))?\]\]", texto or ""):
        destino = m.group(1).strip()
        visible = (m.group(2) or destino).strip()
        salida.append((destino, visible))
    return salida


# Nombre en inglés (como figura en Wikipedia) -> código FIFA. Se usa cuando la página no trae el código.
CODIGOS_FIFA = {
    "mexico": "MEX", "united states": "USA", "canada": "CAN", "argentina": "ARG", "brazil": "BRA",
    "ecuador": "ECU", "uruguay": "URU", "colombia": "COL", "paraguay": "PAR", "bolivia": "BOL",
    "japan": "JPN", "iran": "IRN", "ir iran": "IRN", "uzbekistan": "UZB", "south korea": "KOR",
    "korea republic": "KOR", "jordan": "JOR", "australia": "AUS", "qatar": "QAT", "saudi arabia": "KSA",
    "iraq": "IRQ", "new zealand": "NZL", "new caledonia": "NCL", "morocco": "MAR", "tunisia": "TUN",
    "egypt": "EGY", "algeria": "ALG", "ghana": "GHA", "cape verde": "CPV", "cabo verde": "CPV",
    "south africa": "RSA", "senegal": "SEN", "ivory coast": "CIV", "côte d'ivoire": "CIV",
    "dr congo": "COD", "congo dr": "COD", "nigeria": "NGA", "cameroon": "CMR", "england": "ENG",
    "france": "FRA", "croatia": "CRO", "portugal": "POR", "norway": "NOR", "germany": "GER",
    "netherlands": "NED", "switzerland": "SUI", "spain": "ESP", "belgium": "BEL", "austria": "AUT",
    "scotland": "SCO", "wales": "WAL", "czech republic": "CZE", "czechia": "CZE", "italy": "ITA",
    "turkey": "TUR", "türkiye": "TUR", "denmark": "DEN", "ukraine": "UKR", "sweden": "SWE",
    "poland": "POL", "bosnia and herzegovina": "BIH", "slovakia": "SVK", "kosovo": "KVX",
    "republic of ireland": "IRL", "ireland": "IRL", "albania": "ALB", "north macedonia": "MKD",
    "romania": "ROU", "serbia": "SRB", "hungary": "HUN", "greece": "GRE", "slovenia": "SVN",
    "jamaica": "JAM", "suriname": "SUR", "curaçao": "CUW", "curacao": "CUW", "haiti": "HAI",
    "panama": "PAN", "costa rica": "CRC", "honduras": "HON", "el salvador": "SLV", "guatemala": "GUA",
    "venezuela": "VEN", "peru": "PER", "chile": "CHI", "united arab emirates": "UAE", "oman": "OMA",
    "china": "CHN", "china pr": "CHN", "indonesia": "IDN", "bahrain": "BHR", "palestine": "PLE",
    "mali": "MLI", "burkina faso": "BFA", "gabon": "GAB", "benin": "BEN", "uganda": "UGA",
}


def _primer_parametro_plantilla(valor):
    """{{fb-rt|MEX}} -> 'MEX'; {{flagteam|Mexico|...}} -> 'Mexico' (primer parámetro sin '=')."""
    for m in re.finditer(r"\{\{\s*([^{}|]+?)\s*\|([^{}]*)\}\}", valor or ""):
        nombre_plantilla = m.group(1).strip().lower()
        if nombre_plantilla in ("goal", "goals", "yel", "sent off", "sub", "efn", "abbr"):
            continue
        for parametro in m.group(2).split("|"):
            parametro = parametro.strip()
            if parametro and "=" not in parametro:
                return parametro
    return None


def codigo_equipo(valor):
    """{{fb|MEX}} / {{fb-rt|RSA}} / {{fbw|...}} / cualquier plantilla con código de 3 letras -> 'MEX'."""
    m = re.search(r"\{\{\s*[^{}|]+\|\s*([A-Z]{3})\s*[|}]", valor or "")
    if m:
        return m.group(1)
    nombre = nombre_equipo(valor)
    return CODIGOS_FIFA.get(nombre.lower()) if nombre else None


def nombre_equipo(valor):
    texto = limpiar(valor)
    if texto:
        return texto
    parametro = _primer_parametro_plantilla(valor)
    if parametro and not re.fullmatch(r"[A-Z]{3}", parametro):
        return limpiar(parametro) or None
    return None


def equipos_de_titulo(texto, posicion):
    """Título '===Mexico vs South Africa===' más cercano antes del partido -> ('Mexico', 'South Africa')."""
    encabezados = list(re.finditer(r"^(={2,5})\s*(.+?)\s*\1\s*$", texto[:posicion], re.M))
    if encabezados:
        titulo = limpiar(encabezados[-1].group(2))
        m = re.match(r"(.+?)\s+(?:vs?\.?|v\.)\s+(.+)$", titulo, re.I)
        if m:
            return m.group(1).strip(), m.group(2).strip()
    return None, None


def parsear_fecha(valor):
    m = re.search(r"\{\{\s*start date[^|]*\|\s*(\d{4})\s*\|\s*(\d{1,2})\s*\|\s*(\d{1,2})", valor or "", re.I)
    if m:
        return datetime(int(m.group(1)), int(m.group(2)), int(m.group(3)))
    texto = limpiar(valor)
    for formato in ("%B %d, %Y", "%d %B %Y", "%Y-%m-%d"):
        try:
            return datetime.strptime(texto, formato)
        except ValueError:
            pass
    return None


def parsear_hora(valor):
    """'13:00 [[Central Time Zone|CST]] ([[UTC−6]])' -> (13, 0, -360); '1:00 p.m. CST (UTC−6)' -> (13, 0, -360)."""
    texto = limpiar(valor).replace("\u2212", "-").replace("\u2013", "-").replace("\u00a0", " ")
    if not texto:
        texto = (valor or "").replace("\u2212", "-")
    m_hora = re.search(r"(\d{1,2}):(\d{2})\s*(?:([ap])\.?\s*m\b\.?)?", texto, re.I)
    patron_huso = r"UTC\s*([+-])\s*(\d{1,2})(?::(\d{2}))?"
    m_huso = re.search(patron_huso, texto) or re.search(patron_huso, (valor or "").replace("\u2212", "-"))
    if not m_hora:
        return None
    hora, minuto = int(m_hora.group(1)), int(m_hora.group(2))
    meridiano = (m_hora.group(3) or "").lower()
    if meridiano == "p" and hora < 12:
        hora += 12
    elif meridiano == "a" and hora == 12:
        hora = 0
    offset = None
    if m_huso:
        offset = (int(m_huso.group(2)) * 60 + int(m_huso.group(3) or 0)) * (-1 if m_huso.group(1) == "-" else 1)
    return hora, minuto, offset


def parsear_resultado(valor):
    # {{score link|destino|2–1}} -> 2–1 (si no, limpiar() borraría la plantilla con el resultado)
    texto = re.sub(r"\{\{\s*score link\s*\|[^{}|]*\|([^{}]*)\}\}", r"\1", valor or "", flags=re.I)
    texto = limpiar(texto).replace("\u2013", "-").replace("\u2212", "-")
    m = re.search(r"(\d+)\s*-\s*(\d+)", texto)
    return (int(m.group(1)), int(m.group(2))) if m else (None, None)


def parsear_numero(valor):
    m = re.search(r"\d[\d,\.]*", limpiar(valor))
    if not m:
        return None
    digitos = re.sub(r"[^\d]", "", m.group(0))
    return int(digitos) if digitos else None


def huso_texto(minutos):
    if minutos is None:
        return None
    if minutos == 0:
        return "UTC"
    signo = "-" if minutos < 0 else "+"
    h, mm = divmod(abs(minutos), 60)
    return "UTC{}{}{}".format(signo, h, ":{:02d}".format(mm) if mm else "")


def pais_de_ciudad(ciudad):
    c = (ciudad or "").lower()
    if any(x in c for x in CIUDADES_MEXICO):
        return "MEX"
    if any(x in c for x in CIUDADES_CANADA):
        return "CAN"
    return "USA"


# ------------------------------------------------------------------
# Extracción de partidos

def fase_eliminatoria(seccion):
    s = seccion.lower()
    for patron, fase in FASES_ELIMINATORIA:
        if re.search(patron, s):
            return fase
    return None


def fase_de_posicion(texto, posicion):
    """Recorre los títulos anteriores al partido (del más cercano hacia atrás) hasta encontrar una fase;
    así se saltean los subtítulos del tipo '====Match 73===='."""
    encabezados = list(re.finditer(r"^(={2,5})\s*(.+?)\s*\1\s*$", texto[:posicion], re.M))
    for encabezado in reversed(encabezados):
        fase = fase_eliminatoria(limpiar(encabezado.group(2)))
        if fase:
            return fase
    return None


# Formas en que Wikipedia escribe un partido: la plantilla clásica y la llamada directa al módulo
PLANTILLAS_PARTIDO = [
    r"#invoke:\s*football[ _]?box(?:[ _]collapsible)?\s*\|\s*main",
    r"football[ _]?box(?:[ _]collapsible)?",
]


def extraer_partidos(wikitext, fase_fija=None, grupo=None):
    partidos = []
    for posicion, contenido in extraer_plantillas(wikitext, PLANTILLAS_PARTIDO):
        p = separar_parametros(contenido)
        fase = fase_fija or fase_de_posicion(wikitext, posicion)
        fecha = parsear_fecha(p.get("date"))
        hora = parsear_hora(p.get("time"))
        goles_local, goles_visitante = parsear_resultado(p.get("score"))
        lugar = enlaces(p.get("stadium"))
        estadio = lugar[0][1] if lugar else limpiar(p.get("stadium")).split(",")[0].strip() or None
        estadio_articulo = lugar[0][0] if lugar else None
        ciudad = lugar[1][1] if len(lugar) > 1 else (limpiar(p.get("stadium")).split(",")[1].strip()
                                                     if "," in limpiar(p.get("stadium")) else None)
        fecha_local = fecha_utc = None
        offset = None
        if fecha and hora:
            fecha_local = fecha.replace(hour=hora[0], minute=hora[1])
            offset = hora[2]
            if offset is not None:
                fecha_utc = fecha_local - timedelta(minutes=offset)
        equipo1 = p.get("team1") or p.get("home") or p.get("team_1")
        equipo2 = p.get("team2") or p.get("away") or p.get("team_2")
        local_fifa, local_nombre = codigo_equipo(equipo1), nombre_equipo(equipo1)
        visitante_fifa, visitante_nombre = codigo_equipo(equipo2), nombre_equipo(equipo2)
        if not (local_fifa or local_nombre) or not (visitante_fifa or visitante_nombre):
            # Último recurso: el título de la sección del partido ("Mexico vs South Africa")
            t1, t2 = equipos_de_titulo(wikitext, posicion)
            if t1 and not (local_fifa or local_nombre):
                local_nombre, local_fifa = t1, CODIGOS_FIFA.get(t1.lower())
            if t2 and not (visitante_fifa or visitante_nombre):
                visitante_nombre, visitante_fifa = t2, CODIGOS_FIFA.get(t2.lower())
        if local_fifa and not local_nombre:
            local_nombre = next((n.title() for n, c in CODIGOS_FIFA.items() if c == local_fifa), None)
        if visitante_fifa and not visitante_nombre:
            visitante_nombre = next((n.title() for n, c in CODIGOS_FIFA.items() if c == visitante_fifa), None)
        partidos.append({
            "fase": fase,
            "grupo": grupo,
            "crudo_team1": equipo1,
            "local_fifa": local_fifa,
            "local_nombre": local_nombre,
            "visitante_fifa": visitante_fifa,
            "visitante_nombre": visitante_nombre,
            "fecha_hora_local": fecha_local.strftime("%Y-%m-%d %H:%M:%S") if fecha_local else limpiar(p.get("date")),
            "fecha_hora_utc": fecha_utc.strftime("%Y-%m-%d %H:%M:%S") if fecha_utc else None,
            "offset": offset,
            "estadio": estadio,
            "estadio_articulo": estadio_articulo,
            "ciudad": ciudad,
            "goles_local": goles_local,
            "goles_visitante": goles_visitante,
            "asistencia": parsear_numero(p.get("attendance")),
            "arbitro": limpiar(p.get("referee")) or None,
        })
    return partidos


def capacidad_estadio(wikitext):
    m = re.search(r"\|\s*capacity\s*=\s*([^\n|]+)", wikitext or "", re.I)
    return parsear_numero(m.group(1)) if m else None


# ------------------------------------------------------------------
# Armado del XML

def armar_xml(partidos, grupos, capacidades):
    raiz = ET.Element("mundial", {
        "fuente": "https://en.wikipedia.org/wiki/2026_FIFA_World_Cup",
        "fecha_extraccion": datetime.now().strftime("%Y-%m-%dT%H:%M:%S"),
    })

    # Sedes: una por estadio; el huso es el más frecuente entre sus partidos
    sedes = ET.SubElement(raiz, "sedes")
    por_estadio = {}
    for p in partidos:
        if p["estadio"]:
            por_estadio.setdefault(p["estadio"], []).append(p)
    for estadio, lista in sorted(por_estadio.items()):
        ciudad = Counter(x["ciudad"] for x in lista if x["ciudad"]).most_common(1)
        offset = Counter(x["offset"] for x in lista if x["offset"] is not None).most_common(1)
        ciudad = ciudad[0][0] if ciudad else None
        atributos = {"estadio": estadio}
        if ciudad:
            atributos["ciudad"] = ciudad
            atributos["pais_iso"] = pais_de_ciudad(ciudad)
        capacidad = capacidades.get(lista[0]["estadio_articulo"])
        if capacidad:
            atributos["capacidad"] = str(capacidad)
        if offset:
            atributos["huso_horario"] = huso_texto(offset[0][0])
        ET.SubElement(sedes, "sede", atributos)

    nodo_grupos = ET.SubElement(raiz, "grupos")
    for letra in sorted(grupos):
        g = ET.SubElement(nodo_grupos, "grupo", {"letra": letra})
        for codigo, nombre in sorted(grupos[letra].items()):
            ET.SubElement(g, "seleccion", {"codigo_fifa": codigo, "nombre": nombre or codigo})

    nodo_partidos = ET.SubElement(raiz, "partidos")
    for numero, p in enumerate(partidos, start=1):
        atributos = {"numero": str(numero)}
        if p["fase"]:
            atributos["fase"] = p["fase"]
        if p["grupo"]:
            atributos["grupo"] = p["grupo"]
        nodo = ET.SubElement(nodo_partidos, "partido", atributos)
        for clave, etiqueta in (("local", "local"), ("visitante", "visitante")):
            equipo = ET.SubElement(nodo, etiqueta)
            if p[clave + "_fifa"]:
                equipo.set("codigo_fifa", p[clave + "_fifa"])
            equipo.text = p[clave + "_nombre"] or ""
        for campo in ("fecha_hora_local", "fecha_hora_utc", "estadio", "ciudad", "goles_local",
                      "goles_visitante", "asistencia", "arbitro"):
            hijo = ET.SubElement(nodo, campo)
            if p[campo] is not None:
                hijo.text = str(p[campo])
    return ET.ElementTree(raiz)


# ------------------------------------------------------------------
# Programa principal

EJEMPLO = """
==Matches==
===Mexico vs South Africa===
{{Football box
|date={{Start date|2026|6|11}}
|time=13:00 [[Central Time Zone|CST]] ([[UTC−6]])
|team1={{fb-rt|MEX}}
|score={{score link|2026 FIFA World Cup Group A#Mexico vs South Africa|2–1}}
|report=https://www.fifa.com
|team2={{fb|RSA}}
|goals1=Someone {{goal|12}}
|stadium=[[Estadio Azteca]], [[Mexico City]]
|attendance=83,264<ref>{{cite web|title=x}}</ref>
|referee=[[Facundo Tello]] ([[Argentine Football Association|Argentina]])
}}
"""


EJEMPLO_INVOKE = """
===South Korea vs Czechia===
{{#invoke:football box|main
|date={{Start date|2026|6|11}}
|time=8:00{{nbsp}}p.m. [[Central Time Zone|CST]] ([[UTC−6]])
|team1={{fb-rt|KOR}}
|score=1–1
|team2={{fb|CZE}}
|stadium=[[Estadio Akron]], [[Zapopan]]
|attendance=46,000
|referee=Someone (Somewhere)
}}
"""


EJEMPLO_ELIMINATORIA = """
==Round of 32==
===Mexico vs Japan===
{{Football box
|date=June 28, 2026
|time=1:00 p.m. [[Central Time Zone|CST]] ([[UTC−6]])
|team1={{flagteam|Mexico}}
|score=2–0
|team2=[[Japan national football team|Japan]]
|stadium=[[Estadio Azteca]], [[Mexico City]]
}}
===South Africa vs Spain===
{{Football box
|date=June 29, 2026
|time=12:00 p.m. EDT (UTC−4)
|score=0–3
|stadium=[[MetLife Stadium]], [[East Rutherford, New Jersey|East Rutherford]]
}}
==Round of 16==
===Match 89===
====Argentina vs Germany====
{{Football box
|date=July 4, 2026
|time=12:00 [[Eastern Time Zone|EDT]] ([[UTC−4]])
|team1={{fb-rt|ARG}}
|score=1–1 ([[Overtime (sports)#Association football|a.e.t.]])
|penaltyscore=4–3
|team2={{fb|GER}}
|stadium=[[Lincoln Financial Field]], [[Philadelphia]]
|attendance=67,100
|referee=[[Szymon Marciniak]] ([[Polish Football Association|Poland]])
}}
==Final==
{{Football box
|date={{Start date|2026|7|19}}
|time=15:00 [[Eastern Time Zone|EDT]] ([[UTC−4]])
|team1={{fb-rt|ARG}}
|score=Match 104
|team2={{fb|FRA}}
|stadium=[[MetLife Stadium]], [[East Rutherford, New Jersey|East Rutherford]]
|attendance=
|referee=
}}
"""


def main(argumentos):
    prueba = "--prueba" in argumentos
    argumentos = [a for a in argumentos if a != "--prueba"]
    salida = argumentos[0] if argumentos else "mundial_2026_wikipedia.xml"

    partidos, grupos, capacidades = [], {}, {}

    if prueba:
        partidos = (extraer_partidos(EJEMPLO, "Fase de Grupos", "A") + extraer_partidos(EJEMPLO_INVOKE, "Fase de Grupos", "A")
                    + extraer_partidos(EJEMPLO_ELIMINATORIA))
        capacidades = {"Estadio Azteca": 83264, "Lincoln Financial Field": 67594}
    else:
        os.makedirs(CARPETA_CRUDO, exist_ok=True)
        pendientes = [(titulo, "Fase de Grupos", letra) for letra, titulo in PAGINAS_GRUPOS.items()]
        pendientes += [(PAGINA_ELIMINATORIA, None, None), (PAGINA_FINAL, "Final", None)]
        visitadas, vistos = set(), set()
        while pendientes:
            titulo, fase, letra = pendientes.pop(0)
            if titulo.lower() in visitadas:
                continue
            visitadas.add(titulo.lower())
            print("Descargando", titulo)
            try:
                wikitext = descargar_wikitext(titulo)
            except Exception as error:
                print("  No se pudo descargar:", error)
                continue
            with open(os.path.join(CARPETA_CRUDO, re.sub(r"[^\w]+", "_", titulo) + ".txt"), "w", encoding="utf-8") as archivo:
                archivo.write(wikitext)
            encontrados = []
            for p in extraer_partidos(wikitext, fase, letra):
                clave = (p["fecha_hora_local"], p["estadio"])
                if clave not in vistos:      # el mismo partido puede aparecer en dos páginas
                    vistos.add(clave)
                    encontrados.append(p)
            print("  {} caracteres, {} partidos nuevos".format(len(wikitext), len(encontrados)))
            if fase != "Fase de Grupos":
                # Secciones de la eliminatoria que remiten a otra página ({{main|...}} o {{:Página}})
                for m in re.finditer(r"\{\{\s*(?:main|see also|further|:)\s*\|?\s*([^{}|]*2026 FIFA World Cup[^{}|]*)", wikitext, re.I):
                    destino = m.group(1).split("#")[0].strip()
                    fase_destino = fase or fase_de_posicion(wikitext, m.start())
                    if destino and destino.lower() not in visitadas and fase_destino:
                        pendientes.append((destino, fase_destino, None))
            if not encontrados and fase == "Fase de Grupos":
                i = wikitext.lower().find("team1")
                print("  DIAGNÓSTICO (no se reconoció ningún partido):")
                print("  " + (wikitext[max(0, i - 400):i + 200] if i >= 0 else wikitext[:600]).replace("\n", "\n  "))
            partidos += encontrados
        sin_equipos = [p for p in partidos if not (p["local_fifa"] or p["local_nombre"])]
        if sin_equipos:
            print("AVISO: {} partidos sin selecciones. Ejemplo de team1 crudo: {!r}".format(
                len(sin_equipos), sin_equipos[0]["crudo_team1"]))
        for articulo in sorted({p["estadio_articulo"] for p in partidos if p["estadio_articulo"]}):
            try:
                print("Descargando", articulo)
                capacidades[articulo] = capacidad_estadio(descargar_wikitext(articulo))
            except Exception as error:  # se sigue con los demás estadios
                print("  No se pudo obtener la capacidad:", error)

    orden_fases = ["Fase de Grupos", "Dieciseisavos de final", "Octavos de final", "Cuartos de final",
                   "Semifinales", "Tercer puesto", "Final"]
    partidos.sort(key=lambda p: (orden_fases.index(p["fase"]) if p["fase"] in orden_fases else 99,
                                 p["grupo"] or "", p["fecha_hora_local"] or ""))
    for p in partidos:
        if p["grupo"]:
            for lado in ("local", "visitante"):
                if p[lado + "_fifa"]:
                    grupos.setdefault(p["grupo"], {})[p[lado + "_fifa"]] = p[lado + "_nombre"]

    arbol = armar_xml(partidos, grupos, capacidades)
    ET.indent(arbol, space="  ")
    arbol.write(salida, encoding="utf-8", xml_declaration=True)
    print("Se generó {} con {} partidos, {} grupos y {} sedes.".format(
        salida, len(partidos), len(grupos), len({p['estadio'] for p in partidos if p['estadio']})))


if __name__ == "__main__":
    main(sys.argv[1:])
