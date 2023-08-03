--1. Implementar SP para listar las ventas por cliente

CREATE PROC uSP_Analisis_Ventas
AS
BEGIN
	--SELECT 
	--	p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName as CustomerName,
	--	sum(h.SubTotal) as SubTotal
	--FROM Sales.SalesOrderHeader H
	--	inner join Sales.customer C on h.CustomerID = c.CustomerID
	--	inner join Person.person P on c.PersonID = p.BusinessEntityID
	--group by p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName
	--order by p.FirstName + ' ' + coalesce(p.MiddleName, '') + ' ' + p.LastName
	
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
			sum(h.SubTotal) as SubTotal
		FROM Sales.SalesOrderHeader H
			inner join Sales.customer C on h.CustomerID = c.CustomerID
			inner join cte_person P on c.PersonID = p.BusinessEntityID
		where year(h.OrderDate) = @Year
		group by p.CustomerName
		order by p.CustomerName
	
	if @AgrupodoPorProducto = 1 and @AgrupadoPorCliente = 0
		--exec uSP_Analisis_Ventas_Producto
		SELECT p.Name, sum(d.LineTotal) as LineTotal
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
		SELECT p.CustomerName, pr.Name, sum(d.LineTotal) as LineTotal
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
