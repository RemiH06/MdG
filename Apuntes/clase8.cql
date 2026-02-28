//
MATCH (p:Person)-[r]-(m)
WHERE p.name = "Clint Eastwood"
RETURN p, r, m;
 
 
//
MATCH (p:Person)
WHERE p.name = $nombre
RETURN p;
 
 
//Grafo a dos saltos
MATCH (p:Person)-[r]-(m)-[r2]-(m2)
RETURN p, r, m, r2, m2;
 
// Todos los nodos alcanzables a dos saltos
MATCH (p:Person)-[r*1..2]-(m)
RETURN p, r, m;
 
// Todos los nodos alcanzables a tres saltos
MATCH (p:Person)-[r*1..3]-(m)
RETURN p, r, m;
 
//
MATCH (p:Person)-[r*1..1]-(m)
WHERE p.name = 'Kevin Bacon'
RETURN COUNT(DISTINCT m);
 
 
// Todos los nodos alcanzables a dos saltos: 24
MATCH (p:Person)-[r*1..2]-(m)
WHERE p.name = 'Kevin Bacon'
RETURN COUNT(DISTINCT m);
 
// Exactamente alcanzables a dos saltons son: 21
MATCH (p:Person)-[r*2]-(m)
WHERE p.name = 'Kevin Bacon'
RETURN COUNT(DISTINCT m);