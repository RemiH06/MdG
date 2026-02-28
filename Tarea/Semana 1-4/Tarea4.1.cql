// Preguntas a responder 
// 
// 1. ¿Qué pasatiempo es el que practican más personas?
MATCH (p:Persona)-[t:TIENE]->(h:Pasatiempo)
RETURN h.NombrePasatiempo AS Pasatiempo, count(p) AS NumeroPersonas
ORDER BY NumeroPersonas DESC
LIMIT 1;

// 2. Muestra el nombre de dos personas comparten un mismo pasatiempo
MATCH (p1:Persona)-[:TIENE]->(h:Pasatiempo)<-[:TIENE]-(p2:Persona)
WHERE elementId(p1) < elementId(p2)
RETURN h.NombrePasatiempo AS Pasatiempo, 
       p1.Nombre AS Persona1, 
       p2.Nombre AS Persona2
LIMIT 2;

// 3. Muestra el nombre de las personas que tocan guitarra. Ordénalos de forma descendente según su experiencia.  
MATCH(pa:Pasatiempo{NombrePasatiempo:'Tocar guitarra'})-[r:TIENE]-(pe:Persona)
RETURN pe.Nombre, pa.NombrePasatiempo, r.Experiencia
ORDER BY r.Experiencia DESC LIMIT 2;

// 4. ¿Cuántos y cuales son los amigos de Hugo Castillo?
MATCH(p:Persona{Nombre: 'Hugo Castillo'})-[r:AMIGO]-(pe:Persona)
RETURN pe.Nombre;

// 5. ¿Qué personas practican Ciclismo de Montaña?
MATCH(pa:Pasatiempo{NombrePasatiempo:'Ciclismo de monta�a'})-[r]-(pe:Persona)
RETURN pe.Nombre, pa.NombrePasatiempo;

// 6. ¿Quiénes son amigos de Daniela Rubio?
MATCH(p:Persona{Nombre: 'Daniela Rubio'})-[r:AMIGO]-(pe:Persona)
RETURN pe.Nombre;

// 7. ¿Existe una relación de amistad entre Alessia Lombardi y Mario Ruiz?
MATCH (p1:Persona {Nombre: 'Alessia Lombardi'})
MATCH (p2:Persona {Nombre: 'Mario Ruiz'})
RETURN EXISTS( (p1)-[:AMIGO_DE]-(p2) ) AS SonAmigos;

// 8. ¿Qué pasatiempos tiene más personas asociadas?
MATCH (p:Persona)-[:TIENE]->(h:Pasatiempo)
RETURN h.NombrePasatiempo AS Pasatiempo, count(p) AS NumeroPersonas
ORDER BY NumeroPersonas DESC;

// 9. ¿Qué personas tienen mayor experiencia en un pasatiempo concreto de tu elección?
MATCH (p:Persona)-[t:TIENE]->(h:Pasatiempo {NombrePasatiempo: 'Fotograf�a'})
RETURN p.Nombre AS Persona, t.Experiencia AS Experiencia
ORDER BY t.Experiencia DESC;

// 10. ¿Quiénes son amigos que además comparten pasatiempos?
MATCH (p1:Persona)-[:AMIGO]-(p2:Persona)
MATCH (p1)-[:TIENE]->(h:Pasatiempo)<-[:TIENE]-(p2)
WHERE id(p1) < id(p2)
RETURN p1.Nombre AS Persona1, p2.Nombre AS Persona2, collect(h.NombrePasatiempo) AS PasatiemposCompartidos;


// 11. ¿Qué personas tienen múltiples pasatiempos?
MATCH (p:Persona)-[:TIENE]->(h:Pasatiempo)
WITH p, count(h) AS NumPasatiempos
WHERE NumPasatiempos > 1
RETURN p.Nombre AS Persona, 
       p.IdPersona AS ID,
       NumPasatiempos
ORDER BY NumPasatiempos DESC;

// 12. ¿Cuál es el elementId de Patricia Medina?
MATCH (p:Persona {Nombre: 'Patricia Medina'})
RETURN elementId(p) AS ElementIdDePatricia;

// 13. ¿Qué pasatiempos son comunes en una red de amigos?
MATCH (p1:Persona)-[:AMIGO]-(p2:Persona)
MATCH (p1)-[:TIENE]->(h:Pasatiempo)<-[:TIENE]-(p2)
RETURN DISTINCT h.NombrePasatiempo AS PasatiempoComunEnRedes;

// 14. ¿Cuál es uno de los caminos más cortos entre Alejandro Cruz y Carmen Rivera?
MATCH (p1:Persona {Nombre: 'Alejandro Cruz'})
MATCH (p2:Persona {Nombre: 'Carmen Rivera'})
MATCH path = shortestPath( (p1)-[:AMIGO*]-(p2) )
RETURN [n in nodes(path) | n.Nombre] AS Camino;

// 15. ¿Cuáles son las tres personas que tienen más amigos?
MATCH (p:Persona)-[:AMIGO]-(amigo:Persona)
RETURN p.Nombre AS Persona, count(amigo) AS NumeroAmigos
ORDER BY NumeroAmigos DESC
LIMIT 3;

// 16. ¿Qué personas tienen experiencia menor o igual a 1 en sus pasatiempos?
MATCH (p:Persona)-[t:TIENE]->(h:Pasatiempo)
WHERE t.Experiencia <= 1
RETURN p.Nombre AS Persona, h.NombrePasatiempo AS Pasatiempo, t.Experiencia AS Experiencia
ORDER BY p.Nombre;

// 17. ¿Qué pasatiempos solo los practica una sola persona?
MATCH (p:Persona)-[:TIENE]->(h:Pasatiempo)
WITH h, count(p) AS numPersonas
WHERE numPersonas = 1
RETURN h.NombrePasatiempo AS PasatiempoUnico;

// 18. ¿Qué personas son amigas y además tienen el mismo pasatiempo pero diferente experiencia?
MATCH (p1:Persona)-[:AMIGO]-(p2:Persona)
MATCH (p1)-[t1:TIENE]->(h:Pasatiempo)<-[t2:TIENE]-(p2)
WHERE t1.Experiencia <> t2.Experiencia
  AND elementId(p1) < elementId(p2)
RETURN p1.Nombre AS Persona1, 
       p2.Nombre AS Persona2, 
       h.NombrePasatiempo AS Pasatiempo, 
       t1.Experiencia AS ExperienciaPersona1, 
       t2.Experiencia AS ExperienciaPersona2;

// 19. ¿Qué personas no tienen amigos registrados?
MATCH (p:Persona)
WHERE NOT EXISTS( (p)-[:AMIGO_DE]-() )
RETURN p.Nombre AS PersonaSola;

// 20. ¿Qué personas podrían recomendar un pasatiempo a un amigo según su experiencia?
MATCH (experto:Persona)-[t:TIENE]->(h:Pasatiempo)
WHERE t.Experiencia > 5
MATCH (experto)-[:AMIGO]-(amigo:Persona)
WHERE NOT EXISTS( (amigo)-[:TIENE]->(h) )
RETURN experto.Nombre AS Experto, amigo.Nombre AS Amigo, h.NombrePasatiempo AS PasatiempoRecomendado;