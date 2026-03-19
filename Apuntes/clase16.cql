// Subgrafo no dirigido
CALL gds.graph.project(
    'myGraph',
    'Villian',
    {COMPANION: {orientation:'UNDIRECTED'}}
);

// Louvain
CALL gds.louvain.write('myGraph', {writeProperty: 'louvain'})
YIELD communityCount, modularity, modularities;


//? VILLIAN
// Subgrafo dirigido con pesos
CALL gds.graph.project(
    'myDirectedWeightedGraph',
    'Villian',
    {COMPANION: {orientation:'NATURAL', properties: 'Weight'}}
);

// Comunidades intermedias
CALL gds.louvain.stream('myDirectedWeightedGraph', {includeIntermediateCommunities: true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS name, communityId, intermediateCommunityIds
ORDER BY communityId ASC, intermediateCommunityIds ASC, name ASC;

// Añadiendo un nuevo atributo
CALL gds.louvain.write('myDirectedWeightedGraph', {writeProperty: 'louvainDirectedGraph'})
YIELD communityCount, modularity, modularities;


//? SUPERHERO
// Subgrafo dirigido con pesos
CALL gds.graph.project(
    'myDirectedWeightedGraph2',
    'SuperHero',
    {FRIEND_OF: {orientation:'NATURAL', properties: 'Weight'}}
);

// Comunidades intermedias
CALL gds.louvain.stream('myDirectedWeightedGraph2', {includeIntermediateCommunities: true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS name, communityId, intermediateCommunityIds
ORDER BY communityId ASC, intermediateCommunityIds ASC, name ASC;

// Añadiendo un nuevo atributo
CALL gds.louvain.write('myDirectedWeightedGraph2', {writeProperty: 'louvainDirectedGraph'})
YIELD communityCount, modularity, modularities;


//? K-1 Coloring
// Subgrafo no dirigido
CALL gds.graph.project(
    'uG',
    'Villian',
    {COMPANION: {orientation: 'UNDIRECTED'}}
);

// Escribimos K-1 como atributo
CALL gds.k1coloring.write('uG', {writeProperty: 'K1color'})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// Ya que el CERO causa problemas para aplicar una regla en bloom actualizamos los datos
MATCH (v:Villian)
SET v.K1color = v.K1color+1
RETURN v.K1color as Color, COUNT(v.Name) AS NumIntegrantes, COLLECT(v.Name) as Integrantes
ORDER BY COUNT(v.Name), v.K1color;

// Subgrafo no dirigido
CALL gds.graph.project(
    'uG2',
    'SuperHero',
    {FRIEND_OF: {orientation: 'UNDIRECTED'}}
);

// Escribimos K-1 como atributo
CALL gds.k1coloring.write('uG2', {writeProperty: 'K1color'})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// Ya que el CERO causa problemas para aplicar una regla en bloom actualizamos los datos
MATCH (sh:SuperHero)
SET sh.K1color = sh.K1color+1
RETURN sh.K1color as Color, COUNT(sh.name) AS NumIntegrantes, COLLECT(sh.name) as Integrantes
ORDER BY COUNT(sh.name), sh.K1color;