// Relaciones
// -- -[]- --> <-- -[]-> <-[]-

// Propiedades
// {}

// Crea un
CREATE (n:Persona{nombre:'Remi'});

// SET
MATCH (n:Persona{nombre:'Remi'})
SET n.apellido = 'Heredia';

// REMOVE
MATCH (n:Persona{nombre:'Remi'})
REMOVE n.apellido;

// SQL      Similar     Orden Cypher
// SELECT   RETURN      MATCH
// FROM     MATCH       WHERE
// WHERE    WHERE       RETURN

// Crear compu
CREATE (c:Compu{nombre:'Gabinete1'});

MATCH (c:Compu{nombre:'Gabinete1'})
CREATE (t:Compu{nombre:'Teclado1'})-[r:SE_CONECTA]->(c);
MATCH (c:Compu{nombre:'Gabinete1'})
CREATE (m:Compu{nombre:'Mouse1'})-[r:SE_CONECTA]->(c);
MATCH (c:Compu{nombre:'Gabinete1'})
CREATE (p:Compu{nombre:'Monitor1'})-[r:SE_CONECTA]->(c);


// Conocidos
MATCH (n:Persona{nombre:'Remi'})
RETURN n;

MATCH (n:Persona{nombre:'Remi'})
CREATE (p:Persona{nombre:'Ivo'})<-[r:CONOCE]-(n);
MATCH (n:Persona{nombre:'Remi'})
CREATE (p:Persona{nombre:'Max'})<-[r:CONOCE]-(n);
MATCH (n:Persona{nombre:'Remi'})
CREATE (p:Persona{nombre:'Aissa'})<-[r:CONOCE]-(n);
MATCH (n:Persona{nombre:'Remi'})
CREATE (p:Persona{nombre:'Ivan'})<-[r:CONOCE]-(n);