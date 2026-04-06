//? WCC
// 1. Crear un subgrafo
CALL gds.graph.project(
    'mUG',
    'Villian',
    {COMPANION: {orientation: 'UNDIRECTED', properties: 'Weight'}}
)

// 4. Alterar la estructura del grafo
CALL gds.wcc.write(
    'mUG',
    {writeProperty: 'communityWCC'}
)
YIELD componentCount, componentDistribution

// Villanos por comunidad
MATCH (v:Villian)
RETURN v.communityWCC, COUNT(v.Name), collect(v.Name)
ORDER BY COUNT(v.Name) DESC

// Actualizar las comunidades para eliminar el CERO y ver en bloom
MATCH(v:Villian)
SET v.communityWCC = v.communityWCC+1
RETURN v.communityWCC, COUNT(v.Name), collect(v.Name)
ORDER BY COUNT(v.Name) DESC


//? SCC
// 1. Crear un subgrafo
CALL gds.graph.project(
    'mG',
    'Villian',
    {COMPANION: {properties: 'Weight'}}
)

// 4. Alterar la estructura del grafo
CALL gds.scc.write(
    'mG',
    {writeProperty: 'communitySCC'}
)
YIELD componentCount, componentDistribution

// Villanos por comunidad
MATCH (v:Villian)
RETURN v.communitySCC, COUNT(v.Name), collect(v.Name)
ORDER BY COUNT(v.Name) DESC

// Actualizar las comunidades para eliminar el CERO y ver en bloom
MATCH(v:Villian)
SET v.communitySCC = v.communitySCC+1
RETURN v.communitySCC, COUNT(v.Name), collect(v.Name)
ORDER BY COUNT(v.Name) DESC

//? label propagation
CALL gds.labelPropagation.write('mG', {writeProperty: 'labelPropagation'})
YIELD communityCount, ranIterations, didConverge;

MATCH (v:Villian)
RETURN v.labelPropagation, COUNT(v.Name), COLLECT(v.Name)
ORDER BY COUNT(v.Name) DESC, v.labelPropagation


//? Añadimos una restricción iniciando con la semilla de Joker
MATCH (v:Villian)
WHERE v.Name = 'Joker'
SET v.comunidadInicial = v.labelPropagation

// Subgrafo con la nueva semilla
CALL gds.graph.project(
    'mAG',
    'Villian',
    {COMPANION: {orientation: 'UNDIRECTED'}},
    {nodeProperties: ['comunidadInicial']}
)

// Añadir el atributo con la semilla Joker
CALL gds.labelPropagation.write('mAG',{
    seedProperty: 'comunidadInicial',
    writeProperty: 'labelPropagationSeed'
})
YIELD communityCount, ranIterations, didConverge