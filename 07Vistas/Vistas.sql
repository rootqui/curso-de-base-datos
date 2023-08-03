CREATE VIEW <nombre>
AS
<INSTRUCIONES DE CONSULTA>
GO

SELECT *
FROM SALES.SalesOrderHeader H
	INNER JOIN SALES.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
	INNER JOIN SALES.SpecialOfferProduct O ON D.ProductID = O.ProductID AND O.SpecialOfferID = D.SpecialOfferID 
	INNER JOIN Production.Product P ON P.ProductID = O.ProductID 
	INNER JOIN SALES.Customer C ON C.CustomerID = H.CustomerID 
	LEFT JOIN Person.Person PE ON PE.BusinessEntityID = C.CustomerID 


-- 1. Implementar una vista que retorne el id_producto, nombre_producto, nombre categoria, nombre_subcategoria

CREATE OR ALTER VIEW uV_Producto
AS
SELECT P.ProductID, P.Name AS Name_Product, C.Name AS Name_Category, S.Name AS Name_SubCategory,
	CASE P.MakeFlag WHEN 1 THEN 'Fabricación Interna' ELSE 'Fabricación Externa' END AS [Fabricación], P.Color
FROM Production.Product P -- 504
	LEFT JOIN Production.ProductSubcategory S ON P.ProductSubcategoryID = S.ProductSubcategoryID -- INNER JOIN 295
	LEFT JOIN Production.ProductCategory C ON S.ProductCategoryID = C.ProductCategoryID
	LEFT JOIN Production.ProductModel M ON M.ProductModelID = P.ProductModelID
GO	

SELECT * FROM uV_Producto

CREATE OR ALTER PROC uP_Consulta1_Producto
	@Name varchar(100)
AS
BEGIN
	--SELECT P.ProductID, P.Name AS Name_Product, CASE P.MakeFlag WHEN 1 THEN 'Fabricación Interna' ELSE 'Fabricación Externa' END AS [Fabricación]
	--FROM Production.Product P -- 504
	--	LEFT JOIN Production.ProductSubcategory S ON P.ProductSubcategoryID = S.ProductSubcategoryID -- INNER JOIN 295
	--	LEFT JOIN Production.ProductCategory C ON S.ProductCategoryID = C.ProductCategoryID
	--	--LEFT JOIN Production.ProductModel M ON 
	SELECT P.ProductID, P.Name_Product, P.[Fabricación]
	FROM uV_Producto P
	where P.Name_Product like '%' + @Name + '%'
END
go

CREATE OR ALTER PROC uP_Consulta2_Producto
	@Name varchar(100)
AS
BEGIN
	--SELECT C.Name AS Name_Category, P.ProductID, P.Name AS Name_Product, CASE P.MakeFlag WHEN 1 THEN 'Fabricación Interna' ELSE 'Fabricación Externa' END AS [Fabricación]
	--FROM Production.Product P -- 504
	--	LEFT JOIN Production.ProductSubcategory S ON P.ProductSubcategoryID = S.ProductSubcategoryID -- INNER JOIN 295
	--	LEFT JOIN Production.ProductCategory C ON S.ProductCategoryID = C.ProductCategoryID
	SELECT P.Name_Category, P.ProductID, P.Name_Product, P.[Fabricación]
	FROM uV_Producto P
	where p.Name_Product  like '%' + @Name + '%'
END
GO

CREATE OR ALTER PROC uP_Consulta3_Producto
	@Name varchar(100)
AS
BEGIN
	SELECT C.Name AS Name_Category, S.Name AS Name_SubCategory, P.ProductID, P.Name AS Name_Product, CASE P.MakeFlag WHEN 1 THEN 'Fabricación Interna' ELSE 'Fabricación Externa' END AS [Fabricación]
	FROM Production.Product P -- 504
		LEFT JOIN Production.ProductSubcategory S ON P.ProductSubcategoryID = S.ProductSubcategoryID -- INNER JOIN 295
		LEFT JOIN Production.ProductCategory C ON S.ProductCategoryID = C.ProductCategoryID
	where p.name like '%' + @Name + '%'
END
GO

exec uP_Consulta1_Producto 'x'
exec uP_Consulta2_Producto 'x'
exec uP_Consulta3_Producto 'x'


select P.ProductID, P.Name_Product, P.Name_Category, P.Name_SubCategory, SUM(D.OrderQty) AS TotalOrderQty
from sales.SalesOrderHeader h
	inner join sales.SalesOrderDetail d on h.SalesOrderID = d.SalesOrderID 
	inner join sales.SpecialOfferProduct o on o.SpecialOfferID = d.SpecialOfferID and o.ProductID = d.ProductID
	inner join uV_Producto P ON P.ProductID = O.ProductID 
group by P.ProductID, P.Name_Product, P.Name_Category, P.Name_SubCategory

CREATE VIEW	uV_Customer
AS
SELECT C.CustomerID, P.FirstName + ' ' + COALESCE(P.MiddleName, '') + P.LastName AS FullName  
FROM SALES.Customer C
	LEFT JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
GO

SELECT * FROM uV_Customer

