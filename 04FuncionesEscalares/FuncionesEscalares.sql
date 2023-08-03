CREATE FUNCTION <Nombre>
(
	<Parametros obligatorios>
)
RETURNS <TIPO DE DATO DE RETORNO>
AS
BEGIN
	<INSTRUCCIONES>
	--RESTRICCIONES, NO SE PUEDE EJECUTAR SPS
	--NO SE PUEDEN CREAR TABLAS TEMPORALES LOCALES NI GLOBALES
	--NO SE PUEDE UTILIZAR INSERT, UPDATE, DELETE
	RETURN <VARIABLE RETORNO>
END
GO

-- 1.Implementar la funcion para sumar 2 valores

ALTER FUNCTION uFN_SumaValores
(
	@Valor1 SMALLINT,
	@Valor2 SMALLINT
)
RETURNS INT
AS
BEGIN
	DECLARE @ValorTotal INT

	SET @ValorTotal = @Valor1 + @Valor2 

	RETURN @ValorTotal
END
GO

SELECT DBO.uFN_SumaValores(3, 6)

SELECT, WHERE, FROM

----
DECLARE @X INT = DBO.uFN_SumaValores(3, 6)
SELECT @X * 100
----
DECLARE @V1 SMALLINT = 6, @V2 SMALLINT = 12
DECLARE @X INT = DBO.uFN_SumaValores(@V1, @V2)
SELECT @X * 100
----

--2. Implementar SP que reciba 2 fechas, y muestre el resumen de ventas por producto, primero debe mostrar consulta de los productos 
-- vendidos en ese rango de fechas, luego mostrar la misma lista con el detalle de ventas, utilizar funciones

DECLARE 
	@OrderDateIni DATE = '20110101', 
	@OrderDateFin DATE = '20111231'

SELECT DISTINCT D.ProductID, P.Name 
FROM Sales.SalesOrderHeader H
	INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
	INNER JOIN Sales.SpecialOfferProduct O ON D.SpecialOfferID = O.SpecialOfferID AND D.ProductID = O.ProductID
	INNER JOIN Production.Product P ON P.ProductID = O.ProductID  
WHERE H.OrderDate BETWEEN @OrderDateIni AND @OrderDateFin 


CREATE FUNCTION uFN_TotalQtyRangoFechaProducto
(
	@ProductID INT,
	@OrderDateIni DATE,
	@OrderDateFin DATE
)
RETURNS INT
AS
BEGIN
	DECLARE @OrderQty INT

	SELECT @OrderQty = SUM(D.OrderQty)
	FROM Sales.SalesOrderHeader H
		INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
	WHERE D.ProductID = @ProductID
		AND H.OrderDate BETWEEN @OrderDateIni AND @OrderDateFin 

	RETURN @OrderQty
END
GO


ALTER PROC uP_ConsultaProductos
	@OrderDateIni DATE, 
	@OrderDateFin DATE
AS
BEGIN
	SELECT DISTINCT D.ProductID, P.Name 
	FROM Sales.SalesOrderHeader H
		INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
		INNER JOIN Sales.SpecialOfferProduct O ON D.SpecialOfferID = O.SpecialOfferID AND D.ProductID = O.ProductID
		INNER JOIN Production.Product P ON P.ProductID = O.ProductID  
	WHERE H.OrderDate BETWEEN @OrderDateIni AND @OrderDateFin 

	SELECT DISTINCT D.ProductID, P.Name, dbo.uFN_TotalQtyRangoFechaProducto(D.ProductID, @OrderDateIni, @OrderDateFin)  
	FROM Sales.SalesOrderHeader H
		INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
		INNER JOIN Sales.SpecialOfferProduct O ON D.SpecialOfferID = O.SpecialOfferID AND D.ProductID = O.ProductID
		INNER JOIN Production.Product P ON P.ProductID = O.ProductID  
	WHERE H.OrderDate BETWEEN @OrderDateIni AND @OrderDateFin 
END

EXEC uP_ConsultaProductos '20110101', '20110731'

CREATE PROC uP_ConsultaProductos_V2
	@OrderDateIni DATE, 
	@OrderDateFin DATE
AS
BEGIN
	SELECT DISTINCT D.ProductID, P.Name 
	INTO #TEMP
	FROM Sales.SalesOrderHeader H
		INNER JOIN Sales.SalesOrderDetail D ON H.SalesOrderID = D.SalesOrderID
		INNER JOIN Sales.SpecialOfferProduct O ON D.SpecialOfferID = O.SpecialOfferID AND D.ProductID = O.ProductID
		INNER JOIN Production.Product P ON P.ProductID = O.ProductID  
	WHERE H.OrderDate BETWEEN @OrderDateIni AND @OrderDateFin 

	SELECT ProductID, Name FROM #TEMP

	SELECT ProductID, Name, dbo.uFN_TotalQtyRangoFechaProducto(ProductID, @OrderDateIni, @OrderDateFin)  
	FROM #TEMP
END

EXEC uP_ConsultaProductos_V2 '20110101', '20110731'

