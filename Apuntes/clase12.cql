// 1. Crear el subgrafo no dirigido
CALL gds.graph.project(
    'MyUndirectedGraph',
    'Villian',
    {COMPANION:
        {
            Orientation: 'UNDIRECTED',
            Properties: 'Weight'
        }
    }
);

// 4. Incluir el atributo articulationPoint
CALL gds.articulationPoints.write(
    'MyUndirectedGraph',
    {writeProperty: 'ArticulationPoint'}
)
YIELD articulationPointCount

// Consulta por villano
MATCH (v:Villian)
RETURN v.Name, v.articulationPoint
ORDER BY v.articulationPoint DESC;