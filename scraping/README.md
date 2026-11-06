# Scraping del Mundial 2026 (Wikipedia → XML)

Script: `scraper_mundial_2026.py` (Python 3.9 o superior, solo biblioteca estándar: no hay que instalar nada).

## Uso

```
python scraper_mundial_2026.py C:\Importar\mundial_2026_wikipedia.xml
```

Tarda alrededor de 30 segundos (hace una pausa de 1 segundo entre pedidos). Después se importa desde SQL Server:

```sql
EXEC Torneo.Importar_XML_Mundial @nombre_archivo = 'C:\Importar\mundial_2026_wikipedia.xml';
```

Para probar el parser sin Internet: `python scraper_mundial_2026.py --prueba prueba.xml`.

## Páginas de origen

- `https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_Group_A` … `Group_L` (fase de grupos)
- `https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_knockout_stage` (fase eliminatoria)
- El artículo de cada estadio (capacidad)

## Técnica

1. Se descarga el código fuente de cada página (wikitext) con `?action=raw`.
2. Se buscan las plantillas `{{Football box ...}}` (una por partido) con un parser de llaves balanceadas y se
   separan sus parámetros (`date`, `time`, `team1`, `score`, `team2`, `stadium`, `attendance`, `referee`).
3. Con expresiones regulares se obtienen: fecha, hora local y huso (`UTC−6`), código FIFA de cada selección
   (`{{fb|MEX}}`), goles, estadio y ciudad (enlaces `[[...]]`), asistencia y árbitro.
4. La fase de la eliminatoria sale del título de la sección donde está el partido (`Round of 32` → Dieciseisavos de final, etc.).
5. La capacidad de cada estadio sale del campo `capacity` de la ficha de su artículo.
6. El país de cada sede se deduce de la ciudad (México, Canadá o Estados Unidos).

## Límites de uso

Wikipedia no pide clave. Su política exige un User-Agent que identifique la aplicación (el script lo envía) y no
saturar el sitio (el script espera 1 segundo entre pedidos).
