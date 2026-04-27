// Undirected
CALL gds.graph.project(
    'myUndirectedGraph',
    'Villian',
    {COMPANION:
        {
            orientation:'UNDIRECTED',
            properties:'Weight'
        }
    }
);

// Directed
CALL gds.graph.project(
    'myDirectedGraph',
    'Villian',
    {COMPANION:
        {
            orientation:'NATURAL',
            properties:'Weight'
        }
    }
);

// Minimum Weight Spanning Tree (MWST)
// Árbol de expansión de peso mínimo (MWST)
// MWST
MATCH(source:Villian{Name:'Braniac'})
CALL gds.spanningTree.write('myUndirectedGraph',
    {
        sourceNode: source,
        relationshipWeightProperty: 'Weight',
        writeProperty: 'Cost',
        writeRelationshipType: 'MWST_Brainiac'
    }
)
YIELD effectiveNodeCount
RETURN effectiveNodeCount;

MATCH(n)-[r:MWST_Brainiac]-(m)
RETURN n,r,m;

MATCH(v:Villian)
WHERE NOT ()-[:MWST_Brainiac]-(v)
RETURN v;

// Node similarity es cuando un nodo se parece en sus relaciones específicas a otro
CALL gds.nodeSimilarity.stream('myDirectedGraph')
YIELD node1, node2, similarity
RETURN  gds.util.asNode(node1).Name AS Villian_1,
        gds.util.asNode(node2).Name AS Villian_2,
        similarity
ORDER BY similarity DESCENDING, Villian_1, Villian_2;

// Nodos comparados
CALL gds.nodeSimilarity.stats('myDirectedGraph')
YIELD nodesCompared, similarityPairs;

// Crea una nueva relación entre cada par de nodos y añade el valor como atributo
CALL gds.nodeSimilarity.write('myDirectedGraph',
    {
        writeRelationshipType: 'SIMILAR_Node_Similarity',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// Añadimos un nuevo atributo numérico, con nombre Power, a los villanos
// Valores entre 1 y 10
// sin() genera un valor pseudoaleatorio pero determinista
// abs() evita negativos
// 27 semilla fija
MATCH(v:Villian)
WHERE v.Power IS NULL
SET v.Power = toInteger(abs(sin(id(v)*27))*10)+1;

// Nuevo subgrafo
// NULL en lugar de las relaciones porque solo queremos los nodos
MATCH(v:Villian)
RETURN gds.graph.project(
    'mySimilarGraph',
    v,
    NULL,
    {
        sourceNodeProperties: v {.Power},
        targetNodeProperties: {}
    }
);

// Aplicar en modo Stream
CALL gds.knn.stream('mySimilarGraph',
    {
        topK: 1,
        nodeProperties: ['Power'],
        randomSeed: 1337,
        concurrency: 1,
        sampleRate: 1.0,
        deltaThreshold: 0.0
    }
)
YIELD node1, node2, similarity
RETURN  gds.util.asNode(node1).Name AS Villano_1,
        gds.util.asNode(node2).Name AS Villano_2,
        similarity
ORDER BY similarity ASC, Villano_2, Villano_2;

// Write
// Crea  una nueva relación SIMILAR_atributos entre cada par de nodos y añade el valor como atributo
CALL gds.knn.write('mySimilarGraph',
    {
        writeRelationshipType: 'SIMILAR_atributos',
        writeProperty: 'score',
        topK: 1,
        randomSeed: 42,
        concurrency: 1,
        nodeProperties: ['Power']
    }
)
YIELD nodesCompared, relationshipsWritten