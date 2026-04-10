// ============================================================
// PROYECTO 1 - MINERÍA DE GRAFOS
// Game of Thrones - Red de Interacciones entre Personajes
// ============================================================


// ============================================================
// 0. EXPLORACIÓN INICIAL
// ============================================================

// Esquema del grafo
CALL db.schema.visualization;

// Ver todo el grafo
MATCH (p)-[r]-(q)
RETURN p, r, q;

// Contar nodos
MATCH (p:Personaje)
RETURN COUNT(p) AS total_personajes;

// Contar relaciones
MATCH ()-[r:HABLA]->()
RETURN COUNT(r) AS total_interacciones;

// Ver todos los personajes
MATCH (p:Personaje)
RETURN p.Id AS id, p.Label AS nombre
ORDER BY p.Label;

// Ver muestra de relaciones con peso y temporada
MATCH (a:Personaje)-[r:HABLA]->(b:Personaje)
RETURN a.Label AS origen, b.Label AS destino, r.Weight AS peso, r.Season AS temporada
ORDER BY r.Weight DESC
LIMIT 20;

// Distribución de interacciones por temporada
MATCH ()-[r:HABLA]->()
RETURN r.Season AS temporada, COUNT(r) AS num_interacciones, SUM(r.Weight) AS peso_total
ORDER BY temporada;


// ============================================================
// 1. PROYECCIÓN DE SUBGRAFOS
// ============================================================

// Dirigido NATURAL (Source -> Target con pesos)
CALL gds.graph.project(
    'GoT_Natural',
    'Personaje',
    {HABLA: {
        orientation: 'NATURAL',
        properties: 'Weight'
    }}
);

// Dirigido REVERSE (Target -> Source con pesos)
CALL gds.graph.project(
    'GoT_Reverse',
    'Personaje',
    {HABLA: {
        orientation: 'REVERSE',
        properties: 'Weight'
    }}
);

// No dirigido UNDIRECTED con pesos
CALL gds.graph.project(
    'GoT_Undirected',
    'Personaje',
    {HABLA: {
        orientation: 'UNDIRECTED',
        properties: 'Weight'
    }}
);

// No dirigido SIN pesos (para algoritmos que no los soportan)
CALL gds.graph.project(
    'GoT_Undirected_NoWeight',
    'Personaje',
    {HABLA: {
        orientation: 'UNDIRECTED'
    }}
);

// Listar subgrafos proyectados
CALL gds.graph.list()
YIELD graphName
RETURN graphName;


// ============================================================
// 2. ANÁLISIS DE CENTRALIDAD
// ============================================================

