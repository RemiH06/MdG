// 1. Subgrafo con personajes (tu código original)
CALL gds.graph.project(
    'grafote',
    'Character',
    {SPEAKS_WITH:
        {
            Orientation: 'UNDIRECTED',
            Properties: 'value'
        }
    }
);

// 2. Añade los atributos de centralidad

// 2.1 Degree Centrality (grado total, indegree y outdegree)
CALL gds.degree.write('grafote', {
    writeProperty: 'degree_centrality'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'degree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten
UNION ALL

CALL gds.degree.write('grafote', {
    writeProperty: 'indegree_centrality',
    orientation: 'REVERSE'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'indegree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten
UNION ALL

CALL gds.degree.write('grafote', {
    writeProperty: 'outdegree_centrality',
    orientation: 'NATURAL'
})
YIELD centralityDistribution, nodePropertiesWritten
RETURN 'outdegree' AS metric, centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, nodePropertiesWritten;

// 2.2 PageRank
CALL gds.pageRank.write(
    'grafote',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodePropertiesWritten, ranIterations;

// 2.3 Betweenness Centrality
CALL gds.betweenness.write(
    'grafote', {writeProperty: 'betweenness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN centralityDistribution.min AS minimumScore, 
       centralityDistribution.mean AS meanScore, 
       nodePropertiesWritten;

// 2.4 Closeness Centrality (tu código original adaptado)
CALL gds.closeness.write(
    'grafote', {writeProperty: 'closeness_centrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;

// 2.5 Articulation Points (puntos de articulación)
CALL gds.articulationPoints.write(
    'grafote',
    {writeProperty: 'ArticulationPoint'}
)
YIELD articulationPointCount