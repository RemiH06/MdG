--Category
SELECT 
	CategoryID,
	CategoryName
FROM Northwind.dbo.Categories;

--Supplier
SELECT 
	SupplierID, 
	CompanyName, 
	ContactName,
	ContactTitle,
	Address,
	City,
	Region,
	Country
FROM Northwind.dbo.Suppliers;

--Product
SELECT 
*
FROM Northwind.dbo.Products;

--OrderDetail
SELECT 
*
FROM Northwind.dbo.[Order Details];


--Order
SELECT 
*
FROM Northwind.dbo.Orders;

--Customer
SELECT 
*
FROM Northwind.dbo.Customers;


-- Product PART_OF Category
SELECT
	ProductID,
	CategoryID
FROM Northwind.dbo.Products;

-- Supplier SUPPLIES Product
SELECT
	ProductID,
	SupplierID
FROM Northwind.dbo.Products;

-- Order ORDERS Product
SELECT 
	OrderID,
	ProductID,
	UnitPrice,
	Quantity
FROM Northwind.dbo.[Order Details];

-- Order PURCHASED Customer
SELECT 
	OrderID,
	CustomerID
FROM Northwind.dbo.Orders;


