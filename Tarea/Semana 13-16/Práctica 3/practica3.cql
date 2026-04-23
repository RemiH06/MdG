// ============================================================
//  PRÁCTICA 3 - MINERÍA DE GRAFOS
//  Recomendaciones sobre un grafo - Papelería
//
//  Estructura real de los CSV:
//    Clientes.csv       → id_cliente
//    Productos.csv      → id_producto, Producto
//    Operaciones.csv    → id_operacion, id_cliente, fecha_operacion
//    Detalles.csv       → id_detalle, id_operacion, id_producto, cantidad_producto
//    ES_PARTE_DE.csv    → id_cliente, id_operacion
//    CONTIENE.csv       → id_operacion, id_producto
//    APARECE.csv        → id_operacion, id_producto
// ============================================================


// ============================================================
// INCISO 2 - MODELADO Y MIGRACIÓN
// ============================================================

// 2.3 Restricciones de unicidad
CREATE CONSTRAINT FOR (c:Clientes)    REQUIRE c.id_cliente   IS UNIQUE;
CREATE CONSTRAINT FOR (p:Productos)   REQUIRE p.id_producto  IS UNIQUE;
CREATE CONSTRAINT FOR (o:Operaciones) REQUIRE o.id_operacion IS UNIQUE;
CREATE CONSTRAINT FOR (d:Detalles)    REQUIRE d.id_detalle   IS UNIQUE;

// 2.3 Cargar nodos Clientes
LOAD CSV WITH HEADERS FROM 'file:///Clientes.csv' AS row
MERGE (c:Clientes {id_cliente: toInteger(row.id_cliente)});

// 2.3 Cargar nodos Productos
LOAD CSV WITH HEADERS FROM 'file:///Productos.csv' AS row
MERGE (p:Productos {id_producto: toInteger(row.id_producto)})
SET p.nombre = row.Producto;

// 2.3 Cargar nodos Operaciones
// Nota: fecha_operacion viene en formato dd/MM/yyyy
LOAD CSV WITH HEADERS FROM 'file:///Operaciones.csv' AS row
MERGE (o:Operaciones {id_operacion: toInteger(row.id_operacion)})
SET o.id_cliente      = toInteger(row.id_cliente),
    o.fecha_operacion = date(apoc.date.parse(row.fecha_operacion, 'ms', 'dd/MM/yyyy'));

// 2.3 Cargar nodos Detalles
LOAD CSV WITH HEADERS FROM 'file:///Detalles.csv' AS row
MERGE (d:Detalles {id_detalle: toInteger(row.id_detalle)})
SET d.id_operacion      = toInteger(row.id_operacion),
    d.id_producto       = toInteger(row.id_producto),
    d.cantidad_producto = toInteger(row.cantidad_producto);

// 2.3 Crear relaciones ES_PARTE_DE (Clientes → Operaciones)
LOAD CSV WITH HEADERS FROM 'file:///ES_PARTE_DE.csv' AS row
MATCH (c:Clientes    {id_cliente:   toInteger(row.id_cliente)})
MATCH (o:Operaciones {id_operacion: toInteger(row.id_operacion)})
MERGE (c)-[:ES_PARTE_DE]->(o);

// 2.3 Crear relaciones CONTIENE (Operaciones → Detalles)
LOAD CSV WITH HEADERS FROM 'file:///Detalles.csv' AS row
MATCH (o:Operaciones {id_operacion: toInteger(row.id_operacion)})
MATCH (d:Detalles    {id_detalle:   toInteger(row.id_detalle)})
MERGE (o)-[:CONTIENE]->(d);

// 2.3 Crear relaciones APARECE (Productos → Detalles)
LOAD CSV WITH HEADERS FROM 'file:///Detalles.csv' AS row
MATCH (p:Productos {id_producto: toInteger(row.id_producto)})
MATCH (d:Detalles  {id_detalle:  toInteger(row.id_detalle)})
MERGE (p)-[:APARECE]->(d);

// 2.4 Verificar esquema del grafo (BLOOM)
CALL db.schema.visualization();


// ============================================================
// INCISO 3 - ANÁLISIS BÁSICO DEL GRAFO
// ============================================================

