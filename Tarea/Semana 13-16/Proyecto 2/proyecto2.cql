


//  BLOQUE 1 —  Conteos finales


// 1.1 - Conteo total por tipo de nodo
MATCH (a:Artist) RETURN 'Artist' AS label, count(a) AS total
UNION
MATCH (g:Genre)  RETURN 'Genre'  AS label, count(g) AS total;


// 1.2 - Conteo total por tipo de relación
MATCH ()-[r:COLLABORATED_WITH]->() RETURN 'COLLABORATED_WITH' AS rel, count(r) AS total
UNION
MATCH ()-[r:HAS_GENRE]->()         RETURN 'HAS_GENRE'         AS rel, count(r) AS total;


// 1.3 - Validar que no hay artistas duplicados ni huérfanos
MATCH (a:Artist) WHERE NOT (a)--()
RETURN count(a) AS artistas_aislados;


// 1.1 Conteo de nodos por etiqueta
MATCH (n)
RETURN labels(n)[0] AS etiqueta, count(*) AS total
ORDER BY total DESC;

// 1.2 Conteo de relaciones por tipo
MATCH ()-[r]->()
RETURN type(r) AS tipo_relacion, count(*) AS total
ORDER BY total DESC;

// 1.3 Densidad del subgrafo de colaboraciones
//     d = 2*E / (N*(N-1)) para grafo no dirigido
MATCH (a:Artist)
WITH count(a) AS n
MATCH ()-[r:COLLABORATED_WITH]->()
WITH n, count(r) AS e
RETURN n               AS nodos,
       e               AS aristas,
       (2.0*e)/(n*(n-1)) AS densidad;

// 2.1 Resumen de popularity y followers
MATCH (a:Artist)
RETURN 
    count(a)                              AS total,
    min(a.popularity)                     AS pop_min,
    max(a.popularity)                     AS pop_max,
    round(avg(a.popularity), 2)           AS pop_promedio,
    percentileCont(a.popularity, 0.5)     AS pop_mediana,
    percentileCont(a.popularity, 0.95)    AS pop_p95,
    min(a.followers)                      AS fol_min,
    max(a.followers)                      AS fol_max,
    round(avg(a.followers), 0)            AS fol_promedio,
    percentileCont(a.followers, 0.5)      AS fol_mediana,
    percentileCont(a.followers, 0.95)     AS fol_p95;


// 2.2 Top 10 artistas por popularity
MATCH (a:Artist)
RETURN a.name AS artista, a.popularity AS popularidad, a.followers AS seguidores
ORDER BY a.popularity DESC, a.followers DESC
LIMIT 10;

// 2.3 Top 10 artistas por followers
MATCH (a:Artist)
RETURN a.name AS artista, a.followers AS seguidores, a.popularity AS popularidad
ORDER BY a.followers DESC
LIMIT 10;

// 3.1 Histograma del grado por bins
MATCH (a:Artist)
WITH a, COUNT { (a)-[:COLLABORATED_WITH]-() } AS grado
WITH 
    CASE 
        WHEN grado = 0    THEN '0  (aislados)'
        WHEN grado = 1    THEN '1'
        WHEN grado <= 5   THEN '2-5'
        WHEN grado <= 10  THEN '6-10'
        WHEN grado <= 50  THEN '11-50'
        WHEN grado <= 100 THEN '51-100'
        ELSE                   '100+'
    END AS bin,
    count(a) AS artistas
RETURN bin, artistas
ORDER BY 
    CASE bin
        WHEN '0  (aislados)' THEN 0
        WHEN '1'             THEN 1
        WHEN '2-5'           THEN 2
        WHEN '6-10'          THEN 3
        WHEN '11-50'         THEN 4
        WHEN '51-100'        THEN 5
        ELSE 6
    END;

// 3.2 Estadísticas del grado de colaboración
MATCH (a:Artist)
WITH a, COUNT { (a)-[:COLLABORATED_WITH]-() } AS grado
RETURN 
    min(grado)                          AS grado_min,
    max(grado)                          AS grado_max,
    round(avg(grado), 2)                AS grado_promedio,
    percentileCont(grado, 0.5)          AS grado_mediana,
    percentileCont(grado, 0.95)         AS grado_p95,
    percentileCont(grado, 0.99)         AS grado_p99;

// 4.1 Top 20 por número de colaboraciones (degree centrality cruda)
MATCH (a:Artist)
WITH a, COUNT { (a)-[:COLLABORATED_WITH]-() } AS colaboraciones
ORDER BY colaboraciones DESC
LIMIT 20
RETURN 
    a.name        AS artista,
    colaboraciones,
    a.popularity  AS popularidad,
    a.followers   AS seguidores;

// 5.1 Top 20 géneros con más artistas asociados
MATCH (g:Genre)<-[:HAS_GENRE]-(a:Artist)
WITH g, count(a) AS artistas
ORDER BY artistas DESC
LIMIT 20
RETURN g.name AS genero, artistas;

// 5.2 Distribución de cuántos géneros tiene cada artista
MATCH (a:Artist)
WITH a, COUNT { (a)-[:HAS_GENRE]->(:Genre) } AS num_generos
RETURN 
    num_generos,
    count(a) AS artistas
ORDER BY num_generos;

// 5.3 Artistas sin género asignado
MATCH (a:Artist)
WHERE NOT (a)-[:HAS_GENRE]->()
RETURN count(a) AS artistas_sin_genero;






// BLOQUE 2 — Estadísticas de atributos


// 2.1 - Resumen de followers y popularity (artistas)
MATCH (a:Artist)
RETURN 
    count(a)                         AS n,
    min(a.popularity)                AS pop_min,
    max(a.popularity)                AS pop_max,
    round(avg(a.popularity), 2)      AS pop_avg,
    percentileCont(a.popularity, 0.5) AS pop_mediana,
    min(a.followers)                 AS fol_min,
    max(a.followers)                 AS fol_max,
    round(avg(a.followers), 0)       AS fol_avg,
    percentileCont(a.followers, 0.5) AS fol_mediana;



// Pal documento
CALL db.schema.visualization();