// esquema
CALL db.schema.visualization;

// grafo
MATCH (p)-[r]-(q)
RETURN p,r,q;

// nombres de villanos
MATCH (v:Villian)
RETURN v.Name

// SUBGRAFOS

// Dirigido NATURAL
CALL gds.graph.project(
    'MyNaturalGraph',
    'Villian',
    {COMPANION:
    {
        orientation: 'NATURAL',
        properties: 'Weight'
    }}
)


// Dirigido REVERSE
CALL gds.graph.project(
    'MyReverseGraph',
    'Villian',
    {COMPANION:
    {
        orientation: 'REVERSE',
        properties: 'Weight'
    }}
)

// No dirigido UNDIRECTED
CALL gds.graph.project(
    'MyUndirectedGraph',
    'Villian',
    {COMPANION:
    {
        orientation: 'UNDIRECTED',
        properties: 'Weight'
    }}
)

// Lista los subgrafos
CALL gds.graph.list()
YIELD graphName
RETURN graphName;

// Eliminar grafos
CALL gds.graph.drop('MyNaturalGraph')
CALL gds.graph.drop('MyReverseGraph')
CALL gds.graph.drop('MyUndirectedGraph')



// Añadir atributos
CALL gds.NOMBRE_DEL_ALGORITMO.write(
    'Nombre_del_subgrafo',
    {writeProperty: 'Nombre_del_atributo'}
)
YIELD centralityDistribution, nodePropertiesWritten;

// Degree
CALL gds.degree.write('MyUndirectedGraph', {
    writeProperty: 'degree_centrality'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'degree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten;

// InDegree
CALL gds.degree.write('MyUndirectedGraph', {
    writeProperty: 'indegree_centrality',
    orientation: 'REVERSE'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'indegree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten;

// OutDegree
CALL gds.degree.write('MyUndirectedGraph', {
    writeProperty: 'outdegree_centrality',
    orientation: 'NATURAL'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'outdegree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten;


// PageRank
CALL gds.pageRank.write(
    'MyUndirectedGraph',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodePropertiesWritten, ranIterations;


// Betweenness Centrality
CALL gds.betweenness.write(
    'MyUndirectedGraph', {writeProperty: 'betweenness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, 
       nodePropertiesWritten;


// Closeness Centrality (tu código original adaptado)
CALL gds.closeness.write(
    'MyUndirectedGraph', {writeProperty: 'closeness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;


// Articulation Points (puntos de articulación)
CALL gds.articulationPoints.write(
    'MyUndirectedGraph',
    {writeProperty: 'ArticulationPoint'}
)
YIELD articulationPointCount