// 3.1 Conteo de nodos por etiqueta
MATCH (n)
RETURN labels(n) AS etiqueta, count(n) AS total
ORDER BY total DESC;

// 3.2 Conteo de relaciones por tipo
MATCH ()-[r]->()
RETURN type(r) AS tipo_relacion, count(r) AS total
ORDER BY total DESC;

// 3.3 Grado de salida y entrada promedio por etiqueta
MATCH (n)
RETURN labels(n) AS etiqueta,
       avg(COUNT { (n)-->() }) AS grado_salida_promedio,
       avg(COUNT { (n)<--() }) AS grado_entrada_promedio;

// 3.4 Densidad estimada del grafo
MATCH (n)
WITH count(n) AS nodos
MATCH ()-[r]->()
WITH nodos, count(r) AS aristas
RETURN aristas AS total_aristas,
       nodos    AS total_nodos,
       toFloat(aristas) / (nodos * (nodos - 1)) AS densidad;

// 3.5 Distribución de operaciones por cliente
MATCH (c:Clientes)-[:ES_PARTE_DE]->(o:Operaciones)
RETURN c.id_cliente, count(o) AS num_operaciones
ORDER BY num_operaciones DESC
LIMIT 10;

// 3.6 Productos más referenciados en detalles
MATCH (p:Productos)-[:APARECE]->(d:Detalles)
RETURN p.Producto, count(d) AS apariciones
ORDER BY apariciones DESC
LIMIT 10;


// ============================================================
// INCISO 4 - MODIFICACIÓN ESTRUCTURAL DEL GRAFO
//            Relación directa COMPRADO_CON entre Productos
// ============================================================

// 4.1 Crear relación COMPRADO_CON usando APARECE.csv
//        (productos que comparten la misma operación). Este sí lo importo desde aquí porque no me hallé con la herramienta.
LOAD CSV WITH HEADERS FROM 'file:///APARECE.csv' AS row
WITH toInteger(row.id_operacion) AS op, toInteger(row.id_producto) AS prod
WITH op, collect(prod) AS productos
UNWIND productos AS p1
UNWIND productos AS p2
WITH op, p1, p2
WHERE p1 < p2
MATCH (pr1:Productos {id_producto: p1})
MATCH (pr2:Productos {id_producto: p2})
MERGE (pr1)-[r:COMPRADO_CON]-(pr2)
ON CREATE SET r.weight = 1
ON MATCH  SET r.weight = r.weight + 1;

// 4.2 Verificar la nueva relación
MATCH (p1:Productos)-[r:COMPRADO_CON]-(p2:Productos)
RETURN p1.nombre, p2.nombre, r.weight
ORDER BY r.weight DESC
LIMIT 10;

// 4.3 Esquema del grafo modificado (BLOOM)
CALL db.schema.visualization();


// ============================================================
// INCISO 4 - PROYECCIÓN DE SUBGRAFOS GDS
// ============================================================

// 4.4 Subgrafo no dirigido de Productos
CALL gds.graph.project(
    'mUG_Productos',
    'Productos',
    {
        COMPRADO_CON: {
            orientation: 'UNDIRECTED',
            properties: 'weight'
        }
    }
);

// 4.5 Subgrafo dirigido de Productos
CALL gds.graph.project(
    'mDG_Productos',
    'Productos',
    {
        COMPRADO_CON: {
            orientation: 'NATURAL',
            properties: 'weight'
        }
    }
);

// 4.6 Listar subgrafos creados
CALL gds.graph.list()
YIELD graphName, nodeCount, relationshipCount, database, creationTime;


// ============================================================
// INCISO 4 - ALGORITMOS DE CENTRALIDAD (mínimo 4)
// ============================================================

// 4.C1 PageRank
CALL gds.pageRank.write('mUG_Productos', {
    maxIterations: 20,
    dampingFactor: 0.85,
    relationshipWeightProperty: 'weight',
    writeProperty: 'pagerank'
})
YIELD nodePropertiesWritten, ranIterations;

