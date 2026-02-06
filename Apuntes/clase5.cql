// REVIEW DE LA TAREA 2_1

// ambas vías
MATCH(d)-[r]-(m)
RETURN
  COUNT(r);

// una sola vía
MATCH(d)-[r]->(m)
RETURN
  COUNT(r);

// amigos de pedro que practican natación
MATCH(p:Persona {nombre:"Pedro"})-[a:AMIGO_DE]-(amigo:Persona)
MATCH(amigo)-[r:PRACTICA]->(d:Deporte {nombre:"Natación"})
RETURN amigo;

MATCH(p:Persona)
RETURN p.nombre, p.edad;



// MOVIES
