// Cargar nodos
LOAD CSV WITH HEADERS FROM 'file:///Personas.csv' AS row
CREATE (:Persona {id: toInteger(row.IdPersona), nombre: row.Nombre, colonia: row.Colonia});

// Cargar relaciones
LOAD CSV WITH HEADERS FROM 'file:///Relaciones.csv' AS row
MATCH (source:Persona {id: toInteger(row.IdPersona1)})
MATCH (target:Persona {id: toInteger(row.IdPersona2)})
CREATE (source)-[:AMIGO {peso: toInteger(row.Peso)}]->(target);


// 2.	Describe el grafo
// 2.1.	Una imagen del esquema general. Evidencia una captura de pantalla [3 puntos]
call db.schema.visualization

// 2.2.	¿Cuántos nodos hay? [1 punto]
MATCH (n:Persona)
RETURN COUNT(DISTINCT n);
// 600

// 2.3.	¿Qué atributos tiene cada nodo? [1 punto]
MATCH (n:Persona)
RETURN n.id, n.nombre, n.colonia;
// id, nombre y colonia

// 2.4.	¿Cuántas relaciones hay? [1 punto]
MATCH (n:Persona)-[a:AMIGO]->()
RETURN COUNT(DISTINCT a);
// 600

// 2.5.	¿Qué atributos tiene cada relación? [1 punto]
MATCH (n:Persona)-[a:AMIGO]->(p)
RETURN n.nombre, a.peso, p.nombre;
// peso

// 3.	Preguntas para responder con código cypher
// 3.1.	Muestra el grafo de amigos de la persona con identificador 300. Evidencia captura de pantalla [4 puntos]
MATCH (n:Persona {id: 300})-[r]->(d)
RETURN n,r,d;
// solo tiene un amigo

// 3.2.	Realiza la matriz de adyacencia o la lista de adyacencia del siguiente grafo. [5 puntos] 
// en el docx

// 3.3.	Cuántos y cuáles son los nombres de los amigos alcanzables a dos saltos de la persona con identificador igual a 47. Evidencia captura de pantalla [5 puntos]
MATCH path = (p:Persona {id: 47})-[*0..2]-(a)
RETURN path;
// nombre: "QUIRINO SEDANO RIBAS"

// 3.4.	Crea un nodo con tu nombre y el IdPersona igual a tu número de expediente. Evidencia captura de pantalla [4 puntos]
CREATE (remi:Persona {id: 750662, nombre: 'Remi'})
RETURN remi;

// 3.5.	Realiza lo necesario para que seas amigo de las personas con identificador 17, 38 y 50 y muestra el grafo. Evidencia captura de pantalla [5 puntos]
MATCH (remi:Persona {id: 750662})
MATCH (p1:Persona {id: 17})
MATCH (p2:Persona {id: 38})
MATCH (p3:Persona {id: 50})

CREATE (remi)-[:AMIGO]->(p1)
CREATE (remi)-[:AMIGO]->(p2)
CREATE (remi)-[:AMIGO]->(p3);

MATCH (remi:Persona {id: 750662})-[a:AMIGO]-(d)
RETURN remi, a, d;

// 4.	Utilizando Explore
// 4.1.	Crea una consulta personalizada para que reciba el identificador de un nodo como parámetro y regrese el grafo de sus vecinos a dos saltos. Prueba tu consulta con el nodo 50. Evidencia una captura de pantalla [7 puntos]
MATCH path = (p:Persona {id: 50})-[*0..2]->(a)
RETURN path;

// 4.2.	Muestra la ruta más corta entre el nodo con identificador 200 y el nodo con identificador 400. Evidencia una captura de pantalla [7 puntos]
MATCH (d:Persona {id: 200}), (c:Persona {id: 400})
MATCH path = shortestPath((d)-[:AMIGO*]-(c))
RETURN path;

// 5.	Con base en lo que sabes de los algoritmos de centralidad, responde las siguientes preguntas
CALL gds.graph.project(
  'amigos',
  'Persona',
  {AMIGO:
        {
        orientation: 'UNDIRECTED'
        }
    } 
);

CALL gds.degree.write('amigos', {
  writeProperty: 'Degree'
})
YIELD centralityDistribution, nodePropertiesWritten;
CALL gds.betweenness.write('amigos', {
  writeProperty: 'Betweenness'
})
YIELD centralityDistribution, nodePropertiesWritten;
CALL gds.articulationPoints.write('amigos', {
  writeProperty: 'ArticulationPoints'
})
YIELD nodePropertiesWritten;
CALL gds.pageRank.write('amigos', {
  maxIterations: 20,
  dampingFactor: 0.85,
  writeProperty: 'PageRank'
})
YIELD centralityDistribution, nodePropertiesWritten;

// 5.1.	¿Cuáles serían los identificadores y nombres de los 4 principales nodos que tienen más conexiones inmediatas? Evidencia captura de pantalla [10 puntos]
// degree
MATCH (p:Persona)-[r:AMIGO]-(d:Persona)
RETURN DISTINCT p.nombre, p.Degree
ORDER by p.Degree DESC
LIMIT 4;

// 5.2.	¿Cuáles serían los identificadores y nombres de los 4 principales nodos que sirven como camino esencial o puente entre grupos de nodos y por qué?  Evidencia captura de pantalla [10 puntos]
// betweeness
MATCH (p:Persona)-[r:AMIGO]-(d:Persona)
RETURN DISTINCT p.nombre, p.Betweenness
ORDER by p.Betweenness DESC
LIMIT 4;

// 5.3.	Muestra el identificador y el nombre de 4 nodos que de eliminarlos incrementaría el número de componentes desconectados en el grafo Evidencia captura de pantalla [10 puntos]
// articulation
MATCH (p:Persona)-[r:AMIGO]-(d:Persona)
RETURN DISTINCT p.nombre, p.ArticulationPoints
ORDER by p.ArticulationPoints DESC
LIMIT 4;
// este creo que lo hice mal porque solamente arrojan 1 o 0

// 5.4.	¿Cuáles serían los identificadores y nombres de los 4 principales nodos que propondrías para distribuir un mensaje y por qué?  Evidencia captura de pantalla [10 puntos]
// pagerank
MATCH (p:Persona)-[r:AMIGO]-(d:Persona)
RETURN DISTINCT p.nombre, p.PageRank
ORDER by p.PageRank DESC
LIMIT 4;