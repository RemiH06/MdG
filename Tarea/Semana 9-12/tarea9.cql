// 1. Usa como base los archivos Estados.CSV y Fronteras.CSV para construir el grafo de la República Mexicana. Revisa que en el archivo Fronteras.CSV no falte ninguna frontera; si falta, añádela.
LOAD CSV WITH HEADERS FROM 'file:///Estados.CSV' AS row
CREATE (:Estado {nombre: row.ESTADO});

LOAD CSV WITH HEADERS FROM 'file:///Fronteras.CSV' AS row
MATCH (source:Estado {nombre: row.ESTADO1})
MATCH (target:Estado {nombre: row.ESTADO2})
CREATE (source)-[:FRONTERA_CON]->(target);

// 2. Aplica el algoritmo k1coloring para saber qué color tendría cada estado.
CALL gds.graph.project(
    'uEstados',
    'Estado',
    {FRONTERA_CON: {orientation: 'UNDIRECTED'}}
);

// 3. Añade el atributo k1color a los nodos Estado.
CALL gds.k1coloring.write('uEstados', {writeProperty: 'k1color'})
YIELD nodeCount, colorCount, ranIterations, didConverge;

// 4. Muestra una tabla con el color del Estado, el número de estados por color y el nombre de los estados como una lista.
MATCH (e:Estado)
RETURN e.k1color AS Color, COUNT(e.nombre) AS NumEstados, COLLECT(e.nombre) AS Estados
ORDER BY COUNT(e.nombre), e.k1color;

// 5. Realiza una consulta para actualizar el color=0 al siguiente número más grande de la lista completa de colores.
MATCH (e:Estado)
WITH max(e.k1color) AS maxColor
MATCH (n:Estado WHERE n.k1color = 0)
SET n.k1color = maxColor + 1
RETURN n.k1color AS Color, COUNT(n.nombre) AS NumEstados, COLLECT(n.nombre) AS Estados;

// 6. En Explore muestra los nodos estado y las relaciones frontera.
MATCH (a:Estado)-[r:FRONTERA_CON]-(b:Estado)
RETURN a, r, b;