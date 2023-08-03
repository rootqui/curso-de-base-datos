--1. Implementar SP para listar las ventas por cliente

CREATE PROC uSP_Analisis_Ventas
AS
BEGIN
	;with
	cte_person
	as
	(
		select p.BusinessEntityID, p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName
		from Person.person p
	)
	SELECT 
		p.CustomerName,
		sum(h.SubTotal) as SubTotal
	FROM Sales.SalesOrderHeader H
		inner join Sales.customer C on h.CustomerID = c.CustomerID
		inner join cte_person P on c.PersonID = p.BusinessEntityID
	group by p.CustomerName
	order by p.CustomerName

END
go


EXEC uSP_Analisis_Ventas

--2. Implementar SP para listar las ventas por Producto

CREATE PROC uSP_Analisis_Ventas_Producto
AS
BEGIN
	SELECT p.Name, sum(d.LineTotal) as LineTotal
	FROM Sales.SalesOrderDetail D
		inner join Sales.SpecialOfferProduct O on d.SpecialOfferID = o.SpecialOfferID and d.ProductID = o.ProductID
		inner join Production.Product P on p.ProductID = o.ProductID
	group by p.Name
	order by p.Name
END
go


exec uSP_Analisis_Ventas_Producto

--3. Implementar SP para listar las ventas por Cliente y Producto

CREATE PROC uSP_Analisis_Ventas_Cliente_Producto
AS
BEGIN
	;with
	cte_person
	as
	(
		select p.BusinessEntityID, p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName
		from Person.person p
	)
	SELECT p.CustomerName, pr.Name, sum(d.LineTotal) as LineTotal
	FROM Sales.SalesOrderHeader H
		inner join Sales.customer C on h.CustomerID = c.CustomerID
		inner join cte_person P on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail D on h.SalesOrderID = d.SalesOrderID
		inner join Sales.SpecialOfferProduct O on d.SpecialOfferID = o.SpecialOfferID and d.ProductID = o.ProductID
		inner join Production.Product Pr on pr.ProductID = o.ProductID
	group by p.CustomerName, pr.Name
	order by p.CustomerName, pr.Name
END


EXEC uSP_Analisis_Ventas_Cliente_Producto

--4. Implementar SP para listar las ventas por Cliente y/o Producto

ALTER PROC uSP_Analisis_Ventas_Cliente_Producto_Dinamico
	@AgrupadoPorCliente bit,
	@AgrupodoPorProducto bit,
	@Year smallint,
	@Month tinyint
AS
BEGIN
	if @AgrupadoPorCliente = 1 and @AgrupodoPorProducto = 0
		--exec uSP_Analisis_Ventas
		with
		cte_person
		as
		(
			select p.BusinessEntityID, p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName
			from Person.person p
		)
		SELECT 
			p.CustomerName,
			sum(h.SubTotal) as SubTotal, SUM(H.TaxAmt) AS TaxAmt
		FROM Sales.SalesOrderHeader H
			inner join Sales.customer C on h.CustomerID = c.CustomerID
			inner join cte_person P on c.PersonID = p.BusinessEntityID
		where year(h.OrderDate) = @Year
		group by p.CustomerName
		order by p.CustomerName
	
	if @AgrupodoPorProducto = 1 and @AgrupadoPorCliente = 0
		--exec uSP_Analisis_Ventas_Producto
		SELECT p.Name, sum(d.LineTotal) as LineTotal, SUM(H.TaxAmt) AS TaxAmt
		FROM Sales.SalesOrderHeader H
			inner join Sales.SalesOrderDetail D on h.SalesOrderId = d.SalesOrderId
			inner join Sales.SpecialOfferProduct O on d.SpecialOfferID = o.SpecialOfferID and d.ProductID = o.ProductID
			inner join Production.Product P on p.ProductID = o.ProductID
		where year(h.OrderDate) = @Year
		group by p.Name
		order by p.Name
		
	if @AgrupodoPorProducto = 1 and @AgrupadoPorCliente = 1
		--exec uSP_Analisis_Ventas_Cliente_Producto 
		with
		cte_person
		as
		(
			select p.BusinessEntityID, p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName
			from Person.person p
		)
		SELECT p.CustomerName, pr.Name, sum(d.LineTotal) as LineTotal, SUM(H.TaxAmt) AS TaxAmt
		FROM Sales.SalesOrderHeader H
			inner join Sales.customer C on h.CustomerID = c.CustomerID
			inner join cte_person P on c.PersonID = p.BusinessEntityID
			inner join Sales.SalesOrderDetail D on h.SalesOrderID = d.SalesOrderID
			inner join Sales.SpecialOfferProduct O on d.SpecialOfferID = o.SpecialOfferID and d.ProductID = o.ProductID
			inner join Production.Product Pr on pr.ProductID = o.ProductID
		where year(h.OrderDate) = @Year
		group by p.CustomerName, pr.Name
		order by p.CustomerName, pr.Name
