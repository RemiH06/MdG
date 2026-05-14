"""
=============================================================
 PROYECTO 2 - MINERÍA DE GRAFOS
 Spotify Artist Feature Collaboration Network
 Script ETL: Etapa 2 (Construcción del Grafo) - Metodología KDG
=============================================================

Objetivo:
    Transformar los 2 archivos originales del dataset
    (nodes.csv, edges.csv) en 4 archivos CSV listos para
    ser importados a Neo4j como un grafo HETEROGÉNEO con
    dos tipos de nodo (Artist, Genre) y dos tipos de
    relación (HAS_GENRE, COLLABORATED_WITH).

Justificación del modelo heterogéneo:
    En el dataset original, la columna `genres` es un string
    que contiene una lista (ej: "['pop', 'rock']"). Almacenarla
    como propiedad-array limita el análisis relacional. Al
    promover los géneros a nodos propios:
      - Podemos preguntar qué géneros se conectan más entre sí.
      - Podemos calcular comunidades sobre el bipartito
        artista-género.
      - El grafo queda alineado con la metodología KDG para
        grafos etiquetados y heterogéneos (Ortega-Vázquez et al.,
        Applied Sciences 2024).

Uso:
    Coloca este script en la misma carpeta que nodes.csv y
    edges.csv, y ejecútalo con:
        python etl.py
    Se generará una subcarpeta ./neo4j_import/ con los 4 CSVs.
"""

import ast
import pandas as pd
from pathlib import Path

# -------------------------------------------------------------
# Configuración de rutas (relativas a la ubicación del script)
# -------------------------------------------------------------
SCRIPT_DIR = Path(__file__).parent
INPUT_DIR  = SCRIPT_DIR                       # nodes.csv y edges.csv aquí
OUTPUT_DIR = SCRIPT_DIR / "neo4j_import"      # se crea al lado del script
OUTPUT_DIR.mkdir(exist_ok=True)


# -------------------------------------------------------------
# 1) CARGA DE DATOS ORIGINALES
# -------------------------------------------------------------
print("[1/5] Cargando datos originales...")
nodes = pd.read_csv(INPUT_DIR / "nodes.csv")
edges = pd.read_csv(INPUT_DIR / "edges.csv")
print(f"      nodes: {len(nodes):,} filas, {nodes.shape[1]} columnas")
print(f"      edges: {len(edges):,} filas, {edges.shape[1]} columnas")


# -------------------------------------------------------------
# 2) LIMPIEZA DE NODOS
# -------------------------------------------------------------
print("\n[2/5] Limpiando nodos...")

# 2.1) Quitar filas con nombre nulo (4 casos en el dataset)
nulos_name = nodes['name'].isna().sum()
nodes = nodes.dropna(subset=['name']).copy()
print(f"      Eliminadas {nulos_name} filas con name nulo")

# 2.2) Castear followers a int (vienen como float por los NaN previos)
nodes['followers'] = nodes['followers'].fillna(0).astype('int64')

# 2.3) Parsear la columna 'genres' (string -> lista real)
def parse_list(s):
    """Convierte un string tipo "['pop', 'rock']" en ['pop', 'rock']."""
    if pd.isna(s) or s == '[]':
        return []
    try:
        return ast.literal_eval(s)
    except (ValueError, SyntaxError):
        return []

nodes['genres_list'] = nodes['genres'].apply(parse_list)


# -------------------------------------------------------------
# 3) GENERAR artists.csv (nodos :Artist)
#    Sólo conservamos atributos relevantes para el análisis.
# -------------------------------------------------------------
print("\n[3/5] Generando artists.csv...")
artists_out = nodes[['spotify_id', 'name', 'followers', 'popularity']].copy()
artists_out.to_csv(OUTPUT_DIR / "artists.csv", index=False)
print(f"      -> artists.csv ({len(artists_out):,} filas)")


# -------------------------------------------------------------
# 4) GENERAR genres.csv y artist_genre.csv
# -------------------------------------------------------------
print("\n[4/5] Generando genres.csv y artist_genre.csv...")

# 4.1) Conjunto único de géneros que aparecen en TODO el dataset
all_genres = set()
for g_list in nodes['genres_list']:
    all_genres.update(g_list)
genres_df = pd.DataFrame({'name': sorted(all_genres)})
genres_df.to_csv(OUTPUT_DIR / "genres.csv", index=False)
print(f"      -> genres.csv ({len(genres_df):,} géneros únicos)")

# 4.2) Tabla puente artista-género (cada fila = una arista HAS_GENRE)
ag_rows = []
for sid, glist in zip(nodes['spotify_id'], nodes['genres_list']):
    for g in glist:
        ag_rows.append((sid, g))
ag_df = pd.DataFrame(ag_rows, columns=['spotify_id', 'genre'])
ag_df.to_csv(OUTPUT_DIR / "artist_genre.csv", index=False)
print(f"      -> artist_genre.csv ({len(ag_df):,} relaciones)")


# -------------------------------------------------------------
# 5) GENERAR collaborations.csv (aristas :COLLABORATED_WITH)
#    Filtramos aristas cuyos endpoints existan en el set de
#    artistas válidos (por seguridad referencial).
# -------------------------------------------------------------
print("\n[5/5] Generando collaborations.csv...")
valid_ids = set(nodes['spotify_id'])
mask = edges['id_0'].isin(valid_ids) & edges['id_1'].isin(valid_ids)
edges_clean = edges[mask].copy()
descartadas = len(edges) - len(edges_clean)
edges_clean.to_csv(OUTPUT_DIR / "collaborations.csv", index=False)
print(f"      -> collaborations.csv ({len(edges_clean):,} filas)")
print(f"         (descartadas {descartadas} aristas con endpoints inválidos)")


# -------------------------------------------------------------
# RESUMEN FINAL
# -------------------------------------------------------------
print("\n" + "=" * 50)
print("RESUMEN DEL ETL")
print("=" * 50)
print(f"Artistas (nodos :Artist):              {len(artists_out):>10,}")
print(f"Géneros únicos (nodos :Genre):         {len(genres_df):>10,}")
print(f"Aristas :HAS_GENRE:                    {len(ag_df):>10,}")
print(f"Aristas :COLLABORATED_WITH:            {len(edges_clean):>10,}")
print(f"\nArchivos listos en: {OUTPUT_DIR}")
print("Siguiente paso: copiar a la carpeta import/ del DBMS de Neo4j")
print("y ejecutar 01_load.cql desde Neo4j Browser.")