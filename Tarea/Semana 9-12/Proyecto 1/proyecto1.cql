// Importar
LOAD CSV WITH HEADERS FROM 'file:///nodes_fusionados.csv' AS row
CREATE (:Personaje {id: row.Id, label: row.Label});

LOAD CSV WITH HEADERS FROM 'file:///edges_fusionados.csv' AS row
MATCH (source:Personaje {id: row.Source})
MATCH (target:Personaje {id: row.Target})
CREATE (source)-[:HABLA {weight: row.Weight, season: toInteger(row.Season)}]->(target);