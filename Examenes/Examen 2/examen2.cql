// 2.	Muestra el esquema del grafo Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [1 punto]
CALL db.schema.visualization;

// Subgrafos
CALL gds.graph.project(
  'dG',
  'Producto',
  {
    COMPRA_CONJUNTA: {
      orientation: 'NATURAL',
      properties: ['CompradosEnConjunto']
    }
  }
)
YIELD graphName, nodeCount, relationshipCount;

CALL gds.graph.project(
  'uG',
  'Producto',
  {
    COMPRA_CONJUNTA: {
      orientation: 'UNDIRECTED',
      properties: ['CompradosEnConjunto']
    }
  }
)
YIELD graphName, nodeCount, relationshipCount;

// Analiza el grafo
// 3.	¿Cuál es el número total de productos alcanzables a una distancia de exactamente dos saltos a partir de “Papel milimétrico estándar”? Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
MATCH path = (p:Producto {Nombre: 'Papel milimétrico estándar'})-[*1..2]-(q)
RETURN path;

// 4.	Si se seleccionas el producto “Pluma estándar”, ¿cuáles serían los dos productos recomendados (que actualmente no tengan la relación directa COMPRA_CONJUNTA aplicando el algoritmo Louvain)? Primero, obtén la recomendación de productos con COMPRA_CONJUNTA y después con Louvain.  Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
// Louvain
CALL gds.louvain.write('uG', {writeProperty: 'louvain'})
YIELD communityCount, modularity, modularities;

MATCH(p:Producto {Nombre: 'Pluma estándar'})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre, c.CompradosEnConjunto, q.Nombre
ORDER BY c.CompradosEnConjunto DESC
LIMIT 3;

MATCH(p:Producto {Nombre: 'Pluma estándar'})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre, p.louvain, q.Nombre
ORDER BY p.louvain DESC
LIMIT 3;

// 5.	Si se seleccionas el producto “Libreta profesional”, ¿cuáles son los tres productos que se recomendarían, afinando la recomendación mediante el algoritmo Closeness Centrality? Primero, obtén la recomendación basada en la relación COMPRA_CONJUNTA y después refina la recomendación con el algoritmo Closeness Centrality. Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado. [10 puntos]
// Closeness
CALL gds.closeness.write('dG', {writeProperty: 'closeness_centrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;
CALL gds.closeness.write('uG', {writeProperty: 'closeness_centrality'})
YIELD centralityDistribution, nodePropertiesWritten
RETURN  centralityDistribution.min AS minimumScore,
        centralityDistribution.mean AS meanScore,
        nodePropertiesWritten;

MATCH(p:Producto {Nombre: 'Libreta profesional'})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre, c.CompradosEnConjunto, q.Nombre
ORDER BY c.CompradosEnConjunto DESC
LIMIT 3;

MATCH(p:Producto {Nombre: 'Libreta profesional'})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre, p.louvain, q.Nombre
ORDER BY p.closeness_centrality DESC
LIMIT 3;

// 6.	Si eliges el producto “Grapas estándar” y considerando la dirección de las relaciones, ¿cuántos nodos son alcanzables desde dicho producto?, Además, muestra el grafo incluyendo únicamente 5 de los productos alcanzables aplicando el algoritmo Delta-Stepping Single-Source Shortest Path. Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
MATCH (source:Producto{Nombre:'Grapas estándar'})
CALL gds.allShortestPaths.delta.write('dG',
{
    sourceNode: source,
    relationshipWeightProperty: 'CompradosEnConjunto',
    writeRelationshipType:'PATH_grapasEst',
    writeNodeIds: true,
    writeCosts: true
})
YIELD relationshipsWritten
RETURN relationshipsWritten;

// 7.	Dado el producto “Bloc de notas profesional” y el producto “Regla metálica premium”, y considerando la dirección de las relaciones, determina la ruta más corta aplicando el algoritmo Dijkstra Source-Target Shortest Path. Muestra el Id, el nombre de los productos por los que pasa la ruta y el costo total de la misma. Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
MATCH(source:Producto {Nombre: 'Bloc de notas profesional'})
MATCH(target:Producto {Nombre: 'Regla metálica premium'})
CALL gds.shortestPath.dijkstra.write('dG',
{
    sourceNode: source,
    targetNodes: target,
    relationshipWeightProperty: 'CompradosEnConjunto',
    writeRelationshipType: 'dijkstra_Bloc_Regla',
    writeNodeIds: true,
    writeCosts: true
}
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

MATCH(source:Producto {Nombre: 'Bloc de notas profesional'})-[r:dijkstra_Bloc_Regla]->(target:Producto {Nombre: 'Regla metálica premium'})
WHERE r.nodeIds IS NOT NULL AND size(r.nodeIds)>=2
WITH [id IN r.nodeIds | gds.util.asNode(id)] AS Nodes
UNWIND range(0, size(Nodes)-2) as i
WITH Nodes, Nodes[i] AS n1, Nodes[i+1] AS n2
MATCH (n1)-[rel:COMPRA_CONJUNTA]->(n2)
RETURN n1, rel, n2;

// 8.	Si seleccionas el producto “Paquete de papel bond”, ¿cuáles son los cuatro productos más similares, aplicando un algoritmo de similaridad que analice la estructura de las relaciones y considere la dirección de estas.  Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
CALL gds.nodeSimilarity.write('dG',
    {
        writeRelationshipType: 'SIMILAR_Node_Similarity',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

MATCH(p:Producto {Nombre: 'Paquete de papel bond'})-[r:SIMILAR_Node_Similarity]->(q)
RETURN p.Nombre, r.score, q.Nombre
ORDER BY r.score DESC
LIMIT 4;

// 9.	Mediante el uso de la herramienta dashboard, crea un tablero que reciba como parámetro el nombre de un producto y muestre los dos productos más comprados por COMPRA_CONJUNTA. Prueba tu tablero con el producto “Rollo de papel térmico”. Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
MATCH(p:Producto {Nombre: $producto_nombre})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre as Producto, c.CompradosEnConjunto as comprado, q.Nombre as con
ORDER BY c.CompradosEnConjunto DESC
LIMIT 2;

// 10.	Utilizando la herramienta dashboard crea un tablero que reciba como parámetro el nombre de un producto y muestre cuatro productos recomendados con basa en el algoritmo Louvain, ordenados alfabéticamente de forma ascendente y que no incluya el mismo producto como recomendación. Prueba tu tablero utilizando el producto “Etiquetas adhesivas”. Evidencia captura de pantalla el resultado obtenido y el código Cypher utilizado [10 puntos]
MATCH(p:Producto {Nombre: $producto_nombre_1})-[c:COMPRA_CONJUNTA]-(q)
RETURN p.Nombre, p.louvain, q.Nombre
ORDER BY q.Nombre ASC
LIMIT 4;