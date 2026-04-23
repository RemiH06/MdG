// Undirected
CALL gds.graph.project(
    'mUG',
    'Villian',
    {COMPANION:
        {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

// Directed
CALL gds.graph.project(
    'mDG',
    'Villian',
    {COMPANION:
        {
            orientation: 'NATURAL',
            properties: 'Weight'
        }
    }
);

// Lista los subgrafos creados
CALL gds.graph.list()
YIELD grahpName, nodeCount, relationshipCount, database, creationTime;

// Lex Luthor Undirected
MATCH (source:Villian{Name:'Lex Luthor'})
CALL gds.allShortestPaths.delta.write('myUndirectedGraph',
{
    sourceNode: source,
    relationshipWeightProperty: 'Weight',
    writeRelationshipType:'PATH_Lex_Luthor_Undirected',
    writeNodeIds: true,
    writeCosts: true
})
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Lex Luthor Directed
MATCH (source:Villian{Name:'Lex Luthor'})
CALL gds.allShortestPaths.delta.write('mDG',
{
    sourceNode: source,
    relationshipWeightProperty: 'Weight',
    writeRelationshipType:'PATH_Lex_Luthor',
    writeNodeIds: true,
    writeCosts: true
})
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Consulta de Lex Luthor a Grodd
MATCH (v:Villian{Name:'Lex Luthor'})-[r:PATH_Lex_Luthor_Undirected]->(ov:Villian{Name:'Grodd'})
RETURN r,v,ov;

// Todos los nodos recorridos
MATCH(v:Villian)
WHERE id(v) IN [24,38,27,36,35]
RETURN v.Name, id(v);