// 4.C2 Betweenness Centrality
CALL gds.betweenness.write('mUG_Productos', {
    writeProperty: 'betweenness'
})
YIELD nodePropertiesWritten;

// 4.C3 Degree Centrality
CALL gds.degree.write('mUG_Productos', {
    orientation: 'UNDIRECTED',
    relationshipWeightProperty: 'weight',
    writeProperty: 'degree_centrality'
})
YIELD nodePropertiesWritten;

// 4.C4 Closeness Centrality
CALL gds.closeness.write('mUG_Productos', {
    writeProperty: 'closeness'
})
YIELD nodePropertiesWritten;

// Verificar métricas escritas en los nodos
MATCH (p:Productos)
RETURN p.Producto, p.pagerank, p.betweenness, p.degree_centrality, p.closeness
ORDER BY p.pagerank DESC
LIMIT 10;


// ============================================================
// INCISO 4 - ALGORITMOS DE DETECCIÓN DE COMUNIDADES (mínimo 4)
// ============================================================

// 4.D1 Louvain
CALL gds.louvain.write('mUG_Productos', {
    relationshipWeightProperty: 'weight',
    writeProperty: 'comunidad_louvain'
})
YIELD communityCount, modularity;

// 4.D2 Label Propagation
CALL gds.labelPropagation.write('mUG_Productos', {
    relationshipWeightProperty: 'weight',
    writeProperty: 'comunidad_lpa'
})
YIELD communityCount, ranIterations;

// 4.D3 Weakly Connected Components
CALL gds.wcc.write('mUG_Productos', {
    writeProperty: 'componente_wcc'
})
YIELD componentCount;

// 4.D4 Triangle Count
CALL gds.triangleCount.write('mUG_Productos', {
    writeProperty: 'triangulos'
})
YIELD nodeCount;

// Verificar propiedades de comunidad escritas
MATCH (p:Productos)
RETURN p.Producto,
       p.comunidad_louvain,
       p.comunidad_lpa,
       p.componente_wcc,
       p.triangulos
ORDER BY p.comunidad_louvain
LIMIT 20;


// ============================================================
// INCISO 5 - TABLERO DE ANÁLISIS GENERAL
// ============================================================

// 5.1 Top 5 productos más comprados
MATCH (p:Productos)-[:APARECE]->(d:Detalles)
RETURN p.id_producto, p.Producto, count(d) AS veces_comprado
ORDER BY veces_comprado DESC
LIMIT 5;

// 5.2 Promedio de productos distintos comprados por cliente
MATCH (c:Clientes)-[:ES_PARTE_DE]->(o:Operaciones)-[:CONTIENE]->(d:Detalles)
      <-[:APARECE]-(p:Productos)
WITH c.id_cliente AS cliente, count(DISTINCT p.id_producto) AS productos_distintos
RETURN avg(productos_distintos) AS promedio_productos_por_cliente;

// 5.3 Promedio de productos comprados por año
MATCH (o:Operaciones)-[:CONTIENE]->(d:Detalles)
WITH split(o.fecha_operacion, '/')[2] AS anio, count(d) AS total_productos
RETURN anio, avg(total_productos) AS promedio_productos_por_anio
ORDER BY anio;

// 5.4 Promedio de productos comprados por operación
MATCH (o:Operaciones)-[:CONTIENE]->(d:Detalles)
WITH o.id_operacion AS id_op, count(d) AS productos_en_operacion
RETURN avg(productos_en_operacion) AS promedio_productos_por_operacion;


// ============================================================
// INCISO 6 - TABLERO DE RECOMENDACIONES (parametrizado)
//   Parámetros: $id_producto | $nombre_producto |
//               $id_cliente  | $id_operacion   | $fecha
// ============================================================

// ── Por id_producto ──────────────────────────────────────────

// 6.1 Histórico
MATCH (p:Productos {id_producto: toInteger($productos_id_producto)})-[r:COMPRADO_CON]-(rec:Productos)
RETURN rec.Producto AS producto_recomendado, r.weight AS veces_juntos
ORDER BY r.weight DESC
LIMIT 4;

