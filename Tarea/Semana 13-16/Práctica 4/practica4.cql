// ============================================================
// PRÁCTICA 4 - MINERÍA DE GRAFOS
// Aplicando algoritmos de búsqueda de caminos sobre un grafo
// Base de datos: aeropuertos (Neo4j)
// Esquema: (:Airport {Id, Label, country, latitude, longitude})-[:TO {distance}]->(:Airport)
// ============================================================


// ============================================================
// PASO 2 - VERIFICACIÓN DE MIGRACIÓN
// ============================================================

// 2.1 Verificar nodos importados
MATCH (a:Airport)
RETURN count(a) AS total_aeropuertos;

// 2.2 Verificar relaciones importadas
MATCH ()-[r:TO]->()
RETURN count(r) AS total_rutas;

// 2.3 Ver esquema general
CALL db.schema.visualization;

// 2.4 Muestra de datos
MATCH (a:Airport)
RETURN a.Id, a.Label, a.country, a.latitude, a.longitude
LIMIT 10;

// 2.5 Muestra de relaciones con distancia
MATCH (a:Airport)-[r:TO]->(b:Airport)
RETURN a.Label AS origen, b.Label AS destino, r.distance AS distancia_km
LIMIT 10;


// ============================================================
// PASO 3 - ANÁLISIS BÁSICO DEL GRAFO
// ============================================================

// 3.1 Conteo de nodos y relaciones
MATCH (a:Airport)
RETURN count(a) AS nodos;

MATCH ()-[r:TO]->()
RETURN count(r) AS relaciones;

// 3.2 Distribución de aeropuertos por país (Top 20)
MATCH (a:Airport)
RETURN a.country AS pais, count(a) AS cantidad
ORDER BY cantidad DESC
LIMIT 20;

// 3.3 Densidad del grafo (aproximada)
MATCH (a:Airport)
WITH count(a) AS n
MATCH ()-[r:TO]->()
WITH n, count(r) AS m
RETURN n AS nodos, m AS relaciones, toFloat(m) / (n * (n - 1)) AS densidad;

// 3.4 Grado promedio (OutDegree)
MATCH (a:Airport)-[r:TO]->()
RETURN a.Id, a.Label, count(r) AS out_degree
ORDER BY out_degree DESC
LIMIT 20;

// 3.5 Estadísticas de distancia
MATCH ()-[r:TO]->()
RETURN 
  min(r.distance) AS distancia_minima_km,
  max(r.distance) AS distancia_maxima_km,
  avg(r.distance) AS distancia_promedio_km;

// 3.6 Aeropuertos sin conexiones salientes
MATCH (a:Airport)
WHERE NOT (a)-[:TO]->()
RETURN count(a) AS aeropuertos_sin_salida;

// 3.7 Aeropuertos con más conexiones (top 10 por degree total)
MATCH (a:Airport)
OPTIONAL MATCH (a)-[out:TO]->()
OPTIONAL MATCH ()-[in:TO]->(a)
RETURN a.Label AS aeropuerto, a.country AS pais,
       count(DISTINCT out) AS out_degree,
       count(DISTINCT in) AS in_degree,
       count(DISTINCT out) + count(DISTINCT in) AS total_degree
ORDER BY total_degree DESC
LIMIT 10;


// ============================================================
// PROYECCIÓN DEL GRAFO EN GDS (necesaria para todos los algoritmos)
// ============================================================

// Proyección dirigida con peso distance
CALL gds.graph.project(
  'aeropuertos_dirigido',
  'Airport',
  {
    TO: {
      orientation: 'NATURAL',
      properties: ['distance']
    }
  }
)
YIELD graphName, nodeCount, relationshipCount;

// Proyección no dirigida (para MST / Spanning Tree)
CALL gds.graph.project(
  'aeropuertos_nodirigido',
  'Airport',
  {
    TO: {
      orientation: 'UNDIRECTED',
      properties: ['distance']
    }
  }
)
YIELD graphName, nodeCount, relationshipCount;


// ============================================================
// PREGUNTA 4 - BETWEENNESS CENTRALITY (México) + DIJKSTRA SSSP
// Aeropuerto de México con mayor Betweenness → ruta más corta a todos los demás
// ============================================================

// 4.1 Calcular Betweenness Centrality y encontrar el top de México
CALL gds.betweenness.stream('aeropuertos_dirigido')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS airport, score
WHERE airport.country = 'Mexico'
RETURN airport.Id AS id, airport.Label AS aeropuerto, airport.country AS pais, score AS betweenness
ORDER BY score DESC
LIMIT 5;