END
GO


EXEC uSP_Analisis_Ventas_Cliente_Producto_Dinamico 1, 0, 2011, 0
EXEC uSP_Analisis_Ventas_Cliente_Producto_Dinamico 0, 1, 2011, 0
EXEC uSP_Analisis_Ventas_Cliente_Producto_Dinamico 1, 1, 2011, 0


--5. Implementar Consulta Ventas: Por Cliente / Producto Dinámico

ALTER PROC uSP_Analisis_Ventas_Cliente_Producto_Dinamico_2
	@AgrupadoPorCliente bit,
	@AgrupodoPorProducto bit,
	@Year smallint
AS
BEGIN

	with
	cte_person
	as
	(
		select p.BusinessEntityID, p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName
		from Person.person p
	)
	SELECT p.CustomerName, pr.Name, sum(d.LineTotal) as LineTotal, SUM(H.TaxAmt) AS TaxAmt, SUM(H.Freight) AS Freight
	INTO #TEMP
	FROM Sales.SalesOrderHeader H
		inner join Sales.customer C on h.CustomerID = c.CustomerID
		inner join cte_person P on c.PersonID = p.BusinessEntityID
		inner join Sales.SalesOrderDetail D on h.SalesOrderID = d.SalesOrderID
		inner join Sales.SpecialOfferProduct O on d.SpecialOfferID = o.SpecialOfferID and d.ProductID = o.ProductID
		inner join Production.Product Pr on pr.ProductID = o.ProductID
	where year(h.OrderDate) = @Year
	group by p.CustomerName, pr.Name
	--order by p.CustomerName, pr.Name

	DECLARE @SQL VARCHAR(MAX) =
	'
	SELECT ' + CASE WHEN @AgrupadoPorCliente = 1 THEN 'CustomerName, ' ELSE '' END + ''  + CASE WHEN @AgrupodoPorProducto = 1 THEN 'Name, ' ELSE '' END + ' SUM(LineTotal)  AS LineTotal, SUM(TaxAmt) AS TaxAmt, SUM(Freight) AS Freight
	FROM #TEMP
	GROUP BY ' + CASE WHEN @AgrupadoPorCliente = 1 THEN 'CustomerName ' ELSE '' END + CASE WHEN @AgrupadoPorCliente = 1 AND @AgrupodoPorProducto = 1 THEN ', ' ELSE '' END + CASE WHEN @AgrupodoPorProducto = 1 THEN ' Name ' ELSE '' END

	--PRINT @SQL

	EXEC (@SQL)

END
GO

exec uSP_Analisis_Ventas_Cliente_Producto_Dinamico_2 1, 0, 2011
exec uSP_Analisis_Ventas_Cliente_Producto_Dinamico_2 0, 1, 2011
exec uSP_Analisis_Ventas_Cliente_Producto_Dinamico_2 1, 1, 2011
