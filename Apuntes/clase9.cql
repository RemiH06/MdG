// Experimentos
optional match (v1:Villian)
match (v:Villian)-[r:COMPANION]->(ov:Villian)
return v,r,ov,v1;

optional match (v1:SuperHero)
match (v:SuperHero)-[r:FRIEND_OF]->(ov:SuperHero)
return v,r,ov,v1;

optional match (v1:Villian)
match (v:Villian)-[r:COMPANION]->(ov:Villian)
return v,r,ov,v1;

match ()-[r:FRIEND_OF]->()
return count(DISTINCT r);

match ()-[r:COMPANION]->()
return count(r);

call db.schema.visualization;


// Pasos

// 1. Crea un subgrafo de villanos 
CALL gds.graph.project(
    'myGraph',
    'Villian',
    'COMPANION',
    {relationshipProperties:'Weight'}
);

// 2. Calcular la memoria requerida
CALL gds.pageRank.write.estimate(
    'myGraph',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecutar el algoritmo
CALL gds.pageRank.stream('myGraph')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS Name, score
ORDER BY score DESC, Name ASC;

// 4. Añadir el atributo nodo
CALL gds.pageRank.write(
    'myGraph',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodePropertiesWritten, ranIterations;

MATCH (h:SuperHero)
RETURN h.Name, h.closeness_centrality
ORDER BY h.closeness_centrality DESC
LIMIT 5;