// 4.2 Dijkstra SSSP desde el aeropuerto de México con mayor Betweenness Centrality
CALL gds.betweenness.stream('aeropuertos_dirigido')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS airport, score
WHERE airport.country = 'Mexico'
ORDER BY score DESC
LIMIT 1
CALL gds.allShortestPaths.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: airport,
    relationshipWeightProperty: 'distance'
  }
)
YIELD sourceNode, targetNode, totalCost
RETURN
  gds.util.asNode(sourceNode).Label AS origen,
  gds.util.asNode(targetNode).Label AS destino,
  gds.util.asNode(targetNode).country AS pais_destino,
  round(totalCost) AS distancia_total_km
ORDER BY totalCost ASC
LIMIT 50;

// 4.3 Versión usando Id conocido directamente
MATCH (source:Airport {Id: 'MEX'})
CALL gds.allShortestPaths.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance'
  }
)
YIELD sourceNode, targetNode, totalCost
RETURN 
  gds.util.asNode(sourceNode).Label AS origen,
  gds.util.asNode(targetNode).Label AS destino,
  gds.util.asNode(targetNode).country AS pais_destino,
  round(totalCost) AS distancia_total_km
ORDER BY totalCost
LIMIT 100;


// ============================================================
// PREGUNTA 5 - CLOSENESS CENTRALITY (Italia) → DEGREE (Canadá)
// Ruta más corta entre ambos aeropuertos
// ============================================================

// 5.1 Calcular Closeness Centrality para Italia
CALL gds.closeness.stream('aeropuertos_dirigido')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS airport, score
WHERE airport.country = 'Italy'
RETURN airport.Id AS id, airport.Label AS aeropuerto, score AS closeness
ORDER BY score DESC
LIMIT 5;

// 5.2 Encontrar aeropuerto de mayor Degree en Canadá
MATCH (a:Airport {country: 'Canada'})
OPTIONAL MATCH (a)-[out:TO]->()
OPTIONAL MATCH ()-[in:TO]->(a)
RETURN a.Id AS id, a.Label AS aeropuerto,
       count(DISTINCT out) + count(DISTINCT in) AS total_degree
ORDER BY total_degree DESC
LIMIT 5;

// 5.3 Ruta más corta
MATCH (origen:Airport {Id: 1555})
MATCH (destino:Airport {Id: 193})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
RETURN
  [nodeId IN nodeIds | gds.util.asNode(nodeId).Label] AS ruta,
  [nodeId IN nodeIds | gds.util.asNode(nodeId).country] AS paises,
  costs AS costos_acumulados_km,
  round(totalCost) AS distancia_total_km;

// 5.4 Mapa
MATCH (origen:Airport {Id: 1555})
MATCH (destino:Airport {Id: 193})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
UNWIND range(0, size(nodeIds)-1) AS i
WITH gds.util.asNode(nodeIds[i]) AS airport, costs[i] AS costo_acumulado, totalCost
RETURN
  airport,
  round(costo_acumulado) AS km_acumulados,
  round(totalCost)       AS distancia_total_km
ORDER BY km_acumulados;


// ============================================================
// PREGUNTA 6 - PAGERANK (China) → DEGREE (Estados Unidos)
// Mostrar origen, costo total, costo acumulado e Id de nodos intermedios
// ============================================================

// 6.1 Calcular PageRank para China
CALL gds.pageRank.stream('aeropuertos_dirigido')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS airport, score
WHERE airport.country = 'China'
RETURN airport.Id AS id, airport.Label AS aeropuerto, score AS pagerank
ORDER BY score DESC
LIMIT 5;

// 6.2 Aeropuerto de mayor Degree en Estados Unidos
MATCH (a:Airport {country: 'United States'})
OPTIONAL MATCH (a)-[out:TO]->()
OPTIONAL MATCH ()-[in:TO]->(a)
RETURN a.Id AS id, a.Label AS aeropuerto,
       count(DISTINCT out) + count(DISTINCT in) AS total_degree
ORDER BY total_degree DESC
LIMIT 5;

