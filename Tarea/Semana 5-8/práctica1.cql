// Cargar nodos
LOAD CSV WITH HEADERS FROM 'file:///nodes.csv' AS row
CREATE (:Character {id: toInteger(row.UniqueID), name: row.MovieChar, scenes: toInteger(row.Scenes)});

// Cargar relaciones
LOAD CSV WITH HEADERS FROM 'file:///links.csv' AS row
MATCH (source:Character {id: toInteger(row.Source)})
MATCH (target:Character {id: toInteger(row.Target)})
CREATE (source)-[:SPEAKS_WITH {value: toInteger(row.Value)}]->(target);

// 4.	Muestra el esquema general del grafo. Además, incluye a la captura de pantalla el número de personajes, el número de relaciones y los atributos que tiene cada uno [6 puntos]
// Esquema visual
CALL db.schema.visualization();

// Número de personajes
MATCH (n:Character) 
RETURN count(n) AS total_personajes;

// Número de relaciones
MATCH ()-[r:SPEAKS_WITH]->() 
RETURN count(r) AS total_relaciones;

// Atributos de los nodos
CALL db.schema.nodeTypeProperties()
YIELD nodeType, propertyName, propertyTypes
RETURN nodeType, propertyName, propertyTypes;

// 5.	Crea una consulta que muestre el grafo de personajes con los que habla mace windu [4 puntos]
MATCH (mace:Character {name: 'mace windu'})-[r:SPEAKS_WITH]-(other:Character)
RETURN mace, r, other;

// 6.	Crea la matriz de adyacencia resultado de la pregunta 5, puedes hacerlo en una hoja de cálculo o mano siempre que sea legible tu letra [4 puntos]
// Obtén los datos para construir la matriz de adyacencia de Luke
MATCH (luke:Character {name: 'luke'})-[r:SPEAKS_WITH]-(other:Character)
WITH collect(DISTINCT other.name) AS personajes
MATCH (a:Character) WHERE a.name IN personajes OR a.name = 'luke'
MATCH (b:Character) WHERE b.name IN personajes OR b.name = 'luke'
OPTIONAL MATCH (a)-[r:SPEAKS_WITH]->(b)
RETURN a.name AS origen, b.name AS destino, 
       CASE WHEN r IS NOT NULL THEN 1 ELSE 0 END AS conexion
ORDER BY origen, destino;

// 7.	Crea una consulta que muestre el grafo de personajes con los que habla luke [4 puntos]
MATCH (luke:Character {name: 'luke'})-[r:SPEAKS_WITH]-(other:Character)
RETURN luke, r, other;

// 8.	Crea la lista de adyacencia resultado de la pregunta 7, puedes hacerlo en una hoja de cálculo o mano siempre que sea legible tu letra [4 puntos]
// Obtén los datos para construir la lista de adyacencia de Darth Vader
MATCH (luke:Character {name: 'luke'})-[r:SPEAKS_WITH]-(other:Character)
RETURN luke.name AS nodo, other.name AS adyacente, 
       CASE WHEN startNode(r) = luke THEN 'saliente' ELSE 'entrante' END AS tipo
ORDER BY tipo, adyacente;

// 9.	Crea una consulta que muestre el nombre de los cuatro personajes que hablan más con otros personajes [4 puntos]
MATCH (c:Character)-[r:SPEAKS_WITH]-()
RETURN c.name AS personaje, count(DISTINCT r) AS total_interacciones
ORDER BY total_interacciones DESC
LIMIT 4;

// 10.	Crea una consulta que muestre el OUT_DEGREE, IN_DEGREE y DEGREE del personaje darth vader [6 puntos]
MATCH (vader:Character {name: 'darth vader'})
OPTIONAL MATCH (vader)-[out:SPEAKS_WITH]->()
OPTIONAL MATCH ()-[in:SPEAKS_WITH]->(vader)
RETURN 
  vader.name AS personaje,
  count(DISTINCT out) AS OUT_DEGREE,
  count(DISTINCT in) AS IN_DEGREE,
  count(DISTINCT out) + count(DISTINCT in) AS DEGREE;

// 11.	Utilizando explore (neo4j Bloom) muestra la ruta más corta entre han y owen [2 puntos]


// 12.	Realiza una consulta que muestre el número y el nombre de los personajes con los que habló qui-gon [4 puntos]
MATCH (quigon:Character {name: 'qui-gon'})-[:SPEAKS_WITH]-(other:Character)
RETURN count(DISTINCT other) AS numero_personajes, 
       collect(DISTINCT other.name) AS nombres_personajes;

// 13.	Realiza una frase de búsqueda en explore que reciba el nombre de un personaje y regrese su grafo con los nodos alcanzables a dos saltos. Prueba con c-3po [6 puntos]


// 14.	Crea un personaje con tu nombre [4 puntos]
CREATE (:Character {id: 999, name: 'Remi', scenes: 0});

// 15.	Crea las relaciones necesarias para que hables con c-3po, qui-gon, yoda, jango fett y bb-8 [4 puntos]
MATCH (yo:Character {name: 'Remi'})
MATCH (c3po:Character {name: 'c-3po'})
MATCH (quigon:Character {name: 'qui-gon'})
MATCH (yoda:Character {name: 'yoda'})
MATCH (jango:Character {name: 'jango fett'})
MATCH (bb8:Character {name: 'bb-8'})
CREATE (yo)-[:SPEAKS_WITH {value: 1}]->(c3po)
CREATE (yo)-[:SPEAKS_WITH {value: 1}]->(quigon)
CREATE (yo)-[:SPEAKS_WITH {value: 1}]->(yoda)
CREATE (yo)-[:SPEAKS_WITH {value: 1}]->(jango)
CREATE (yo)-[:SPEAKS_WITH {value: 1}]->(bb8);

// 16.	Muestra el grafo donde tú hablas con todos los personajes [2 puntos]
MATCH (yo:Character {name: 'Remi'})-[r:SPEAKS_WITH]->(other:Character)
RETURN yo, r, other;

// 17.	Muestra la ruta más corta entre general grievous y tu [4 puntos]
MATCH (grievous:Character {name: 'general grievous'}), (yo:Character {name: 'Remi'})
MATCH path = shortestPath((grievous)-[:SPEAKS_WITH*]-(yo))
RETURN path;

// 18.	Crea un tablero que contenga:


// 18.1.	El esquema general del grafo [1 punto]


// 18.2.	Un parámetro (filter) para seleccionar al personaje que desees, por default debe estar seleccionado bb-8 [2 puntos]


// 18.3.	Una tabla con el OUT_DEGREE, IN_DEGREE y DEGREE del personaje elegido en el parámetro. [1 punto]


// 18.4.	El grafo a dos saltos del personaje elegido en el parámetro. [4 puntos]


// 18.5.	Una tabla con el top 4 de personajes con base en el OUT_DEGREE. La tabla debe tener el nombre del personaje y el valor [4 puntos]


// 18.6.	Una gráfica de barras con el IN_DEGREE de los personajes [4 puntos]


