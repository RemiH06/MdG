// 0.1 Unicidad de Artist por spotify_id
CREATE CONSTRAINT artist_id IF NOT EXISTS
  FOR (a:Artist) REQUIRE a.spotify_id IS UNIQUE;

// 0.2 Unicidad de Genre por name
CREATE CONSTRAINT genre_name IF NOT EXISTS
  FOR (g:Genre) REQUIRE g.name IS UNIQUE;



LOAD CSV WITH HEADERS FROM 'file:///artists.csv' AS row
MERGE (a:Artist { spotify_id: row.spotify_id })
SET
  a.name       = row.name,
  a.followers  = toInteger(row.followers),
  a.popularity = toInteger(row.popularity);



LOAD CSV WITH HEADERS FROM 'file:///genres.csv' AS row
MERGE (:Genre { name: row.name });



LOAD CSV WITH HEADERS FROM 'file:///artist_genre.csv' AS row
CALL {
  WITH row
  MATCH (a:Artist { spotify_id: row.spotify_id })
  MATCH (g:Genre  { name: row.genre })
  MERGE (a)-[:HAS_GENRE]->(g)
} IN TRANSACTIONS OF 500 ROWS;



LOAD CSV WITH HEADERS FROM 'file:///collaborations.csv' AS row
CALL {
  WITH row
  MATCH (a:Artist { spotify_id: row.id_0 })
  MATCH (b:Artist { spotify_id: row.id_1 })
  MERGE (a)-[:COLLABORATED_WITH]->(b)
} IN TRANSACTIONS OF 500 ROWS;



// V.1 Conteo de nodos por etiqueta
MATCH (n)
RETURN labels(n)[0] AS etiqueta, count(*) AS total
ORDER BY total DESC;

// V.2 Conteo de relaciones por tipo
MATCH ()-[r]->()
RETURN type(r) AS tipo_relacion, count(*) AS total
ORDER BY total DESC;