// 6.3 Ruta con detalle de costo acumulado por nodo
MATCH (origen:Airport {Id: 3364})
MATCH (destino:Airport {Id: 3682})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
UNWIND range(0, size(nodeIds)-1) AS i
RETURN
  gds.util.asNode(nodeIds[0]).Label AS aeropuerto_origen,
  gds.util.asNode(nodeIds[i]).Id    AS id_nodo,
  gds.util.asNode(nodeIds[i]).Label AS aeropuerto,
  gds.util.asNode(nodeIds[i]).country AS pais,
  round(costs[i])   AS costo_acumulado_km,
  round(totalCost)  AS costo_total_km;


// ============================================================
// PREGUNTA 7 - INDEGREE (Alemania) → INDEGREE (Grecia)
// ============================================================

// 7.1 InDegree de aeropuertos en Alemania
MATCH (a:Airport {country: 'Germany'})
OPTIONAL MATCH ()-[in:TO]->(a)
RETURN a.Id AS id, a.Label AS aeropuerto, count(in) AS in_degree
ORDER BY in_degree DESC
LIMIT 5;

// 7.2 InDegree de aeropuertos en Grecia
MATCH (a:Airport {country: 'Greece'})
OPTIONAL MATCH ()-[in:TO]->(a)
RETURN a.Id AS id, a.Label AS aeropuerto, count(in) AS in_degree
ORDER BY in_degree DESC
LIMIT 5;

// 7.3 Ruta más corta
MATCH (origen:Airport {Id: 340})
MATCH (destino:Airport {Id: 3941})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
RETURN
  [nodeId IN nodeIds | gds.util.asNode(nodeId).Label] AS ruta_completa,
  [nodeId IN nodeIds | gds.util.asNode(nodeId).Id]    AS ids_nodos,
  costs                                                AS costos_acumulados_km,
  round(totalCost)                                     AS distancia_total_km;


// ============================================================
// PREGUNTA 8 - MINIMUM SPANNING TREE desde Guadalajara
// Forma más barata de conectar todos los nodos alcanzables desde GDL
// ============================================================

// 8.1 Verificar Id del aeropuerto de Guadalajara
MATCH (a:Airport)
WHERE a.Label CONTAINS 'Guadalajara' OR a.Id = 'GDL'
RETURN a.Id, a.Label, a.country;

// 8.2 Prim Minimum Spanning Tree desde Guadalajara
MATCH (source:Airport {Id: 'GDL'})
CALL gds.spanningTree.stream(
  'aeropuertos_nodirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance',
    objective: 'minimum'
  }
)
YIELD nodeId, parentId, weight
RETURN 
  gds.util.asNode(nodeId).Label AS aeropuerto,
  gds.util.asNode(nodeId).country AS pais,
  gds.util.asNode(parentId).Label AS conectado_desde,
  round(weight) AS distancia_km
ORDER BY weight;

// 8.3 Costo total del MST desde Guadalajara
MATCH (source:Airport {Id: 1804})
CALL gds.spanningTree.stream(
  'aeropuertos_nodirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance',
    objective: 'minimum'
  }
)
YIELD nodeId, parentId, weight
RETURN 
  count(nodeId) AS nodos_conectados,
  round(sum(weight)) AS costo_total_km;


// ============================================================
// PREGUNTA 9 - PAGERANK (Francia) → aeropuertos FUERA de la ruta mínima
// ============================================================

// 9.1 Aeropuerto con mayor PageRank en Francia
CALL gds.pageRank.stream('aeropuertos_dirigido')
YIELD nodeId, score
WITH gds.util.asNode(nodeId) AS airport, score
WHERE airport.country = 'France'
RETURN airport.Id AS id, airport.Label AS aeropuerto, score AS pagerank
ORDER BY score DESC
LIMIT 5;

// 9.2 Obtener el mínimo número de aeropuertos alcanzables (BFS / hop count)
MATCH (source:Airport {Id: 1382})
CALL gds.bfs.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source
  }
)
YIELD path
WITH nodes(path) AS nodos_ruta
UNWIND nodos_ruta AS n
RETURN DISTINCT n.Id AS id, n.Label AS aeropuerto, n.country AS pais
ORDER BY aeropuerto;

// 9.3 Aeropuertos que quedan FUERA de la ruta alcanzable
MATCH (source:Airport {Id: 1382})
CALL gds.bfs.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source
  }
)
YIELD path
WITH collect(DISTINCT [n IN nodes(path) | n.Id]) AS todos_los_ids
UNWIND todos_los_ids AS lista
UNWIND lista AS id_alcanzable
WITH collect(DISTINCT id_alcanzable) AS alcanzables
MATCH (a:Airport)
WHERE NOT a.Id IN alcanzables
RETURN a.Id AS id, a.Label AS aeropuerto, a.country AS pais
ORDER BY pais, aeropuerto;


