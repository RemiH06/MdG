MATCH(v:Villian)
RETURN v.Name;

call db.schema.visualization;

// Undirected
CALL gds.graph.project(
    'mUG2',
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
    'mDG3',
    'Villian',
    {COMPANION:
        {
            orientation: 'NATURAL',
            properties: 'Weight'
        }
    }
);

// Dirigido. Ultron y Cheetah
MATCH(source:Villian {Name:'Ultron'})
MATCH(target:Villian {Name:'Cheetah'})
CALL gds.shortestPath.dijkstra.write('mDG2',
{
    sourceNode: source,
    targetNodes: target,
    relationshipWeightProperty: 'Weight',
    writeRelationshipType: 'shortestPath_dijkstra_d_Ultron_Cheetah',
    writeNodeIds: true,
    writeCosts: true
}
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Muestra la nueva relación
MATCH(n)-[r:shortestPath_dijkstra_d_Ultron_Cheetah]->(m)
RETURN n,r,m;

// Consulta que muestre los nombres y los ids del camino Ultron a Cheetah
UNWIND[41,45,46,24,38] as vid
MATCH(v:Villian)
WHERE id(v) = vid
RETURN v.Name(v), id(v);

// Muestra los datos de la nueva relación
MATCH(n)-[r:shortestPath_dijkstra_d_Ultron_Cheetah]->(m)
RETURN n.Name, r.nodeIds, r.costs, r.totalCost, m.Name
ORDER BY r.totalCost DESC;

// paso 1
MATCH(source:Villian{Name:'Ultron'})-[r:shortestPath_dijkstra_d_Ultron_Cheetah]->(ov:Villian{Name:'Cheetah'})
RETURN r.nodeIds;

// paso 2
WITH [id IN [41,45,46,24,38] | gds.util.asNode(id)] AS Nodes
RETURN Nodes.Name;

// paso 3
UNWIND range(0, 5-2) as i
RETURN i;

// paso 4
MATCH(source:Villian{Name:'Ultron'})-[r:shortestPath_dijkstra_d_Ultron_Cheetah]->(ov:Villian{Name:'Cheetah'})
WHERE r.nodeIds IS NOT NULL AND size(r.nodeIds)>=2
WITH [id IN r.nodeIds | gds.util.asNode(id)] AS Nodes
UNWIND range(0, size(Nodes)-2) as i
WITH Nodes, Nodes[i] AS n1, Nodes[i+1] AS n2
MATCH (n1)-[rel:COMPANION]->(n2)
RETURN n1, rel, n2;

//? EL EJEMPLO

// Directed
CALL gds.graph.project(
    'mUG3',
    'Villian',
    {COMPANION:
        {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

// Dirigido. Flash Rebirth y Deathstroke
MATCH(source:Villian {Name:'Flash Rebirth'})
MATCH(target:Villian {Name:'Deathstroke'})
CALL gds.shortestPath.dijkstra.write('mUG3',
{
    sourceNode: source,
    targetNodes: target,
    relationshipWeightProperty: 'Weight',
    writeRelationshipType: 'dijkstra_d',
    writeNodeIds: true,
    writeCosts: true
}
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Muestra la nueva relación
MATCH(n)-[r:dijkstra_d]->(m)
RETURN n,r,m;

MATCH(source:Villian{Name:'Flash Rebirth'})-[r:dijkstra_d]->(ov:Villian{Name:'Deathstroke'})
WHERE r.nodeIds IS NOT NULL AND size(r.nodeIds)>=2
WITH [id IN r.nodeIds | gds.util.asNode(id)] AS Nodes
UNWIND range(0, size(Nodes)-2) as i
WITH Nodes, Nodes[i] AS n1, Nodes[i+1] AS n2
MATCH (n1)-[rel:COMPANION]->(n2)
RETURN n1, rel, n2;