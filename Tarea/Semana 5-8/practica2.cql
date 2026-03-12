// Cargar nodos
LOAD CSV WITH HEADERS FROM 'file:///nodos.csv' AS row
CREATE (:Airport {id: toInteger(row.Id), label: row.Label, country: row.country, latitude: toFloat(row.latitude), longitude: toFloat(row.longitude)});

// Cargar relaciones
LOAD CSV WITH HEADERS FROM 'file:///enlaces.csv' AS row
MATCH (source:Airport {id: toInteger(row.Source)})
MATCH (target:Airport {id: toInteger(row.Target)})
CREATE (source)-[:CONNECTS]->(target);

// 2.	Análisis básico
// 2.1.	Una imagen que incluya: 
// 1) del esquema general del grafo
CALL db.schema.visualization

// 2) Número de nodos y atributos,
MATCH (n)
RETURN count(n)

// 3) Número de relaciones y atributos. Puedes crear el esquema en explore o query, copiar la imagen y añadir manualmente los demás datos a la imagen. [7 puntos]
MATCH ()-[r]->()
RETURN count(r)

// 2.2.	Una imagen del grafo completo en dashboards sobre un mapa del mundo que muestre los aeropuertos. Debe recibir como parámetro el nombre del país, por default debe ser México. [7 puntos]


// 3.	Consultas básicas


// 3.1.	Una consulta con cypher que muestre una tabla con nombre del país y el número aeropuertos por cada uno. Ordena de mayor a menor por número de aeropuertos y muestra únicamente los primeros 7. [4 puntos]
MATCH (a:Airport)
RETURN a.country AS Pais, COUNT(a) AS Numero_Aeropuertos
ORDER BY Numero_Aeropuertos DESC
LIMIT 7;

// 3.2.	Una consulta con cypher que muestre una tabla el nombre y el país de los 7 aeropuertos con más conexiones. [4 puntos]
MATCH (a:Airport)-[r:CONNECTS]-()
RETURN a.label AS Aeropuerto, a.country AS Pais, COUNT(r) AS Numero_Conexiones
ORDER BY Numero_Conexiones DESC
LIMIT 7;

// 3.3.	Una frase de búsqueda en explore que reciba el nombre del aeropuerto como parámetro y te regrese su grafo a dos saltos. Prueba con un aeropuerto de tu elección de México. [5 puntos]
MATCH path = (a:Airport {label: 'Guadalajara'})-[*1..2]-(conexiones)
RETURN path
LIMIT 100;

// 3.4.	Una frase de búsqueda en explore que reciba el nombre del país como parámetro y te regrese su grafo de aeropuertos. Prueba con Canada. [5 puntos]
MATCH (a:Airport {country: 'Canada'})-[r]-(d)
RETURN a, r, d;

// 4.	Preguntas guía [14 puntos]
// 4.1.	Ahora que conoces la base de datos, redacta 7 preguntas que se puedan responder con los algoritmos de centralidad aplicadas a este grafo. Cada pregunta debe redactarse técnicamente y de tal forma que un usuario de aeropuertos (viajero o trabajador del aeropuerto) pueda entender sin tecnicismos. Por ejemplo: 


// 5.	Modificación de la estructura del grafo [14 puntos]
// Centralidad
// Proyectar el grafo en memoria para GDS
CALL gds.graph.project(
  'airports-network',
  'Airport',
  {CONNECTS:
        {
        orientation: 'UNDIRECTED'
        }
    } 
);

// 5.1.	Añade un atributo Degree con su valor correspondiente a cada nodo Airport
CALL gds.degree.write('airports-network', {
  writeProperty: 'Degree'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.2.	Añade un atributo In_Degree con su valor correspondiente a cada nodo Airport
CALL gds.degree.write('airports-network', {
  orientation: 'REVERSE',
  writeProperty: 'InDegree'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.3.	Añade un atributo Out_Degree con su valor correspondiente a cada nodo Airport
CALL gds.degree.write('airports-network', {
  orientation: 'NATURAL',
  writeProperty: 'OutDegree'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.4.	Añade un atributo PageRank con su valor correspondiente a cada nodo Airport
CALL gds.pageRank.write('airports-network', {
  maxIterations: 20,
  dampingFactor: 0.85,
  writeProperty: 'PageRank'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.5.	Añade un atributo Betweenness Centrality con su valor correspondiente a cada nodo
CALL gds.betweenness.write('airports-network', {
  writeProperty: 'Betweenness'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.6.	Añade un atributo Closeness Centrality con su valor correspondiente a cada nodo Airport
CALL gds.closeness.write('airports-network', {
  writeProperty: 'Closeness'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.7.	Añade un atributo Articulation Points su valor correspondiente a cada nodo Airport
CALL gds.articulationPoints.write('airports-network', {
  writeProperty: 'ArticulationPoints'
})
YIELD nodePropertiesWritten;


// 6.	Análisis estructural

// 6.1.	Crea uno o varios tableros que contengan la información necesaria para responder a cada una de las preguntas que redactaste en el inciso 4. Se espera la captura de pantalla de los tableros como evidencia. [14 puntos]
// 1
MATCH (a:Airport)
RETURN a.label AS Aeropuerto, 
       a.country AS Pais,
       a.Degree AS Numero_Conexiones,
       a.OutDegree AS Vuelos_Salida,
       a.InDegree AS Vuelos_Llegada
ORDER BY a.Degree DESC
LIMIT 10;

// 2
MATCH (a:Airport)
WHERE a.Betweenness IS NOT NULL
RETURN a.label AS Aeropuerto,
       a.country AS Pais,
       a.Betweenness AS Valor_Puente,
       a.Degree AS Conexiones_Directas
ORDER BY a.Betweenness DESC
LIMIT 10;

// 3
MATCH (a:Airport)
WHERE a.Closeness IS NOT NULL
RETURN a.label AS Aeropuerto,
       a.country AS Pais,
       a.Closeness AS Proximidad_Global,
       a.Degree AS Conexiones_Directas
ORDER BY a.Closeness DESC
LIMIT 10;

// 4
MATCH (a:Airport)
WHERE a.PageRank IS NOT NULL
RETURN a.label AS Aeropuerto,
       a.country AS Pais,
       a.PageRank AS Influencia_Global,
       a.Degree AS Conexiones_Directas
ORDER BY a.PageRank DESC
LIMIT 10;

// 5
MATCH (mexico:Airport {country: 'Mexico'})
MATCH (china:Airport {country: 'China'})
MATCH path = shortestPath((mexico)-[:CONNECTS*]-(china))
RETURN path
ORDER BY length(path) ASC
LIMIT 1;

// 6
MATCH (a:Airport)
OPTIONAL MATCH (a)-[r:CONNECTS]-()
WITH a, COUNT(r) AS num_conexiones
RETURN a.label AS Aeropuerto, 
       a.country AS Pais,
       num_conexiones AS Conexiones_Totales
ORDER BY num_conexiones ASC
LIMIT 10;

// 7
MATCH (a:Airport)
OPTIONAL MATCH (a)-[r:CONNECTS]-()
WITH a, COUNT(r) AS num_conexiones
ORDER BY num_conexiones DESC
LIMIT 1

MATCH (a)-[conexiones:CONNECTS]-(vecinos:Airport)
RETURN a AS Aeropuerto_Central,
       vecinos AS Aeropuertos_Vecinos,
       conexiones AS Rutas_Directas;