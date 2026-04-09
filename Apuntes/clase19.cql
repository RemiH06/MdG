// Recomienda buscando en todas las órdenes los demás productos
MATCH (p:Product)<-[r:ORDERS]-(o:Order)-[r2:ORDERS]->(op:Product)
WHERE p.productName = 'Chai'
RETURN p.productName, COUNT(o.orderID) as cuantocuantocuanto, op.productName, COLLECT(o.orderID) as lista
ORDER BY cuantocuantocuanto DESC;

// Recomienda buscando en todas las órdenes los demás productos de la misma categoría
MATCH (c1:Category)<-[]-(p1:Product)<-[r:ORDERS]-(o:Order)-[r2:ORDERS]->(p2:Product)-[]->(c2:Category)
WHERE p1.productName = 'Chai' AND c1.categoryID = c2.categoryID
RETURN p1.productName, COUNT(o.orderID) as cuantocuantocuanto, p2.productName, c1.categoryName, COLLECT(o.orderID) as lista
ORDER BY cuantocuantocuanto DESC;

// Recomienda buscando en todas las órdenes los demás productos del mismo proveedor
MATCH (s1:Supplier)-[]->(p1:Product)<-[r:ORDERS]-(o:Order)-[r2:ORDERS]->(p2:Product)<-[]-(s2:Supplier)
WHERE p1.productName = 'Chai' AND s1.supplierID = s2.supplierID
RETURN p1.productName, COUNT(o.orderID) as cuantocuantocuanto, p2.productName, s1.companyName, COLLECT(o.orderID) as lista
ORDER BY cuantocuantocuanto DESC;

// Recomienda buscando en todas las órdenes los demás productos de un solo cliente
MATCH (p1:Product)<--(o:Order)-->(p2:Product)
MATCH (o:Order)<--(c:Customer)
WHERE p1.productName = 'Chang' AND c.companyName = "Save-a-lot Markets"
RETURN p1.productName, COUNT(o.orderID) as cuantocuantocuanto, p2.productName, COLLECT(o.orderID) as lista
ORDER BY cuantocuantocuanto DESC;