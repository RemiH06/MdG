// 2.a — Esquema del grafo heterogéneo
//       Muestra los tipos de nodo y relación del modelo
CALL db.schema.visualization();


// 2.b — Muestra visual: 50 artistas con sus géneros
MATCH (a:Artist)-[:HAS_GENRE]->(g:Genre)
WITH a, g LIMIT 50
RETURN a, g;



// 3.a — Subgrafo de los 30 artistas más populares
//       y sus colaboraciones entre ellos
MATCH (a:Artist)
WITH a ORDER BY a.popularity DESC LIMIT 30
WITH collect(a) AS top
UNWIND top AS a
UNWIND top AS b
WITH a, b
WHERE id(a) < id(b)
MATCH (a)-[r:COLLABORATED_WITH]-(b)
RETURN a, r, b;


// 3.b — Artistas muy populares y sus géneros asociados
//       Ilustra la relación HAS_GENRE
MATCH (a:Artist)-[r:HAS_GENRE]->(g:Genre)
WHERE a.popularity > 80
WITH a, r, g LIMIT 60
RETURN a, r, g;



// 4.a — Ego-network del artista con más colaboraciones (el hub principal)
MATCH (a:Artist)
WITH a, COUNT { (a)-[:COLLABORATED_WITH]-() } AS grado
ORDER BY grado DESC LIMIT 1
MATCH (a)-[r:COLLABORATED_WITH]-(vecino:Artist)
RETURN a, r, vecino;


// 4.b — Red de los top 15 por degree con sus conexiones entre ellos
MATCH (a:Artist)
WITH a, COUNT { (a)-[:COLLABORATED_WITH]-() } AS grado
ORDER BY grado DESC LIMIT 15
WITH collect(a) AS hubs
UNWIND hubs AS a
UNWIND hubs AS b
WITH a, b WHERE id(a) < id(b)
MATCH (a)-[r:COLLABORATED_WITH]-(b)
RETURN a, r, b;



// 5.0 — Escribir communityId como propiedad (ejecutar UNA vez)
CALL gds.louvain.write('collab-graph', { writeProperty: 'comunidad' })
YIELD communityCount, modularity;


// 5.a — Top 200 artistas más populares coloreados por comunidad
//       En Browser: click en nodo → estilos → colorear por 'comunidad'
MATCH (a:Artist)
WITH a ORDER BY a.popularity DESC LIMIT 200
MATCH (a)-[r:COLLABORATED_WITH]-(b:Artist)
WHERE b.popularity > 50
RETURN a, r, b;


// 5.b — Artistas de las 3 comunidades más grandes con sus conexiones
MATCH (a:Artist)
WITH a.comunidad AS com, count(*) AS tam
ORDER BY tam DESC LIMIT 3
WITH collect(com) AS top3
MATCH (a:Artist)-[r:COLLABORATED_WITH]-(b:Artist)
WHERE a.comunidad IN top3 AND b.comunidad IN top3
  AND a.popularity > 60 AND b.popularity > 60
RETURN a, r, b LIMIT 300;



// 6.a — Camino más corto visual entre dos artistas
MATCH (a:Artist { name: 'Bad Bunny' }),
      (b:Artist { name: 'Drake' })
MATCH path = shortestPath((a)-[:COLLABORATED_WITH*]-(b))
RETURN path;


// 6.b — Todos los caminos de longitud ≤ 3 entre dos artistas
//       Muestra la vecindad compartida
MATCH (a:Artist { name: 'Bad Bunny' }),
      (b:Artist { name: 'Drake' })
MATCH path = (a)-[:COLLABORATED_WITH*1..3]-(b)
RETURN path LIMIT 50;



// 7.a — Subgrafo mixto: artistas + géneros top juntos
//       Ajusta los géneros según los que más aparezcan en tu dataset
MATCH (g:Genre)<-[:HAS_GENRE]-(a:Artist)-[r:COLLABORATED_WITH]-(b:Artist)
WHERE g.name IN ['pop', 'rap', 'latin', 'reggaeton', 'hip hop']
  AND a.popularity > 70 AND b.popularity > 70
RETURN g, a, r, b LIMIT 200;
