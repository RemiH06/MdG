// Preguntas a responder 

// 1. ¿Qué pasatiempo es el que practican más personas?
MATCH (p:Pasatiempo)-[r]-()
RETURN p.NombrePasatiempo,
       COUNT(CASE WHEN startNode(r) = p THEN r END) AS OutDegree,
       COUNT(CASE WHEN endNode(r) = p THEN r END) AS InDegree,
       COUNT(r) AS Degree
ORDER BY Degree DESC LIMIT 1;

// 2. Muestra el nombre de dos personas comparten un mismo pasatiempo
MATCH(pa:Pasatiempo{NombrePasatiempo:'Senderismo'})-[r]-(pe:Persona)
RETURN pe.Nombre, pa.NombrePasatiempo
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

// 8. ¿Qué pasatiempos tiene más personas asociadas?
MATCH (p:Pasatiempo)-[r]-()
RETURN p.NombrePasatiempo,
       COUNT(CASE WHEN startNode(r) = p THEN r END) AS OutDegree,
       COUNT(CASE WHEN endNode(r) = p THEN r END) AS InDegree,
       COUNT(r) AS Degree

// 9. ¿Qué personas tienen mayor experiencia en un pasatiempo concreto de tu elección?

// 10. ¿Quiénes son amigos que además comparten pasatiempos?

// 

// 11. ¿Qué personas tienen múltiples pasatiempos?

// 12. ¿Cuál es el elementId de Patricia Medina?

// 13. ¿Qué pasatiempos son comunes en una red de amigos?

// 14. ¿Cuál es uno de los caminos más cortos entre Alejandro Cruz y Carmen Rivera?

// 15. ¿Cuáles son las tres personas que tienen más amigos?

// 16. ¿Qué personas tienen experiencia menor o igual a 1 en sus pasatiempos?

// 17. ¿Qué pasatiempos solo los practica una sola persona?

// 18. ¿Qué personas son amigas y además tienen el mismo pasatiempo pero diferente experiencia?

// 19. ¿Qué personas no tienen amigos registrados?

// 20. ¿Qué personas podrían recomendar un pasatiempo a un amigo según su experiencia?