// ============================================================
// PREGUNTA 10 - DESDE CANCÚN, máximo 10,000 km sin repetir aeropuertos
// ============================================================

// 10.1 Verificar Id de Cancún
MATCH (a:Airport)
WHERE a.Label CONTAINS 'Cancun' OR a.Label CONTAINS 'Cancún' OR a.Id = 'CUN'
RETURN a.Id, a.Label, a.country;

// 10.2 Dijkstra desde Cancún con límite de 10,000 km (Single Source)
MATCH (source:Airport {Id: 1852})
CALL gds.allShortestPaths.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance'
  }
)
YIELD targetNode, totalCost
WHERE totalCost <= 10000 AND totalCost > 0
RETURN 
  gds.util.asNode(targetNode).Id AS id,
  gds.util.asNode(targetNode).Label AS aeropuerto,
  gds.util.asNode(targetNode).country AS pais,
  round(totalCost) AS distancia_acumulada_km
ORDER BY totalCost;

// 10.3 Conteo de aeropuertos alcanzables desde Cancún dentro de 10,000 km
MATCH (source:Airport {Id: 1852})
CALL gds.allShortestPaths.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance'
  }
)
YIELD targetNode, totalCost
WHERE totalCost <= 10000 AND totalCost > 0
RETURN count(targetNode) AS total_aeropuertos_alcanzables;


// ============================================================
// PREGUNTA 11 - PRESUPUESTO: 18 pesos/km, presupuesto 25,000 pesos
// Máximo de km permitidos: 25000 / 18 = 1388.88 km
// ============================================================

// 11.1 Calcular distancia máxima en km
// Presupuesto: 25,000 pesos / 18 pesos por km = 1,388.88 km máximo

// 11.2 Ruta
MATCH (source:Airport {Id: 1804})
CALL gds.allShortestPaths.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: source,
    relationshipWeightProperty: 'distance'
  }
)
YIELD targetNode, totalCost, nodeIds, costs
WHERE totalCost <= 1388.88 AND totalCost > 0
RETURN 
  gds.util.asNode(nodeIds[0]).Label AS aeropuerto_origen,
  gds.util.asNode(targetNode).Label AS aeropuerto_destino,
  gds.util.asNode(targetNode).country AS pais_destino,
  [nId IN nodeIds | gds.util.asNode(nId).Label] AS ruta_completa,
  round(totalCost) AS distancia_total_km,
  round(totalCost * 18) AS costo_total_pesos,
  25000 - round(totalCost * 18) AS presupuesto_restante_pesos
ORDER BY totalCost DESC;

// 11.3 Detalle del presupuesto gastado nodo por nodo en la ruta más lejana dentro del presupuesto
MATCH (origen:Airport {Id: 1804}), (destino:Airport {Id: 1795})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
UNWIND range(0, size(nodeIds)-1) AS i
RETURN
  gds.util.asNode(nodeIds[0]).Label AS aeropuerto_origen,
  i AS paso,
  gds.util.asNode(nodeIds[i]).Id AS id_aeropuerto,
  gds.util.asNode(nodeIds[i]).Label AS aeropuerto,
  gds.util.asNode(nodeIds[i]).country AS pais,
  round(costs[i]) AS km_acumulados,
  round(costs[i] * 18) AS pesos_gastados_acumulados,
  round(totalCost) AS km_totales,
  round(totalCost * 18) AS costo_total_pesos,
  25000 - round(totalCost * 18) AS presupuesto_restante;

// 11.4 Mapa
MATCH (origen:Airport {Id: 1804})
MATCH (destino:Airport {Id: 1795})
CALL gds.shortestPath.dijkstra.stream(
  'aeropuertos_dirigido',
  {
    sourceNode: origen,
    targetNode: destino,
    relationshipWeightProperty: 'distance'
  }
)
YIELD nodeIds, costs, totalCost
UNWIND range(0, size(nodeIds)-1) AS i
WITH gds.util.asNode(nodeIds[i]) AS airport, costs[i] AS costo_acumulado, totalCost
RETURN
  airport,
  round(costo_acumulado) AS km_acumulados,
  round(totalCost)       AS distancia_total_km
ORDER BY km_acumulados;