// 6.2 Centralidad
MATCH (p:Productos {id_producto: toInteger($productos_id_producto)})-[:COMPRADO_CON]-(rec:Productos)
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3 Comunidad
MATCH (p:Productos {id_producto: toInteger($productos_id_producto)})
MATCH (rec:Productos)
WHERE rec.comunidad_louvain = p.comunidad_louvain
  AND rec.id_producto <> p.id_producto
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;

// ── Por nombre_producto ──────────────────────────────────────

// 6.1b Histórico
MATCH (p:Productos)-[r:COMPRADO_CON]-(rec:Productos)
WHERE toLower(p.Producto) CONTAINS toLower($productos_producto)
RETURN rec.Producto AS producto_recomendado, r.weight AS veces_juntos
ORDER BY r.weight DESC
LIMIT 4;

// 6.2b Centralidad
MATCH (p:Productos)-[:COMPRADO_CON]-(rec:Productos)
WHERE toLower(p.Producto) CONTAINS toLower($productos_producto)
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3b Comunidad
MATCH (p:Productos)
WHERE toLower(p.Producto) CONTAINS toLower($productos_producto)
MATCH (rec:Productos)
WHERE rec.comunidad_louvain = p.comunidad_louvain
  AND rec.id_producto <> p.id_producto
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;

// ── Por id_cliente ───────────────────────────────────────────

