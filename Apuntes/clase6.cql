MATCH (n)
RETURN labels(n) AS tipo, count(n) AS cantidad
ORDER BY cantidad DESC;

MATCH ()-[r]->()
RETURN type(r) AS tipo, count(r) AS cantidad
ORDER BY cantidad DESC;


MATCH (n)
RETURN count(n) AS total_nodos;

MATCH ()-[r]->()
RETURN count(r) AS total_relaciones;


// Devuelve Tom Hanks
MATCH (p:Person)
WHERE p.name = 'Tom Hanks'
RETURN p;

// Devuelve películas de Tom Hanks y sus películas
MATCH (p:Person)-[r:ACTED_IN]->(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN p, r, m;

// In degree de Tom Hanks
MATCH (p:Person)-[r]->(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN p.name, COUNT(DISTINCT r) as InDegree;

// Tom Hanks Degrees
MATCH (p:Person)-[r]-(m:Movie)
WHERE p.name = 'Tom Hanks'
RETURN p.name,
       COUNT(CASE WHEN startNode(r) = p THEN r END) AS OutDegree,
       COUNT(CASE WHEN endNode(r) = p THEN r END) AS InDegree,
       COUNT(r) AS Degree;

// O bien
MATCH (p:Person{name:'Tom Hanks'})
CALL (p) {
    WITH p
    MATCH (p:Person)-[r]->(m:Movie)
    RETURN COUNT(DISTINCT r) as OutDegree
}
CALL (p) {
    WITH p
    MATCH (p:Person)<-[r]-(m:Movie)
    RETURN COUNT(DISTINCT r) as InDegree
}
CALL (p) {
    WITH p
    MATCH (p:Person)-[r]-(m:Movie)
    RETURN COUNT(DISTINCT r) as Degree
}
RETURN p.name AS Actor, OutDegree, InDegree, Degree;

// 1. Número de películas
MATCH (n:Movie)
RETURN labels(n) AS tipo, count(n) AS cantidad
ORDER BY cantidad DESC;
// 38

// 2. Películas con año
MATCH (m:Movie)
RETURN m.title, m.released;

// 3. Número de actores
MATCH (n:Person)-[:ACTED_IN]->( )
RETURN labels(n) AS tipo, count(n) AS cantidad
ORDER BY cantidad DESC;
// 172

// 4. Número de directores
MATCH (n:Person)-[:DIRECTED]-( )
RETURN labels(n) AS tipo, count(n) AS cantidad
ORDER BY cantidad DESC;
// 44

// 5. Número de actores en matrix
MATCH (n:Person)-[:ACTED_IN]->(m:Movie{title: 'The Matrix'})
RETURN n;
// 5

// 6. Promedio de años de lanzamiento de las películas
MATCH (m:Movie)
RETURN AVG(m.released);
// 1998.2894736842109

// 7. Directores con sus películas
MATCH (n:Person)-[r:DIRECTED]->(m:Movie)
RETURN n, r, m;

// 8. Actores con cantidad de películas
MATCH (n:Person)-[r:ACTED_IN]->(m:Movie)
RETURN n.name, count(m);

// 9. Actor con mayor cantidad de películas
MATCH (n:Person)-[:ACTED_IN]->(m:Movie)
RETURN n.name, count(m) AS totalPeliculas
ORDER BY totalPeliculas DESC
LIMIT 1;
// Tom Hanks

// 10. Persona con más relaciones en la BD
MATCH (n:Person)-[r]-()
RETURN n.name, count(r) AS totalRelaciones
ORDER BY totalRelaciones DESC
LIMIT 1;
// Tom Hanks

// 11. Película con más actores
MATCH (m:Movie)<-[r:ACTED_IN]-(n:Person)
RETURN m.title, count(n) AS totalActores
ORDER BY totalActores DESC
LIMIT 1;
// A Few Good Men

// 12. Camino más corto entre dos actores (Tom Hanks y Keanu Reeves)


// 13. Moda: año en el que se estrenaron más pelis
MATCH (m:Movie)
RETURN m.released AS year, count(*) AS totalPeliculas
ORDER BY totalPeliculas DESC
LIMIT 1;
// 1999 con 4 películas

// 14. Actor que ha trabajado más con directores diferentes
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)<-[:DIRECTED]-(d:Person)
RETURN a.name, count(DISTINCT d) AS totalDirectores
ORDER BY totalDirectores DESC
LIMIT 1;
// Tom Hanks con 11 directores

// 15. Actor con más coactores diferentes
MATCH (a:Person)-[:ACTED_IN]->(m:Movie)<-[:ACTED_IN]-(c:Person)
WHERE a <> c
RETURN a.name, count(DISTINCT c) AS totalCoactores
ORDER BY totalCoactores DESC
LIMIT 1;
// Tom Hanks con 34 coactores