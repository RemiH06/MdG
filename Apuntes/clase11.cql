// Closeness centrality

// 1. Crear subgrafo
CALL gds.graph.project(
    'MyGraph',
    'Villian',
    'COMPANION',
    {relationshipProperties:'Weight'}
);

// 2. Cálculo de memoria
CALL gds.closeness.stream.estimate('MyGraph', {})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Aplicar el algoritmo


// 4. Incluir el atributo ********
CALL gds.closeness.write('MyGraph', {writeProperty: 'closeness_centrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;

// comprobación
MATCH (v:Villian)
RETURN v.Name, v.closeness_centrality
ORDER BY v.closeness_centrality DESC;

// AHORA CON LOS HÉROES

// 1. Crear subgrafo
CALL gds.graph.project(
    'grafoHeroes',
    'SuperHero',
    'FRIEND_OF',
    {relationshipProperties:'Weight'}
);

// 2. Cálculo de memoria
CALL gds.closeness.stream.estimate('grafoHeroes', {})
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Aplicar el algoritmo


// 4. Incluir el atributo ********
CALL gds.closeness.write('grafoHeroes', {writeProperty: 'closeness_centrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;

// comprobación
MATCH (h:SuperHero)
RETURN h.Name, h.closeness_centrality
ORDER BY h.closeness_centrality DESC;