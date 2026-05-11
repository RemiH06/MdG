![Neo4j](https://img.shields.io/badge/Neo4j-008CC1?style=for-the-badge&logo=neo4j&logoColor=white)
![Cypher](https://img.shields.io/badge/Cypher-Query_Language-blue?style=for-the-badge)

```ascii
 ███╗   ███╗██╗███╗   ██╗███████╗██████╗ ██╗ █████╗     ██████╗ ███████╗
 ████╗ ████║██║████╗  ██║██╔════╝██╔══██╗██║██╔══██╗    ██╔══██╗██╔════╝
 ██╔████╔██║██║██╔██╗ ██║█████╗  ██████╔╝██║███████║    ██║  ██║█████╗  
 ██║╚██╔╝██║██║██║╚██╗██║██╔══╝  ██╔══██╗██║██╔══██║    ██║  ██║██╔══╝  
 ██║ ╚═╝ ██║██║██║ ╚████║███████╗██║  ██║██║██║  ██║    ██████╔╝███████╗
 ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝    ╚═════╝ ╚══════╝
  ██████╗ ██████╗  █████╗ ███████╗ ██████╗ ███████╗
 ██╔════╝ ██╔══██╗██╔══██╗██╔════╝██╔═══██╗██╔════╝
 ██║  ███╗██████╔╝███████║█████╗  ██║   ██║███████╗
 ██║   ██║██╔══██╗██╔══██║██╔══╝  ██║   ██║╚════██║
 ╚██████╔╝██║  ██║██║  ██║██║     ╚██████╔╝███████║
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝

        by Remi (@RemiH06) · ITESO · 5to Semestre · P2026
```

---

## Descripción

Repositorio de apuntes, prácticas, tareas y proyectos de la materia **Minería de Grafos (MdG)** cursada en el 5to semestre del ITESO (Primavera 2026). Incluye código Cypher, notebooks de Python y documentos de análisis sobre bases de datos de grafos con Neo4j.

---

## Temas vistos en el semestre

### Fundamentos teóricos
- Diferencias entre bases de datos **SQL y NoSQL** (ACID vs CAP, escalamiento vertical vs horizontal)
- Teoría de grafos: definición formal `G = (V, E)`, matriz de adyacencia, lista de adyacencia, pares ordenados
- Grafos dirigidos, no dirigidos y homogéneos

### Neo4j y Cypher
- Instalación y configuración del entorno
- Sintaxis básica: nodos `()`, relaciones `-->`, propiedades `{}`
- Operaciones CRUD: `CREATE`, `MATCH`, `SET`, `REMOVE`, `RETURN`
- Comparación con SQL: `SELECT → RETURN`, `FROM → MATCH`, `WHERE → WHERE`
- Importación de datos con archivos CSV
- Creación y gestión de subgrafos con `gds.graph.project()`

### Algoritmos de centralidad
- **Degree Centrality** (in-degree, out-degree)
- **PageRank** (con factor de amortiguación y número de iteraciones)
- **Betweenness Centrality**
- **Closeness Centrality**
- **Articulation Points**

### Detección de comunidades
- **Louvain** (con comunidades intermedias y semillas)
- **Weakly Connected Components (WCC)**
- **Strongly Connected Components (SCC)**
- **Label Propagation** (con y sin semilla)
- **K-1 Coloring**

### Algoritmos de similitud
- **Node Similarity** (basada en relaciones compartidas)
- **K-Nearest Neighbors (KNN)** (basada en atributos de nodos)

### Algoritmos de búsqueda de caminos
- **Shortest Path** con Dijkstra (dirigido y no dirigido)
- **All Shortest Paths** con Delta-Stepping
- **Minimum Weight Spanning Tree (MWST)**
- Análisis de saltos con `r*1..n`

### Sistemas de recomendación
- Recomendación basada en co-ocurrencia en órdenes (dataset Northwind)
- Filtrado por categoría, proveedor y cliente
- Recomendación colaborativa con Node Similarity y KNN

### Datasets trabajados
| Dataset | Descripción |
|---|---|
| Red social (Personas / Amigos / Pasatiempos) | Grafo social básico para consultas Cypher |
| Marvel (SuperHeroes & Villains) | Centralidad, comunidades y caminos |
| Neo4j Movies | Exploración y consultas sobre actores y películas |
| Northwind (Neo4j) | Recomendaciones en base a órdenes de productos |
| Game of Thrones (S1–S8) | Proyecto final de análisis de red de personajes |
| Estados de México | Coloración de grafos y mapas con geojson |
| Papelería (dataset propio) | Operaciones, clientes y productos |
| Aeropuertos | Algoritmos de caminos |

---

## Estructura del repositorio

```
MdG/
├── Apuntes/          # Notas de clase (.md) y código de sesiones (.cql)
├── Examenes/         # Exámenes aplicados y datos de apoyo
├── Material/         # Datasets CSV, guías de prácticas y material del profesor
└── Tarea/
    ├── Semana 1-4    # Fundamentos Neo4j, Cypher y modelado
    ├── Semana 5-8    # Algoritmos de centralidad y comunidades
    ├── Semana 9-12   # Proyecto 1: Game of Thrones
    └── Semana 13-16  # Caminos, recomendaciones y Proyecto 2
```

---

## Setup

1. Instalar dependencias de Python:

   ```bash
   pip install -r Material/env_setup/requirements.txt
   ```

2. Tener Neo4j Desktop o Neo4j AuraDB activo con el plugin **Graph Data Science (GDS)** habilitado.

3. Para los notebooks de análisis, abrir con Jupyter:

   ```bash
   jupyter notebook
   ```

---

## Tecnologías

- [Neo4j](https://neo4j.com/) + Graph Data Science (GDS)
- Cypher Query Language
- Python (driver `neo4j`, `pandas`, `geopandas`, `matplotlib`)
- Neo4j Bloom (visualización)