// --- 2.1 DEGREE CENTRALITY (no dirigido) ---
// ¿Quién interactúa con más personajes distintos?
CALL gds.degree.write('GoT_Undirected', {
    writeProperty: 'degree_centrality'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'degree' AS metrica,
       centralityDistribution.min AS minimo,
       centralityDistribution.mean AS promedio,
       centralityDistribution.max AS maximo,
       nodePropertiesWritten;

// --- 2.2 IN-DEGREE (¿quién es más escuchado / recibe más interacciones?) ---
CALL gds.degree.write('GoT_Undirected', {
    writeProperty: 'indegree_centrality',
    orientation: 'REVERSE'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'indegree' AS metrica,
       centralityDistribution.min AS minimo,
       centralityDistribution.mean AS promedio,
       centralityDistribution.max AS maximo,
       nodePropertiesWritten;

// --- 2.3 OUT-DEGREE (¿quién inicia más interacciones?) ---
CALL gds.degree.write('GoT_Undirected', {
    writeProperty: 'outdegree_centrality',
    orientation: 'NATURAL'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'outdegree' AS metrica,
       centralityDistribution.min AS minimo,
       centralityDistribution.mean AS promedio,
       centralityDistribution.max AS maximo,
       nodePropertiesWritten;

// --- 2.4 PAGE RANK (influencia propagada en la red) ---
// ¿Qué personajes son influyentes porque interactúan con otros influyentes?
CALL gds.pageRank.write(
    'GoT_Undirected',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Ver top 10 por PageRank
MATCH (p:Personaje)
RETURN p.Label AS personaje, p.pageRank AS pageRank
ORDER BY pageRank DESC
LIMIT 10;

// --- 2.5 BETWEENNESS CENTRALITY ---
// ¿Qué personajes son puentes entre grupos (P1 de análisis)?
CALL gds.betweenness.write(
    'GoT_Undirected',
    {writeProperty: 'betweenness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimo,
       centralityDistribution.mean AS promedio,
       centralityDistribution.max AS maximo,
       nodePropertiesWritten;

// Ver top 10 por Betweenness
MATCH (p:Personaje)
RETURN p.Label AS personaje, p.betweenness_centrality AS betweenness
ORDER BY betweenness DESC
LIMIT 10;

// --- 2.6 CLOSENESS CENTRALITY ---
// ¿Qué personajes pueden alcanzar al resto de la red más rápido?
CALL gds.closeness.write(
    'GoT_Undirected',
    {writeProperty: 'closeness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimo,
       centralityDistribution.mean AS promedio,
       centralityDistribution.max AS maximo,
       nodePropertiesWritten;

// --- 2.7 ARTICULATION POINTS ---
// ¿Qué personajes, si desaparecieran, fragmentarían la red?
CALL gds.articulationPoints.write(
    'GoT_Undirected_NoWeight',
    {writeProperty: 'ArticulationPoint'}
)
YIELD articulationPointCount;

// Ver los puntos de articulación
MATCH (p:Personaje)
WHERE p.ArticulationPoint = true
RETURN p.Label AS personaje_puente
ORDER BY p.betweenness_centrality DESC;

// Tabla resumen de métricas de centralidad (top 15)
MATCH (p:Personaje)
RETURN p.Label AS personaje,
       p.degree_centrality AS degree,
       p.pageRank AS pagerank,
       p.betweenness_centrality AS betweenness,
       p.closeness_centrality AS closeness
ORDER BY p.pageRank DESC
LIMIT 15;


// ============================================================
// 3. ANÁLISIS DE COMUNIDADES
// ============================================================

// --- 3.1 LOUVAIN (no dirigido, sin pesos) ---
// P2: ¿Qué comunidades naturales existen en la red?
CALL gds.graph.project(
    'GoT_Louvain_Base',
    'Personaje',
    {HABLA: {orientation: 'UNDIRECTED'}}
);

CALL gds.louvain.write('GoT_Louvain_Base', {
    writeProperty: 'louvain'
})
YIELD communityCount, modularity, modularities;

// Ver comunidades y sus integrantes
MATCH (p:Personaje)
RETURN p.louvain AS comunidad,
       COUNT(p) AS num_integrantes,
       COLLECT(p.Label) AS integrantes
ORDER BY num_integrantes DESC;

// --- 3.2 LOUVAIN CON PESOS (dirigido) ---
// Comunidades considerando la intensidad de las interacciones
CALL gds.graph.project(
    'GoT_Louvain_Weighted',
    'Personaje',
    {HABLA: {orientation: 'NATURAL', properties: 'Weight'}}
);

// Ver comunidades intermedias (proceso jerárquico)
CALL gds.louvain.stream('GoT_Louvain_Weighted', {
    includeIntermediateCommunities: true
})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Label AS personaje,
       communityId,
       intermediateCommunityIds
ORDER BY communityId ASC, personaje ASC;

// Escribir como atributo
CALL gds.louvain.write('GoT_Louvain_Weighted', {
    writeProperty: 'louvain_weighted'
})
YIELD communityCount, modularity, modularities;

// --- 3.3 K-1 COLORING ---
// Colorear el grafo: personajes del mismo color no comparten interacción directa
CALL gds.graph.project(
    'GoT_Coloring',
    'Personaje',
    {HABLA: {orientation: 'UNDIRECTED'}}
);

CALL gds.k1coloring.write('GoT_Coloring', {
    writeProperty: 'K1color'
})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// Ajustar para evitar color 0 (problemático en Bloom)
MATCH (p:Personaje)
SET p.K1color = p.K1color + 1
RETURN p.K1color AS color,
       COUNT(p.Label) AS num_integrantes,
       COLLECT(p.Label) AS integrantes
ORDER BY num_integrantes DESC, p.K1color;


// ============================================================
// 4. TRANSFORMACIÓN DEL GRAFO
// ============================================================

// --- 4.1 ENRIQUECIMIENTO: categoría de centralidad ---
// Clasificar personajes por su nivel de influencia (degree_centrality)
MATCH (p:Personaje)
WITH p, p.degree_centrality AS deg
SET p.categoria_influencia =
    CASE
        WHEN deg >= 20 THEN 'Principal'
        WHEN deg >= 10 THEN 'Secundario'
        WHEN deg >= 3  THEN 'Menor'
        ELSE 'Marginal'
    END
RETURN p.categoria_influencia AS categoria,
       COUNT(p) AS cantidad
ORDER BY cantidad DESC;

// --- 4.2 SUBGRAFO: solo personajes principales (P3 - evolución temporal) ---
// Interacciones entre los personajes más conectados
MATCH (a:Personaje)-[r:HABLA]->(b:Personaje)
WHERE a.degree_centrality >= 20 AND b.degree_centrality >= 20
RETURN a.Label AS origen, b.Label AS destino,
       r.Weight AS peso, r.Season AS temporada
ORDER BY r.Season, r.Weight DESC;

// --- 4.3 SUBGRAFO POR TEMPORADA (P3 - evolución) ---
// Personajes más activos por temporada
MATCH (a:Personaje)-[r:HABLA]->(b:Personaje)
WITH r.Season AS temporada, a, SUM(r.Weight) AS peso_total
RETURN temporada,
       a.Label AS personaje,
       peso_total
ORDER BY temporada, peso_total DESC;

// Top 5 por temporada
MATCH (a:Personaje)-[r:HABLA]->(b:Personaje)
WITH r.Season AS temporada, a.Label AS personaje, SUM(r.Weight) AS interacciones
ORDER BY temporada, interacciones DESC
WITH temporada, COLLECT({personaje: personaje, interacciones: interacciones})[0..5] AS top5
RETURN temporada, top5
ORDER BY temporada;

// --- 4.4 SUBGRAFO: Puntos de articulación con sus vecinos ---
// Ver el contexto local de los personajes-puente
MATCH (p:Personaje)-[r:HABLA]-(vecino:Personaje)
WHERE p.ArticulationPoint = true
RETURN p.Label AS puente,
       vecino.Label AS vecino,
       r.Weight AS peso
ORDER BY p.betweenness_centrality DESC, peso DESC;


// ============================================================
// 5. CONSULTAS DE ANÁLISIS PARA PREGUNTAS DE INVESTIGACIÓN
// ============================================================

// P1: ¿Quién actúa como puente entre grupos (betweenness alto)?
MATCH (p:Personaje)
RETURN p.Label AS personaje,
       p.betweenness_centrality AS betweenness,
       p.louvain AS comunidad,
       p.ArticulationPoint AS es_punto_articulacion
ORDER BY betweenness DESC
LIMIT 10;

// P2: ¿Las comunidades corresponden a casas/facciones de GoT?
MATCH (p:Personaje)
RETURN p.louvain_weighted AS comunidad,
       COUNT(p) AS miembros,
       COLLECT(p.Label) AS personajes
ORDER BY miembros DESC;

// P3: Evolución de centralidad - ¿Quién sube/baja de importancia?
MATCH (a:Personaje)-[r:HABLA]->(b:Personaje)
WITH r.Season AS temporada, a.Label AS personaje, 
     SUM(r.Weight) AS peso_out,
     COUNT(DISTINCT b) AS contactos_distintos
RETURN temporada, personaje, peso_out, contactos_distintos
ORDER BY temporada, peso_out DESC;


// ============================================================
// 6. LIMPIEZA - ELIMINAR SUBGRAFOS PROYECTADOS
// ============================================================

CALL gds.graph.drop('GoT_Natural');
CALL gds.graph.drop('GoT_Reverse');
CALL gds.graph.drop('GoT_Undirected');
CALL gds.graph.drop('GoT_Undirected_NoWeight');
CALL gds.graph.drop('GoT_Louvain_Base');
CALL gds.graph.drop('GoT_Louvain_Weighted');
CALL gds.graph.drop('GoT_Coloring');