// 6.1c Histórico
MATCH (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->(o:Operaciones)
      -[:CONTIENE]->(d:Detalles)<-[:APARECE]-(comprado:Productos)
WITH collect(DISTINCT comprado.id_producto) AS ya_comprados
MATCH (comprado2:Productos)-[r:COMPRADO_CON]-(rec:Productos)
WHERE comprado2.id_producto IN ya_comprados
  AND NOT rec.id_producto IN ya_comprados
RETURN rec.Producto AS producto_recomendado, sum(r.weight) AS score
ORDER BY score DESC
LIMIT 4;

// 6.2c Centralidad
MATCH (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->(o:Operaciones)
      -[:CONTIENE]->(d:Detalles)<-[:APARECE]-(comprado:Productos)
WITH collect(DISTINCT comprado.id_producto) AS ya_comprados
MATCH (comprado2:Productos)-[:COMPRADO_CON]-(rec:Productos)
WHERE comprado2.id_producto IN ya_comprados
  AND NOT rec.id_producto IN ya_comprados
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3c Comunidad
MATCH (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->(o:Operaciones)
      -[:CONTIENE]->(d:Detalles)<-[:APARECE]-(comprado:Productos)
WITH collect(DISTINCT comprado.comunidad_louvain) AS comunidades,
     collect(DISTINCT comprado.id_producto) AS ya_comprados
MATCH (rec:Productos)
WHERE rec.comunidad_louvain IN comunidades
  AND NOT rec.id_producto IN ya_comprados
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;

// ── Por id_operacion ─────────────────────────────────────────

// 6.1d Histórico
MATCH (o:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->(d:Detalles)
      <-[:APARECE]-(p:Productos)
WITH collect(DISTINCT p.id_producto) AS en_operacion
MATCH (p2:Productos)-[r:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN en_operacion
  AND NOT rec.id_producto IN en_operacion
RETURN rec.Producto AS producto_recomendado, sum(r.weight) AS score
ORDER BY score DESC
LIMIT 4;

// 6.2d Centralidad
MATCH (o:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->(d:Detalles)
      <-[:APARECE]-(p:Productos)
WITH collect(DISTINCT p.id_producto) AS en_operacion
MATCH (p2:Productos)-[:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN en_operacion
  AND NOT rec.id_producto IN en_operacion
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3d Comunidad
MATCH (o:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->(d:Detalles)
      <-[:APARECE]-(p:Productos)
WITH collect(DISTINCT p.comunidad_louvain) AS comunidades,
     collect(DISTINCT p.id_producto) AS en_operacion
MATCH (rec:Productos)
WHERE rec.comunidad_louvain IN comunidades
  AND NOT rec.id_producto IN en_operacion
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;

// ── Por fecha ────────────────────────────────────────────────
// Formato del parámetro $fecha: 'dd/MM/yyyy'  ej. '12/02/2020'

// 6.1e Histórico
MATCH (o:Operaciones)-[:CONTIENE]->(d:Detalles)<-[:APARECE]-(p:Productos)
WHERE o.fecha_operacion = $operaciones_fecha_operacion
WITH collect(DISTINCT p.id_producto) AS en_fecha
MATCH (p2:Productos)-[r:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN en_fecha
  AND NOT rec.id_producto IN en_fecha
RETURN rec.Producto AS producto_recomendado, sum(r.weight) AS score
ORDER BY score DESC
LIMIT 4;

// 6.2e Centralidad
MATCH (o:Operaciones)-[:CONTIENE]->(d:Detalles)<-[:APARECE]-(p:Productos)
WHERE o.fecha_operacion = $operaciones_fecha_operacion
WITH collect(DISTINCT p.id_producto) AS en_fecha
MATCH (p2:Productos)-[:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN en_fecha
  AND NOT rec.id_producto IN en_fecha
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3e Comunidad
MATCH (o:Operaciones)-[:CONTIENE]->(d:Detalles)<-[:APARECE]-(p:Productos)
WHERE o.fecha_operacion = $operaciones_fecha_operacion
WITH collect(DISTINCT p.comunidad_louvain) AS comunidades,
     collect(DISTINCT p.id_producto) AS en_fecha
MATCH (rec:Productos)
WHERE rec.comunidad_louvain IN comunidades
  AND NOT rec.id_producto IN en_fecha
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;

// ── Todo junto ────────────────────────────────────────────────

// 6.1 Histórico (una sola consulta, 5 parámetros)
MATCH (p:Productos)
WHERE p.id_producto = toInteger($productos_id_producto)
   OR toLower(p.Producto) CONTAINS toLower($productos_producto)
   OR p.id_producto IN [
        (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->
        (:Operaciones)-[:CONTIENE]->(:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {fecha_operacion: $operaciones_fecha_operacion})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
WITH collect(DISTINCT p.id_producto) AS semilla
MATCH (p2:Productos)-[r:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN semilla
  AND NOT rec.id_producto IN semilla
RETURN rec.Producto AS producto_recomendado, sum(r.weight) AS score
ORDER BY score DESC
LIMIT 4;

// 6.2 Centralidad
MATCH (p:Productos)
WHERE p.id_producto = toInteger($productos_id_producto)
   OR toLower(p.Producto) CONTAINS toLower($productos_producto)
   OR p.id_producto IN [
        (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->
        (:Operaciones)-[:CONTIENE]->(:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {fecha_operacion: $operaciones_fecha_operacion})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
WITH collect(DISTINCT p.id_producto) AS semilla
MATCH (p2:Productos)-[:COMPRADO_CON]-(rec:Productos)
WHERE p2.id_producto IN semilla
  AND NOT rec.id_producto IN semilla
RETURN DISTINCT(rec.Producto) AS producto_recomendado, rec.pagerank AS pagerank
ORDER BY rec.pagerank DESC
LIMIT 4;

// 6.3 Comunidad
MATCH (p:Productos)
WHERE p.id_producto = toInteger($productos_id_producto)
   OR toLower(p.Producto) CONTAINS toLower($productos_producto)
   OR p.id_producto IN [
        (c:Clientes {id_cliente: toInteger($clientes_id_cliente)})-[:ES_PARTE_DE]->
        (:Operaciones)-[:CONTIENE]->(:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {id_operacion: toInteger($operaciones_id_operacion)})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
   OR p.id_producto IN [
        (:Operaciones {fecha_operacion: $operaciones_fecha_operacion})-[:CONTIENE]->
        (:Detalles)<-[:APARECE]-(px:Productos) | px.id_producto
      ]
WITH collect(DISTINCT p.comunidad_louvain) AS comunidades,
     collect(DISTINCT p.id_producto) AS semilla
MATCH (rec:Productos)
WHERE rec.comunidad_louvain IN comunidades
  AND NOT rec.id_producto IN semilla
RETURN rec.Producto AS producto_recomendado, rec.pagerank AS relevancia
ORDER BY rec.pagerank DESC
LIMIT 4;